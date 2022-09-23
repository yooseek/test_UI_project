import 'dart:ui';

import 'package:flutter/material.dart';

class FadeAnimationRouteButton extends StatelessWidget {
  final Widget buttonChildWidget;
  final Widget nextScreen;
  final int duration;

  const FadeAnimationRouteButton({
    required this.buttonChildWidget,
    required this.nextScreen,
    this.duration = 1,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    print('FadeAnimationRouteButton build');
    return ElevatedButton(
        onPressed: () {
          Navigator.of(context)
              .push(_createRoute());
        },
        child: buttonChildWidget);
  }

  Route _createRoute() {
    return PageRouteBuilder(
      pageBuilder: (context, animation, secondaryAnimation) {
        return FadeTransition(
          opacity: Tween<double>(begin: 0.0, end: 1.0).animate(animation),
          child: nextScreen,
        );
      },
      transitionDuration: Duration(seconds: duration),
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        final opacityTween =
            Tween<double>(begin: 0.0, end: 1.0).animate(animation);

        return BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
          child: FadeTransition(opacity: opacityTween, child: child),
        );
      },
    );
  }
}
