import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/services.dart';
import 'package:html/dom.dart' as dom;
import 'package:html/parser.dart';
import 'package:http/http.dart' as http;
import 'dart:ui' hide Path;

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:path_provider/path_provider.dart';
import 'package:rxdart/rxdart.dart';
import 'package:screenshot/screenshot.dart';
import 'package:share/share.dart';
import 'package:test_ui_project/api/retrofit_service.dart';
import 'package:test_ui_project/models/band.dart';
import 'package:test_ui_project/provider/socket_provider.dart';
import 'package:test_ui_project/screen/bootpay_perchase_screen.dart';
import 'package:test_ui_project/screen/bootpay_screen.dart';
import 'package:webview_flutter/webview_flutter.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      //showSemanticsDebugger: true,
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
      ),
      // home: const MyHomePage(title: '스크린 샷 테스트입니다',),
      home: SettingView(),
    );
  }
}

class SettingView extends StatelessWidget {
  const SettingView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    const methodChannel = const MethodChannel('appSettings');

    return Center(
      child: Column(
        children: [
          Text('앱 세팅 열기'),
          ElevatedButton(onPressed: () async {
            try {
              methodChannel.invokeMethod('noti');
            } on PlatformException catch (e) {
              print(e);
            }
          }, child: Text('알림 세팅 열기'))
        ],
      ),
    );
  }
}


class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);
  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final _screenShotController = ScreenshotController();
  int _counter = 0;

  void _incrementCounter() {
    setState(() {
      _counter++;
    });
  }


  @override
  void initState() {
    super.initState();
    test();
  }

  test() async {
    final httpService = RetrofitService(Dio());
    final response = await compute(httpService.getChangeNumberCheck,"01050043394");

    print(response.toString());
}

  @override
  Widget build(BuildContext context) {
    return Screenshot(
      controller: _screenShotController,
      child: Scaffold(
        appBar: AppBar(
          title: Text(widget.title),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              const Text(
                'You have pushed the button this many times:',
              ),
              Text(
                '$_counter',
                style: Theme.of(context).textTheme.headline4,
              ),
              ElevatedButton(
                onPressed: () async {

                  final box = context.findRenderObject() as RenderBox?;

                  const _shareText = '공유할 텍스트'; // 스크린샷 공유일 땐 별로 노 필요
                  final _screenshot = await _screenShotController.capture(delay: const Duration(milliseconds: 10));

                  if (_screenshot != null) {
                    // 스크린샷을 문서 디렉토리에 저장
                    final _documentDirectoryPath = await getApplicationDocumentsDirectory();
                    final _documentDirectoryPath2 = await getApplicationSupportDirectory();
                    final _temporaryDirectoryPath3 = await getTemporaryDirectory();

                    /// '/data/user/0/com.example.test_ui_project/app_flutter' - 해당 앱만의 저장공간이며 앱이 삭제되면 없어진다
                    print('_documentDirectoryPath : $_documentDirectoryPath');
                    /// '/data/user/0/com.example.test_ui_project/files'
                    print('_documentDirectoryPath2 : $_documentDirectoryPath2');
                    /// '/data/user/0/com.example.test_ui_project/cache' - 캐쉬같이 임시로 데이터를 저장하는 공간이고 언제든지 삭제될 수 있다
                    print('_temporaryDirectoryPath3 : $_temporaryDirectoryPath3');

                    // 해당 Path로 파일 생성하기
                    final imagePath = await File('${_documentDirectoryPath.path}/screenshot.png').create();

                    // 생성된 빈 파일에 스크린샷을 바이트로 변환해서 채워넣기
                    await imagePath.writeAsBytes(_screenshot);

                    // 스크린샷과 텍스트 공유
                    await Share.shareFiles([imagePath.path], text: _shareText,
                        sharePositionOrigin: box!.localToGlobal(Offset.zero) & box.size,
                    );
                  }
                },
                child: const Text('스크린 샷 공유를 해봅시당'),
              ),
            ],
          ),
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: _incrementCounter,
          tooltip: 'Increment',
          child: const Icon(Icons.add),
        ),
      ),
    );
  }
}

class TempScreen extends StatefulWidget {
  const TempScreen({Key? key}) : super(key: key);

  @override
  State<TempScreen> createState() => _TempScreenState();
}

class _TempScreenState extends State<TempScreen>
    with SingleTickerProviderStateMixin {
  int a = 0;
  double opa = 1;
  late final ScrollController scrollController;

  final _scrollPos = ValueNotifier(0.0);

  @override
  void initState() {
    super.initState();
    scrollController = ScrollController()
      ..addListener(() {
        _scrollPos.value = scrollController.position.pixels;
      });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: ElevatedButton(
          onPressed: () {
            print('click');
          },
          child: const Text('앱바'),
        ),
        title: ValueListenableBuilder<double>(
          valueListenable: _scrollPos,
          builder: (_, value, child) {
            // get some value between 0 and 1, based on the amt scrolled
            double opacity = (1 - value / 150).clamp(0, 1);
            return Opacity(opacity: opacity, child: child);
          },
          child: const Text('타이틀입니다'),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final controller = ScaffoldMessenger.of(context)
              .showSnackBar(const SnackBar(content: Text("복잡한 작업 실행 시작.")));
          print(controller);
          print('체크 1');
          // compute(complexTask,a);
          await complexTask(a);
          print('체크 5');

          if (mounted) {
            print('체크 2');
            controller.close();
            ScaffoldMessenger.of(context)
                .showSnackBar(const SnackBar(content: Text("복잡한 작업 실행 끝.")));
          }
          print('체크 4');
        },
        child: const Icon(Icons.add),
      ),
      body: NotificationListener<ScrollEndNotification>(
        onNotification: (noti) {
          return true;
        },
        child: Stack(
          children: [
            Center(
              child: Row(
                children: [
                  ElevatedButton(
                      onPressed: () {
                        print('click');
                      },
                      child: const Text('버튼')),
                  Text(a.toString()),
                ],
              ),
            ),
            CustomScrollView(
              controller: scrollController,
              slivers: [
                SliverIgnorePointer(
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      childCount: 1,
                      (context, index) => Container(
                        height: 500,
                      ),
                    ),
                  ),
                  ignoring: true,
                ),
                SliverToBoxAdapter(
                  child: Column(
                    children: [
                      Container(
                        height: 500,
                        color: Colors.red,
                      )
                    ],
                  ),
                ),
              ],
            ),
            AbsorbPointer(
              child: Container(
                height: 500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  static Future<int> complexTask(int a) async {
    // for (int i = 0; i < 900000000; ++i) {
    //   if(i == 800000000) debugPrint('체크 3');
    //   a++;
    // }
    int result = 0;
    await Future.delayed(const Duration(seconds: 2));
    print('체크 3');
    return result;
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
        const SizedBox(
          height: 200,
        ),
        StreamBuilder<String>(
          stream: subject.stream.distinct().debounceTime(const Duration(seconds: 1)),
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
