import 'package:flutter/cupertino.dart';
import 'package:test_ui_project/models/thing.dart';

@immutable
class Person extends Thing{
  final int age;

  const Person({
    required this.age,
    required super.name,
  });

  @override
  String toString() {
    return 'Animal{name : $name, type: $age}';
  }

  Map<String, dynamic> toMap() {
    return {
      'name': super.name,
      'type': this.age,
    };
  }

  factory Person.fromJson(Map<String, dynamic> map) {
    return Person(
      name: map['name'] as String,
      age: map['age'] as int,
    );
  }
}