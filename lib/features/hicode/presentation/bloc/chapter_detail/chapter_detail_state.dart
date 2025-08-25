part of 'chapter_detail_bloc.dart';

enum MaterialDetailStatus { initial, loading, success, failure }

class MaterialDetailState extends Equatable {
  const MaterialDetailState({
    this.status = MaterialDetailStatus.initial,
    this.title,
    this.description,
    this.subChapters = const [],
    this.finalExamStatus,
    this.materialIconPath,
    this.searchQuery = '', // TAMBAHKAN INI
    this.filteredSubChapters = const [], // TAMBAHKAN INI
  });

  final MaterialDetailStatus status;
  final String? title;
  final String? description;
  final List<Map<String, dynamic>> subChapters;
  final Map<String, dynamic>? finalExamStatus;
  final String? materialIconPath;
  final String searchQuery; // Properti baru untuk teks pencarian
  final List<Map<String, dynamic>> filteredSubChapters; // Properti baru untuk hasil filter

  MaterialDetailState copyWith({
    MaterialDetailStatus? status,
    String? title,
    String? description,
    List<Map<String, dynamic>>? subChapters,
    Map<String, dynamic>? finalExamStatus,
    String? materialIconPath,
    String? searchQuery, // TAMBAHKAN INI
    List<Map<String, dynamic>>? filteredSubChapters, // TAMBAHKAN INI
  }) {
    return MaterialDetailState(
      status: status ?? this.status,
      title: title ?? this.title,
      description: description ?? this.description,
      subChapters: subChapters ?? this.subChapters,
      finalExamStatus: finalExamStatus ?? this.finalExamStatus,
      materialIconPath: materialIconPath ?? this.materialIconPath,
      searchQuery: searchQuery ?? this.searchQuery,
      filteredSubChapters: filteredSubChapters ?? this.filteredSubChapters,
    );
  }

  @override
  List<Object?> get props => [
        status,
        title,
        description,
        subChapters,
        finalExamStatus,
        materialIconPath,
        searchQuery, // TAMBAHKAN INI
        filteredSubChapters, // TAMBAHKAN INI
      ];
}