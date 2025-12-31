import 'package:equatable/equatable.dart';
// Import model Lecturer kamu
import '../../data/models/lecturer_model.dart';

class LecturerState extends Equatable {
  final String selectedCategory;
  final String searchQuery;
  final List<Lecturer> filteredLecturers;

  const LecturerState({
    this.selectedCategory = "Semua", // Default "Semua"
    this.searchQuery = "",
    this.filteredLecturers = const [], // Default kosong dulu
  });

  // CopyWith: Teknik update state tanpa menghapus data lama yg gak berubah
  LecturerState copyWith({
    String? selectedCategory,
    String? searchQuery,
    List<Lecturer>? filteredLecturers,
  }) {
    return LecturerState(
      selectedCategory: selectedCategory ?? this.selectedCategory,
      searchQuery: searchQuery ?? this.searchQuery,
      filteredLecturers: filteredLecturers ?? this.filteredLecturers,
    );
  }

  @override
  List<Object> get props => [selectedCategory, filteredLecturers];
}
