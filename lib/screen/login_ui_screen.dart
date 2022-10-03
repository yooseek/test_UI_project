import 'package:flutter/material.dart';
import 'dart:math' as math;

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size.width;
    double degrees = 90;
    double radians = degrees * math.pi / 180;

    return Scaffold(
      body: Stack(
        children: [
          _TopWidget(),
          _TransformRotate(),
          _TransformScale(),
          _TransformTranslate(),
        ],
      ),
    );
  }
}

class _TransformRotate extends StatefulWidget {
  const _TransformRotate({Key? key}) : super(key: key);

  @override
  State<_TransformRotate> createState() => _TransformRotateState();
}

class _TransformRotateState extends State<_TransformRotate> {
  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size.width;
    double degrees = 30;
    double radians = degrees * math.pi / 180;

    return Transform.rotate(
      // angle: -25 * math.pi / 180,
      angle: math.pi / 8,
      alignment: Alignment.bottomRight,
      child: Container(
        width: screenSize * 0.8,
        height: screenSize * 0.8,
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(150), color: Colors.orange),
      ),
    );
  }
}

class _TransformScale extends StatefulWidget {
  const _TransformScale({Key? key}) : super(key: key);

  @override
  State<_TransformScale> createState() => _TransformScaleState();
}

class _TransformScaleState extends State<_TransformScale> {
  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size.width;
    return Transform.scale(
      // 0.5배 키우기
      scale: 0.5,
      child: Container(
        width: screenSize * 0.8,
        height: screenSize * 0.8,
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(150), color: Colors.teal),
      ),
    );
  }
}

class _TransformTranslate extends StatefulWidget {
  const _TransformTranslate({Key? key}) : super(key: key);

  @override
  State<_TransformTranslate> createState() => _TransformTranslateState();
}

class _TransformTranslateState extends State<_TransformTranslate> {
  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size.width;
    double degrees = 30;
    double radians = degrees * math.pi / 180;

    return Transform.translate(
      offset: Offset(100.0, 200.0),
      child: Container(
        width: screenSize * 0.8,
        height: screenSize * 0.8,
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(150), color: Colors.blue),
      ),
    );
  }
}

class _TopWidget extends StatefulWidget {
  const _TopWidget({Key? key}) : super(key: key);

  @override
  State<_TopWidget> createState() => _TopWidgetState();
}

class _TopWidgetState extends State<_TopWidget> {
  double x = 0;
  double y = 0;
  double z = 0;

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size.width;

    return Transform(
      transform: Matrix4(
        1, 0, 0, 0,
        0, 1, 0, 0,
        0, 0, 1, 0,
        0, 0, 0, 1,
      )
        ..rotateX(x)
        ..rotateY(y)
        ..rotateZ(z),
      alignment: FractionalOffset.center,
      child: GestureDetector(
        onPanUpdate: (DragUpdateDetails details) {
          print('dx = ${details.delta.dx / 100}');
          print('dy = ${details.delta.dy / 100}');
          setState(() {
            x = x + details.delta.dx / 100;
            y = y - details.delta.dy / 100;
          });
        },
        child: Container(
          width: screenSize * 0.5,
          height: screenSize * 0.5,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(150),
            color: Colors.pink
          ),
        ),
      ),
    );
  }
}
