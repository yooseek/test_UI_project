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
        body: GridTileWidget(),
      ),
    );
  }
}

class GridTileWidget extends StatelessWidget {
  const GridTileWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
          child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Padding(
            padding: EdgeInsets.all(8.0),
            child: Text(
              "Table",
              textScaleFactor: 2,
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(5.0),
            child: Table(
              textDirection: TextDirection.rtl,
              defaultVerticalAlignment: TableCellVerticalAlignment.middle,
              border: TableBorder.all(width: 2.0, color: Colors.black12),
              children: [
                const TableRow(
                    decoration: BoxDecoration(
                      color: Colors.blueGrey,
                    ),
                    children: [
                      TableCell(
                        verticalAlignment: TableCellVerticalAlignment.middle,
                        child: Padding(
                          padding: EdgeInsets.all(8.0),
                          child: Text(
                            "Name",
                            style: TextStyle(color: Colors.white),
                            textScaleFactor: 1.1,
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                      TableCell(
                        verticalAlignment: TableCellVerticalAlignment.middle,
                        child: Padding(
                          padding: EdgeInsets.all(8.0),
                          child: Text(
                            "Number",
                            style: TextStyle(color: Colors.white),
                            textScaleFactor: 1.1,
                          ),
                        ),
                      ),
                      TableCell(
                        verticalAlignment: TableCellVerticalAlignment.middle,
                        child: Padding(
                          padding: EdgeInsets.all(8.0),
                          child: Text(
                            "Grade",
                            style: TextStyle(color: Colors.white),
                            textScaleFactor: 1.1,
                          ),
                        ),
                      ),
                    ]),
                ...List.generate(
                    7,
                    (index) => const TableRow(children: [
                          TableCell(
                            verticalAlignment:
                                TableCellVerticalAlignment.middle,
                            child: Padding(
                              padding: EdgeInsets.all(8.0),
                              child: Text(
                                "Name",
                                style: TextStyle(
                                    fontSize: 14, color: Colors.black12),
                                textScaleFactor: 1,
                              ),
                            ),
                          ),
                          TableCell(
                            verticalAlignment:
                                TableCellVerticalAlignment.middle,
                            child: Padding(
                              padding: EdgeInsets.all(8.0),
                              child: Text(
                                "Number",
                                style: TextStyle(
                                    fontSize: 14, color: Colors.black12),
                                textScaleFactor: 1,
                              ),
                            ),
                          ),
                          TableCell(
                            verticalAlignment:
                                TableCellVerticalAlignment.middle,
                            child: Padding(
                              padding: EdgeInsets.all(8.0),
                              child: Text(
                                "Grade",
                                style: TextStyle(
                                    fontSize: 14, color: Colors.black12),
                                textScaleFactor: 1,
                              ),
                            ),
                          ),
                        ],
                    ),
                )
              ],
            ),
          ),
        ],
      )),
    );
  }
}

class tempScreen extends StatelessWidget {
  const tempScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.indigoAccent,
      child: Center(child: Text('템프 스크린')),
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
