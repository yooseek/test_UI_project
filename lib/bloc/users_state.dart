part of 'users_bloc.dart';

class UsersState extends Equatable {
  final List<User> users;

  const UsersState({required this.users});

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

  @override
  List<Object> get props => [users];

}

class User {
  final int id;
  final String name;

  const User({
    required this.id,
    required this.name,
  });
}