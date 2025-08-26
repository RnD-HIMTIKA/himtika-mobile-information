part of 'category_management_bloc.dart';

abstract class CategoryManagementEvent extends Equatable {
  const CategoryManagementEvent();
  @override
  List<Object?> get props => [];
}

class LoadCategories extends CategoryManagementEvent {}

class AddCategorySubmitted extends CategoryManagementEvent {
  final String name;
  // PERBAIKAN: Ganti iconUrl menjadi iconFile
  final File iconFile; 
  const AddCategorySubmitted({required this.name, required this.iconFile});
  @override
  List<Object?> get props => [name, iconFile];
}

class UpdateCategorySubmitted extends CategoryManagementEvent {
  final String id;
  final String name;
  // PERBAIKAN: iconFile sekarang opsional (nullable)
  final File? iconFile; 
  const UpdateCategorySubmitted({required this.id, required this.name, this.iconFile});
  @override
  List<Object?> get props => [id, name, iconFile];
}

class DeleteCategoryPressed extends CategoryManagementEvent {
  final String id;
  const DeleteCategoryPressed({required this.id});
  @override
  List<Object?> get props => [id];
}