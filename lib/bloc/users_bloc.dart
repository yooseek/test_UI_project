import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

part 'users_event.dart';
part 'users_state.dart';

class UsersBloc extends Bloc<UsersEvent, UsersState> {
  UsersBloc() : super(UsersState.init()) {
    on<AddUserEvent>(_onAddUserEvent);
  }

  Future<void> _onAddUserEvent (AddUserEvent event, Emitter emit) async {
    // final currentUsers = state.users..add(event.user);

    final currentUsers = [...state.users, event.user];

    print(currentUsers);

    emit(state.copyWith(users: currentUsers));
  }
}
