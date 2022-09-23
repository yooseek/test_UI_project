import 'dart:ui';
import 'dart:math';

import 'package:flutter/material.dart';

class IntervalFadeAnimationWidget extends StatefulWidget {
  final List<Widget> childs;
  final int duration;

  const IntervalFadeAnimationWidget({
    required this.childs,
    this.duration = 1,
    Key? key,
  }) : super(key: key);

  @override
  State<IntervalFadeAnimationWidget> createState() =>
      _FadeAnimationRouteButtonState();
}

class _FadeAnimationRouteButtonState extends State<IntervalFadeAnimationWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController controller;

  @override
  void initState() {
    super.initState();

    controller = AnimationController(
        vsync: this, duration: Duration(seconds: widget.duration));

    controller.forward();
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 100,
      child: ListView.builder(
        itemBuilder: (context, index) {
          // fade 추가
          Animation<double> fadeAnimation = Tween(begin: 0.0, end: 1.0)
              .animate(CurvedAnimation(
              parent: controller,
              curve: Interval(0.1 * index, 0.6 + index * 0.1,
                  curve: Curves.linear)));
          
          // 오른쪽에서 날아옴
          Animation<Offset> slideAnimation =
              Tween<Offset>(begin: const Offset(0.3, 0.0), end: Offset.zero).animate(
                  CurvedAnimation(parent: controller, curve: Interval(0.1 * index, 0.6 + index * 0.1,
                      curve: Curves.linear)));

          return FadeTransition(
            opacity: fadeAnimation,
            child: SlideTransition(
              position: slideAnimation,
              child: widget.childs[index],
            ),
          );
        },
        itemCount: widget.childs.length,
      ),
    );
  }
}
