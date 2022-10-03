import 'package:flutter/material.dart';

class TextAnimationWidget extends StatefulWidget {
  const TextAnimationWidget({
    super.key,
    required this.text,
    this.duration = 1,
  });
  final String text;
  final int duration;

  @override
  State<TextAnimationWidget> createState() => _TextAnimationWidgetState();
}

class _TextAnimationWidgetState extends State<TextAnimationWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController controller;
  late Animation<double> fadeInAnimation;
  late Animation<int> textStepAnimation;

  @override
  void initState() {
    super.initState();

    controller = AnimationController(
        vsync: this, duration: Duration(seconds: widget.duration));

    fadeInAnimation = Tween<double>(begin: 0, end: 1.0).animate(
        CurvedAnimation(parent: controller, curve: Curves.linear));

    textStepAnimation = StepTween(begin: 0, end: widget.text.length)
        .animate(CurvedAnimation(parent: controller, curve: Curves.easeIn));

    controller.forward();
  }


  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // fade 까지 주려면
    return FadeTransition(
      opacity: fadeInAnimation,
      child: AnimatedBuilder(
        builder: (context, child) {
          String text = widget.text.substring(0, textStepAnimation.value);
          return Text(
            text,
            style: const TextStyle(
              fontSize: 22,
              color: Colors.blue,
              fontWeight: FontWeight.bold,
            ),
          );
        },
        animation: textStepAnimation,
      ),
    );

    // 단순 텍스트 타이핑은 아래

  //   return AnimatedBuilder(
  //     builder: (context, child) {
  //       String text = widget.text.substring(0, textStepAnimation.value);
  //       return Text(
  //         text,
  //         style: const TextStyle(
  //           fontSize: 22,
  //           color: Colors.blue,
  //           fontWeight: FontWeight.bold,
  //         ),
  //       );
  //     },
  //     animation: textStepAnimation,
  //   );
  }
}
