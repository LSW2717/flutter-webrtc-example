import 'dart:async';

import 'package:flutter/material.dart';

import '../../../../../common/const/typography.dart';

class FakeVideo extends StatefulWidget {
  const FakeVideo({super.key});

  @override
  State<FakeVideo> createState() => _WidgetTextState();
}

class _WidgetTextState extends State<FakeVideo> {

  String _text = "친구를 기다리는 중입니다";
  int _dotCount = 0;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _startAnimation();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _startAnimation() {
    _timer = Timer.periodic(const Duration(milliseconds: 500), (timer) {
      setState(() {
        _dotCount = (_dotCount + 1) % 5;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black,
      width: MediaQuery.of(context).size.width,
      height: MediaQuery.of(context).size.height,
      child: Center(
        child: Text(
          '$_text${"." * _dotCount}',
          style: text22.copyWith(color: Colors.white, height: -3),
        ),
      ),
    );
  }
}
