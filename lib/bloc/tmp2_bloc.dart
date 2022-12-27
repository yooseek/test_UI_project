import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:test_ui_project/repository/tmp_repo.dart';

part 'tmp2_event.dart';
part 'tmp2_state.dart';

mixin BaseState<T> {
  T get initial;
}

class BaseBloc<E,S extends BaseState> extends Bloc<E,S> {
  BaseBloc(S) : super(S);
}

class Tmp2Bloc extends BaseBloc<Tmp2Event,Tmp2State> {
  final TmpRepository tmpRepository;

  Tmp2Bloc({required this.tmpRepository})
      : super(const Tmp2State(count: 0, countList: [])) {
    on<InitTmpEvent3>(_onInitTmpEvent1);
    on<InitTmpEvent4>(_onInitTmpEvent2);
    on<AddCount2>(_onAddCount);
    on<MinusCount2>(_onMinusCount);
    on<ChangeTmpEvent2>(_onChangeTmpEvent);
  }

  FutureOr<void> _onInitTmpEvent1(event,Emitter<Tmp2State> emit) async {
    await emit.onEach(
      tmpRepository.getCountList,
      onData: (countList) {
        if(countList is List<int>?){
          emit(state.copyWith(countList: countList));
        }
      },
      onError: (_, __) {
        print('getCountList 에러 밟생!');
      },
    );
  }

  FutureOr<void> _onInitTmpEvent2(event,Emitter<Tmp2State> emit) async {
    await emit.onEach(
      tmpRepository.getCount,
      onData: (count) {
        if(count is int?){
          emit(state.copyWith(count: count));
        }
      },
      onError: (_, __) {
        print('getCount 에러 밟생!');
      },
    );
  }

  FutureOr<void> _onAddCount(event, emit) {
    tmpRepository.addAllCountList();
  }

  FutureOr<void> _onMinusCount(event, emit) {
    tmpRepository.minusAllCountList();
  }

  FutureOr<void> _onChangeTmpEvent(ChangeTmpEvent2 event, emit) {
    emit(state.copyWith(count: event.count, countList: event.countList));
  }

  @override
  Future<void> close() {
    return super.close();
  }
}
