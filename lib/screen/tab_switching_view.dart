import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:test_ui_project/component/animation/fade_animation_route_button.dart';
import 'package:test_ui_project/component/animation/fade_animation_widget.dart';
import 'package:test_ui_project/component/animation/interval_fade_animation_list.dart';
import 'package:test_ui_project/component/animation/rotate_animation_widget.dart';
import 'package:test_ui_project/component/animation/text_animation_widget.dart';
import 'package:test_ui_project/component/animation/interval_slide_animation_list.dart';
import 'package:test_ui_project/component/animation/slide_animation_widget.dart';
import 'package:test_ui_project/component/animation/slide_animation_route_button.dart';
import 'package:test_ui_project/component/tab_switching_view.dart';

class TabSwitching extends StatefulWidget {
  const TabSwitching({Key? key}) : super(key: key);

  @override
  State<TabSwitching> createState() => _TabSwitchingState();
}

class _TabSwitchingState extends State<TabSwitching>{
  int pageIndex = 0;

  @override
  Widget build(BuildContext context) {
    print('TabSwitching build');
    return TabSwitchingView(
        currentTabIndex: pageIndex,
        tabCount: 4,
        tabBuilder: (context, index) {
          return Container(
            color: pageIndex == 0
                ? Colors.red
                : pageIndex == 1
                    ? Colors.blue
                    : Colors.orange,
            child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Center(
                    child: ElevatedButton(
                      onPressed: () {
                        setState(() {
                          pageIndex++;
                          if (pageIndex > 3) {
                            pageIndex = 0;
                          }
                        });
                      },
                      child: const Text('다음페이지'),
                    ),
                  ),
                  const FadeAnimationRouteButton(
                    buttonChildWidget: Text('페이드 버튼'),
                    nextScreen: PageTwoScreen(),
                  ),
                  const SlideAnimationRouteButton(
                    buttonChildWidget: Text('슬라이드 버튼'),
                    nextScreen: PageTwoScreen(),
                    duration: 5,
                  ),
                  ElevatedButton(onPressed: (){
                    Navigator.of(context).push(MaterialPageRoute(builder: (_) => PageTwoScreen()));
                  }, child: Text('페이지 투'))
                ],
              ),
            );
        });
  }
}

class PageTwoScreen extends StatelessWidget {
  const PageTwoScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('페이지 투'),
      ),
      body: Container(
        color: Colors.white,
        child: Center(
          child: Column(
            children: [
              Text(
                '페이지 투투투투투',
                style: TextStyle(fontSize: 30.0, color: Colors.blue),
              ),
              PageTwoText(),
            ],
          ),
        ),
      ),
    );
  }
}

class PageTwoText extends StatelessWidget {
  const PageTwoText({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: const [
          Text('페이지 투투투'),
          SlideAnimationWidget(child: Text('슬라이드 애니메이션')),
          FadeAnimationWidget(child: Text('페이드 애니메이션')),
          IntervalSlideAnimationWidget(childs: [
            Text('1번 애니메이션'),
            Text('2번 애니메이션'),
            Text('3번 애니메이션'),
          ],duration: 5,),
          IntervalFadeAnimationWidget(childs: [
            Text('1번 애니메이션'),
            Text('2번 애니메이션'),
            Text('3번 애니메이션'),
          ],duration: 5,),
          TextAnimationWidget(text: '텍스트 애니메이션 입니다',duration: 5),
          RotateAnimationWidget(text: '로테이션 애니메이션 위젯입니다.',duration: 2,)
        ],
      ),
    );
  }
}
