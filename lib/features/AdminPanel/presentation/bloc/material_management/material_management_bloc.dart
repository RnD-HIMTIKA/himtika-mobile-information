import 'dart:io';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:himtika_mobile_information/features/AdminPanel/domain/entities/admin_hicode_material.dart';
import 'package:himtika_mobile_information/features/AdminPanel/domain/usecases/hicode/create_hicode_material.dart';
import 'package:himtika_mobile_information/features/AdminPanel/domain/usecases/hicode/get_admin_hicode_materials.dart';
import 'package:himtika_mobile_information/features/AdminPanel/domain/usecases/hicode/get_hicode_categories.dart';
// --- TAMBAHKAN IMPORT ---
import 'package:himtika_mobile_information/features/AdminPanel/domain/usecases/hicode/delete_hicode_material.dart';
import 'package:himtika_mobile_information/features/AdminPanel/domain/usecases/hicode/update_hicode_material.dart';
// --- AKHIR TAMBAHAN ---
import 'package:himtika_mobile_information/features/hicode/domain/entities/hicode_category.dart';

part 'material_management_event.dart';
part 'material_management_state.dart';

class MaterialManagementBloc
    extends Bloc<MaterialManagementEvent, MaterialManagementState> {
  final GetAdminHiCodeMaterials _getAdminHiCodeMaterials;
  final CreateHiCodeMaterial _createHiCodeMaterial;
  final GetHiCodeCategories _getHiCodeCategories;
  final DeleteHiCodeMaterial _deleteHiCodeMaterial; // <-- TAMBAHKAN
  final UpdateHiCodeMaterial _updateHiCodeMaterial; // <-- TAMBAHKAN

  MaterialManagementBloc({
    required GetAdminHiCodeMaterials getAdminHiCodeMaterials,
    required CreateHiCodeMaterial createHiCodeMaterial,
    required GetHiCodeCategories getHiCodeCategories,
    required DeleteHiCodeMaterial deleteHiCodeMaterial, // <-- TAMBAHKAN
    required UpdateHiCodeMaterial updateHiCodeMaterial, // <-- TAMBAHKAN
  })  : _getAdminHiCodeMaterials = getAdminHiCodeMaterials,
        _createHiCodeMaterial = createHiCodeMaterial,
        _getHiCodeCategories = getHiCodeCategories,
        _deleteHiCodeMaterial = deleteHiCodeMaterial, // <-- TAMBAHKAN
        _updateHiCodeMaterial = updateHiCodeMaterial, // <-- TAMBAHKAN
        super(const MaterialManagementState()) {
    on<LoadAdminMaterials>(_onLoadAdminMaterials);
    on<AddMaterialSubmitted>(_onAddMaterial);
    on<DeleteMaterialPressed>(_onDeleteMaterial); // <-- DAFTARKAN
    on<UpdateMaterialSubmitted>(_onUpdateMaterial); // <-- DAFTARKAN
  }

  Future<void> _onLoadAdminMaterials(
      LoadAdminMaterials event, Emitter<MaterialManagementState> emit) async {
    emit(state.copyWith(status: MaterialManagementStatus.loading));
    try {
      final materialsFuture = _getAdminHiCodeMaterials();
      final categoriesFuture = _getHiCodeCategories();

      final results = await Future.wait([materialsFuture, categoriesFuture]);

      final materials = results[0] as List<AdminHiCodeMaterial>;
      final categories = results[1] as List<HiCodeCategory>;

      emit(state.copyWith(
        status: MaterialManagementStatus.success,
        materials: materials,
        categories: categories,
      ));
    } catch (e) {
      emit(state.copyWith(
          status: MaterialManagementStatus.failure, errorMessage: e.toString()));
    }
  }

  Future<void> _onAddMaterial(
      AddMaterialSubmitted event, Emitter<MaterialManagementState> emit) async {
    emit(state.copyWith(status: MaterialManagementStatus.loading));
    try {
      await _createHiCodeMaterial(
        categoryId: event.categoryId,
        title: event.title,
        description: event.description,
        imageFile: event.imageFile,
        borderColor: event.borderColor,
      );
      add(LoadAdminMaterials()); // Muat ulang daftar setelah berhasil
    } catch (e) {
      emit(state.copyWith(
          status: MaterialManagementStatus.failure,
          errorMessage: e.toString().replaceFirst('Exception: ', '')));
      // Kembali ke success agar UI tidak stuck di loading
      emit(state.copyWith(status: MaterialManagementStatus.success));
    }
  }

  // --- HANDLER BARU UNTUK DELETE ---
  Future<void> _onDeleteMaterial(
      DeleteMaterialPressed event, Emitter<MaterialManagementState> emit) async {
    emit(state.copyWith(status: MaterialManagementStatus.loading));
    try {
      await _deleteHiCodeMaterial(id: event.id);
      add(LoadAdminMaterials()); 
    } catch (e) {
      emit(state.copyWith(
        status: MaterialManagementStatus.failure,
        errorMessage: e.toString().replaceFirst('Exception: ', ''),
      ));
      emit(state.copyWith(status: MaterialManagementStatus.success));
    }
  }

  // --- HANDLER BARU UNTUK UPDATE ---
  Future<void> _onUpdateMaterial(
      UpdateMaterialSubmitted event, Emitter<MaterialManagementState> emit) async {
    emit(state.copyWith(status: MaterialManagementStatus.loading));
    try {
      await _updateHiCodeMaterial(
        id: event.id,
        categoryId: event.categoryId,
        title: event.title,
        description: event.description,
        imageFile: event.imageFile,
        borderColor: event.borderColor,
      );
      add(LoadAdminMaterials()); 
    } catch (e) {
      emit(state.copyWith(
        status: MaterialManagementStatus.failure,
        errorMessage: e.toString().replaceFirst('Exception: ', ''),
      ));
      emit(state.copyWith(status: MaterialManagementStatus.success));
    }
  }
}