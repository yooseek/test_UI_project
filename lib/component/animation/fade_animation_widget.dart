import 'dart:ui';

import 'package:flutter/material.dart';

class FadeAnimationWidget extends StatefulWidget {
  final Widget child;
  final int duration;

  const FadeAnimationWidget({
    required this.child,
    this.duration = 1,
    Key? key,
  }) : super(key: key);

  @override
  State<FadeAnimationWidget> createState() =>
      _FadeAnimationRouteButtonState();
}

class _FadeAnimationRouteButtonState extends State<FadeAnimationWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController controller;
  late Animation<double> fadeAnimation;

  @override
  void initState() {
    super.initState();

    controller = AnimationController(
        vsync: this, duration: Duration(seconds: widget.duration));

    fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(parent: controller, curve: Curves.easeInOutCubic));

    controller.forward();
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: fadeAnimation,
      child: widget.child,
    );
  }
}
