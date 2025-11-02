part of 'material_management_bloc.dart';

abstract class MaterialManagementEvent extends Equatable {
  const MaterialManagementEvent();
  @override
  List<Object?> get props => [];
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
  List<Object?> get props => [categoryId, title, description, imageFile, borderColor];
}

// --- TAMBAHKAN EVENT BARU INI ---
class UpdateMaterialSubmitted extends MaterialManagementEvent {
  final String id;
  final String categoryId;
  final String title;
  final String description;
  final File? imageFile; // Opsional
  final String borderColor;

  const UpdateMaterialSubmitted({
    required this.id,
    required this.categoryId,
    required this.title,
    required this.description,
    this.imageFile,
    required this.borderColor,
  });

  @override
  List<Object?> get props => [id, categoryId, title, description, imageFile, borderColor];
}
// --- AKHIR TAMBAHAN ---

// --- TAMBAHKAN EVENT BARU INI ---
class DeleteMaterialPressed extends MaterialManagementEvent {
  final String id;
  const DeleteMaterialPressed({required this.id});

  @override
  List<Object?> get props => [id];
}
// --- AKHIR TAMBAHAN ---