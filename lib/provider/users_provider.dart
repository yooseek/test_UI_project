import 'package:flutter/cupertino.dart';
import 'package:test_ui_project/bloc/users_bloc.dart';

class UsersProvider with ChangeNotifier {
  List<User> users;

  UsersProvider({
    required this.users,
  });

  void addUser(User user) {
    users.add(user);

    notifyListeners();
  }
}

class TestMixin {
  const TestMixin();
}