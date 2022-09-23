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
          Positioned(
            child: _TopWidget(),
          ),
           _TopWidget2(),
        ],
      ),
    );
  }
}

class _TopWidget2 extends StatefulWidget {
  const _TopWidget2({Key? key}) : super(key: key);

  @override
  State<_TopWidget2> createState() => _TopWidget2State();
}

class _TopWidget2State extends State<_TopWidget2> {
  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size.width;
    double degrees = 30;
    double radians = degrees * math.pi / 180;

    return AnimatedContainer(
      duration: Duration(seconds: 1),
      child: Transform.rotate(
        // angle: -25 * math.pi / 180,
        angle: radians,
        child: GestureDetector(
          onPanUpdate: (DragUpdateDetails details) {
            print('dx = ${details.delta.dx / 100}');
            print('dy = ${details.delta.dy / 100}');
            setState(() {
              degrees = 0;
            });
          },
          onTap: () {
            setState(() {
              degrees = 90;
            });
          },
          child: Container(
            width: screenSize * 0.8,
            height: screenSize * 0.8,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(150),
              color: Colors.orange
            ),
          ),
        ),
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
        1,0,0,0,
        0,1,0,0,
        0,0,1,0,
        0,0,0,1,
      )..rotateX(x)..rotateY(y)..rotateZ(z),
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
            gradient: LinearGradient(
              colors: [
                Color(0x27292A),
                Color(0xB316BFC4),
              ],
              begin: Alignment(-0.2, 0.8),
              end: Alignment.bottomCenter,
            ),
          ),
        ),
      ),
    );
  }
}
