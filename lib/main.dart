import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'package:dio/dio.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_cube/flutter_cube.dart';
import 'package:go_router/go_router.dart';
import 'package:html/dom.dart' as dom;
import 'package:html/parser.dart';
import 'package:http/http.dart' as http;
import 'dart:ui' hide Path;
import 'dart:ui' as ui;
import 'dart:collection';

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart' hide Material;
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:image_sequence_animator/image_sequence_animator.dart';
import 'package:model_viewer_plus/model_viewer_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'package:rive/rive.dart' hide LinearGradient;
import 'package:rxdart/rxdart.dart';
import 'package:screenshot/screenshot.dart';
import 'package:share/share.dart';
import 'package:test_ui_project/api/retrofit_service.dart';
import 'package:test_ui_project/bloc/tmp2_bloc.dart';
import 'package:test_ui_project/bloc/tmp_bloc.dart';
import 'package:test_ui_project/component/image_shadow.dart';
import 'package:test_ui_project/injection_container.dart';
import 'package:test_ui_project/models/band.dart';
import 'package:test_ui_project/models/person.dart';
import 'package:test_ui_project/provider/socket_provider.dart';
import 'package:test_ui_project/repository/tmp_repo.dart';
import 'package:test_ui_project/screen/bootpay_perchase_screen.dart';
import 'package:test_ui_project/screen/bootpay_screen.dart';
import 'package:webview_flutter/webview_flutter.dart';

final _router = GoRouter(
  initialLocation: '/unAuth',
  routes: [
    ShellRoute(
      // navigatorKey: _shellNavigatorKey,
      builder: (BuildContext context, GoRouterState state, Widget child) {
        return BottomNavScreen(child: child);
      },
      routes: <RouteBase>[
        GoRoute(
            path: '/shl1/:id',
            builder: (BuildContext context, GoRouterState state) {
              return shlScreen1(id: state.params['id']!);
            },
            routes: [
              GoRoute(
                path: 'subshl1/:id2',
                builder: (BuildContext context, GoRouterState state) {
                  return subShlScreen1(id: state.params['id2']!);
                },
              ),
              GoRoute(
                path: 'subshl2/:id2',
                builder: (BuildContext context, GoRouterState state) {
                  return subShlScreen2(id: state.params['id2']!);
                },
              ),
            ]),
        GoRoute(
          path: '/shl2/:id',
          builder: (BuildContext context, GoRouterState state) {
            return shlScreen2(id: state.params['id']!);
          },
        ),
        GoRoute(
          path: '/shl3/:id',
          builder: (BuildContext context, GoRouterState state) {
            return shlScreen3(id: state.params['id']!);
          },
        ),
      ],
    ),

    /// /users/1

    /// /users?id=1
    GoRoute(
        name: 'tmp2',
        path: '/2',
        builder: (context, state) => tmpScreen2(id: state.queryParams['id']!),
        pageBuilder: (context, state) {
          return MaterialPage(
            key: state.pageKey,
            child: tmpScreen2(id: state.queryParams['id']!),
          );
        }),
    GoRoute(
      name: 'tmp4',
      path: '/4/:id',
      builder: (context, state) => tmpScreen4(id: state.params['id']!),
    ),
    GoRoute(
        name: 'auth',
        path: '/auth',
        builder: (context, state) => tmpScreen1(id: '1', auth: true),
        routes: [
          GoRoute(
              name: 'tmp1',
              path: '1/:id',
              builder: (context, state) =>
                  tmpScreen1(id: state.params['id']!, auth: true),
              routes: [
                GoRoute(
                  name: 'tmp1_sub1',
                  path: ':id2',
                  builder: (context, state) => tmpScreen1(
                      id: state.params['id']!,
                      id2: state.params['id2'],
                      auth: true),
                ),
                GoRoute(
                  name: 'tmp1_sub2',
                  path: ':id2',
                  builder: (context, state) => tmpScreen1(
                      id: state.params['id2']!,
                      id2: state.params['id2'],
                      auth: true),
                ),
                GoRoute(
                  name: 'tmp3',
                  path: '3/:id2',
                  builder: (context, state) =>
                      tmpScreen3(id: state.params['id2']!),
                ),
              ]),
        ]),
    GoRoute(
      name: 'unAuth',
      path: '/unAuth',
      builder: (context, state) => tmpScreen1(id: '-1', auth: false),
    ),
  ],
  debugLogDiagnostics: true,
);

void main() async {
  await initializeDependencies();

  runApp(const MyApp());
}

class MyCustomScrollBehavior extends MaterialScrollBehavior {
  @override
  Widget buildOverscrollIndicator(
      BuildContext context, Widget child, ScrollableDetails details) {
    return child;
  }
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
    return MaterialApp(
        //showSemanticsDebugger: true,
        scrollBehavior: MyCustomScrollBehavior(),
        title: 'Flutter Demo',
        theme: ThemeData(
          primarySwatch: Colors.blue,
          useMaterial3: true,
        ),
        // routerConfig: _router,
        home: CustomBackDropContainer(
          constrainSize: Size(100, 200),
        ));
  }
}

class SimpleRive extends StatefulWidget {
  const SimpleRive({Key? key}) : super(key: key);

  @override
  State<SimpleRive> createState() => _SimpleRiveState();
}
class _SimpleRiveState extends State<SimpleRive> {
  late RiveAnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = SimpleAnimation('Change', autoplay: true);
  }

  void _togglePlay() =>
      setState(() => _controller.isActive = !_controller.isActive);

  bool get isPlaying => _controller.isActive;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: GestureDetector(
          child: RiveAnimation.asset(
            'assets/images/new_Alert.riv',
            controllers: [_controller],
            // stateMachines: const ['Pressed'],
            // Update the play state when the widget's initialized
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _togglePlay,
        tooltip: isPlaying ? 'Pause' : 'Play',
        child: Icon(
          isPlaying ? Icons.pause : Icons.play_arrow,
        ),
      ),
    );
  }
}

class CustomBackDropContainer extends StatefulWidget {
  const CustomBackDropContainer({required this.constrainSize, Key? key})
      : super(key: key);

  final Size constrainSize;

  @override
  State<CustomBackDropContainer> createState() =>
      _CustomBackDropContainerState();
}

class _CustomBackDropContainerState extends State<CustomBackDropContainer>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  // 애니메이션 속도 비율
  final double _kFlingVelocity = 2.0;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 12300),
      value: 1.0,
      vsync: this,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  bool get _animationStatus {
    final AnimationStatus status = _controller.status;
    return status == AnimationStatus.completed ||
        status == AnimationStatus.forward;
  }

  void _toggleBackdropLayerVisibility() {
    // 간편한 모드 - 기본 스프링 애니메이션을 사용해라
    _controller.fling(velocity: _animationStatus ? -_kFlingVelocity : _kFlingVelocity);
  }

  @override
  Widget build(BuildContext context) {
    final Size layerSize = widget.constrainSize;
    final size = MediaQuery.of(context).size;

    Animation<RelativeRect> layerAnimation = RelativeRectTween(
      begin: RelativeRect.fromLTRB(
          size.width - layerSize.width,size.height - layerSize.height, 0, 0),
      end: const RelativeRect.fromLTRB(0.0, 0.0, 0.0, 0.0),
    ).animate(_controller.view);

    Animation<Rect?> relAnimation = RectTween(
      begin: Rect.fromLTRB(0.0, 0.0, 0.0, 0.0),
      end: Rect.fromLTRB(0.0, 0.0, 0.0, 100.0),
    ).animate(_controller.view);

    return Scaffold(
      body: Stack(
        children: [
          // widget.backLayer,
          Positioned.fill(
            child: Container(color: Colors.red),
          ),
          RelativePositionedTransition(
            rect: relAnimation,
            size: Size(0,100),
            child: Container(
              decoration: const BoxDecoration(
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(46.0),
                ),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: _toggleBackdropLayerVisibility,
                    child: Container(
                      height: 140.0,
                      alignment: AlignmentDirectional.centerStart,
                    ),
                  ),
                  Expanded(
                    child: Container(color: Colors.white,child: Center(child: Text('Front')),),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class CustomRiveAnimation extends StatefulWidget {
  const CustomRiveAnimation({Key? key}) : super(key: key);

  @override
  State<CustomRiveAnimation> createState() => _CustomRiveAnimationState();
}

class _CustomRiveAnimationState extends State<CustomRiveAnimation> {
  // Controller for playback
  late RiveAnimationController _controller;
  late StateMachineController _stateController;
  SMIBool? _pressed;
  SMITrigger? _triggerPressed;

  void _togglePlay() =>
      setState(() => _controller.isActive = !_controller.isActive);

  bool get isPlaying => _controller.isActive;

  @override
  void initState() {
    super.initState();
    _controller = SimpleAnimation('go');
  }

  void _hitPressed() {
    print(_pressed?.value);
    if (_pressed?.value == false) {
      _pressed?.value = true;
      _triggerPressed?.fire();
    } else {
      _pressed?.value = false;
      _pressed?.change(false);
    }
  }

  void _onInit(Artboard art) {
    _stateController = StateMachineController.fromArtboard(
            art, 'State Machine 1', onStateChange: _onStateChange)
        as StateMachineController;

    print('_stateController ===========================  $_stateController');
    _pressed = _stateController.findInput<bool>('Pressed') as SMIBool?;
    _triggerPressed = _stateController.findSMI('Pressed') as SMITrigger?;
    print('_pressed ===========================  ${_pressed?.name}');

    art.addController(_stateController);
  }

  void _onStateChange(String stateMachineName, String stateName) =>
      print('stateMachineName : $stateMachineName --- stateName : $stateName');

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: GestureDetector(
          onTap: _hitPressed,
          child: RiveAnimation.asset(
            'assets/images/rive_one.riv',
            // controllers: [_controller],
            // stateMachines: const ['Pressed'],
            // Update the play state when the widget's initialized
            onInit: _onInit,
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _togglePlay,
        tooltip: isPlaying ? 'Pause' : 'Play',
        child: Icon(
          isPlaying ? Icons.pause : Icons.play_arrow,
        ),
      ),
    );
  }
}

class CustomPaintInterAction extends StatefulWidget {
  const CustomPaintInterAction({Key? key}) : super(key: key);

  @override
  State<CustomPaintInterAction> createState() => _CustomPaintInterActionState();
}

class _CustomPaintInterActionState extends State<CustomPaintInterAction>
    with SingleTickerProviderStateMixin {
  late final AnimationController controller;
  late Animation<double> animation;
  late final PageController pageController;

  bool isAnimationTouch = true;

  @override
  void initState() {
    super.initState();
    controller =
        AnimationController(vsync: this, duration: const Duration(seconds: 1));
    pageController = PageController(initialPage: 0)
      ..addListener(() {
        pageController.offset;
      });

    animation = Tween<double>(begin: 0, end: 2.0)
        .animate(CurvedAnimation(parent: controller, curve: Curves.linear));

    // controller.forward();
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Center(
            child: Column(
      children: [
        Container(
          width: 200,
          height: 200,
        ),
        Container(
            width: 200,
            height: 200,
            child: CustomPaint(
              painter: LocationCustomPainter(pageController),
            )),
        Expanded(
          child: PageView(
            controller: pageController,
            children: [
              Center(
                child: Text('1'),
              ),
              Center(
                child: Text('2'),
              ),
              Center(
                child: Text('3'),
              ),
              Center(
                child: Text('4'),
              ),
            ],
          ),
        ),
        TextButton(
          child: Text('animation restart'),
          onPressed: () {
            if (isAnimationTouch) {
              controller.reverse();
              setState(() {
                isAnimationTouch = false;
              });
            } else {
              controller.forward();
              setState(() {
                isAnimationTouch = true;
              });
            }
          },
        ),
      ],
    )));
  }
}

class LocationCustomPainter extends CustomPainter {
  final PageController _animation;

  LocationCustomPainter(this._animation) : super(repaint: _animation);

  Path _createAnyPath(Size size) {
    double w = size.width;
    double h = size.height;

    /// 이곳에 커스텀 ClipPath 작성
    return Path()
      ..lineTo(w, 0)
      ..lineTo(w, h)
      ..lineTo(0, h)
      ..lineTo(0, 0);
  }

  @override
  void paint(Canvas canvas, Size size) {
    final animationPercent = _animation.page!;

    final path = _createAnyPath(size);

    final Paint paint = Paint();
    paint.color = Colors.amberAccent;
    paint.style = PaintingStyle.stroke;
    paint.strokeWidth = 10.0;

    /// 캔버스 자체를 돌리기
    canvas.translate(size.width * 0.5, size.height * 0.5);
    canvas.rotate(pi / 180 * animationPercent / 2 * 45);
    canvas.translate(-size.width * 0.5, -size.height * 0.5);

    canvas.translate(size.width * 0.5, size.height * 0.5);
    canvas.rotate(pi / 180 * animationPercent / 4 * 45);
    canvas.translate(-size.width * 0.5, -size.height * 0.5);

    // canvas.drawPath(path, paint);

    /// Path를 설정해서 마름모로 변환 시키기 - 변환될 꼭지점을 만들고 애니메이션 비율을 곱하면 됨
    path.moveTo(0 + (size.width / 2 * animationPercent), 0);
    // Top
    path.lineTo(0 + (size.width / 2 * animationPercent), 0);
    path.lineTo(size.width, 0 + (size.height / 2 * animationPercent));
    // Bottom
    path.lineTo(size.width - (size.width / 2 * animationPercent), size.height);
    path.lineTo(0, size.height - (size.height / 2 * animationPercent));
    // End
    // path.close();

    path.moveTo(0, 0);
    // Top
    path.lineTo(size.width * animationPercent, 0);
    path.lineTo(size.width, size.height * animationPercent);
    // Bottom
    path.lineTo(size.width - (size.width * animationPercent), size.height);
    path.lineTo(0, size.height - (size.height * animationPercent));
    // End
    // path.close();

    path.moveTo(0 + (size.width / 4 * animationPercent), 0);
    // Top
    path.lineTo(0 + (size.width / 4 * animationPercent), 0);
    path.lineTo(size.width, 0 + (size.height / 4 * animationPercent));
    // Bottom
    path.lineTo(size.width - (size.width / 4 * animationPercent), size.height);
    path.lineTo(0, size.height - (size.height / 4 * animationPercent));
    // End
    // path.close();

    path.moveTo(0 + (size.width * animationPercent), 0);
    // Top
    path.lineTo(0 + (size.width * animationPercent), 0);
    path.lineTo(size.width, 0 + (size.height * animationPercent));
    // Bottom
    path.lineTo(size.width - (size.width * animationPercent), size.height);
    path.lineTo(0, size.height - (size.height * animationPercent));
    // End
    path.close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}

class OpacityDrawer extends StatefulWidget {
  const OpacityDrawer({Key? key}) : super(key: key);

  @override
  State<OpacityDrawer> createState() => _OpacityDrawerState();
}

class _OpacityDrawerState extends State<OpacityDrawer> {
  bool isInVisible = false;
  final int visibleIndex = 3;
  final List<bool> visibleList = [true, true, true];
  double fontSize = 12.0;

  changeVisibleList(int index) {
    for (int i = 0; i < visibleIndex; i++) {
      if (i == index) {
        visibleList[i] = true;
      } else {
        visibleList[i] = false;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawerScrimColor: Colors.transparent,
      endDrawer: Drawer(
        backgroundColor: isInVisible ? Colors.white.withOpacity(0.5) : null,
        width: 220,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Opacity(
                opacity: visibleList[0] ? 1.0 : 0.5,
                child: Container(
                  child: Column(
                    children: [
                      Text('글자 크기 조절하기', style: TextStyle(color: Colors.red)),
                      Slider.adaptive(
                        value: fontSize,
                        onChangeEnd: (val) {
                          setState(() {
                            changeVisibleList(0);
                            isInVisible = false;
                          });
                        },
                        onChangeStart: (val) {
                          setState(() {
                            changeVisibleList(0);
                            isInVisible = true;
                          });
                        },
                        onChanged: (double value) {
                          setState(() {
                            fontSize = value;
                          });
                        },
                        label: fontSize.round().toString(),
                        divisions: 10,
                        max: 18,
                        min: 8,
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 26),
              Opacity(
                opacity: visibleList[1] ? 1.0 : 0.5,
                child: Container(
                  color: Colors.white,
                  child: Text('메뉴 1', style: TextStyle(color: Colors.red)),
                ),
              ),
              SizedBox(height: 26),
              Opacity(
                opacity: visibleList[2] ? 1.0 : 0.5,
                child: Container(
                  color: Colors.white,
                  child: Text('메뉴 2', style: TextStyle(color: Colors.red)),
                ),
              ),
            ],
          ),
        ),
      ),
      body: Center(
        child: Text(
            '이번 포스트에서는 앱 <밀리의 서재>의 기능 중 일부를 구현해보려한다.'
            '우연히 <밀리의 서재> 웹 사이트에서 앱을 소개하는 동영상을 보았는데 흥미로운 부분이 있었다.'
            '바로 시선 감지(Eye Tracking)와 뷰어 내부의 스타일 변경 인터랙션, UX이다.'
            '재밌어 보이는 기능, 인터랙션 이였기 때문에 두가지 기능 모두 구현해보려 했었는데, 시선 감지의 정확도가 좀 떨어져서 뷰어 내부의 스타일 변경 인터랙션만 작성하려 한다.'
            '밀리의 서재에서는 drawer에서 텍스트 스타일을 커스텀할 수 있는데, 이 과정에서의 UX를 굉장히 잘 만들었다고 생각한다.'
            '그래서, 어떤 UX인데??'
            '밀리의서재 - 자유로운 보기 설정'
            '위의 이미지에서 볼 수 있듯이, 폰트 사이즈를 변경하게되면, 뒤의 글의 크기가 실시간으로 변경되며 이를 바로 확인할 수 있다.'
            '이 과정에서 유저가 드래그하고 있는 영역을 제외하고는 투명하게 변한다'
            '텍스트 크기를 표현하는 숫자가 얼마나 크고 작은지, 바로 눈으로 확인하여 쉽게 알 수 있게 하였다.'
            '드로워(Drawer)?'
            '햄버거 버튼으로도 불리는 메뉴 버튼을 누르면 나오는 옆에서 튀어나오는 화면을 본적이 있을 것이다.'
            '이것을 Drawer라고 한다. Drawer는 나오는 방향에 따라 이름을 다르게 부르는데 왼쪽 -> 오른쪽이면 Drawer, 오른쪽 -> 왼쪽이면 EndDrawer라고 부른다.'
            '이는 Scaffold에서 선언할 수 있다.',
            style: TextStyle(fontSize: fontSize)),
      ),
    );
  }
}

class ReverseCustomList extends StatefulWidget {
  const ReverseCustomList({Key? key}) : super(key: key);

  @override
  State<ReverseCustomList> createState() => _ReverseCustomListState();
}

class _ReverseCustomListState extends State<ReverseCustomList> {
  List<String> testList = List.generate(30, (index) => index.toString());
  late Map<String, int> testListIndex = {};
  int count = 30;

  @override
  void initState() {
    super.initState();
    updateListIndex(0);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Expanded(
            child: ListView.custom(
              reverse: true,
              childrenDelegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final element = testList[testList.length - 1 - index];

                    return Container(
                      key: ValueKey(element), // ex) element.id
                      height: 80,
                      alignment: Alignment.center,
                      child: Text(element), // ex) element.content
                    );
                  },
                  childCount: testList.length,
                  findChildIndexCallback: (key) {
                    final valueKey = key as ValueKey<String>;
                    final val = testListIndex[valueKey.value]!;

                    return testList.length - 1 - val;
                  }),
            ),
          ),
          TextButton(
            child: Text('리스트 추가하기'),
            onPressed: () {
              setState(() {
                testList.add(count.toString());
                updateListIndex(testList.length - 1);
                count++;
              });
            },
          ),
        ],
      ),
    );
  }

  void updateListIndex(int start) {
    for (int i = start; i < testList.length; i++) {
      testListIndex[testList[i]] = i;
    }
  }
}

class OKCustomPainter extends StatefulWidget {
  const OKCustomPainter({Key? key}) : super(key: key);

  @override
  State<OKCustomPainter> createState() => _OKCustomPainterState();
}

class _OKCustomPainterState extends State<OKCustomPainter>
    with SingleTickerProviderStateMixin {
  late final AnimationController controller;

  @override
  void initState() {
    super.initState();
    controller =
        AnimationController(vsync: this, duration: Duration(milliseconds: 800));

    controller.forward();
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: CustomPaint(
          size: const Size(300, 300),
          painter: AnimatedPathPainter(controller),
        ),
      ),
    );
  }
}

class AnimatedPathPainter extends CustomPainter {
  final Animation<double> _animation;

  AnimatedPathPainter(this._animation) : super(repaint: _animation);

  Path extractPathUntilLength(
    Path originalPath,
    double length,
  ) {
    var currentLength = 0.0;

    final path = Path();

    var metricsIterator = originalPath.computeMetrics().iterator;

    while (metricsIterator.moveNext()) {
      var metric = metricsIterator.current;

      var nextLength = currentLength + metric.length;

      final isLastSegment = nextLength > length;
      if (isLastSegment) {
        final remainingLength = length - currentLength;
        final pathSegment = metric.extractPath(0.0, remainingLength);

        path.addPath(pathSegment, Offset.zero);
        break;
      } else {
        // There might be a more efficient way of extracting an entire path
        final pathSegment = metric.extractPath(0.0, metric.length);
        path.addPath(pathSegment, Offset.zero);
      }

      currentLength = nextLength;
    }

    return path;
  }

  Path createAnimatedPath(
    Path originalPath,
    double animationPercent,
  ) {
    // ComputeMetrics can only be iterated once!
    final totalLength = originalPath
        .computeMetrics()
        .fold(0.0, (double prev, PathMetric metric) => prev + metric.length);

    final currentLength = totalLength * animationPercent;

    return extractPathUntilLength(originalPath, currentLength);
  }

  Path _createAnyPath(Size size) {
    double w = size.width;
    double h = size.height;

    Offset startPoint = Offset(w * 0.23, h * 0.5);
    Offset centerPoint = Offset(w * 0.43, h * 0.7);
    Offset endPoint = Offset(w * 0.75, h * 0.35);

    /// 이곳에 커스텀 ClipPath 작성
    return Path()
      ..moveTo(w * 0.5, 0)
      ..relativeArcToPoint(Offset(0, h),
          radius: Radius.circular(10), clockwise: false)
      ..relativeArcToPoint(Offset(0, -h),
          radius: Radius.circular(10), clockwise: false)
      ..moveTo(startPoint.dx, startPoint.dy)
      ..lineTo(centerPoint.dx, centerPoint.dy)
      ..lineTo(endPoint.dx, endPoint.dy);
  }

  Path _createCheckPath(Size size) {
    double w = size.width;
    double h = size.height;

    Offset startPoint = Offset(w * 0.23, h * 0.5);
    Offset centerPoint = Offset(w * 0.43, h * 0.7);
    Offset endPoint = Offset(w * 0.75, h * 0.35);

    /// 이곳에 커스텀 ClipPath 작성
    return Path()
      ..moveTo(startPoint.dx, startPoint.dy)
      ..lineTo(centerPoint.dx, centerPoint.dy)
      ..lineTo(endPoint.dx, endPoint.dy);
  }

  @override
  void paint(Canvas canvas, Size size) {
    final animationPercent = _animation.value;

    final path = createAnimatedPath(_createAnyPath(size), animationPercent);

    final Paint paint = Paint();
    paint.color = Colors.amberAccent;
    paint.style = PaintingStyle.stroke;
    paint.strokeWidth = 5.0;

    /// path에 따라 쭈욱 그리는 애니메이션
    // canvas.drawPath(path, paint);

    /// 원이 커지는 애니메이션
    canvas.drawCircle(
      Offset(
        size.width / 2,
        size.height / 2,
      ),
      1 + min(animationPercent * size.width, size.width / 2),
      paint,
    );

    final checkPath =
        createAnimatedPath(_createCheckPath(size), animationPercent * 2);

    /// check표시 애니메이션
    canvas.drawPath(checkPath, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}

class SecondPage extends StatelessWidget {
  const SecondPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        color: Colors.orange,
        child: Center(
          child: TextButton(
              child: Text('뒤로'),
              onPressed: () {
                Navigator.of(context).pop();
              }),
        ),
      ),
    );
  }
}

class ClipHalfWidget extends StatefulWidget {
  const ClipHalfWidget({Key? key}) : super(key: key);

  @override
  State<ClipHalfWidget> createState() => _ClipHalfWidgetState();
}

class _ClipHalfWidgetState extends State<ClipHalfWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController controller;
  late Animation<Offset> slideAnimation1;
  late Animation<Offset> slideAnimation2;

  late ScrollController leftScrollController;
  late ScrollController rightScrollController;

  @override
  void initState() {
    super.initState();

    controller =
        AnimationController(vsync: this, duration: Duration(milliseconds: 800));

    // 오른쪽으로 이동
    slideAnimation1 =
        Tween<Offset>(begin: Offset.zero, end: const Offset(1.0, 0.0)).animate(
            CurvedAnimation(parent: controller, curve: Curves.easeInCubic));
    // 왼쪽으로 이동
    slideAnimation2 =
        Tween<Offset>(begin: Offset.zero, end: const Offset(-1.0, 0.0)).animate(
            CurvedAnimation(parent: controller, curve: Curves.easeInCubic));

    controller.addListener(() {
      if (controller.isCompleted) {
        Navigator.of(context).push(PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) {
            return SecondPage();
          },
          transitionDuration: const Duration(milliseconds: 800),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            final opacityTween =
                Tween<double>(begin: 0.0, end: 1.0).animate(animation);

            return BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
              child: FadeTransition(opacity: opacityTween, child: child),
            );
          },
        ));
        controller.reverse();
      }
    });

    leftScrollController = ScrollController(keepScrollOffset: true)
      ..addListener(() {
        rightScrollController.jumpTo(leftScrollController.offset);
      });
    rightScrollController = ScrollController(keepScrollOffset: true)
      ..addListener(() {
        // leftScrollController.jumpTo(rightScrollController.offset);
      });
  }

  @override
  void dispose() {
    controller.dispose();
    leftScrollController.dispose();
    rightScrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        controller.forward();
        if (controller.isCompleted) {}
      },
      child: Scaffold(
        body: Stack(
          children: [
            AnimatedBuilder(
              animation: controller,
              builder: (context, child) {
                return SlideTransition(
                  position: slideAnimation2,
                  child: child,
                );
              },
              child: ClipPath(
                clipper: CustomClipPath1(),
                child: SingleChildScrollView(
                  physics: const ClampingScrollPhysics(),
                  controller: leftScrollController,
                  child: Center(
                    child: Column(
                      children: [
                        const SizedBox(height: 100),
                        ...List.generate(
                          30,
                          (index) => Container(
                              color: Colors.redAccent,
                              margin: EdgeInsets.only(bottom: 30),
                              child:
                                  Text('test --------- ${index.toString()}')),
                        )
                      ],
                    ),
                  ),
                ),
              ),
            ),
            AnimatedBuilder(
              animation: controller,
              builder: (context, child) {
                return SlideTransition(
                  position: slideAnimation1,
                  child: child,
                );
              },
              child: ClipPath(
                clipper: CustomClipPath2(),
                child: SingleChildScrollView(
                  controller: rightScrollController,
                  child: Center(
                    child: Column(
                      children: [
                        const SizedBox(height: 100),
                        ...List.generate(
                          30,
                          (index) => Container(
                              color: Colors.redAccent,
                              margin: EdgeInsets.only(bottom: 30),
                              child:
                                  Text('test --------- ${index.toString()}')),
                        )
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class CustomClipPath1 extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    Path path = Path()
      ..addRect(Rect.fromLTRB(0, 0, size.width / 2, size.height));

    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) {
    return true;
  }
}

class CustomClipPath2 extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    Path path = Path()
      ..addRect(Rect.fromLTRB(size.width / 2, 0, size.width, size.height));

    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) {
    return true;
  }
}

class AnimationPositionOnScroll extends StatefulWidget {
  const AnimationPositionOnScroll({Key? key}) : super(key: key);

  @override
  State<AnimationPositionOnScroll> createState() =>
      _AnimationPositionOnScrollState();
}

class _AnimationPositionOnScrollState extends State<AnimationPositionOnScroll> {
  final globalKeys = <GlobalKey>[];
  int tapIndex = 0;
  final List<String> testDataList =
      List.generate(30, (index) => index.toString());

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        tapIndex = tapIndex + 5;
        if (tapIndex > testDataList.length - 1) {
          tapIndex = testDataList.length - 1;
        }

        Scrollable.ensureVisible(
          globalKeys[tapIndex].currentContext!,
          duration: Duration(milliseconds: 600),
          curve: Curves.easeInOut,
        );
      },
      child: Scaffold(
        body: SingleChildScrollView(
          child: Column(
            children: [
              const SizedBox(height: 100),
              ..._buildQuetsionBoxs(testDataList)
            ],
          ),
        ),
      ),
    );
  }

  List<Widget> _buildQuetsionBoxs(List<String> dataList) {
    final lists = <Widget>[];

    for (var i = 0; i < dataList.length; i++) {
      final testData = dataList[i];
      globalKeys.add(GlobalKey());

      lists.add(
        CustomWidgetBox(
            globalKeys: globalKeys, widgetIndex: i, text: 'test --- $testData'),
      );
    }

    return lists;
  }
}

class CustomWidgetBox extends StatelessWidget {
  const CustomWidgetBox({
    Key? key,
    required this.widgetIndex,
    required this.globalKeys,
    required this.text,
  }) : super(key: key);
  final int widgetIndex;
  final List<GlobalKey> globalKeys;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      key: globalKeys[widgetIndex],
      margin: const EdgeInsets.only(bottom: 50),
      child: Center(
        child: Text(text),
      ),
    );
  }
}

class LikeIcon extends StatefulWidget {
  const LikeIcon({Key? key}) : super(key: key);

  @override
  State<LikeIcon> createState() => _LikeIconState();
}

class _LikeIconState extends State<LikeIcon> {
  List<Widget> realIcons = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Container(
          width: 100,
          height: 250,
          child: Stack(
            children: [
              ...realIcons,
              GestureDetector(
                onTap: () {
                  setState(() {
                    realIcons.add(IconAnimation(onAnimationFinished: () {}));
                  });
                },
                onLongPress: () {
                  setState(() {
                    realIcons.add(IconAnimation(onAnimationFinished: () {}));
                  });
                },
                child: Align(
                  alignment: Alignment.bottomCenter,
                  child: Row(
                    children: [
                      const Text('버튼 !!! '),
                      const SizedBox(width: 10),
                      Text(realIcons.length.toString()),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class IconAnimation extends StatefulWidget {
  const IconAnimation({required this.onAnimationFinished, super.key});

  final VoidCallback onAnimationFinished;

  @override
  State<IconAnimation> createState() => _IIconAnimationState();
}

class _IIconAnimationState extends State<IconAnimation>
    with SingleTickerProviderStateMixin {
  bool isVisible = true;
  final int maxX = 40;
  final int minX = -40;
  final int maxRight = 52;
  final int minRight = 50;

  late AnimationController controller;

  late Animation<double> animationX;
  late Animation<double> animationY;
  late Animation<double> scaleAnimation;
  late Animation<double> opacityAnimation;

  @override
  void initState() {
    super.initState();
    controller = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 1000));
    animationX = Tween<double>(begin: 0.0, end: 0.5)
        .animate(CurvedAnimation(parent: controller, curve: Curves.easeInOut));
    animationY = Tween<double>(begin: 0.0, end: 0.85)
        .animate(CurvedAnimation(parent: controller, curve: Curves.easeInOut));
    scaleAnimation = Tween<double>(begin: 0.85, end: 1.0)
        .animate(CurvedAnimation(parent: controller, curve: Curves.easeInOut));
    opacityAnimation = Tween<double>(begin: 1.0, end: 0.0)
        .animate(CurvedAnimation(parent: controller, curve: Curves.easeInOut));

    controller.forward();
    controller.addListener(() {
      if (controller.status == AnimationStatus.completed) {
        controller.dispose();
        setState(() {
          isVisible = false;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final animationYRange = Random().nextInt(10) + 100;
    final animationXRange = Random().nextInt(maxX - minX) + minX;
    final rightPosition =
        Random().nextInt(maxRight - minRight) + minRight.toDouble();

    return Positioned(
      right: rightPosition,
      bottom: 10,
      child: Visibility(
        visible: isVisible,
        child: AnimatedBuilder(
          animation: animationY,
          builder: (context, child) {
            return Transform.scale(
              scale: scaleAnimation.value,
              child: Transform.translate(
                offset: Offset(animationX.value * animationXRange,
                    animationY.value * -animationYRange),
                child: Opacity(opacity: opacityAnimation.value, child: child),
              ),
            );
          },
          child: const Icon(Icons.heart_broken_rounded),
        ),
      ),
    );
  }
}

class Layer3DAnimation extends StatefulWidget {
  const Layer3DAnimation({Key? key}) : super(key: key);

  @override
  State<Layer3DAnimation> createState() => _Layer3DAnimationState();
}

class _Layer3DAnimationState extends State<Layer3DAnimation>
    with SingleTickerProviderStateMixin {
  late AnimationController controller;

  late Animation<double> backgroundAnimation;
  late Animation<double> layerAnimation;
  late Animation<Offset> offsetAnimation;
  late Animation<Offset> offset2Animation;
  late Animation<Offset> offset3Animation;
  late Animation<Offset> offset4Animation;
  late Animation<Offset> offset5Animation;

  bool isCheck = false;

  @override
  void initState() {
    super.initState();
    controller = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 500));
    backgroundAnimation = Tween<double>(begin: 0.0, end: 0.85)
        .animate(CurvedAnimation(parent: controller, curve: Curves.easeInOut));
    layerAnimation = Tween<double>(begin: 0.0, end: 0.85)
        .animate(CurvedAnimation(parent: controller, curve: Curves.easeInOut));

    /// 레이어별 간격 조정 하려면 offset 값들을 조정하면 된다
    offsetAnimation = Tween<Offset>(
            begin: const Offset(0.0, 0.0), end: Offset(-50.0, -200.0))
        .animate(CurvedAnimation(parent: controller, curve: Curves.easeInOut));
    offset2Animation = Tween<Offset>(
            begin: const Offset(0.0, 0.0), end: Offset(0.0, -160.0))
        .animate(CurvedAnimation(parent: controller, curve: Curves.easeInOut));
    offset3Animation = Tween<Offset>(
            begin: const Offset(0.0, 0.0), end: Offset(50.0, -120.0))
        .animate(CurvedAnimation(parent: controller, curve: Curves.easeInOut));
    offset4Animation = Tween<Offset>(
            begin: const Offset(0.0, 0.0), end: Offset(100.0, -80.0))
        .animate(CurvedAnimation(parent: controller, curve: Curves.easeInOut));
    offset5Animation = Tween<Offset>(
            begin: const Offset(0.0, 0.0), end: Offset(150.0, -40.0))
        .animate(CurvedAnimation(parent: controller, curve: Curves.easeInOut));
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: backgroundAnimation,
      builder: (context, child) {
        return Scaffold(
          backgroundColor:
              Colors.white.withOpacity(1 - backgroundAnimation.value),
          body: child,
        );
      },
      child: Center(
        child: InkWell(
          onTap: () {
            if (!isCheck) {
              controller.forward();
            } else {
              controller.reverse();
            }
            setState(() {
              isCheck = !isCheck;
            });
          },
          child: AnimatedBuilder(
            animation: layerAnimation,
            builder: (context, child) {
              return Transform(
                  transform: Matrix4.identity()
                    ..rotateX(layerAnimation.value)
                    ..rotateZ(layerAnimation.value),
                  child: child);
            },
            child: Stack(
              children: [
                AnimatedBuilder(
                  animation: offset5Animation,
                  builder: (context, widget) {
                    return Transform.translate(
                        offset: offset5Animation.value, child: widget);
                  },
                  child: Container(
                    width: 200,
                    height: 200,
                    decoration:
                        BoxDecoration(color: Colors.transparent, boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.4),
                        blurRadius: 20,
                        spreadRadius: 2,
                      )
                    ]),
                  ),
                ),
                AnimatedBuilder(
                  animation: offset4Animation,
                  builder: (context, widget) {
                    return Transform.translate(
                        offset: offset4Animation.value, child: widget);
                  },
                  child: Container(
                    width: 200,
                    height: 200,
                    color: Colors.grey[200],
                  ),
                ),
                AnimatedBuilder(
                  animation: offset3Animation,
                  builder: (context, widget) {
                    return Transform.translate(
                        offset: offset3Animation.value, child: widget);
                  },
                  child: Container(
                    width: 200,
                    height: 200,
                    color: Colors.orange,
                  ),
                ),
                AnimatedBuilder(
                  animation: offset2Animation,
                  builder: (context, widget) {
                    return Transform.translate(
                        offset: offset2Animation.value, child: widget);
                  },
                  child: Container(
                    width: 200,
                    height: 200,
                    decoration: BoxDecoration(
                        border: Border.all(
                          color: Colors.pink,
                          width: 2,
                        ),
                        color: Colors.transparent),
                  ),
                ),
                AnimatedBuilder(
                  animation: offsetAnimation,
                  builder: (context, widget) {
                    return Transform.translate(
                        offset: offsetAnimation.value, child: widget);
                  },
                  child: Container(
                      width: 200,
                      height: 200,
                      decoration: BoxDecoration(
                          border: Border.all(
                            color: Colors.grey.shade200,
                            width: 2,
                          ),
                          color: Colors.transparent),
                      child: Center(child: Text('컬러 필터'))),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class BottomNavScreen extends StatefulWidget {
  const BottomNavScreen({required this.child, Key? key}) : super(key: key);

  final Widget child;

  @override
  State<BottomNavScreen> createState() => _BottomNavScreenState();
}

class _BottomNavScreenState extends State<BottomNavScreen> {
  static int _calculateSelectedIndex(BuildContext context) {
    final String location = GoRouterState.of(context).location;
    if (location.startsWith('/shl1')) {
      return 0;
    }
    if (location.startsWith('/shl2')) {
      return 1;
    }
    if (location.startsWith('/shl3')) {
      return 2;
    }
    return 0;
  }

  void _onItemTapped(int index, BuildContext context) {
    switch (index) {
      case 0:
        GoRouter.of(context).go('/shl1/123');
        break;
      case 1:
        GoRouter.of(context).go('/shl2/123');
        break;
      case 2:
        GoRouter.of(context).go('/shl3/123');
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: widget.child,
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'shl1 Screen',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.business),
            label: 'shl2 Screen',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.notification_important_rounded),
            label: 'shl3 Screen',
          ),
        ],
        currentIndex: _calculateSelectedIndex(context),
        onTap: (int idx) => _onItemTapped(idx, context),
      ),
    );
  }
}

class shlScreen1 extends StatelessWidget {
  const shlScreen1({required this.id, Key? key}) : super(key: key);

  final String id;

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Center(
        child: Column(
          children: [
            SizedBox(
              height: 120,
            ),
            TextButton(
                child: Text('shl1'), onPressed: () => context.push('/1/123')),
            TextButton(
                child: Text('subShl1'),
                onPressed: () => context.push('/shl1/123/subShl1/123')),
            TextButton(
                child: Text('subShl2'),
                onPressed: () => context.go('/shl1/123/subShl2/123'))
          ],
        ),
      ),
    );
  }
}

class shlScreen2 extends StatelessWidget {
  const shlScreen2({required this.id, Key? key}) : super(key: key);

  final String id;

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Center(
        child: Column(
          children: [
            SizedBox(
              height: 120,
            ),
            TextButton(
                child: Text('shl2'), onPressed: () => context.go('/1/123'))
          ],
        ),
      ),
    );
  }
}

class shlScreen3 extends StatelessWidget {
  const shlScreen3({required this.id, Key? key}) : super(key: key);

  final String id;

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Center(
        child: Column(
          children: [
            SizedBox(
              height: 120,
            ),
            TextButton(
                child: Text('shl3'), onPressed: () => context.go('/1/123'))
          ],
        ),
      ),
    );
  }
}

class subShlScreen1 extends StatelessWidget {
  const subShlScreen1({required this.id, Key? key}) : super(key: key);

  final String id;

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Center(
        child: Column(
          children: [
            SizedBox(
              height: 120,
            ),
            TextButton(
                child: Text('subShlScreen1'),
                onPressed: () => context.go('/1/123')),
            TextButton(child: Text('pop'), onPressed: () => context.pop())
          ],
        ),
      ),
    );
  }
}

class subShlScreen2 extends StatelessWidget {
  const subShlScreen2({required this.id, Key? key}) : super(key: key);

  final String id;

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Center(
        child: Column(
          children: [
            SizedBox(
              height: 120,
            ),
            TextButton(
                child: Text('subShlScreen2'),
                onPressed: () => context.go('/1/123')),
            TextButton(child: Text('pop'), onPressed: () => context.pop())
          ],
        ),
      ),
    );
  }
}

class tmpScreen1 extends StatelessWidget {
  const tmpScreen1({required this.id, this.id2, this.auth = false, Key? key})
      : super(key: key);

  final String id;
  final String? id2;
  final bool auth;

  @override
  Widget build(BuildContext context) {
    if (id2 == '123') {
      return BlocProvider<TmpBloc>(
        create: (context) => serviceLocator()
          ..add(InitTmpEvent1())
          ..add(InitTmpEvent2()),
        child: Scaffold(
          body: Container(
            child: Center(
              child: BlocBuilder<TmpBloc, TmpState>(
                builder: (context, state) {
                  final count = state.count;
                  final countList = state.countList;

                  if (auth) {
                    return Column(
                      children: [
                        SizedBox(
                          height: 120,
                        ),
                        Text(count.toString()),
                        Text('---------- auth ---------'),
                        Text('sub 2 page!!!!!!!!!!!!!!!!!!!!!!!'),
                        SizedBox(
                          height: 20,
                        ),
                        ...countList.map((e) => Text(e.toString())).toList(),
                        TextButton(
                            child: Text('++'),
                            onPressed: () =>
                                serviceLocator<TmpBloc>().add(AddCount())),
                        TextButton(
                            child: Text('--'),
                            onPressed: () =>
                                serviceLocator<TmpBloc>().add(MinusCount())),
                        TextButton(
                            child: Text('tmp1sub1'),
                            onPressed: () => context.goNamed('tmp1_sub1',
                                params: {'id': '12', 'id2': '12'})),
                        TextButton(
                            child: Text('tmp1sub2'),
                            onPressed: () => context.goNamed('tmp1_sub2',
                                params: {'id': '12', 'id2': '123'})),
                        TextButton(
                            child: Text('tmp2'),
                            onPressed: () => context.go('/2?id=123')),
                        TextButton(
                            child: Text('shl1'),
                            onPressed: () => context.go('/shl1/123')),
                        TextButton(
                            child: Text('auth'),
                            onPressed: () => context.goNamed('auth')),
                        TextButton(
                            child: Text('un auth'),
                            onPressed: () => context.goNamed('unAuth')),
                      ],
                    );
                  }

                  return Column(
                    children: [
                      SizedBox(
                        height: 120,
                      ),
                      Text(count.toString()),
                      Text('---------- unauth ---------'),
                      Text('sub 2 page!!!!!!!!!!!!!!!!!!!!!!!'),
                      SizedBox(
                        height: 20,
                      ),
                      ...countList.map((e) => Text(e.toString())).toList(),
                      TextButton(
                          child: Text('++'),
                          onPressed: () =>
                              serviceLocator<TmpBloc>().add(AddCount())),
                      TextButton(
                          child: Text('--'),
                          onPressed: () =>
                              serviceLocator<TmpBloc>().add(MinusCount())),
                      TextButton(
                          child: Text('tmp1sub1'),
                          onPressed: () => context.goNamed('tmp1_sub1',
                              params: {'id': '12', 'id2': '12'})),
                      TextButton(
                          child: Text('tmp1sub2'),
                          onPressed: () => context.goNamed('tmp1_sub2',
                              params: {'id': '12', 'id2': '123'})),
                      TextButton(
                          child: Text('tmp2'),
                          onPressed: () => context.go('/2?id=123')),
                      TextButton(
                          child: Text('shl1'),
                          onPressed: () => context.go('/shl1/123')),
                      TextButton(
                          child: Text('auth'),
                          onPressed: () => context.goNamed('auth')),
                      TextButton(
                          child: Text('un auth'),
                          onPressed: () => context.goNamed('unAuth')),
                    ],
                  );
                },
              ),
            ),
          ),
        ),
      );
    } else {
      return BlocProvider<TmpBloc>(
        create: (context) => serviceLocator()
          ..add(InitTmpEvent1())
          ..add(InitTmpEvent2()),
        child: Scaffold(
          body: Container(
            child: Center(
              child: BlocBuilder<TmpBloc, TmpState>(
                builder: (context, state) {
                  final count = state.count;
                  final countList = state.countList;

                  if (auth) {
                    return Column(
                      children: [
                        SizedBox(
                          height: 120,
                        ),
                        Text(count.toString()),
                        Text('---------- auth ---------'),
                        SizedBox(
                          height: 20,
                        ),
                        ...countList.map((e) => Text(e.toString())).toList(),
                        TextButton(
                            child: Text('++'),
                            onPressed: () =>
                                serviceLocator<TmpBloc>().add(AddCount())),
                        TextButton(
                            child: Text('--'),
                            onPressed: () =>
                                serviceLocator<TmpBloc>().add(MinusCount())),
                        TextButton(
                            child: Text('tmp1sub1'),
                            onPressed: () => context.goNamed('tmp1_sub1',
                                params: {'id': '12', 'id2': '12'})),
                        TextButton(
                            child: Text('tmp1sub2'),
                            onPressed: () => context.goNamed('tmp1_sub2',
                                params: {'id': '12', 'id2': '123'})),
                        TextButton(
                            child: Text('tmp2'),
                            onPressed: () => context.go('/2?id=123')),
                        TextButton(
                            child: Text('shl1'),
                            onPressed: () => context.go('/shl1/123')),
                        TextButton(
                            child: Text('auth'),
                            onPressed: () => context.goNamed('auth')),
                        TextButton(
                            child: Text('un auth'),
                            onPressed: () => context.goNamed('unAuth')),
                      ],
                    );
                  }

                  return Column(
                    children: [
                      SizedBox(
                        height: 120,
                      ),
                      Text('---------- unauth ---------'),
                      Text(count.toString()),
                      SizedBox(
                        height: 20,
                      ),
                      ...countList.map((e) => Text(e.toString())).toList(),
                      TextButton(
                          child: Text('++'),
                          onPressed: () =>
                              serviceLocator<TmpBloc>().add(AddCount())),
                      TextButton(
                          child: Text('--'),
                          onPressed: () =>
                              serviceLocator<TmpBloc>().add(MinusCount())),
                      TextButton(
                          child: Text('tmp1sub1'),
                          onPressed: () => context.goNamed('tmp1_sub1',
                              params: {'id': '12', 'id2': '12'})),
                      TextButton(
                          child: Text('tmp1sub2'),
                          onPressed: () => context.goNamed('tmp1_sub2',
                              params: {'id': '12', 'id2': '123'})),
                      TextButton(
                          child: Text('tmp2'),
                          onPressed: () => context.go('/2?id=123')),
                      TextButton(
                          child: Text('shl1'),
                          onPressed: () => context.go('/shl1/123')),
                      TextButton(
                          child: Text('auth'),
                          onPressed: () => context.goNamed('auth')),
                      TextButton(
                          child: Text('un auth'),
                          onPressed: () => context.goNamed('unAuth')),
                    ],
                  );
                },
              ),
            ),
          ),
        ),
      );
    }
  }
}

class tmpScreen2 extends StatelessWidget {
  const tmpScreen2({required this.id, Key? key}) : super(key: key);
  final String id;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        child: Center(
          child: Column(
            children: [
              SizedBox(
                height: 120,
              ),
              TextButton(
                  child: Text('tmp1'),
                  onPressed: () =>
                      context.goNamed('tmp1', params: {'id': '123'})),
              TextButton(
                  child: Text('tmp3'),
                  onPressed: () => context.go('/auth/1/123/3/123')),
              TextButton(
                  child: Text('tmp4'), onPressed: () => context.go('/4/123'))
            ],
          ),
        ),
      ),
    );
  }
}

class tmpScreen3 extends StatelessWidget {
  const tmpScreen3({required this.id, Key? key}) : super(key: key);
  final String id;

  @override
  Widget build(BuildContext context) {
    return BlocProvider<TmpBloc>(
      create: (context) => serviceLocator()
        ..add(InitTmpEvent1())
        ..add(InitTmpEvent2()),
      child: Scaffold(
        body: Container(
          child: Center(
            child: BlocBuilder<TmpBloc, TmpState>(
              builder: (context, state) {
                final count = state.count;
                final countList = state.countList;
                return Column(
                  children: [
                    SizedBox(
                      height: 120,
                    ),
                    Text(count.toString()),
                    SizedBox(
                      height: 20,
                    ),
                    ...countList.map((e) => Text(e.toString())).toList(),
                    TextButton(
                        child: Text('++'),
                        onPressed: () =>
                            serviceLocator<TmpBloc>().add(AddCount())),
                    TextButton(
                        child: Text('--'),
                        onPressed: () =>
                            serviceLocator<TmpBloc>().add(MinusCount())),
                    TextButton(
                        child: Text('tmp2'),
                        onPressed: () => context.push('/2?id=123')),
                    TextButton(
                        child: Text('pop'), onPressed: () => context.pop())
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}

class tmpScreen4 extends StatelessWidget {
  const tmpScreen4({required this.id, Key? key}) : super(key: key);
  final String id;

  @override
  Widget build(BuildContext context) {
    return BlocProvider<Tmp2Bloc>(
      create: (context) => serviceLocator()
        ..add(InitTmpEvent3())
        ..add(InitTmpEvent4()),
      child: Scaffold(
        body: Container(
          child: Center(
            child: BlocBuilder<Tmp2Bloc, Tmp2State>(
              builder: (context, state) {
                final count = state.count;
                final countList = state.countList;
                return Column(
                  children: [
                    SizedBox(
                      height: 120,
                    ),
                    Text(count.toString()),
                    SizedBox(
                      height: 20,
                    ),
                    ...countList.map((e) => Text(e.toString())).toList(),
                    TextButton(
                        child: Text('++'),
                        onPressed: () =>
                            serviceLocator<Tmp2Bloc>().add(AddCount2())),
                    TextButton(
                        child: Text('--'),
                        onPressed: () =>
                            serviceLocator<Tmp2Bloc>().add(MinusCount2())),
                    TextButton(
                        child: Text('tmp2'),
                        onPressed: () => context.go('/2?id=123'))
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}

class CustomPage3DContainer extends StatefulWidget {
  const CustomPage3DContainer({Key? key}) : super(key: key);

  @override
  State<CustomPage3DContainer> createState() => _CustomPage3DContainerState();
}

class _CustomPage3DContainerState extends State<CustomPage3DContainer>
    with SingleTickerProviderStateMixin {
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
          // Container(color: Color(0xFFaaa598)),
          _buildFirstContainer(),
          _buildSecondContainer(),
          _build3DText(),
        ],
      ),
    );
  }

  _buildFirstContainer() => Positioned.fill(
        top: -_extraHeight,
        bottom: -_extraHeight,
        child: AnimatedBuilder(
          animation: _animator,
          builder: (context, widget) => Transform.translate(
            offset: Offset(_maxSlide * _animator.value, 0),

            /// 이 부분이 핵심
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
                AnimatedBuilder(
                  animation: _animator,
                  builder: (_, __) => Container(
                      color: Colors.black.withOpacity(
                          _maxSlide * (_animator.value / _screen.width))),
                ),
              ],
            ),
          ),
        ),
      );

  _buildSecondContainer() => Positioned.fill(
        top: -_extraHeight,
        bottom: -_extraHeight,
        left: 0,
        right: _screen.width - _maxSlide,
        child: AnimatedBuilder(
          animation: _animator,
          builder: (context, widget) {
            return Transform.translate(
              offset: Offset(_maxSlide * (_animator.value - 1), 0),

              /// 이 부분이 핵심
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
                                    "Text",
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
                      color: Colors.black.withOpacity(
                          (1 - _maxSlide * (_animator.value / _screen.width)) -
                              0.2)),
                ),
              ],
            ),
          ),
        ),
      );

  _build3DText() => Positioned(
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
              children: <Widget>[
                Text(
                  "여기에\n텍스트를\n입력하세요",
                  style: TextStyle(
                    fontSize: 30,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                Row(
                  children: <Widget>[
                    Text(
                      "추가",
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
}

class Page3DContainer extends StatefulWidget {
  const Page3DContainer({Key? key}) : super(key: key);

  @override
  State<Page3DContainer> createState() => _Page3DContainerState();
}

class _Page3DContainerState extends State<Page3DContainer>
    with SingleTickerProviderStateMixin {
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

              final texture = await loadTexture(
                  test['Material.001'], 'assets/cube/sonyTest.mtl');
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
            loadMtl('assets/cube/sonyTest.mtl').then((val) {
              print(val);
              print(val['Material.001']);
              girl.mesh.material = val['Material.001']!;

              girl.updateTransform();
              girl.scene!.updateTexture();
            });

            final texture = await loadTexture(
                girl.mesh.material, 'assets/cube/sonyTest.mtl');
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
