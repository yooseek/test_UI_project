import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:test_ui_project/component/animation/fade_animation_widget.dart';
import 'package:collection/collection.dart' as collection;

class BackDropScreen extends StatelessWidget {
  const BackDropScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            TopContent(
              child: ClipRRect(
                borderRadius: BorderRadius.only(
                    topRight:
                        Radius.elliptical(size.width / 2, size.height / 2)),
                child: Hero(
                    tag: 'hi',
                    child: Image.asset('assets/images/screen_shot0.png')),
              ),
            ),
            BottomList(
              topPadding: 500,
              childList: List.generate(100, (index) => index),
              deviceSize: size,
            ),
          ],
        ),
      ),
    );
  }
}

class TopContent extends StatelessWidget {
  final Widget child;

  const TopContent({required this.child, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return child;
  }
}

class BottomList extends StatefulWidget {
  final double topPadding;
  final List childList;
  final Size deviceSize;

  const BottomList({
    required this.topPadding,
    required this.childList,
    required this.deviceSize,
    Key? key,
  }) : super(key: key);

  @override
  State<BottomList> createState() => _BottomListState();
}

class _BottomListState extends State<BottomList> {
  late final ScrollController _scroller = ScrollController()
    ..addListener(_handleScrollChanged);
  final _scrollPos = ValueNotifier(0.0);
  bool isBackdropFilter = true;

  void _handleScrollChanged() {
    _scrollPos.value = _scroller.position.pixels;
  }

  @override
  void dispose() {
    _scroller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PopRouterOnOverScroll(
      controller: _scroller,
      child: LayoutBuilder(builder: (_, constraints) {
        return AnimatedBuilder(
          animation: _scroller,
          builder: (_, __) {
            bool showBackdrop = true;
            double backdropAmt = 0;
            if (_scroller.hasClients) {
              double blurStart = 50;
              double maxScroll = 150;
              double scrollPx = _scroller.position.pixels - blurStart;
              // Normalize scroll position to a value between 0 and 1
              backdropAmt =
                  (_scroller.position.pixels - blurStart).clamp(0, maxScroll) /
                      maxScroll;
              // Disable backdrop once it is offscreen for an easy perf win
              showBackdrop =
                  (scrollPx + (widget.deviceSize.height - widget.topPadding) <=
                      widget.deviceSize.height);
            }
            return Stack(
              children: [
                if (showBackdrop) ...[
                  AppBackdrop(
                    strength: backdropAmt,
                    child: IgnorePointer(
                      child: Container(
                        color: Colors.grey.withOpacity(backdropAmt * .6),
                      ),
                    ),
                  ),
                ],
                disableByScroll(),
                _bottomListContent(),
              ],
            );
          },
        );
      }),
    );
  }

  // ???????????? ????????? ???????????? ??????
  ValueListenableBuilder<double> disableByScroll() {
    return ValueListenableBuilder<double>(
      valueListenable: _scrollPos,
      builder: (_, value, child) {
        // get some value between 0 and 1, based on the amt scrolled
        double opacity = (1 - value / 150).clamp(0, 1);
        return Opacity(opacity: opacity, child: child);
      },
      child: Container(
        height: 50,
        width: 50,
        color: Colors.teal,
      ),
    );
  }

  Widget _bottomListContent() {
    Container buildHandle() {
      return Container(
        width: 35,
        height: 5,
        decoration: BoxDecoration(
            color: Colors.grey, borderRadius: BorderRadius.circular(99)),
      );
    }

    final listItems = <Widget>[];
    for (var e in widget.childList) {
      listItems.add(
        FadeAnimationWidget(
          duration: 2,
          child: Container(
            width: double.infinity,
            child: Text(
              e.toString(),
              style: TextStyle(fontSize: 18.0),
            ),
          ),
        ),
      );
    }

    return SingleChildScrollView(
      controller: _scroller,
      physics: const BouncingScrollPhysics(),
      child: Column(
        children: [
          IgnorePointer(
            child: Container(
              height: widget.topPadding,
            ),
          ),
          Container(
            decoration: BoxDecoration(
              color: Colors.green,
              borderRadius: BorderRadius.circular(20),
            ),
            padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            child: Column(
              children: [buildHandle(), ...listItems],
            ),
          ),
        ],
      ),
    );
  }
}

class PopRouterOnOverScroll extends StatefulWidget {
  const PopRouterOnOverScroll(
      {Key? key, required this.child, required this.controller})
      : super(key: key);
  final ScrollController controller;
  final Widget child;

  @override
  State<PopRouterOnOverScroll> createState() => _PopRouterOnOverScrollState();
}

class _PopRouterOnOverScrollState extends State<PopRouterOnOverScroll> {
  final _scrollToPopThreshold = 70;
  bool _isPointerDown = false;

  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_handleScrollChanged);
  }

  @override
  void didUpdateWidget(covariant PopRouterOnOverScroll oldWidget) {
    if (widget.controller != oldWidget.controller) {
      widget.controller.addListener(_handleScrollChanged);
    }
    super.didUpdateWidget(oldWidget);
  }

  bool _checkPointerIsDown(d) => _isPointerDown = d.dragDetails != null;

  @override
  Widget build(BuildContext context) {
    return NotificationListener<ScrollUpdateNotification>(
      onNotification: _checkPointerIsDown,
      child: widget.child,
    );
  }

  void _handleScrollChanged() {
    // If user pulls far down on the elastic list, pop back to
    final px = widget.controller.position.pixels;
    if (px < -_scrollToPopThreshold) {
      if (_isPointerDown) {
        Navigator.of(context).pop();
        widget.controller.removeListener(_handleScrollChanged);
      }
    }
  }
}

class AppBackdrop extends StatelessWidget {
  const AppBackdrop({
    Key? key,
    this.strength = 1,
    this.child,
  }) : super(key: key);

  final double strength;
  final Widget? child;

  @override
  Widget build(BuildContext context) {
    final double normalStrength = strength.clamp(0, 1);

    return BackdropFilter(
      filter: ImageFilter.blur(
          sigmaX: normalStrength * 5.0, sigmaY: normalStrength * 5.0),
      child: child ?? const SizedBox.expand(),
    );
  }

}
