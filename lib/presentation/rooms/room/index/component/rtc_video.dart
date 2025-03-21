import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:flutter_webrtc_example/presentation/rooms/room/full_screen_video/view.dart' as full_screen;

class RtcVideo extends ConsumerStatefulWidget {
  final RTCVideoRenderer localRenderer;
  final RTCVideoRenderer remoteRenderer;
  final int index;

  const RtcVideo({
    required this.localRenderer,
    required this.remoteRenderer,
    required this.index,
    super.key,
  });

  @override
  ConsumerState<RtcVideo> createState() => _WidgetVideoState();
}

class _WidgetVideoState extends ConsumerState<RtcVideo> {

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.grey[500],
      child: GestureDetector(
        onTap: () {
          Navigator.push(
            context,
            PageRouteBuilder(
              pageBuilder: (
                  context,
                  animation,
                  secondaryAnimation,
                  ) =>
                  full_screen.View(
                    localRenderer: widget.localRenderer,
                    remoteRenderer: widget.remoteRenderer,
                    index: widget.index,
                    isMe: true,
                  ),
              transitionsBuilder: (
                  context,
                  animation,
                  secondaryAnimation,
                  child,
                  ) {
                return FadeTransition(
                  opacity: animation,
                  child: child,
                );
              },
            ),
          );
        },
        child: Hero(
          tag: 'video-${0}',
          child: RTCVideoView(
            widget.remoteRenderer,
            objectFit: RTCVideoViewObjectFit.RTCVideoViewObjectFitCover,
            mirror: true,
          ),
        ),
      ),
    );
  }
}
