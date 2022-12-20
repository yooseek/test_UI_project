import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'package:dio/dio.dart';
import 'package:flutter/services.dart';
import 'package:flutter_cube/flutter_cube.dart';
import 'package:html/dom.dart' as dom;
import 'package:html/parser.dart';
import 'package:http/http.dart' as http;
import 'dart:ui' hide Path;
import 'dart:ui' as ui;

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart' hide Material;
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:image_sequence_animator/image_sequence_animator.dart';
import 'package:model_viewer_plus/model_viewer_plus.dart';
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

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  // This widget is the root of your application.

  @override
  Widget build(BuildContext context) {
    String js = '''
  const modelViewer = document.querySelector('#widget');
  modelViewer.addEventListener('click', event => {
    var ani = modelViewer.animationName === 'idle' ? 'anotherAni' : 'idle';
    modelViewer.setAttribute('animation-name', ani);
  });
''';

    return MaterialApp(
      //showSemanticsDebugger: true,
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
      ),
      home: Scaffold(
          appBar: AppBar(title: Text("Model Viewer")), body: Page3DContainer()),
    );
  }
}
class Page3DContainer extends StatefulWidget {
  const Page3DContainer({Key? key}) : super(key: key);

  @override
  State<Page3DContainer> createState() => _Page3DContainerState();
}

class _Page3DContainerState extends State<Page3DContainer> with SingleTickerProviderStateMixin {

  var _maxSlide = 0.75;
  var _extraHeight = 0.1;
  late double _startingPos;
  var _drawerVisible = false;
  late AnimationController _animationController;
  Size _screen = Size(0, 0);
  late CurvedAnimation _animator;
  late CurvedAnimation _objAnimator;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 800),
    );
    _animator = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOutQuad,
      reverseCurve: Curves.easeInQuad,
    );
    _objAnimator = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
      reverseCurve: Curves.easeIn,
    );
  }

  @override
  void didChangeDependencies() {
    _screen = MediaQuery.of(context).size;
    _maxSlide *= _screen.width;
    _extraHeight *= _screen.height;
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onHorizontalDragStart: _onDragStart,
      onHorizontalDragUpdate: _onDragUpdate,
      onHorizontalDragEnd: _onDragEnd,
      child: Stack(
        children: [
          Container(color: Color(0xFFaaa598)),
          _buildBackground(),
          _build3dObject(),
          _buildDrawer(),
          _buildHeader(),
          _buildOverlay(),
        ],
      ),
    );
  }

  void _onDragStart(DragStartDetails details) {
    _startingPos = details.globalPosition.dx;
  }

  void _onDragUpdate(DragUpdateDetails details) {
    final globalDelta = details.globalPosition.dx - _startingPos;

    if (globalDelta > 0) {
      /// 왼쪽에서 오른쪽으로 드래그 할때
      final pos = globalDelta / _screen.width;
      if (_drawerVisible && pos <= 1.0) return;
      _animationController.value = pos;
    } else {
      /// 오른쪽에서 왼쪽으로 드래그 할때
      /// 화면을 드래그한 포지션 비율
      final pos = 1 - (globalDelta.abs() / _screen.width);
      if (!_drawerVisible && pos >= 0.0) return;
      _animationController.value = pos;
    }
  }

  void _onDragEnd(DragEndDetails details) {
    /// 1초에 좌우로 500 픽셀 이상을 한번에 드래그 했을 때
    if (details.velocity.pixelsPerSecond.dx.abs() > 500) {

      /// 왼쪽에서 오른쪽으로 드래그 되었을 때
      if (details.velocity.pixelsPerSecond.dx > 0) {
        _animationController.forward(from: _animationController.value);
        _drawerVisible = true;
      } else {
        /// 오른쪽에서 왼쪽으로 드래그 되었을 때
        _animationController.reverse(from: _animationController.value);
        _drawerVisible = false;
      }
      return;
    }
    /// 1초에 좌우로 500픽셀 이상 빠르게 드래그 하지 않았을 때 (애니메이션이 중간일때)
    if (_animationController.value > 0.5) {
      {
        _animationController.forward(from: _animationController.value);
        _drawerVisible = true;
      }
    } else {
      {
        _animationController.reverse(from: _animationController.value);
        _drawerVisible = false;
      }
    }
  }

  void _toggleDrawer() {
    if (_animationController.value < 0.5)
      _animationController.forward();
    else
      _animationController.reverse();
  }

  _buildMenuItem(String s, {bool active = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: InkWell(
        onTap: () {},
        child: Text(
          s.toUpperCase(),
          style: TextStyle(
            fontSize: 25,
            color: active ? Color(0xffbb0000) : null,
            fontWeight: FontWeight.w900,
          ),
        ),
      ),
    );
  }

  _buildFooterMenuItem(String s) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: InkWell(
        onTap: () {},
        child: Text(
          s.toUpperCase(),
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w900,
          ),
        ),
      ),
    );
  }

  _buildBackground() => Positioned.fill(
    top: -_extraHeight,
    bottom: -_extraHeight,
    child: AnimatedBuilder(
      animation: _animator,
      builder: (context, widget) => Transform.translate(
        offset: Offset(_maxSlide * _animator.value, 0),
        child: Transform(
          transform: Matrix4.identity()
            ..setEntry(3, 2, 0.001)
            ..rotateY((pi / 2 + 0.1) * -_animator.value),
          alignment: Alignment.centerLeft,
          child: widget,
        ),
      ),
      child: Container(
        color: Color(0xffe8dfce),
        child: Stack(
          children: <Widget>[
            //Fender word
            Positioned(
              top: _extraHeight + 0.1 * _screen.height,
              left: 80,
              child: Transform.rotate(
                angle: 90 * (pi / 180),
                alignment: Alignment.centerLeft,
                child: Text(
                  "FENDER",
                  style: TextStyle(
                    fontSize: 100,
                    color: Color(0xFFc7c0b2),
                    shadows: [
                      Shadow(
                        color: Colors.black26,
                        blurRadius: 5,
                        offset: Offset(2.0, 0.0),
                      ),
                    ],
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ),
            // Shadow
            Positioned(
              top: _extraHeight + 0.13 * _screen.height,
              bottom: _extraHeight + 0.24 * _screen.height,
              left: _maxSlide - 0.41 * _screen.width,
              right: _screen.width * 1.06 - _maxSlide,
              child: Column(
                children: <Widget>[
                  Flexible(
                    child: FractionallySizedBox(
                      widthFactor: 0.2,
                      child: Container(
                        decoration: BoxDecoration(
                          boxShadow: [
                            BoxShadow(
                              blurRadius: 50,
                              color: Colors.black38,
                            )
                          ],
                          borderRadius: BorderRadius.circular(50),
                        ),
                      ),
                    ),
                  ),
                  Flexible(
                    child: Container(
                      decoration: BoxDecoration(
                        boxShadow: [
                          BoxShadow(
                            blurRadius: 50,
                            color: Colors.black26,
                          )
                        ],
                        borderRadius: BorderRadius.circular(50),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            AnimatedBuilder(
              animation: _animator,
              builder: (_, __) => Container(
                color: Colors.black.withAlpha(
                  (150 * _animator.value).floor(),
                ),
              ),
            ),
          ],
        ),
      ),
    ),
  );

  _buildDrawer() => Positioned.fill(
    top: -_extraHeight,
    bottom: -_extraHeight,
    left: 0,
    right: _screen.width - _maxSlide,
    child: AnimatedBuilder(
      animation: _animator,
      builder: (context, widget) {
        return Transform.translate(
          offset: Offset(_maxSlide * (_animator.value - 1), 0),
          child: Transform(
            transform: Matrix4.identity()
              ..setEntry(3, 2, 0.001)
              ..rotateY(pi * (1 - _animator.value) / 2),
            alignment: Alignment.centerRight,
            child: widget,
          ),
        );
      },
      child: Container(
        color: Color(0xffe8dfce),
        child: Stack(
          children: <Widget>[
            Positioned(
              top: 0,
              bottom: 0,
              right: 0,
              child: Container(
                width: 5,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.transparent, Colors.black12],
                  ),
                ),
              ),
            ),
            Positioned.fill(
              top: _extraHeight,
              bottom: _extraHeight,
              child: SafeArea(
                child: Container(
                  width: _maxSlide,
                  child: Padding(
                    padding: const EdgeInsets.all(40.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        Row(
                          children: <Widget>[
                            Container(
                              width: 25,
                              height: 25,
                              decoration: BoxDecoration(
                                border: Border.all(
                                  color: Colors.black26,
                                  width: 4,
                                ),
                                shape: BoxShape.circle,
                              ),
                            ),
                            Transform.translate(
                              offset: Offset(-15, 0),
                              child: Text(
                                "STRING",
                                style: TextStyle(
                                  fontSize: 12,
                                  backgroundColor: Color(0xffe8dfce),
                                  fontWeight: FontWeight.w900,
                                  fontStyle: FontStyle.italic,
                                ),
                              ),
                            )
                          ],
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            _buildMenuItem("Guitars", active: true),
                            _buildMenuItem("Basses"),
                            _buildMenuItem("Amps"),
                            _buildMenuItem("Pedals"),
                            _buildMenuItem("Others"),
                          ],
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            _buildFooterMenuItem("About"),
                            _buildFooterMenuItem("Support"),
                            _buildFooterMenuItem("Terms"),
                            _buildFooterMenuItem("Faqs"),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            AnimatedBuilder(
              animation: _animator,
              builder: (_, __) => Container(
                width: _maxSlide,
                color: Colors.black.withAlpha(
                  (150 * (1 - _animator.value)).floor(),
                ),
              ),
            ),
          ],
        ),
      ),
    ),
  );

  _build3dObject() => Positioned(
    top: 0.1 * _screen.height,
    bottom: 0.22 * _screen.height,
    left: _maxSlide - _screen.width * 0.5,
    right: _screen.width * 0.85 - _maxSlide,
    child: AnimatedBuilder(
      animation: _objAnimator,
      builder: (_, __) => ImageSequenceAnimator(
        "assets/guitarSequence", //folderName
        "", //fileName
        1, //suffixStart
        4, //suffixCount
        "png", //fileFormat
        120, //frameCount
        fps: 60,
        isLooping: false,
        isBoomerang: true,
        isAutoPlay: false,
      ),
    ),
  );

  _buildHeader() => SafeArea(
    child: AnimatedBuilder(
        animation: _animator,
        builder: (_, __) {
          return Transform.translate(
            offset: Offset((_screen.width - 60) * _animator.value, 0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                SizedBox(
                  width: 50,
                  height: 50,
                  child: InkWell(
                    onTap: _toggleDrawer,
                    child: Icon(Icons.menu),
                  ),
                ),
                Opacity(
                  opacity: 1 - _animator.value,
                  child: Text(
                    "PRODUCT DETAIL",
                    style: TextStyle(fontWeight: FontWeight.w900),
                  ),
                ),
                SizedBox(width: 50, height: 50),
              ],
            ),
          );
        }),
  );

  _buildOverlay() => Positioned(
    top: 0,
    bottom: 50,
    left: 0,
    right: 0,
    child: AnimatedBuilder(
      animation: _animator,
      builder: (_, widget) => Opacity(
        opacity: 1 - _animator.value,
        child: Transform.translate(
          offset: Offset((_maxSlide + 50) * _animator.value, 0),
          child: Transform(
            transform: Matrix4.identity()
              ..setEntry(3, 2, 0.001)
              ..rotateY((pi / 2 + 0.1) * -_animator.value),
            alignment: Alignment.centerLeft,
            child: widget,
          ),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 50.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          mainAxisSize: MainAxisSize.max,
          children: <Widget>[
            Text(
              "Fender\nAmerican\nElite Strat",
              style: TextStyle(
                fontSize: 30,
                fontWeight: FontWeight.w900,
              ),
            ),
            Row(
              children: <Widget>[
                Text(
                  "SPEC",
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
                Icon(Icons.keyboard_arrow_down),
              ],
            ),
          ],
        ),
      ),
    ),
  );
}


class GLB3DTest extends StatefulWidget {
  const GLB3DTest({Key? key}) : super(key: key);

  @override
  State<GLB3DTest> createState() => _GLB3DTestState();
}

class _GLB3DTestState extends State<GLB3DTest> {
  bool check = false;
  late Object girl;
  late Object boy;

  String js = '''
  const modelViewer = document.querySelector('#kfa-main-image');
  modelViewer.addEventListener('click', event => {
    var ani = modelViewer.animationName === '456' ? '123' : '456';
    modelViewer.setAttribute('animation-name', ani);
  });
''';

  @override
  void initState() {
    super.initState();
    // girl = Object(fileName: 'assets/cube/sonyTest.obj');
    girl = Object(fileName: 'assets/cube/sonyTest.obj', lighting: true);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
            child: Cube(
              onSceneCreated: (Scene scene) {
                scene.camera.position.setFrom(Vector3(0, 0, 10));
                scene.light.position.setFrom(Vector3(0, 15, 15));
                scene.textureBlendMode = BlendMode.modulate;
                // scene.world.add(Object(scale: Vector3(5.0, 5.0, 5.0), lighting: true, fileName: 'assets/cube/cup_green_obj.obj'));

                scene.world.add(girl);

                // scene.world.add(boy);

                scene.camera.zoom = 10;
              },
              onObjectCreated: (obj) async {
                final test = await loadMtl('assets/cube/sonyTest.mtl');
                print(test);
                print(test['Material.001']);

                final texture = await loadTexture(test['Material.001'],'assets/cube/sonyTest.mtl');
                print(texture);

                girl.mesh.material = test['Material.001']!;
                girl.updateTransform();
                girl.scene!.updateTexture();
              },
            ),
          ),
        TextButton(
          child: Text('변경'),
          onPressed: () async {
            loadMtl('assets/cube/sonyTest.mtl').then((val){
              print(val);
              print(val['Material.001']);
              girl.mesh.material = val['Material.001']!;

              girl.updateTransform();
              girl.scene!.updateTexture();
            });

            final texture = await loadTexture(girl.mesh.material,'assets/cube/sonyTest.mtl');
            print(texture);

            loadImageFromAsset('assets/cube/cup_green_obj.png').then((value) {
              print('value --------------- ${value.runtimeType}');
              print('value --------------- ${girl.mesh.texture}');
              girl.mesh.texture = value;
              girl.scene!.updateTexture();
            });
          },
        ),
      ],
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
          ElevatedButton(
              onPressed: () async {
                try {
                  methodChannel.invokeMethod('noti');
                } on PlatformException catch (e) {
                  print(e);
                }
              },
              child: Text('알림 세팅 열기'))
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
    final response =
        await compute(httpService.getChangeNumberCheck, "01050043394");

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
                  final _screenshot = await _screenShotController.capture(
                      delay: const Duration(milliseconds: 10));

                  if (_screenshot != null) {
                    // 스크린샷을 문서 디렉토리에 저장
                    final _documentDirectoryPath =
                        await getApplicationDocumentsDirectory();
                    final _documentDirectoryPath2 =
                        await getApplicationSupportDirectory();
                    final _temporaryDirectoryPath3 =
                        await getTemporaryDirectory();

                    /// '/data/user/0/com.example.test_ui_project/app_flutter' - 해당 앱만의 저장공간이며 앱이 삭제되면 없어진다
                    print('_documentDirectoryPath : $_documentDirectoryPath');

                    /// '/data/user/0/com.example.test_ui_project/files'
                    print('_documentDirectoryPath2 : $_documentDirectoryPath2');

                    /// '/data/user/0/com.example.test_ui_project/cache' - 캐쉬같이 임시로 데이터를 저장하는 공간이고 언제든지 삭제될 수 있다
                    print(
                        '_temporaryDirectoryPath3 : $_temporaryDirectoryPath3');

                    // 해당 Path로 파일 생성하기
                    final imagePath = await File(
                            '${_documentDirectoryPath.path}/screenshot.png')
                        .create();

                    // 생성된 빈 파일에 스크린샷을 바이트로 변환해서 채워넣기
                    await imagePath.writeAsBytes(_screenshot);

                    // 스크린샷과 텍스트 공유
                    await Share.shareFiles(
                      [imagePath.path],
                      text: _shareText,
                      sharePositionOrigin:
                          box!.localToGlobal(Offset.zero) & box.size,
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
          stream: subject.stream
              .distinct()
              .debounceTime(const Duration(seconds: 1)),
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
