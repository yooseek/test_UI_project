import 'package:flutter/cupertino.dart';
import 'package:test_ui_project/models/thing.dart';

enum AnimalType {
  dog, cat, rabbit, unknown
}

@immutable
class Animal extends Thing{
  final AnimalType type;

  const Animal({
    required this.type,
    required super.name,
  });


  @override
  String toString() {
    return 'Animal{name : $name, type: $type}';
  }

  Map<String, dynamic> toMap() {
    return {
      'name': super.name,
      'type': this.type,
    };
  }

  factory Animal.fromJson(Map<String, dynamic> map) {
    return Animal(
      name: map['name'] as String,
      type: map['type'] as AnimalType,
    );
  }
}