import 'package:flutter/cupertino.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:flutter_webrtc_example/presentation/rooms/room/index/component/fake_video.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../common/auth/auth_state_provider.dart';
import '../../../../data/ws/stomp_rtc.dart';
import '../../../../data/ws/stomp_rtc_media.dart';

part 'view_model.g.dart';

@riverpod
class ViewModel extends _$ViewModel {
  @protected
  late AuthState? auth;

  @protected
  late StompRtcMedia media;

  @protected
  late StompRtc stompClient;

  String? get userId => auth?.userId;

  Map<String, RTCVideoRenderer> videoListMap = {};

  String? token;


  @override
  State build(String channelId) {
    auth = ref.watch(authProvider);
    stompClient = ref.watch(stompRtcProvider);
    media = ref.watch(stompRtcMediaProvider);
    init();
    ref.onDispose(() async {
      await disConnect();
    });
    return InitState();
  }

  Future<void> init() async {
    await initRenderers();
    await permission();
    await connectWithRoom();
  }

  Future<void> initRenderers() async {
    RTCVideoRenderer localRenderer = RTCVideoRenderer();

    await localRenderer.initialize();

    Widget fakeVideo = const FakeVideo();

    state = LoadedState(
      localRenderer: localRenderer,
      remoteRenderers: [],
      loadingVideo: fakeVideo,
    );
  }

  Future<void> permission() async {
    Map<Permission, PermissionStatus> statuses = await [
      Permission.location,
      Permission.storage,
      Permission.camera,
      Permission.microphone
    ].request();
  }

  Future<void> connectWithRoom() {
    final camState = ref.read(camStateProvider);
    final micState = ref.read(micStateProvider);
    final faceState = ref.read(faceStateProvider);
    final roomId = channelId;
    final userId = this.userId ?? "";

    return stompClient.join(roomId, userId, onStreamCallback).then((_) {
      print("[Web Rct Socket] Stomp Activate");
      return media.userMedia(camState, micState, faceState);
    }).then((stream) {
      return stompClient.streaming(stream);
    }).then((stream) {
      onStreamCallback(key: userId, stream: stream);
    });
  }

  Future<void> changeAction() async {
    final camState = ref.read(camStateProvider);
    final micState = ref.read(micStateProvider);
    final faceState = ref.read(faceStateProvider);

    media.userMedia(camState, micState, faceState).then((stream) {
      return stompClient.streaming(stream);
    });
  }

  Future<void> reconnect() async {
    if (stompClient.isConnected()) {
      await disConnect();
    }
    await connectWithRoom();
  }

  Future<void> disConnect() async {
    await stompClient.leave();
  }

  ///////////////////////////////////////////////////////////////////////////////////////////////

  void onStreamCallback({
    required String key,
    MediaStream? stream,
    bool? destroy,
  }) async {
    final pState = state;

    if (pState is! LoadedState) return;

    final video = videoListMap[key];

    if (destroy == true) {
      if (video != null) {
        await video.dispose();
        videoListMap.remove(key);

        List<RTCVideoRenderer> updatedRenderers =
        List.from(pState.remoteRenderers);
        updatedRenderers.remove(video);

        Widget? fakeVideo;

        if (updatedRenderers.isEmpty) {
          fakeVideo = const FakeVideo();
        }

        state = LoadedState(
          localRenderer: pState.localRenderer,
          remoteRenderers: updatedRenderers,
          loadingVideo: fakeVideo,
        );
      }
      return;
    }

    if (key == userId) {
      var localRenderer = pState.localRenderer;

      localRenderer.srcObject = stream;

      state = LoadedState(
        localRenderer: localRenderer,
        remoteRenderers: pState.remoteRenderers,
        loadingVideo: pState.loadingVideo,
      );
      return;
    }

    if (video == null) {
      final remoteRenderer = RTCVideoRenderer();
      await remoteRenderer.initialize();

      print('pc.onTrack media info');
      printMediaStreamInfo(stream!);

      remoteRenderer.srcObject = stream;

      videoListMap[key] = remoteRenderer;

      List<RTCVideoRenderer> updatedRenderers =
      List.from(pState.remoteRenderers)..add(remoteRenderer);

      state = LoadedState(
        localRenderer: pState.localRenderer,
        remoteRenderers: updatedRenderers,
        loadingVideo: null,
      );
    }
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
}

sealed class State {}

class InitState extends State {
  InitState();
}

class LoadedState extends State {
  final RTCVideoRenderer localRenderer;
  final List<RTCVideoRenderer> remoteRenderers;
  final Widget? loadingVideo;

  LoadedState({
    required this.localRenderer,
    required this.remoteRenderers,
    this.loadingVideo,
  });
}

class ErrorState extends State {
  final String error;

  ErrorState({
    required this.error,
  });
}

@Riverpod(keepAlive: true)
class MicState extends _$MicState {
  @override
  bool build() {
    return true;
  }

  void toggleButton() {
    state = !state;
  }
}

@Riverpod(keepAlive: true)
class CamState extends _$CamState {
  @override
  bool build() {
    return true;
  }

  void toggleButton() {
    state = !state;
  }
}

@Riverpod(keepAlive: true)
class FaceState extends _$FaceState {
  @override
  bool build() {
    return true;
  }

  void toggleButton() {
    state = !state;
  }
}
