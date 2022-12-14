part of 'tmp2_bloc.dart';

class Tmp2State extends Equatable with BaseState<Tmp2State> {
  final int count;
  final List<int> countList;

  const Tmp2State({
    required this.count,
    required this.countList,
  });

  Tmp2State copyWith({
    int? count,
    List<int>? countList,
  }) {
    return Tmp2State(
      count: count ?? this.count,
      countList: countList ?? this.countList,
    );
  }

  @override
  List<Object> get props => [count, countList];

  @override
  Tmp2State get initial => const Tmp2State(count: 0,countList: []);
}