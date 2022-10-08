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

class tempScreen extends StatelessWidget {
  const tempScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
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
        Expanded(
          child: ListWheelScrollView.useDelegate(
            childDelegate: ListWheelChildLoopingListDelegate(
              children: List.generate(3000, (index) {
                return TestList(text: index.toString(),);
              }),
            ),
            // 아이템당 높이
            itemExtent: 50,
            // 바퀴의 지름 설정 - 원통의 지름과 주축의 뷰포트 크기 사이의 비율
            diameterRatio: 2.0,
            // 바퀴의 축을 설정
            offAxisFraction: -0.5,
            // 확대 설정
            useMagnifier: true,
            magnification: 1.5,
            // 돋보기 위와 아래에 나타나는 휠에 적용할 불투명도 값
            overAndUnderCenterOpacity: 0.5,
          ),
        ),
      ],
    );
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
