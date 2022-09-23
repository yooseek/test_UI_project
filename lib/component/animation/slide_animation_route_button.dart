import 'dart:ui';

import 'package:flutter/material.dart';

class SlideAnimationRouteButton extends StatelessWidget {
  final Widget buttonChildWidget;
  final Widget nextScreen;
  final int duration;

  const SlideAnimationRouteButton({
    required this.buttonChildWidget,
    required this.nextScreen,
    this.duration = 1,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    print('SlideAnimationRouteButton build');

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
        return nextScreen;
      },
      transitionDuration: Duration(seconds: duration),
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        // 아래에서 위로
        final slideAnimation =
            Tween(begin: const Offset(0.0, 1.0), end: Offset.zero).animate(
          CurvedAnimation(parent: animation, curve: Curves.easeInCubic),
        );

        return SlideTransition(
          position: slideAnimation,
          child: child,
        );
      },
    );
  }
}
