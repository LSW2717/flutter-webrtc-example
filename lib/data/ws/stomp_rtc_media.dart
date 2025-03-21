import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'stomp_rtc_media.g.dart';

@Riverpod(keepAlive: true)
StompRtcMedia stompRtcMedia(Ref ref) {
  return StompRtcMedia();
}

class StompRtcMedia {

  Future<MediaStream> userMedia(
      bool camState,
      bool micState,
      bool faceState,
      ) {
    return navigator.mediaDevices.getUserMedia({
      'video': {
        'facingMode': faceState ? 'user' : 'environment',
      },
      'audio': true,
    }).then((stream) {
      stream.getVideoTracks()[0].enabled = camState;
      stream.getAudioTracks()[0].enabled = micState;
      return stream;
    });
  }

  Future<MediaStream> updateStream({
    MediaStream? existsStream,
    MediaStream? newStream,
  }) {
    if (existsStream == null) {
      return Future.value(newStream);
    }
    return Future(() {
      final videoTracks = existsStream.getVideoTracks().toList();

      newStream?.getVideoTracks().forEach((track) {
        videoTracks.forEach((track) {
          existsStream.removeTrack(track);
          track.stop();
        });
        existsStream.addTrack(track);
      });

      final audioTracks = existsStream.getAudioTracks().toList();

      newStream?.getAudioTracks().forEach((track) {
        audioTracks.forEach((track) {
          existsStream.removeTrack(track);
          track.stop();
        });
        existsStream.addTrack(track);
      });

      return existsStream;
    });
  }
}
