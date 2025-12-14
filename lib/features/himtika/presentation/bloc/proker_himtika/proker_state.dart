part of 'proker_bloc.dart';

enum ProkerStatus { initial, loading, success, failure }

class ProkerState extends Equatable {
  final ProkerStatus status;
  final String heroImagePath;
  final String description;
  final List<String> categories;
  final String selectedCategory;
  // Struktur data: List of Maps (Setiap map berisi 'dept' dan 'programs')
  final List<Map<String, dynamic>> filteredProkerList;

  const ProkerState({
    this.status = ProkerStatus.initial,
    this.heroImagePath = '',
    this.description = '',
    this.categories = const [],
    this.selectedCategory = '',
    this.filteredProkerList = const [],
  });

  ProkerState copyWith({
    ProkerStatus? status,
    String? heroImagePath,
    String? description,
    List<String>? categories,
    String? selectedCategory,
    List<Map<String, dynamic>>? filteredProkerList,
  }) {
    return ProkerState(
      status: status ?? this.status,
      heroImagePath: heroImagePath ?? this.heroImagePath,
      description: description ?? this.description,
      categories: categories ?? this.categories,
      selectedCategory: selectedCategory ?? this.selectedCategory,
      filteredProkerList: filteredProkerList ?? this.filteredProkerList,
    );
  }

  @override
  List<Object> get props => [
        status,
        heroImagePath,
        description,
        categories,
        selectedCategory,
        filteredProkerList
      ];
}
