part of 'tmp2_bloc.dart';

abstract class Tmp2Event {
  const Tmp2Event();
}

class InitTmpEvent3 extends Tmp2Event{}
class InitTmpEvent4 extends Tmp2Event{}

class AddCount2 extends Tmp2Event{}

class MinusCount2 extends Tmp2Event{}
class ChangeTmpEvent2 extends Tmp2Event{
  final int? count;
  final List<int>? countList;

  const ChangeTmpEvent2({
    this.count,
    this.countList,
  });
}