import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../domain/entities/workspace_with_members.dart';
import '../../../domain/usecases/create_workspace.dart';
import '../../../domain/repositories/calendar_repository.dart';
import '../../../domain/usecases/update_workspace.dart';
import '../../../domain/usecases/delete_workspace.dart';

part 'workspace_event.dart';
part 'workspace_state.dart';

class WorkspaceBloc extends Bloc<WorkspaceEvent, WorkspaceState> {
  final CalendarRepository _calendarRepository;
  final CreateWorkspace _createWorkspace;
  final UpdateWorkspace _updateWorkspace;
  final DeleteWorkspace _deleteWorkspace;

  WorkspaceBloc({
    required CalendarRepository calendarRepository,
    required CreateWorkspace createWorkspace,
    required UpdateWorkspace updateWorkspace,
    required DeleteWorkspace deleteWorkspace,
  })  : _calendarRepository = calendarRepository,
        _createWorkspace = createWorkspace,
        _updateWorkspace = updateWorkspace,
        _deleteWorkspace = deleteWorkspace,
        super(const WorkspaceState()) {
    on<LoadMyWorkspaces>(_onLoadMyWorkspaces);
    on<CreateWorkspaceSubmitted>(_onCreateWorkspaceSubmitted);
    on<UpdateWorkspaceSubmitted>(_onUpdateWorkspaceSubmitted);
    on<DeleteWorkspacePressed>(_onDeleteWorkspacePressed);
  }

  Future<void> _onLoadMyWorkspaces(
    LoadMyWorkspaces event,
    Emitter<WorkspaceState> emit,
  ) async {
    emit(state.copyWith(status: WorkspaceStatus.loading));
    try {
      // PASTIKAN METODE YANG DIPANGGIL ADALAH getMyWorkspacesWithMembers()
      final workspaces = await _calendarRepository.getMyWorkspacesWithMembers();
      emit(state.copyWith(
        status: WorkspaceStatus.loaded,
        workspaces: workspaces,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: WorkspaceStatus.failure,
        errorMessage: e.toString(),
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
      // Setelah berhasil, panggil event untuk memuat ulang daftar workspace
      add(LoadMyWorkspaces());
    } catch (e) {
      // Jika gagal, emit state failure dengan pesan error
      emit(state.copyWith(
        status: WorkspaceStatus.failure,
        errorMessage: e.toString().replaceFirst('Exception: ', ''),
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
    } catch (e) {
      emit(state.copyWith(
        status: WorkspaceStatus.failure,
        errorMessage: e.toString().replaceFirst('Exception: ', ''),
      ));
    }
  }

  // Handler untuk delete
  Future<void> _onDeleteWorkspacePressed(
    DeleteWorkspacePressed event,
    Emitter<WorkspaceState> emit,
  ) async {
    try {
      await _deleteWorkspace(event.workspaceId);
      add(LoadMyWorkspaces()); // Muat ulang daftar setelah hapus
    } catch (e) {
      emit(state.copyWith(
        status: WorkspaceStatus.failure,
        errorMessage: e.toString().replaceFirst('Exception: ', ''),
      ));
    }
  }
}