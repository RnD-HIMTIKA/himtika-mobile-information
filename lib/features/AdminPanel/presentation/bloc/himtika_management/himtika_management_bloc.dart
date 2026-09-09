import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../himtika/domain/entities/himtika_kabinet.dart';
import '../../../../himtika/domain/entities/himtika_about.dart';
import '../../../../himtika/domain/entities/himtika_divisi.dart';
import '../../../../himtika/domain/entities/himtika_pengurus.dart';
import '../../../../himtika/domain/repositories/himtika_repository.dart';
import 'himtika_management_event.dart';
import 'himtika_management_state.dart';

class HimtikaManagementBloc
    extends Bloc<HimtikaManagementEvent, HimtikaManagementState> {
  final HimtikaRepository _repository;

  HimtikaManagementBloc({required HimtikaRepository repository})
      : _repository = repository,
        super(const HimtikaManagementState()) {
    on<FetchHimtikaAdminData>(_onFetchHimtikaAdminData);
    on<UpdateKabinetEvent>(_onUpdateKabinet);
    on<UpdateAboutEvent>(_onUpdateAbout);
    on<CreateDivisiEvent>(_onCreateDivisi);
    on<UpdateDivisiEvent>(_onUpdateDivisi);
    on<DeleteDivisiEvent>(_onDeleteDivisi);
    on<CreatePengurusEvent>(_onCreatePengurus);
    on<UpdatePengurusEvent>(_onUpdatePengurus);
    on<DeletePengurusEvent>(_onDeletePengurus);
    on<SelectDivisiFilterEvent>(_onSelectDivisiFilter);
  }

  Future<void> _onFetchHimtikaAdminData(
    FetchHimtikaAdminData event,
    Emitter<HimtikaManagementState> emit,
  ) async {
    emit(state.copyWith(status: HimtikaManagementStatus.loading));
    try {
      final results = await Future.wait([
        _repository.getActiveKabinet(),
        _repository.getAboutInfo(),
        _repository.getDivisiList(),
        _repository.getAllPengurus(),
      ]);

      final kabinet = results[0] as HimtikaKabinet?;
      final about = results[1] as HimtikaAbout?;
      final divisiList = results[2] as List<HimtikaDivisi>;
      final pengurusList = results[3] as List<HimtikaPengurus>;

      String? selectedId = state.selectedDivisiId;
      if ((selectedId == null || selectedId.isEmpty) && divisiList.isNotEmpty) {
        selectedId = divisiList.first.id;
      }

      emit(state.copyWith(
        status: HimtikaManagementStatus.success,
        kabinet: kabinet,
        about: about,
        divisiList: divisiList,
        pengurusList: pengurusList,
        selectedDivisiId: selectedId,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: HimtikaManagementStatus.failure,
        errorMessage: e.toString().replaceFirst('Exception: ', ''),
      ));
    }
  }

  Future<void> _onUpdateKabinet(
    UpdateKabinetEvent event,
    Emitter<HimtikaManagementState> emit,
  ) async {
    emit(state.copyWith(isSubmitting: true));
    try {
      String? logoUrl = event.kabinet.logoUrl;
      if (event.logoFile != null) {
        logoUrl = await _repository.uploadImage(
          file: event.logoFile!,
          bucketName: 'himtika-assets',
          pathPrefix: 'kabinet',
        );
      }

      final updatedKabinet = event.kabinet.copyWith(logoUrl: logoUrl);
      await _repository.updateKabinet(updatedKabinet);
      final refreshedKabinet = await _repository.getActiveKabinet();

      emit(state.copyWith(
        kabinet: refreshedKabinet ?? updatedKabinet,
        isSubmitting: false,
        successMessage: 'Berhasil mengedit informasi Kabinet!',
      ));
    } catch (e) {
      emit(state.copyWith(
        isSubmitting: false,
        errorMessage: 'Gagal memperbarui kabinet: ${e.toString().replaceFirst('Exception: ', '')}',
      ));
    }
  }

  Future<void> _onUpdateAbout(
    UpdateAboutEvent event,
    Emitter<HimtikaManagementState> emit,
  ) async {
    emit(state.copyWith(isSubmitting: true));
    try {
      await _repository.updateAboutInfo(event.about);
      final refreshedAbout = await _repository.getAboutInfo();

      emit(state.copyWith(
        about: refreshedAbout ?? event.about,
        isSubmitting: false,
        successMessage: 'Berhasil mengedit Visi, Misi, dan Sejarah!',
      ));
    } catch (e) {
      emit(state.copyWith(
        isSubmitting: false,
        errorMessage: 'Gagal memperbarui informasi organisasi: ${e.toString().replaceFirst('Exception: ', '')}',
      ));
    }
  }

  Future<void> _onCreateDivisi(
    CreateDivisiEvent event,
    Emitter<HimtikaManagementState> emit,
  ) async {
    emit(state.copyWith(isSubmitting: true));
    try {
      String? logoUrl = event.divisi.logoUrl;
      if (event.logoFile != null) {
        logoUrl = await _repository.uploadImage(
          file: event.logoFile!,
          bucketName: 'division_logos',
          pathPrefix: 'divisi',
        );
      }

      final divisiToCreate = event.divisi.copyWith(logoUrl: logoUrl);
      await _repository.createDivisi(divisiToCreate);

      final updatedDivisiList = await _repository.getDivisiList();
      String? selectedId = state.selectedDivisiId;
      if (selectedId == null || selectedId.isEmpty) {
        selectedId = updatedDivisiList.isNotEmpty ? updatedDivisiList.first.id : null;
      }

      emit(state.copyWith(
        divisiList: updatedDivisiList,
        selectedDivisiId: selectedId,
        isSubmitting: false,
        successMessage: 'Divisi baru berhasil ditambahkan!',
      ));
    } catch (e) {
      emit(state.copyWith(
        isSubmitting: false,
        errorMessage: 'Gagal menambah divisi: ${e.toString().replaceFirst('Exception: ', '')}',
      ));
    }
  }

  Future<void> _onUpdateDivisi(
    UpdateDivisiEvent event,
    Emitter<HimtikaManagementState> emit,
  ) async {
    emit(state.copyWith(isSubmitting: true));
    try {
      String? logoUrl = event.divisi.logoUrl;
      if (event.logoFile != null) {
        logoUrl = await _repository.uploadImage(
          file: event.logoFile!,
          bucketName: 'division_logos',
          pathPrefix: 'divisi',
        );
      }

      final divisiToUpdate = event.divisi.copyWith(logoUrl: logoUrl);
      await _repository.updateDivisi(divisiToUpdate);

      final updatedDivisiList = await _repository.getDivisiList();

      emit(state.copyWith(
        divisiList: updatedDivisiList,
        isSubmitting: false,
        successMessage: 'Informasi divisi berhasil diperbarui!',
      ));
    } catch (e) {
      emit(state.copyWith(
        isSubmitting: false,
        errorMessage: 'Gagal memperbarui divisi: ${e.toString().replaceFirst('Exception: ', '')}',
      ));
    }
  }

  Future<void> _onDeleteDivisi(
    DeleteDivisiEvent event,
    Emitter<HimtikaManagementState> emit,
  ) async {
    emit(state.copyWith(isSubmitting: true));
    try {
      await _repository.deleteDivisi(event.divisiId);

      final updatedDivisiList = await _repository.getDivisiList();
      final updatedPengurusList = await _repository.getAllPengurus();

      String? selectedId = state.selectedDivisiId;
      if (selectedId == event.divisiId) {
        selectedId = updatedDivisiList.isNotEmpty ? updatedDivisiList.first.id : null;
      }

      emit(state.copyWith(
        divisiList: updatedDivisiList,
        pengurusList: updatedPengurusList,
        selectedDivisiId: selectedId,
        isSubmitting: false,
        successMessage: 'Divisi berhasil dihapus!',
      ));
    } catch (e) {
      emit(state.copyWith(
        isSubmitting: false,
        errorMessage: 'Gagal menghapus divisi: ${e.toString().replaceFirst('Exception: ', '')}',
      ));
    }
  }

  Future<void> _onCreatePengurus(
    CreatePengurusEvent event,
    Emitter<HimtikaManagementState> emit,
  ) async {
    emit(state.copyWith(isSubmitting: true));
    try {
      String? fotoUrl = event.pengurus.fotoUrl;
      if (event.fotoFile != null) {
        fotoUrl = await _repository.uploadImage(
          file: event.fotoFile!,
          bucketName: 'himtika-assets',
          pathPrefix: 'pengurus',
        );
      }

      final pengurusToCreate = event.pengurus.copyWith(fotoUrl: fotoUrl);
      await _repository.createPengurus(pengurusToCreate);

      final updatedPengurusList = await _repository.getAllPengurus();

      emit(state.copyWith(
        pengurusList: updatedPengurusList,
        isSubmitting: false,
        successMessage: 'Anggota pengurus baru berhasil ditambahkan!',
      ));
    } catch (e) {
      emit(state.copyWith(
        isSubmitting: false,
        errorMessage: 'Gagal menambah pengurus: ${e.toString().replaceFirst('Exception: ', '')}',
      ));
    }
  }

  Future<void> _onUpdatePengurus(
    UpdatePengurusEvent event,
    Emitter<HimtikaManagementState> emit,
  ) async {
    emit(state.copyWith(isSubmitting: true));
    try {
      String? fotoUrl = event.pengurus.fotoUrl;
      if (event.fotoFile != null) {
        fotoUrl = await _repository.uploadImage(
          file: event.fotoFile!,
          bucketName: 'himtika-assets',
          pathPrefix: 'pengurus',
        );
      }

      final pengurusToUpdate = event.pengurus.copyWith(fotoUrl: fotoUrl);
      await _repository.updatePengurus(pengurusToUpdate);

      final updatedPengurusList = await _repository.getAllPengurus();

      emit(state.copyWith(
        pengurusList: updatedPengurusList,
        isSubmitting: false,
        successMessage: 'Data pengurus berhasil diperbarui!',
      ));
    } catch (e) {
      emit(state.copyWith(
        isSubmitting: false,
        errorMessage: 'Gagal memperbarui pengurus: ${e.toString().replaceFirst('Exception: ', '')}',
      ));
    }
  }

  Future<void> _onDeletePengurus(
    DeletePengurusEvent event,
    Emitter<HimtikaManagementState> emit,
  ) async {
    emit(state.copyWith(isSubmitting: true));
    try {
      await _repository.deletePengurus(event.pengurusId);

      final updatedPengurusList = await _repository.getAllPengurus();

      emit(state.copyWith(
        pengurusList: updatedPengurusList,
        isSubmitting: false,
        successMessage: 'Anggota pengurus berhasil dihapus!',
      ));
    } catch (e) {
      emit(state.copyWith(
        isSubmitting: false,
        errorMessage: 'Gagal menghapus pengurus: ${e.toString().replaceFirst('Exception: ', '')}',
      ));
    }
  }

  Future<void> _onSelectDivisiFilter(
    SelectDivisiFilterEvent event,
    Emitter<HimtikaManagementState> emit,
  ) async {
    emit(state.copyWith(selectedDivisiId: event.divisiId));
  }
}
