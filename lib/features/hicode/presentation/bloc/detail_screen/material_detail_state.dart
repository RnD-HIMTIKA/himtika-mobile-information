part of 'material_detail_bloc.dart';

enum MaterialDetailStatus { initial, loading, success, failure }

class MaterialDetailState extends Equatable {
  const MaterialDetailState({
    this.status = MaterialDetailStatus.initial,
    this.title,
    this.description,
    this.subChapters = const [],
    this.finalExamStatus,
    this.materialIconPath, // 1. Tambahkan properti baru
  });

  final MaterialDetailStatus status;
  final String? title;
  final String? description;
  final List<Map<String, dynamic>> subChapters;
  final Map<String, dynamic>? finalExamStatus;
  final String? materialIconPath; // Properti baru

  MaterialDetailState copyWith({
    MaterialDetailStatus? status,
    String? title,
    String? description,
    List<Map<String, dynamic>>? subChapters,
    Map<String, dynamic>? finalExamStatus,
    String? materialIconPath, // 2. Tambahkan di copyWith
  }) {
    return MaterialDetailState(
      status: status ?? this.status,
      title: title ?? this.title,
      description: description ?? this.description,
      subChapters: subChapters ?? this.subChapters,
      finalExamStatus: finalExamStatus ?? this.finalExamStatus,
      materialIconPath: materialIconPath ?? this.materialIconPath, // Tambahkan di sini
    );
  }

  @override
  List<Object?> get props => [
        status,
        title,
        description,
        subChapters,
        finalExamStatus,
        materialIconPath // 3. Tambahkan di props
      ];
}