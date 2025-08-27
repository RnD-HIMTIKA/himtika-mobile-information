part of 'material_management_bloc.dart';

enum MaterialManagementStatus { initial, loading, success, failure }

class MaterialManagementState extends Equatable {
  final MaterialManagementStatus status;
  final List<AdminHiCodeMaterial> materials;
  final List<HiCodeCategory> categories; // <-- TAMBAHKAN INI
  final String? errorMessage;

  const MaterialManagementState({
    this.status = MaterialManagementStatus.initial,
    this.materials = const [],
    this.categories = const [], // <-- TAMBAHKAN INI
    this.errorMessage,
  });

  MaterialManagementState copyWith({
    MaterialManagementStatus? status,
    List<AdminHiCodeMaterial>? materials,
    List<HiCodeCategory>? categories, // <-- TAMBAHKAN INI
    String? errorMessage,
  }) {
    return MaterialManagementState(
      status: status ?? this.status,
      materials: materials ?? this.materials,
      categories: categories ?? this.categories, // <-- TAMBAHKAN INI
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [status, materials, categories, errorMessage];
}