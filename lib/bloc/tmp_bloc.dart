import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';
import 'package:test_ui_project/repository/tmp_repo.dart';

part 'tmp_event.dart';

part 'tmp_state.dart';

class TmpBloc extends Bloc<TmpEvent, TmpState> {
  final TmpRepository tmpRepository;

  TmpBloc({required this.tmpRepository})
      : super(const TmpState(count: 0, countList: [])) {
    on<InitTmpEvent1>(_onInitTmpEvent1);
    on<InitTmpEvent2>(_onInitTmpEvent2);
    on<AddCount>(_onAddCount);
    on<MinusCount>(_onMinusCount);
    on<ChangeTmpEvent>(_onChangeTmpEvent);
  }

  FutureOr<void> _onInitTmpEvent1(event,Emitter<TmpState> emit) async {
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

  FutureOr<void> _onInitTmpEvent2(event,Emitter<TmpState> emit) async {
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

  FutureOr<void> _onChangeTmpEvent(ChangeTmpEvent event, emit) {
    emit(state.copyWith(count: event.count, countList: event.countList));
  }

  @override
  Future<void> close() {
    return super.close();
  }
}
