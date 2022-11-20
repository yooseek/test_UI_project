part of 'users_bloc.dart';

abstract class UsersEvent extends Equatable {
  const UsersEvent();
}

class AddUserEvent extends UsersEvent {
  final User user;

  const AddUserEvent({
    required this.user,
  });

  @override
  List<Object> get props => [user];
}