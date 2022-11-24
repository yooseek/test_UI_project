import 'dart:async';
import 'dart:isolate';
import 'dart:math';
import 'dart:ui' hide Path;

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:provider/provider.dart';
import 'package:rxdart/rxdart.dart';
import 'package:test_ui_project/bloc/users_bloc.dart';
import 'package:test_ui_project/mixin/stf_mixin.dart';
import 'package:test_ui_project/models/band.dart';
import 'package:test_ui_project/provider/socket_provider.dart';
import 'package:test_ui_project/provider/users_provider.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        BlocProvider(create: (context) => UsersBloc()),
        ChangeNotifierProvider(create: (context) => UsersProvider(users: [])),
      ],
      child: MaterialApp(
        theme: ThemeData(useMaterial3: true),
        home: UsersScreen(),
      ),
    );
  }
}

class UsersScreen extends StatelessWidget {
  const UsersScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<UsersBloc, UsersState>(
      builder: (context, state) {
        final users = Provider.of<UsersProvider>(context,listen: true).users;
        final usersProvider = Provider.of<UsersProvider>(context);

        print(usersProvider.users);
        usersProvider.users = [];
        print(usersProvider.users);

        return Scaffold(
          body: Center(
                child: SingleChildScrollView(
              child: Column(
                children: [
                  for (int i = 0; i < state.users.length; i++)
                    ListTile(
                      title: Text(state.users[i].name),
                    ),
                  for (int i = 0; i < users.length; i++)
                    ListTile(
                      title: Text(users[i].name),
                    ),
                  ElevatedButton(
                      onPressed: () {
                        BlocProvider.of<UsersBloc>(context)
                            .add(AddUserEvent(user: User(id: 1, name: 'User - bloc')));
                      },
                      child: Text('Input User - Bloc')),
                  ElevatedButton(
                      onPressed: () {
                        Provider.of<UsersProvider>(context,listen: false).addUser(User(id: 2, name: 'User - provider'));
                      },
                      child: Text('Input User - Provider')),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class PageScreen extends StatefulWidget {
  const PageScreen({Key? key}) : super(key: key);

  @override
  State<PageScreen> createState() => _PageScreenState();
}

class _PageScreenState extends State<PageScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController controller;

  @override
  void initState() {
    super.initState();
    controller =
        AnimationController(vsync: this, duration: Duration(seconds: 1));

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
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            height: 300,
            width: 300,
            color: Colors.blue,
            child: CustomPaint(
              painter: AnimatedPathPainter(controller),
            ),
          ),
        ],
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

    final path = new Path();

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

    /// 이곳에 커스텀 ClipPath 작성
    return Path()
      ..lineTo(0, h * 0.3)
      ..quadraticBezierTo(w * 0.3, h * 0.7, w * 0.6, h * 0.4)
      ..quadraticBezierTo(w * 0.8, h * 0.7, w, h)
      ..lineTo(w, 0)
      ..lineTo(0, 0);
  }

  @override
  void paint(Canvas canvas, Size size) {
    final animationPercent = _animation.value;

    final path = createAnimatedPath(_createAnyPath(size), animationPercent);

    final Paint paint = Paint();
    paint.color = Colors.amberAccent;
    paint.style = PaintingStyle.stroke;
    paint.strokeWidth = 10.0;

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}

class CustomClipPath extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    double w = size.width;
    double h = size.height;

    final path = Path();

    // 1번 점 (0,0)
    // path.lineTo(0, h); // 2번 점 (0,h)
    // path.quadraticBezierTo(w * 0.5, h - 100, w, h); // 3번점(w*0.5,h-100) 호 그리기
    // path.lineTo(w, h); // 4번 점 (w,h)
    // path.lineTo(w, 0); // 5번 점 (w,0)
    // path.close(); // 선그리기 종료
    //
    // // 1번 점 (0,0)
    // path.lineTo(0, h-100); // 2번 점 (0,h)
    // path.quadraticBezierTo(w * 0.5, h, w, h-100); // 3번점(w*0.5,h) 호 그리기
    // path.lineTo(w, h); // 4번 점 (w,h)
    // path.lineTo(w, 0); // 5번 점 (w,0)
    // path.close(); // 선그리기 종료

    path.moveTo(0, h * 0.1);
    path.lineTo(0, h / 2);
    path.cubicTo(w * 0.5, h, w * 0.7, h * 0.6, w, h);
    path.lineTo(w, 0);

    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) {
    return true;
  }
}

class SocketScreen extends StatelessWidget {
  const SocketScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final socketService = Provider.of<SocketProvider>(context);
    // socketService.socket.emit(event);

    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(
          child: SizedBox(
            height: 200,
          ),
        ),
        SliverToBoxAdapter(
            child: ServerStatusWidget(socketService: socketService)),
        SliverToBoxAdapter(child: EmitWidget(socketService: socketService)),
        PayloadListWidget(),
      ],
    );
  }
}

class PayloadListWidget extends StatefulWidget {
  const PayloadListWidget({
    Key? key,
  }) : super(key: key);

  @override
  State<PayloadListWidget> createState() => _PayloadListWidgetState();
}

class _PayloadListWidgetState extends State<PayloadListWidget> {
  List<Band> bands = [];

  @override
  Widget build(BuildContext context) {
    final socketService = Provider.of<SocketProvider>(context);

    return SliverList(
      delegate: SliverChildBuilderDelegate(
        childCount: bands.length,
        (context, index) {
          return Dismissible(
            key: Key(bands[index].id),
            onDismissed: (direction) {
              socketService.socket.emit('delete-band', {'id': bands[index].id});
            },
            child: ListTile(
              onTap: () {
                socketService.socket.emit('vote-band', {'id': bands[index].id});
              },
              title: Text(bands[index].name),
              trailing: Text(bands[index].votes.toString()),
            ),
          );
        },
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    final socketService = Provider.of<SocketProvider>(context, listen: false);
    socketService.socket.on('active-bands', (payload) {
      bands = (payload as List).map((e) => Band.fromMap(e)).toList();
      setState(() {});
    });
  }

  @override
  void dispose() {
    super.dispose();
    final socketService = Provider.of<SocketProvider>(context, listen: false);
    socketService.socket.off('active-bands');
  }
}

class EmitWidget extends StatefulWidget {
  const EmitWidget({
    Key? key,
    required this.socketService,
  }) : super(key: key);

  final SocketProvider socketService;

  @override
  State<EmitWidget> createState() => _EmitWidgetState();
}

class _EmitWidgetState extends State<EmitWidget> {
  final TextEditingController textEditingController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      child: TextField(
        controller: textEditingController,
        onSubmitted: (String value) {
          // widget.socketService.emit('emitir-mensaje', {'name': value});
          widget.socketService.emit('add-band', {'name': value});
          textEditingController.clear();
        },
      ),
    );
  }
}

class ServerStatusWidget extends StatelessWidget {
  const ServerStatusWidget({
    Key? key,
    required this.socketService,
  }) : super(key: key);

  final SocketProvider socketService;

  @override
  Widget build(BuildContext context) {
    return socketService.serverStatus == ServiceStatus.online
        ? const CircleAvatar(
            backgroundColor: Colors.transparent,
            child: Icon(
              Icons.gpp_good,
              color: Colors.greenAccent,
              size: 28.0,
            ),
          )
        : const CircleAvatar(
            backgroundColor: Colors.transparent,
            child: Icon(
              Icons.error,
              color: Colors.redAccent,
              size: 28.0,
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
          child: Text('앱바'),
        ),
        title: ValueListenableBuilder<double>(
          valueListenable: _scrollPos,
          builder: (_, value, child) {
            // get some value between 0 and 1, based on the amt scrolled
            double opacity = (1 - value / 150).clamp(0, 1);
            return Opacity(opacity: opacity, child: child);
          },
          child: Text('타이틀입니다'),
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
                      child: Text('버튼')),
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
                  ignoring: false,
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
            // AbsorbPointer(
            //   child: Container(
            //     height: 500,
            //   ),
            // ),
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
    await Future.delayed(Duration(seconds: 2));
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
