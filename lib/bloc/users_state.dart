part of 'users_bloc.dart';

class UsersState{
   List<User> users;

   UsersState({required this.users});

  factory UsersState.init() {
    return UsersState(users: []);
  }

  UsersState copyWith({
    List<User>? users,
  }) {
    return UsersState(
      users: users ?? this.users,
    );
  }
}

class User {
  final int id;
  final String name;

  const User({
    required this.id,
    required this.name,
  });
}