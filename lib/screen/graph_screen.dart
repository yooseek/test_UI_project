import 'dart:math';

import 'package:flutter/material.dart';
import 'dart:ui' as ui;

class GraphScreen extends StatelessWidget {
  const GraphScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          height: 200,
          width: double.infinity,
        ),
        SingleChildScrollView(
          child: Container(
            height: 300,
            width: 400,
            color: Colors.black,
            child: CustomPaint(
              painter: ChartPainter(),
            ),
          ),
        ),
      ],
    );
  }
}

class ChartPainter extends CustomPainter {
  final List<int> test = List.generate(50, (index) => Random().nextInt(20));

  late int minValue = test.reduce(min);
  late int maxValue = test.reduce(max);

  final int verticalUnit = 5;
  final int horizontalUnit = 10;

  final double bottomPadding = 40; // 텍스트가 들어갈 패딩(아랫쪽)을 구합니다.
  final double topPadding = 20; // 텍스트가 들어갈 패딩(위쪽)을 구합니다.
  final double rightPadding = 30; // 패딩(오른쪽)을 구합니다.
  final double leftPadding = 15; //세로메뉴 패딩(왼쪽)을 구합니다.
  final double horizontalLeftPadding = 50; //가로메뉴 패딩(왼쪽)을 구합니다.


  final MaterialColor myColor = Colors.orange;

  late final strokePaint = Paint()
    ..color = myColor
    ..style = PaintingStyle.stroke
    ..strokeWidth = 3
    ..strokeCap = StrokeCap.round;

  @override
  void paint(Canvas canvas, Size size) {
    double h = size.height - topPadding - bottomPadding; // 패딩을 제외한 화면의 높이를 구합니다.
    double w = size.width - horizontalLeftPadding - rightPadding; // 패딩을 제외한 화면의 넓이를 구합니다.

    // 세로 텍스트
    final verticalSpacing = (maxValue - minValue) / verticalUnit;
    for (var i = 0; i <= verticalUnit; i++) {
      // 세로 축에 적을 글자들
      final tp = TextPainter(
          text: TextSpan(
            text: '${(minValue + verticalSpacing * i).round()}',
            style: const TextStyle(fontSize: 12.0, color: Colors.white),
          ),
          textAlign: TextAlign.center,
          textDirection: TextDirection.ltr);
      // 위치 잡고
      tp.layout();
      // 어디에 그릴지
      tp.paint(canvas, Offset(leftPadding, h + topPadding - i * (h/verticalUnit)));
    }

    // 가로 텍스트
    for (var i = 0; i <= test.length; i += horizontalUnit) {
      // 가로 축에 적을 글자들
      final tp = TextPainter(
          text: TextSpan(
            text: '$i',
            style: TextStyle(fontSize: 12.0, color: Colors.white),
          ),
          textAlign: TextAlign.start,
          textDirection: TextDirection.ltr);
      // 위치 잡고
      tp.layout();
      // 어디에 그릴지
      tp.paint(
          canvas, Offset(i*(w/test.length) + horizontalLeftPadding, h + bottomPadding));
    }

    // 그래프 그리기
    var lastX = 0.0;
    var lastY = 0.0;
    final strokePath = Path();
    for (var i = 0; i < test.length; i++) {
      final current = test[i];
      var nextIndex = i + 1;
      // 마지막 점이 끝나는 곳
      if (i + 1 > test.length - 1) {
        nextIndex = test.length - 1;
      }
      final next = test[nextIndex];

      final leftRatio = (current - minValue) / (maxValue - minValue);
      final rightRatio = (next - minValue) / (maxValue - minValue);

      final x1 = i*(w/test.length) + horizontalLeftPadding;
      final y1 = h -
          (leftRatio * (h)) + topPadding;

      final x2 = (i+1)*(w/test.length) + horizontalLeftPadding;
      final y2 = h -
          (rightRatio * (h)) + topPadding;

      // 첫번째 점을 찍을 곳
      if (i == 0) {
        strokePath.moveTo(x1, y1);
      }
      // 현재 점과 다음점의 중간을 찾은 다음 계속 이어그리기
      lastX = (x1 + x2) / 2.0;
      lastY = (y1 + y2) / 2.0;
      // 곡선으로 그리기
      strokePath.quadraticBezierTo(x1, y1, lastX, lastY);
    }

    // 계산 끝 그리기
    final fillPath = Path.from(strokePath)
      ..lineTo(lastX, h + topPadding)
      ..lineTo(horizontalLeftPadding,
          h + topPadding)
      ..close();

    final fillPaint = Paint()
      ..color = myColor
      ..style = PaintingStyle.fill
      ..shader = ui.Gradient.linear(
        Offset.zero,
        Offset(0, (size.height / verticalUnit) / 2),
        [
          Colors.pink,
          Colors.white,
        ],
      );

    print(test[0]);
    print(test[10]);
    print(test[20]);

    canvas.drawPath(fillPath, fillPaint);
    canvas.drawPath(strokePath, strokePaint);
  }

  @override
  bool shouldRepaint(ChartPainter oldDelegate) {
    return oldDelegate.test != test;
  }
}
