// Lokasi: lib/hicode/presentation/bloc/hicode_state.dart

part of 'hicode_bloc.dart';

enum HicodeStatus { initial, loading, success, failure }

class HicodeState extends Equatable {
  const HicodeState({
    this.status = HicodeStatus.initial,
    this.categories = const <Map<String, dynamic>>[],
    this.materials = const <Map<String, dynamic>>[],
    this.isExamReady = false, // 1. Tambahkan properti baru dengan nilai default 'false'
  });

  final HicodeStatus status;
  final List<Map<String, dynamic>> categories;
  final List<Map<String, dynamic>> materials;
  final bool isExamReady; // Properti baru

  HicodeState copyWith({
    HicodeStatus? status,
    List<Map<String, dynamic>>? categories,
    List<Map<String, dynamic>>? materials,
    bool? isExamReady, // 2. Tambahkan di copyWith
  }) {
    return HicodeState(
      status: status ?? this.status,
      categories: categories ?? this.categories,
      materials: materials ?? this.materials,
      isExamReady: isExamReady ?? this.isExamReady, // Tambahkan di sini
    );
  }

  @override
  List<Object> get props => [status, categories, materials, isExamReady]; // 3. Tambahkan di props
}