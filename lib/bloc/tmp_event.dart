part of 'tmp_bloc.dart';

@immutable
abstract class TmpEvent {
  const TmpEvent();
}

class InitTmpEvent1 extends TmpEvent{}
class InitTmpEvent2 extends TmpEvent{}

class AddCount extends TmpEvent{}

class MinusCount extends TmpEvent{}
class ChangeTmpEvent extends TmpEvent{
  final int? count;
  final List<int>? countList;

  const ChangeTmpEvent({
    this.count,
    this.countList,
  });
}