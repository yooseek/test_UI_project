import 'package:flutter/material.dart';

class SimpleRotateAnimationWidget extends StatefulWidget {
  final Widget child;
  final int duration;
  const SimpleRotateAnimationWidget({
    required this.child,
    this.duration = 1,
    Key? key,
  }) : super(key: key);

  @override
  State<SimpleRotateAnimationWidget> createState() =>
      _SimpleRotateAnimationWidgetState();
}

class _SimpleRotateAnimationWidgetState
    extends State<SimpleRotateAnimationWidget> {
  double turns = 0.0;

  // 1/8 씩 돌리기 즉, 45도 씩
  void _changeRotation() {
    setState(() => turns += 1.0 / 8.0);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _changeRotation,
      child: AnimatedRotation(
        turns: turns,
        duration: Duration(seconds: widget.duration),
        child: widget.child,
      ),
    );
  }
}
