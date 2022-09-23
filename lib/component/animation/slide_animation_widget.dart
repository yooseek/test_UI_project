import 'dart:ui';

import 'package:flutter/material.dart';

class SlideAnimationWidget extends StatefulWidget {
  final Widget child;
  final int duration;

  const SlideAnimationWidget({
    required this.child,
    this.duration = 1,
    Key? key,
  }) : super(key: key);

  @override
  State<SlideAnimationWidget> createState() =>
      _FadeAnimationRouteButtonState();
}

class _FadeAnimationRouteButtonState extends State<SlideAnimationWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController controller;
  late Animation<Offset> slideAnimation;

  @override
  void initState() {
    super.initState();

    controller = AnimationController(
        vsync: this, duration: Duration(seconds: widget.duration));

    // 오른쪽으로 이동
    slideAnimation =
        Tween<Offset>(begin: Offset.zero, end: const Offset(1.0, 0.0)).animate(
            CurvedAnimation(parent: controller, curve: Curves.easeInCubic));

    controller.forward();
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SlideTransition(
      position: slideAnimation,
      child: widget.child,
    );
  }
}
