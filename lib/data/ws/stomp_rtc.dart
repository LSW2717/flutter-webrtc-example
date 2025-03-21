import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:flutter_webrtc_example/data/ws/stomp_base.dart';
import 'package:flutter_webrtc_example/data/ws/stomp_rtc_media.dart';
import 'package:pretty_json/pretty_json.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:stomp_dart_client/stomp_dart_client.dart';

import '../../common/const/data.dart';

part 'stomp_rtc.g.dart';

typedef StreamCallback = void Function(
    {required String key, MediaStream? stream, bool? destroy});

@riverpod
StompRtc stompRtc(Ref ref) {
  final stompRtcMedia = ref.watch(stompRtcMediaProvider);

  return StompRtc(
    stompRtcMedia: stompRtcMedia,
  );
}

class StompRtc extends StompBase {
  final StompRtcMedia stompRtcMedia;

  StompRtc({
    required this.stompRtcMedia,
  });

  late String roomId;
  late String userId;
  late StreamCallback onStreamCallback;

  String url = BACKEND_SOCKET_URL;

  Map<String, RTCPeerConnection> pcListMap = {};

  MediaStream? localStream;

  final config = {
    'iceServers': [
      {
        "url": "stun:stun.l.google.com:19302",
      },
    ],
    'sdpSemantics': 'unified-plan',
  };

  final sdpConstraints = {
    'mandatory': {
      'OfferToReceiveAudio': true,
      'OfferToReceiveVideo': true,
    },
    'optional': []
  };

  Future<StompBase> join(
      String roomId,
      String userId,
      StreamCallback onStreamCallback,
      ) async {
    this.roomId = roomId;
    this.userId = userId;
    this.onStreamCallback = onStreamCallback;

    final destination = '/topic/peer/keyDestroy/$roomId';
    final payload = {'key': userId};

    final connectUrl = url;

    return super.connect(
        destination: destination,
        payload: payload,
        url: connectUrl,
        onConnect: (frame) {
          print('subscribe keyRequest');
          super.subscribe(
            destination: '/topic/peer.keyRequest.$roomId',
            payloadCallBack: onKeyRequest,
          ).then((ws) {
            print('subscribe keyResponse');
            return ws.subscribe(
              destination: '/topic/peer.keyResponse.$roomId',
              payloadCallBack: onKeyResponse,
            );
          }).then((ws) {
            print('subscribe keyDestroy');
            return ws.subscribe(
              destination: '/topic/peer.keyDestroy.$roomId',
              payloadCallBack: onKeyDestroy,
              headers: {'key': userId},
            );
          }).then((ws) {
            print('subscribe peerOffer');
            return ws.subscribe(
              destination: '/topic/peer.offer.$roomId.$userId',
              payloadCallBack: onPeerOffer,
            );
          }).then((ws) {
            print('subscribe peerAnswer');
            return ws.subscribe(
              destination: '/topic/peer.answer.$roomId.$userId',
              payloadCallBack: onPeerAnswer,
            );
          }).then((ws) {
            print('subscribe iceCandidate');
            return ws.subscribe(
              destination: '/topic/peer.iceCandidate.$roomId.$userId',
              payloadCallBack: onPeerIceCandidate,
            );
          });
        });
  }

  Future<StompBase> leave() async {
    for (var key in pcListMap.keys) {
      var pc = pcListMap[key];
      if (pc != null) {
        pc.onIceCandidate = null;
        pc.onTrack = null;
        pc.onAddStream = null;
        pc.onRemoveStream = null;
        try {
          await pc.close();
          print("Connection closed for key: $key");
        } catch (e) {
          print("Error closing connection for key $key: $e");
        }
      }
    }
    pcListMap.clear();

    localStream?.getTracks().forEach((track) {
      localStream?.removeTrack(track);
      track.stop();
    });
    return super.disconnect();
  }

  Future<MediaStream> streaming(MediaStream userStream) {
    if (!super.isConnected()) {
      return Future.error({});
    }

    return stompRtcMedia
        .updateStream(existsStream: localStream, newStream: userStream)
        .then((stream) {
      if (localStream == null) {
        localStream = stream;
        onStartStreaming();
      } else {
        localStream = stream;
        onUpdateStreaming(stream);
      }
      return Future.value(localStream);
    });
  }

  Future<void> onStartStreaming() async {
    final payload = '"$userId"';
    final destination = '/app/peer.keyRequest.$roomId';

    await super.broadcast(destination: destination, payload: payload);
  }

  void onUpdateStreaming(MediaStream stream) {
    for (final pc in pcListMap.values) {
      pc.getSenders().then((senders) {
        for (final sender in senders) {
          final newTrack = localStream?.getTracks().firstWhere(
                (t) => t.kind == sender.track?.kind,
          );
          try {
            sender.replaceTrack(newTrack);
          } catch (e) {
            print("Error replacing track: $e");
          }
        }
      });
    }
    onStreamCallback(key: userId, stream: stream);
  }

  Future<void> onKeyRequest(StompFrame frame) async {
    print('keyRequest: ${_printFrame(frame)}');
    if (frame.body != null) {
      final body = jsonDecode(frame.body!);

      final key = body['key'];

      if (key == userId) return;

      final payload = '"$userId"';
      final destination = '/app/peer.keyResponse.$roomId';

      await super.broadcast(destination: destination, payload: payload);
    }
  }

  Future<void> onKeyResponse(StompFrame frame) async {
    print('keyResponse: ${_printFrame(frame)}');

    if (frame.body != null) {
      final body = jsonDecode(frame.body!);

      final key = body['key'];

      if (key == userId) return;

      print("GET Other key: ${frame.body}");

      if (!pcListMap.containsKey(key)) {
        fireConnection(key).then((pc) {
          pcListMap[key] = pc;
          pc.createOffer().then((offer) async {
            print("Sending offer At: $key");
            pc.setLocalDescription(offer);
            return offer;
          }).then((offer) async {
            String jsonOffer = jsonEncode(offer.toMap());
            String destination = '/app/peer.offer.$roomId.$key';
            String payload = '{"key":"$userId","body":$jsonOffer}';
            await super.broadcast(destination: destination, payload: payload);
          });
        });
      }
    }
  }

  Future<void> onKeyDestroy(StompFrame frame) async {
    Map<String, dynamic> received = jsonDecode(frame.body!);

    final key = received['key'];

    if (pcListMap[key] == null) return;

    print('onKeyDestroy Key destroy!!! $key');

    pcListMap.remove(key);

    onStreamCallback(key: key, destroy: true);
  }

  Future<void> onPeerOffer(StompFrame frame) async {
    print('offer: ${_printFrame(frame)}');

    if (frame.body != null) {
      try {
        Map<String, dynamic> received = jsonDecode(frame.body!);
        String key = received['key'];
        Map<String, dynamic> offer = received['body'];
        String sdp = offer['sdp'].replaceAll('setup:actpass', 'setup:active');
        String type = offer['type'];

        fireConnection(key).then((pc) async {
          pcListMap[key] = pc;
          pc.setRemoteDescription(RTCSessionDescription(sdp, type));
          print('pc signal!!! onPeerOffer');
          print('key: $key, $pc');
          print(await pc.getSignalingState());

          return pc;
        }).then((pc) {
          pc.onSignalingState = (state) {
            if (state == RTCSignalingState.RTCSignalingStateHaveRemoteOffer) {
              pc.createAnswer().then((answer) async {
                pc.setLocalDescription(answer);
                return answer;
              }).then((answer) async {
                String jsonAnswer = jsonEncode(answer.toMap());
                String payload = '{"key":"$userId","body":$jsonAnswer}';
                String destination = '/app/peer.answer.$roomId.$key';

                await super
                    .broadcast(destination: destination, payload: payload);
              });
            }
          };
        });
      } catch (e) {
        print('/topic/peer/offer : $e');
      }
    }
  }

  Future<void> onPeerAnswer(StompFrame frame) async {
    print('answer: ${_printFrame(frame)}');
    if (frame.body != null) {
      try {
        Map<String, dynamic> received = jsonDecode(frame.body!);
        String key = received['key'];
        Map<String, dynamic> answer = received['body'];
        String sdp = answer['sdp'];
        String type = answer['type'];

        RTCPeerConnection? pc = pcListMap[key];

        if (pc != null) {
          pc.setRemoteDescription(RTCSessionDescription(sdp, type)).then((_) {
            print("Remote Description set successfully");
          }).catchError((error) {
            print("Error setting Remote Description: $error");
          });
        }
      } catch (e) {
        print('/topic/peer/answer : $e');
      }
    }
  }

  Future<void> onPeerIceCandidate(StompFrame frame) async {
    print('iceCandidate: ${_printFrame(frame)}');
    if (frame.body != null) {
      try {
        Map<String, dynamic> received = jsonDecode(frame.body!);
        String key = received['key'];
        Map<String, dynamic> body = received['body'];
        String candidate = body['candidate'];
        String sdpMid = body['sdpMid'];
        int sdpMLineIndex = body['sdpMLineIndex'];

        if (key == userId) return;

        RTCPeerConnection? pc = pcListMap[key];

        if (pc != null) {
          print("onIceCandidate: $key");
          print("onIceCandidate: $candidate , $sdpMid , $sdpMLineIndex");

          RTCIceCandidate candidates = RTCIceCandidate(
            candidate,
            sdpMid,
            sdpMLineIndex,
          );

          pc.addCandidate(candidates).then((_) {
            print("ICE Candidate added successfully");
          }).catchError((error) {
            print("Error adding ICE Candidate: $error");
          });
        }
      } catch (e) {
        print('/topic/peer/iceCandidate : $e');
      }
    }
  }

  Future<RTCPeerConnection> fireConnection(String otherKey) {
    return createPeerConnection(config, sdpConstraints).then((pc) async {
      try {
        pc.onIceCandidate = (ice) async {
          if (ice.candidate != null) {
            String jsonIce = jsonEncode(ice.toMap());
            String payload = '{"key":"$userId","body":$jsonIce}';
            String destination = '/app/peer.iceCandidate.$roomId.$otherKey';
            super.broadcast(destination: destination, payload: payload);
          }
        };

        pc.onIceGatheringState = (state) {
          print("ICE Gathering State: $state");
        };

        pc.onTrack = (event) {
          if (event.streams.isNotEmpty) {
            MediaStream remoteStream = event.streams[0];
            onStreamCallback(key: otherKey, stream: remoteStream);
          }
        };

        pc.onIceConnectionState = (state) {
          print("ICE Connection State: $state");
        };

        pc.onConnectionState = (state) {
          print("Peer Connection State: $state");
        };

        pc.onAddStream = (stream) {
          print("Stream added: $stream");
        };

        localStream?.getTracks().forEach((track) async {
          await pc.addTrack(track, localStream!);
        });
      } catch (e) {
        print('fireConnection failured');
      }

      return pc;
    });
  }

  void printMediaStreamInfo(MediaStream stream) {
    // 비디오 트랙 정보 출력
    List<MediaStreamTrack> videoTracks = stream.getVideoTracks();
    print('비디오 트랙 수: ${videoTracks.length}');
    for (MediaStreamTrack track in videoTracks) {
      print('비디오 트랙 정보:');
      print('ID: ${track.id}');
      print('Label: ${track.label}');
      print('Kind: ${track.kind}');
      print('Enabled: ${track.enabled}');
    }

    // 오디오 트랙 정보 출력
    List<MediaStreamTrack> audioTracks = stream.getAudioTracks();
    print('오디오 트랙 수: ${audioTracks.length}');
    for (MediaStreamTrack track in audioTracks) {
      print('오디오 트랙 정보:');
      print('ID: ${track.id}');
      print('Label: ${track.label}');
      print('Kind: ${track.kind}');
      print('Enabled: ${track.enabled}');
    }
  }

  String _printFrame(StompFrame frame) {
    return "\ncommand >> ${frame.command}\nheaders >> \n${prettyJson(frame.headers)}\nbody >> \n${prettyJson(jsonDecode(frame.body ?? '{}'))}";
  }
}
