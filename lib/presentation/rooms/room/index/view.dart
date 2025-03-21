import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_webrtc_example/presentation/rooms/room/index/view_model.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import '../../../../common/widget/alert.dart';
import 'component/rtc_video.dart';
import 'view_model.dart' as video;

class View extends ConsumerStatefulWidget {
  final String channelId;

  const View({
    required this.channelId,
    super.key,
  });

  @override
  ConsumerState<View> createState() => _ViewState();
}

class _ViewState extends ConsumerState<View> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    super.dispose();
    WidgetsBinding.instance.removeObserver(this);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);

    if (state == AppLifecycleState.paused) {
      // 앱이 백그라운드로 이동할 때 처리할 코드
      print('App is in the background.');
      // ref.read(trust.viewModelProvider(widget.room).notifier).disConnect();
    } else if (state == AppLifecycleState.resumed) {
      // 앱이 포그라운드로 돌아올 때 처리할 코드
      // ref.read(trust.viewModelProvider(widget.room).notifier).reconnect();
      print('App is in the foreground.');
    } else if (state == AppLifecycleState.inactive) {
      // 앱이 활성화되지 않을 때 처리할 코드 (예: 전화가 올 때)
      print('App is inactive.');
    } else if (state == AppLifecycleState.detached) {
      // 앱이 종료되기 전에 호출됨
      print('App is detached.');
    }
  }

  SliverGridDelegateWithMaxCrossAxisExtent gridDelegate(int totalPersons) {
    var orientation = MediaQuery.of(context).orientation;
    final height = MediaQuery.of(context).size.height;
    final width = MediaQuery.of(context).size.width;

    if (totalPersons == 1 && orientation == Orientation.portrait) {
      return SliverGridDelegateWithMaxCrossAxisExtent(
        maxCrossAxisExtent: width,
        childAspectRatio: width / (height / 2),
      );
    } else if (totalPersons == 1 && orientation == Orientation.landscape) {
      return SliverGridDelegateWithMaxCrossAxisExtent(
        maxCrossAxisExtent: width / 2,
        childAspectRatio: (width / 2) / height,
      );
    } else if (totalPersons <= 3 && orientation == Orientation.portrait) {
      return SliverGridDelegateWithMaxCrossAxisExtent(
        maxCrossAxisExtent: width,
        childAspectRatio: width / (height / totalPersons),
      );
    } else if (totalPersons <= 3 && orientation == Orientation.landscape) {
      return SliverGridDelegateWithMaxCrossAxisExtent(
        maxCrossAxisExtent: width / totalPersons,
        childAspectRatio: (width / totalPersons) / height,
      );
    } else if (totalPersons == 4) {
      return SliverGridDelegateWithMaxCrossAxisExtent(
        maxCrossAxisExtent: width / 2,
        childAspectRatio: (width / 2) / (height / 2),
      );
    } else if (totalPersons > 4 && orientation == Orientation.portrait) {
      return SliverGridDelegateWithMaxCrossAxisExtent(
        maxCrossAxisExtent: width / 2,
        childAspectRatio: (width / 2) / (height / 3),
      );
    } else {
      return SliverGridDelegateWithMaxCrossAxisExtent(
        maxCrossAxisExtent: width / 3,
        childAspectRatio: (width / 3) / (height / 2),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final micState = ref.watch(micStateProvider);
    final camState = ref.watch(camStateProvider);
    final micNotifier = ref.read(micStateProvider.notifier);
    final camNotifier = ref.read(camStateProvider.notifier);
    final faceNotifier = ref.read(faceStateProvider.notifier);
    final roomNotifier =
    ref.read(video.viewModelProvider(widget.channelId).notifier);
    return Scaffold(
      backgroundColor: Colors.white,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        elevation: 0,
        scrolledUnderElevation: 0,
        backgroundColor: Colors.transparent,
        leading: IconButton(
          onPressed: () {
            context.pop();
          },
          icon: const Icon(
            Icons.arrow_back_ios_new,
            size: 18,
            color: Colors.white,
          ),
        ),
      ),
      body: Stack(
        children: [
          CustomScrollView(
            physics: Platform.isIOS
                ? const BouncingScrollPhysics(
            )
                : const ClampingScrollPhysics(
            ),
            slivers: [
              Builder(
                builder: (context) {
                  final videoState =
                  ref.watch(video.viewModelProvider(widget.channelId));
                  if (videoState is video.LoadedState) {
                    final totalPersons = videoState.remoteRenderers.length +
                        (videoState.loadingVideo != null ? 1 : 0) + 1;
                    return SliverGrid(
                      gridDelegate: gridDelegate(totalPersons),
                      delegate: SliverChildBuilderDelegate(
                        childCount: totalPersons,
                            (context, index) {
                          if (index == 0) {
                            return RtcVideo(
                              localRenderer: videoState.localRenderer,
                              remoteRenderer: videoState.localRenderer,
                              index: index,
                            );
                          } else if (index <= videoState.remoteRenderers.length) {
                            return RtcVideo(
                              localRenderer: videoState.localRenderer,
                              remoteRenderer:
                              videoState.remoteRenderers[index - 1],
                              index: index,
                            );
                          } else if (videoState.loadingVideo != null) {
                            return videoState.loadingVideo;
                          } else {
                            return const SizedBox.shrink();
                          }
                        },
                      ),
                    );
                  } else {
                    return const SliverToBoxAdapter(child: SizedBox.shrink());
                  }
                },
              ),
            ],
          ),
          Positioned(
            bottom: 20,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  width: 70,
                  height: 70,
                  child: ElevatedButton(
                    onPressed: () async {
                      camNotifier.toggleButton();
                      await roomNotifier.changeAction();
                    },
                    style: ButtonStyle(
                      shape: WidgetStateProperty.all(
                        const CircleBorder(),
                      ),
                      backgroundColor: WidgetStateProperty.all(Colors.grey[50]),
                    ),
                    child: camState
                        ? Icon(
                      Icons.videocam,
                      color: Colors.grey[900],
                    )
                        : Icon(
                      Icons.videocam_off,
                      color: Colors.grey[900],
                    ),
                  ),
                ),
                const Gap(15),
                SizedBox(
                  width: 70,
                  height: 70,
                  child: ElevatedButton(
                    onPressed: () async {
                      faceNotifier.toggleButton();
                      await roomNotifier.changeAction();
                    },
                    style: ButtonStyle(
                      shape: WidgetStateProperty.all(
                        const CircleBorder(),
                      ),
                      backgroundColor: WidgetStateProperty.all(Colors.grey[50]),
                    ),
                    child: Icon(
                      Icons.cameraswitch,
                      color: Colors.grey[900],
                      size: 25,
                    ),
                  ),
                ),
                const Gap(15),
                SizedBox(
                  width: 70,
                  height: 70,
                  child: ElevatedButton(
                    onPressed: () async {
                      micNotifier.toggleButton();
                      await roomNotifier.changeAction();
                    },
                    style: ButtonStyle(
                      shape: WidgetStateProperty.all(
                        const CircleBorder(),
                      ),
                      backgroundColor: WidgetStateProperty.all(Colors.grey[50]),
                    ),
                    child: micState
                        ? Icon(
                      Icons.mic,
                      color: Colors.grey[900],
                    )
                        : Icon(
                      Icons.mic_off,
                      color: Colors.grey[900],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
