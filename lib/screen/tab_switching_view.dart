import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:test_ui_project/component/animation/fade_animation_route_button.dart';
import 'package:test_ui_project/component/animation/fade_animation_widget.dart';
import 'package:test_ui_project/component/animation/interval_fade_animation_list.dart';
import 'package:test_ui_project/component/animation/rotate_animation_widget.dart';
import 'package:test_ui_project/component/animation/simple_rotate_animation_widget.dart';
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
                      child: const Text('???????????????'),
                    ),
                  ),
                  const FadeAnimationRouteButton(
                    buttonChildWidget: Text('????????? ??????'),
                    nextScreen: PageTwoScreen(),
                  ),
                  const SlideAnimationRouteButton(
                    buttonChildWidget: Text('???????????? ??????'),
                    nextScreen: PageTwoScreen(),
                    duration: 3,
                  ),
                  ElevatedButton(onPressed: (){
                    Navigator.of(context).push(MaterialPageRoute(builder: (_) => PageTwoScreen()));
                  }, child: Text('????????? ???'))
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
        title: Text('????????? ???'),
      ),
      body: Container(
        color: Colors.white,
        child: Center(
          child: SingleChildScrollView(

            child: PageTwoText()
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
          Text('????????? ?????????'),
          SlideAnimationWidget(child: Text('???????????? ???????????????')),
          FadeAnimationWidget(child: Text('????????? ???????????????')),
          IntervalSlideAnimationWidget(childs: [
            Text('1??? ???????????????'),
            Text('2??? ???????????????'),
            Text('3??? ???????????????'),
          ],duration: 5,),
          IntervalFadeAnimationWidget(childs: [
            Text('1??? ???????????????'),
            Text('2??? ???????????????'),
            Text('3??? ???????????????'),
          ],duration: 5,),
          TextAnimationWidget(text: '????????? ??????????????? ?????????',duration: 5),
          RotateAnimationWidget(text: '???????????? ??????????????? ???????????????.',duration: 2,),
          SimpleRotateAnimationWidget(child: Text('?????? ??????????????? ?????????.')),
        ],
      ),
    );
  }
}
