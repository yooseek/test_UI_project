import 'package:rxdart/rxdart.dart';

abstract class TmpRepository {
  Stream<int> get getCount;
  Stream<List<int>> get getCountList;
  Future<void> addAllCountList();
  Future<void> minusAllCountList();
}

class TmpRepositoryImpl implements TmpRepository{
  TmpRepositoryImpl() {
    countObserve = BehaviorSubject.seeded(0);
    countListObserve = BehaviorSubject.seeded([0]);
  }

  late final BehaviorSubject<int> countObserve;
  late final BehaviorSubject<List<int>> countListObserve;

  @override
  Stream<int> get getCount => countObserve.stream;
  Sink<int> get _setCount => countObserve.sink;

  @override
  Stream<List<int>> get getCountList => countListObserve.stream;
  Sink<List<int>> get _setCountList => countListObserve.sink;

  @override
  Future<void> addAllCountList() async {
    _setCount.add(++countObserve.value);
    _setCountList.add([...countListObserve.value, countObserve.value]);
  }

  @override
  Future<void> minusAllCountList() async {
    _setCount.add(--countObserve.value);
    _setCountList.add([...countListObserve.value, countObserve.value]);
  }
}