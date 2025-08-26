import 'dart:io';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:himtika_mobile_information/features/AdminPanel/domain/usecases/hicode/create_hicode_category.dart';
import 'package:himtika_mobile_information/features/AdminPanel/domain/usecases/hicode/delete_hicode_category.dart';
import 'package:himtika_mobile_information/features/AdminPanel/domain/usecases/hicode/get_hicode_categories.dart';
import 'package:himtika_mobile_information/features/AdminPanel/domain/usecases/hicode/update_hicode_category.dart';
import 'package:himtika_mobile_information/features/hicode/domain/entities/hicode_category.dart';

part 'category_management_event.dart';
part 'category_management_state.dart';

class CategoryManagementBloc extends Bloc<CategoryManagementEvent, CategoryManagementState> {
  final GetHiCodeCategories _getCategories;
  final CreateHiCodeCategory _createCategory;
  final UpdateHiCodeCategory _updateCategory;
  final DeleteHiCodeCategory _deleteCategory;

  CategoryManagementBloc({
    required GetHiCodeCategories getCategories,
    required CreateHiCodeCategory createCategory,
    required UpdateHiCodeCategory updateCategory,
    required DeleteHiCodeCategory deleteCategory,
  })  : _getCategories = getCategories,
        _createCategory = createCategory,
        _updateCategory = updateCategory,
        _deleteCategory = deleteCategory,
        super(const CategoryManagementState()) {
    on<LoadCategories>(_onLoadCategories);
    on<AddCategorySubmitted>(_onAddCategory);
    on<UpdateCategorySubmitted>(_onUpdateCategory);
    on<DeleteCategoryPressed>(_onDeleteCategory);
  }

  Future<void> _onLoadCategories(
      LoadCategories event, Emitter<CategoryManagementState> emit) async {
    emit(state.copyWith(status: CategoryManagementStatus.loading));
    try {
      final categories = await _getCategories();
      emit(state.copyWith(status: CategoryManagementStatus.success, categories: categories));
    } catch (e) {
      emit(state.copyWith(status: CategoryManagementStatus.failure, errorMessage: e.toString()));
    }
  }

  Future<void> _onAddCategory(
      AddCategorySubmitted event, Emitter<CategoryManagementState> emit) async {
    emit(state.copyWith(status: CategoryManagementStatus.loading));
    try {
      // PERBAIKAN: Panggil use case dengan parameter yang benar
      await _createCategory(name: event.name, iconFile: event.iconFile);
      add(LoadCategories());
    } catch (e) {
      emit(state.copyWith(status: CategoryManagementStatus.failure, errorMessage: e.toString()));
    }
  }

  Future<void> _onUpdateCategory(
      UpdateCategorySubmitted event, Emitter<CategoryManagementState> emit) async {
    emit(state.copyWith(status: CategoryManagementStatus.loading));
    try {
      // PERBAIKAN: Panggil use case dengan parameter yang benar
      await _updateCategory(id: event.id, name: event.name, iconFile: event.iconFile);
      add(LoadCategories());
    } catch (e) {
      emit(state.copyWith(status: CategoryManagementStatus.failure, errorMessage: e.toString()));
    }
  }

  Future<void> _onDeleteCategory(
      DeleteCategoryPressed event, Emitter<CategoryManagementState> emit) async {
    emit(state.copyWith(status: CategoryManagementStatus.loading));
    try {
      await _deleteCategory(id: event.id);
      add(LoadCategories());
    } catch (e) {
      emit(state.copyWith(status: CategoryManagementStatus.failure, errorMessage: e.toString()));
    }
  }
}