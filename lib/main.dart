import 'dart:async';
import 'dart:isolate';
import 'dart:math';
import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:rxdart/rxdart.dart';
import 'package:test_ui_project/component/animation/rotate_animation_widget.dart';
import 'package:test_ui_project/screen/back_drop_screen.dart';
import 'package:test_ui_project/screen/login_ui_screen.dart';
import 'package:test_ui_project/screen/tab_switching_view.dart';

void main() async {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    print('빌드 실행');
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: Scaffold(
        body: tempScreen(),
      ),
    );
  }
}

class tempScreen extends StatefulWidget {
  const tempScreen({Key? key}) : super(key: key);

  @override
  State<tempScreen> createState() => _tempScreenState();
}

class _tempScreenState extends State<tempScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController controller;
  late final Animation<double> animation;
  bool showFirstWidget = true;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Center(
          child: ElevatedButton(
            child: Text('담페이지'),
            onPressed: () {
              Navigator.of(context).push(MaterialPageRoute(
                builder: (_) => BackDropScreen(),
              ));
            },
          ),
        ),
        SizedBox(
          height: 200,
        ),
        AnimatedBuilder(
          animation: animation,
          builder: (BuildContext context, Widget? child) {
            return Transform.rotate(
              angle: animation.value,
              child: child,
            );
          },
          child: SizedBox(
            height: 300,
            child: Align(
              heightFactor: 2.0,
              widthFactor: 2.0,
              alignment: Alignment(0.5, 1.0),
              child: Image.asset(
                'assets/images/hi.png',
              ),
            ),
          ),
        ),
        Positioned(
          bottom: 30,
          child: Column(
            children: [
              Text('위에 있는 위젯임다'),
              AnimatedCrossFade(
                duration: Duration(seconds: 1),
                firstChild: SizedBox(height: 300,child: Text('첫번 째 위젯임다')),
                secondChild: Text('두번 째 위젯임다'),
                crossFadeState: showFirstWidget
                    ? CrossFadeState.showFirst
                    : CrossFadeState.showSecond,
                // 위젯 크키가 다를 때 이런 방식도 가능, 이건 안써도됨
                layoutBuilder:
                    (firstWidget, firstKey, secondWidget, secondKey) {
                  return Stack(
                    children: [
                      Positioned(key: secondKey, child: secondWidget),
                      Positioned(key: firstKey, child: firstWidget),
                    ],
                  );
                },
              ),
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    showFirstWidget = !showFirstWidget;
                  });
                },
                child: Text('위젯 바꾸기'),
              ),
            ],
          ),
        ),
      ],
    );
  }

  @override
  void initState() {
    super.initState();
    controller = AnimationController(
      duration: Duration(seconds: 3),
      vsync: this,
    );
    animation = Tween(begin: 0.0, end: 2.0 * pi).animate(controller);
    controller.forward();
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }
}

class TestList extends StatelessWidget {
  final String text;

  const TestList({required this.text, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    print('빌드됨 $text');
    return Container(
      color: Colors.orange,
      child: Text(text),
    );
  }
}

class RXScreen extends HookWidget {
  const RXScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // 위젯이 리빌드 될 때마다 subject를 다시 생성한다
    final subject = useMemoized(() => BehaviorSubject<String>(), [key]);

    // 위젯이 리빌드 될 때마다 예전 subject를 삭제한다
    useEffect(
      () => subject.close,
      [subject],
    );

    return Column(
      children: [
        SizedBox(
          height: 200,
        ),
        StreamBuilder<String>(
          stream: subject.stream.distinct().debounceTime(Duration(seconds: 1)),
          initialData: '비어있습니다',
          builder: (context, snapshot) {
            return Text(snapshot.data.toString());
          },
        ),
        TextField(onChanged: subject.sink.add),
      ],
    );
  }
}
