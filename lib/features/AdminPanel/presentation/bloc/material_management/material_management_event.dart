part of 'material_management_bloc.dart';

abstract class MaterialManagementEvent extends Equatable {
  const MaterialManagementEvent();
  @override
  List<Object> get props => [];
}

class LoadAdminMaterials extends MaterialManagementEvent {}

class AddMaterialSubmitted extends MaterialManagementEvent {
  final String categoryId;
  final String title;
  final String description;
  final File imageFile;
  final String borderColor;

  const AddMaterialSubmitted({
    required this.categoryId,
    required this.title,
    required this.description,
    required this.imageFile,
    required this.borderColor,
  });

  @override
  List<Object> get props => [categoryId, title, description, imageFile, borderColor];
}