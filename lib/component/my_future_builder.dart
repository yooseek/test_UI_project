import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class MyFutureBuilder<T extends Object> extends StatelessWidget {
  const MyFutureBuilder({required this.future, required this.builder, Key? key})
      : super(key: key);

  final Future<T>? future;
  final Widget Function(BuildContext context, T data) builder;

  @override
  Widget build(BuildContext context) => FutureBuilder<T>(
    future: future,
    builder: (context, snapshot) {
      if (snapshot.connectionState == ConnectionState.waiting) {
        return Scaffold(
          appBar: AppBar(title: const Text('Loading...')),
          body: const Center(child: CircularProgressIndicator()),
        );
      }

      if (snapshot.hasError) {
        return Scaffold(
          appBar: AppBar(title: const Text('Error')),
          body: Center(child: Text(snapshot.error!.toString())),
        );
      }

      assert(snapshot.hasData);
      return builder(context, snapshot.data!);
    },
  );
}