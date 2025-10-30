part of 'himtika_bloc.dart';

enum HimtikaStatus { initial, loading, success, failure }

class HimtikaState extends Equatable {
  const HimtikaState({
    this.status = HimtikaStatus.initial,
    this.importantParts = const [],
  });

  final HimtikaStatus status;
  final List<Map<String, String>> importantParts;

  HimtikaState copyWith({
    HimtikaStatus? status,
    List<Map<String, String>>? importantParts,
  }) {
    return HimtikaState(
      status: status ?? this.status,
      importantParts: importantParts ?? this.importantParts,
    );
  }

  @override
  List<Object> get props => [status, importantParts];
}