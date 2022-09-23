import 'dart:math';

import 'package:flutter/material.dart';

class RotateAnimationWidget extends StatefulWidget {
  const RotateAnimationWidget({
    super.key,
    required this.text,
    this.duration = 1,
  });
  final String text;
  final int duration;

  @override
  State<RotateAnimationWidget> createState() => _RotateAnimationWidgetState();
}

class _RotateAnimationWidgetState extends State<RotateAnimationWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController controller;
  late Animation<double> rotateAnimation;

  @override
  void initState() {
    super.initState();

    controller = AnimationController(
        vsync: this, duration: Duration(seconds: widget.duration));

    rotateAnimation = Tween(begin: 0.0, end: 0.07).animate(
        CurvedAnimation(parent: controller, curve: const ShakeCurve(count: 3)));

    controller.forward();
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return RotationTransition(
      turns: rotateAnimation,
      child: Text(
            widget.text,
            style: const TextStyle(
              fontSize: 22,
              color: Colors.blue,
              fontWeight: FontWeight.bold,
            ),
          ),
    );

  }
}

class ShakeCurve extends Curve {
  final double count;
  const ShakeCurve({this.count = 1});

  @override
  double transformInternal(double t) {
    // t = 시간
    // count = 흔드는 횟수
    // var val = sin(count * 2 * pi * t + 0.5) * 0.5 + 0.7;

    // 사인 그래프
    var val = sin(count * 2 * pi * t);
    return val;
  }
}