import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';

class View extends ConsumerStatefulWidget {
  final RTCVideoRenderer localRenderer;
  final RTCVideoRenderer remoteRenderer;
  final int index;
  final bool isMe;

  const View({
    required this.localRenderer,
    required this.remoteRenderer,
    required this.index,
    required this.isMe,
    super.key,
  });

  @override
  ConsumerState<View> createState() => _ViewState();
}

class _ViewState extends ConsumerState<View> {
  bool _showVideo = false;

  @override
  void initState() {
    super.initState();

    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted) {
        setState(() {
          _showVideo = true;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: GestureDetector(
        onTap: () => Navigator.of(context).pop(),
        child: Stack(
          children: [
            Center(
              child: Hero(
                tag: 'video-${widget.index}',
                child: OrientationBuilder(builder: (context, orientation) {
                  return SizedBox(
                    width: MediaQuery.of(context).size.width,
                    height: MediaQuery.of(context).size.height,
                    child: InteractiveViewer(
                      maxScale: 4,
                      child: RTCVideoView(
                        widget.remoteRenderer,
                        objectFit: RTCVideoViewObjectFit.RTCVideoViewObjectFitCover,
                        mirror: true,
                      ),
                    ),
                  );
                }),
              ),
            ),
            if (!widget.isMe && _showVideo)
              Positioned(
                bottom: 20,
                right: 20,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: SizedBox(
                    width: 200,
                    height: 150,
                    child: RTCVideoView(
                      widget.localRenderer,
                      objectFit:
                      RTCVideoViewObjectFit.RTCVideoViewObjectFitCover,
                      mirror: true,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
