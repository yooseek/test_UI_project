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
import 'package:sensors_plus/sensors_plus.dart';
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
        body: TempScreen(),
      ),
    );
  }
}

class TempScreen extends StatefulWidget {
  const TempScreen({Key? key}) : super(key: key);

  @override
  State<TempScreen> createState() => _TempScreenState();
}

class _TempScreenState extends State<TempScreen> with SingleTickerProviderStateMixin{
  // late final StreamSubscription<AccelerometerEvent> accelerometerListener;
  // late final StreamSubscription<UserAccelerometerEvent> userAccelerometerListener;
  // late final StreamSubscription<GyroscopeEvent> gyroscopeListener;
  // late final StreamSubscription<MagnetometerEvent> magnetometerListener;

  late final AnimationController testAnimation;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          SizedBox(height: 200,),
          Container(
            color: Colors.indigoAccent.withOpacity(0.2),
            child: Center(child: Text('템프 스크린')),
          ),
          Flow(
            delegate: MyFlowDelegate(testAnimation),
            children: [
              Icon(Icons.abc),
              Icon(Icons.access_alarm),
            ],
          ),
        ],
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    // accelerometerEvents.listen((AccelerometerEvent event) {
    //   print(event);
    // });
    // userAccelerometerEvents.listen((UserAccelerometerEvent event) {
    //   print(event);
    // });
    // gyroscopeEvents.listen((GyroscopeEvent event) {
    //   print(event);
    // });
    // magnetometerEvents.listen((MagnetometerEvent event) {
    //   print(event);
    // });

    testAnimation = AnimationController(
        duration: const Duration(seconds: 2),
        vsync: this
    );
  }
}

class MyFlowDelegate extends FlowDelegate {
  MyFlowDelegate(this.animation) :super(repaint: animation);
  final Animation<double> animation;

  @override
  void paintChildren(FlowPaintingContext context) {
    context.paintChild(0,transform: Matrix4.identity());
    context.paintChild(1,
        transform: Matrix4.translationValues(0, 50, 0));

    for(int i =0; i<context.childCount ; i++) {
      final offset = i*animation.value * 50;
      context.paintChild(i,
        transform: Matrix4.translationValues(-offset, -offset, 0),
      );
    }
  }

  @override
  bool shouldRepaint(MyFlowDelegate oldDelegate) {
    return animation != oldDelegate.animation;
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
