import 'dart:convert';
import 'dart:io';

import 'package:test_ui_project/models/animal.dart';
import 'package:test_ui_project/models/person.dart';

import '../models/thing.dart';

class Api {
  List<Person>? _persons;
  List<Animal>? _animals;

  Future<List<Thing>> search(String searchTerm) async {
    final term = searchTerm.trim().toLowerCase();

    final cacheResults = _extractThingUsingSearchTerm(term);
    if(cacheResults != null) {
      return cacheResults;
    }
    final persons = await _getJson('http://127.0.0.1:5500/apis/person.json')
    .then((value) => value.map((e) => Person.fromJson(e)));
    _persons = persons.toList();

    final animals = await _getJson('http://127.0.0.1:5500/apis/animals.json')
        .then((value) => value.map((e) => Animal.fromJson(e)));
    _animals = animals.toList();

    return _extractThingUsingSearchTerm(term) ?? [];
  }


  List<Thing>? _extractThingUsingSearchTerm(String term) {
    final cachedAnimal = _animals;
    final cachedPerson = _persons;
    if(cachedAnimal != null && cachedPerson != null) {
      List<Thing> result = [];
      for(final animal in cachedAnimal) {
        if(animal.name.trimmedContains(term)) {
          result.add(animal);
        }
      }
      for(final person in cachedPerson) {
        if(person.name.trimmedContains(term)) {
          result.add(person);
        }
      }
      return result;
    }else{
      return null;
    }
  }

  Api();

  Future<List<dynamic>> _getJson(String url) async {
    return HttpClient().getUrl(Uri.parse(url))
        .then((value) => value.close())
    .then((response) => response.transform(utf8.decoder).join())
    .then((jsonString) => json.decode(jsonString) as List<dynamic>);
  }
}

extension TrimmedCaseInsensitiveContain on String {
  bool trimmedContains(String other) => trim().toLowerCase().contains(other.trim().toLowerCase());
}