part of 'hicode_bloc.dart';

enum HicodeStatus { initial, loading, success, failure }

class HicodeState extends Equatable {
  const HicodeState({
    this.status = HicodeStatus.initial,
    this.categories = const <Map<String, dynamic>>[],
    this.materials = const <Map<String, dynamic>>[],
  });

  final HicodeStatus status;
  final List<Map<String, dynamic>> categories;
  final List<Map<String, dynamic>> materials;

  HicodeState copyWith({
    HicodeStatus? status,
    List<Map<String, dynamic>>? categories,
    List<Map<String, dynamic>>? materials,
  }) {
    return HicodeState(
      status: status ?? this.status,
      categories: categories ?? this.categories,
      materials: materials ?? this.materials,
    );
  }

  @override
  List<Object> get props => [status, categories, materials];
}