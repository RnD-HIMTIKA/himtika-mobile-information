import 'dart:async';
import 'package:sentry_flutter/sentry_flutter.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:himtika_mobile_information/core/blocs/connectivity_bloc.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import '../../../domain/entities/workspace_with_members.dart';
import '../../../domain/usecases/create_workspace.dart';
import '../../../domain/repositories/calendar_repository.dart';
import '../../../domain/usecases/update_workspace.dart';
import '../../../domain/usecases/delete_workspace.dart';
import '../../../domain/usecases/update_member_role.dart';

part 'workspace_event.dart';
part 'workspace_state.dart';

class WorkspaceBloc extends Bloc<WorkspaceEvent, WorkspaceState> {
  final CalendarRepository _calendarRepository;
  final CreateWorkspace _createWorkspace;
  final UpdateWorkspace _updateWorkspace;
  final DeleteWorkspace _deleteWorkspace;
  final UpdateMemberRole _updateMemberRole;

  final ConnectivityBloc _connectivityBloc;
  StreamSubscription? _connectivitySubscription;
  bool _wasOffline = false;

  WorkspaceBloc({
    required CalendarRepository calendarRepository,
    required CreateWorkspace createWorkspace,
    required UpdateWorkspace updateWorkspace,
    required DeleteWorkspace deleteWorkspace,
    required UpdateMemberRole updateMemberRole,
    required ConnectivityBloc connectivityBloc,
  })  : _calendarRepository = calendarRepository,
        _createWorkspace = createWorkspace,
        _updateWorkspace = updateWorkspace,
        _deleteWorkspace = deleteWorkspace,
        _updateMemberRole = updateMemberRole,
        _connectivityBloc = connectivityBloc,
        super(const WorkspaceState()) {
    on<LoadMyWorkspaces>(_onLoadMyWorkspaces);
    on<CreateWorkspaceSubmitted>(_onCreateWorkspaceSubmitted);
    on<UpdateWorkspaceSubmitted>(_onUpdateWorkspaceSubmitted);
    on<DeleteWorkspacePressed>(_onDeleteWorkspacePressed);
    on<UpdateMemberRolePressed>(_onUpdateMemberRolePressed);

    _listenToConnectivity();
  }

  void _listenToConnectivity() {
    // Cek status awal
    if (_connectivityBloc.state.result == ConnectivityResult.none) {
      _wasOffline = true;
    }

    _connectivitySubscription = _connectivityBloc.stream.listen((connectivityState) {
      final isOnline = connectivityState.result != ConnectivityResult.none;
      if (isOnline && _wasOffline) {
        print("--- [WorkspaceBloc] Kembali Online, memuat ulang workspaces... ---");
        add(LoadMyWorkspaces()); // Panggil event refresh
      }
      _wasOffline = !isOnline;
    });
  }

  // --- 8. Tambahkan dispose ---
  @override
  Future<void> close() {
    _connectivitySubscription?.cancel();
    return super.close();
  }

  Future<void> _onLoadMyWorkspaces(
    LoadMyWorkspaces event,
    Emitter<WorkspaceState> emit,
  ) async {
    emit(state.copyWith(status: WorkspaceStatus.loading));
    try {
      // PASTIKAN METODE YANG DIPANGGIL ADALAH getMyWorkspacesWithMembers()
      final workspaces = await _calendarRepository.getMyWorkspacesWithMembers();

      workspaces.sort((a, b) {
        if (a.workspace.title == 'Agenda Himtika') return -1; // 'a' (Agenda Himtika) harus di depan
        if (b.workspace.title == 'Agenda Himtika') return 1;  // 'b' (Agenda Himtika) harus di depan
        // Jika bukan Agenda Himtika, urutkan berdasarkan tanggal dibuat
        return b.workspace.lastUpdated!.compareTo(a.workspace.lastUpdated!);
      });
      
      emit(state.copyWith(
        status: WorkspaceStatus.loaded,
        workspaces: workspaces,
      ));
    } catch (e, stackTrace) { // <-- UBAH
      // 1. Log Licik
      Sentry.captureException(e, stackTrace: stackTrace);
      // 2. Pesan Profesional
      String message = "Gagal memuat workspace.";
      if (e.toString().toLowerCase().contains('socket')) {
        message = "Koneksi gagal. Periksa internet Anda.";
      }
      emit(state.copyWith(
        status: WorkspaceStatus.failure,
        errorMessage: message, // <-- Pesan profesional
      ));
    }
  }

  // Handler untuk membuat workspace
  Future<void> _onCreateWorkspaceSubmitted(
    CreateWorkspaceSubmitted event,
    Emitter<WorkspaceState> emit,
  ) async {
    try {
      await _createWorkspace(title: event.title, description: event.description);
      add(LoadMyWorkspaces());
    } catch (e, stackTrace) { // <-- UBAH
      // 1. Log Licik
      Sentry.captureException(e, stackTrace: stackTrace);
      // 2. Pesan Profesional
      String message = e.toString().replaceFirst('Exception: ', '');
      if (e.toString().toLowerCase().contains('socket')) {
        message = "Koneksi gagal. Periksa internet Anda.";
      } else if (!message.contains('Judul workspace')) { 
        // Hanya tampilkan error umum jika BUKAN validasi
        message = "Gagal membuat workspace. Coba lagi nanti.";
      }
      emit(state.copyWith(
        status: WorkspaceStatus.failure,
        errorMessage: message, // <-- Pesan profesional
      ));
    }
  }

  // Handler untuk update
  Future<void> _onUpdateWorkspaceSubmitted(
    UpdateWorkspaceSubmitted event,
    Emitter<WorkspaceState> emit,
  ) async {
    try {
      await _updateWorkspace(
        workspaceId: event.workspaceId,
        title: event.title,
        description: event.description,
      );
      add(LoadMyWorkspaces()); // Muat ulang daftar setelah update
    } catch (e, stackTrace) { // <-- UBAH
      // 1. Log Licik
      Sentry.captureException(e, stackTrace: stackTrace);
      // 2. Pesan Profesional
      String message = e.toString().replaceFirst('Exception: ', '');
      if (e.toString().toLowerCase().contains('socket')) {
        message = "Koneksi gagal. Periksa internet Anda.";
      } else if (!message.contains('Judul workspace')) {
        message = "Gagal memperbarui workspace. Coba lagi nanti.";
      }
      emit(state.copyWith(
        status: WorkspaceStatus.failure,
        errorMessage: message, // <-- Pesan profesional
      ));
    }
  }

  Future<void> _onDeleteWorkspacePressed(
    DeleteWorkspacePressed event,
    Emitter<WorkspaceState> emit,
  ) async {
    try {
      await _deleteWorkspace(event.workspaceId);
      add(LoadMyWorkspaces()); // Muat ulang daftar setelah hapus
    } catch (e, stackTrace) { // <-- UBAH
      // 1. Log Licik
      Sentry.captureException(e, stackTrace: stackTrace);
      // 2. Pesan Profesional
      String message = "Gagal menghapus workspace.";
      if (e.toString().toLowerCase().contains('socket')) {
        message = "Koneksi gagal. Periksa internet Anda.";
      }
      emit(state.copyWith(
        status: WorkspaceStatus.failure,
        errorMessage: message, // <-- Pesan profesional
      ));
    }
  }

  Future<void> _onUpdateMemberRolePressed(
    UpdateMemberRolePressed event,
    Emitter<WorkspaceState> emit,
  ) async {
    try {
      await _updateMemberRole(
        workspaceId: event.workspaceId,
        userIdToUpdate: event.userIdToUpdate,
        newRole: event.newRole,
      );
      // Muat ulang daftar workspace agar UI ter-refresh
      add(LoadMyWorkspaces());
    } catch (e, stackTrace) { // <-- UBAH
      // 1. Log Licik
      Sentry.captureException(e, stackTrace: stackTrace);
      // 2. Pesan Profesional
      String message = e.toString().replaceFirst('Exception: ', '');
      if (e.toString().toLowerCase().contains('socket')) {
        message = "Koneksi gagal. Periksa internet Anda.";
      } else if (!message.contains('Role tidak valid')) { // Sembunyikan error validasi internal
        message = "Gagal mengubah role. Coba lagi nanti.";
      }
      emit(state.copyWith(
        status: WorkspaceStatus.failure,
        errorMessage: message, // <-- Pesan profesional
      ));
    }
  }
}