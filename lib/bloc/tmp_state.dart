part of 'tmp_bloc.dart';

@immutable
class TmpState extends Equatable {
  final int count;
  final List<int> countList;

  const TmpState({
    required this.count,
    required this.countList,
  });

  TmpState copyWith({
    int? count,
    List<int>? countList,
  }) {
    return TmpState(
      count: count ?? this.count,
      countList: countList ?? this.countList,
    );
  }

  @override
  List<Object> get props => [count, countList];
}

