import 'dart:math';
import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:test_ui_project/screen/login_ui_screen.dart';
import 'package:test_ui_project/screen/tab_switching_view.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: Scaffold(
        // Scaffold의 body나 floating button이 가려지는 것을 막기위해 스스로 크기를 조절하고 모두 보이게 할지를 결정하는 프로퍼티
        resizeToAvoidBottomInset: true,
        body: CustomListView(),
        drawer: Drawer(),
      ),
    );
  }
}

class CustomListView extends StatefulWidget {
  CustomListView({Key? key}) : super(key: key);

  @override
  State<CustomListView> createState() => _CustomListViewState();
}

class _CustomListViewState extends State<CustomListView> {
  List<int> testList = List.generate(20, (index) => index);

  final TextEditingController textEditingController = TextEditingController();

  final GlobalKey<FormState> formKey = GlobalKey();

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).requestFocus(FocusNode());
      },
      child: SingleChildScrollView(
        keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
        child: Form(
              // form의 컨트롤러처럼 작용하는 formKey
              key: formKey,
              autovalidateMode: AutovalidateMode.onUserInteraction,
              child: Column(
                children: [
                  ElevatedButton(
                      onPressed: () {
                        // formKey는 생성을 했는데 Form 위젯과 결합을 안했을 때
                        if (formKey.currentState == null) {
                          return;
                        }
                        if (formKey.currentState!.validate()) {
                          formKey.currentState!.save();

                          print('저장되었습니다');
                          FocusScope.of(context).unfocus();
                        } else {}
                      },
                      child: Text('저장하기')),
                  ConstrainedBox(
                    constraints: BoxConstraints.loose(Size(500, 100)),
                    child: TextFormField(
                      controller: textEditingController,
                      // null이 return 되면 에러가 없다.
                      // 에러가 있으면 에러를 String 값으로 리턴한다.
                      validator: (String? val) {
                        if (textEditingController.text.trim().isEmpty) {
                          return '값을 입력해주세요';
                        }
                        return null;
                      },
                      // 초기값 세팅하기
                      initialValue: null,
                      // 저장하기 - 상위 Form 에서 save 함수가 호출될 때 하위 onSaved 가 실행됨
                      onSaved: (String? val) {
                        print('저장됨 - $val');
                        textEditingController.clear();
                      },
                      // 기본 키보드 타입 바꾸기
                      keyboardType: TextInputType.multiline,
                      // 인풋 내용 필터링
                      inputFormatters: [
                        FilteringTextInputFormatter.singleLineFormatter
                      ],
                      // 글자 제한
                      maxLength: 300,
                      maxLines: null,
                      // 텍스트 필드 세로로 최대한으로 늘이기
                      expands: true,
                      cursorColor: Colors.grey,
                      decoration: InputDecoration(
                        border: InputBorder.none,
                        filled: true,
                        fillColor: Colors.grey[300],
                        // 접미사 글자
                        suffixText: ' 접미사',
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
