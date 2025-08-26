part of 'category_management_bloc.dart';

enum CategoryManagementStatus { initial, loading, success, failure }

class CategoryManagementState extends Equatable {
  final CategoryManagementStatus status;
  final List<HiCodeCategory> categories;
  final String? errorMessage;

  const CategoryManagementState({
    this.status = CategoryManagementStatus.initial,
    this.categories = const [],
    this.errorMessage,
  });

  CategoryManagementState copyWith({
    CategoryManagementStatus? status,
    List<HiCodeCategory>? categories,
    String? errorMessage,
  }) {
    return CategoryManagementState(
      status: status ?? this.status,
      categories: categories ?? this.categories,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [status, categories, errorMessage];
}