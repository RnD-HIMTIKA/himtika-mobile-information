import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../domain/entities/workspace.dart';
import '../../../domain/entities/workspace_with_members.dart';
import '../../../domain/usecases/create_workspace.dart';
import '../../../domain/repositories/calendar_repository.dart';

part 'workspace_event.dart';
part 'workspace_state.dart';

class WorkspaceBloc extends Bloc<WorkspaceEvent, WorkspaceState> {
  // Ganti GetMyWorkspaces menjadi CalendarRepository
  final CalendarRepository _calendarRepository; 
  final CreateWorkspace _createWorkspace;

  WorkspaceBloc({
    required CalendarRepository calendarRepository,
    required CreateWorkspace createWorkspace,
  })  : _calendarRepository = calendarRepository,
        _createWorkspace = createWorkspace,
        super(const WorkspaceState()) {
    on<LoadMyWorkspaces>(_onLoadMyWorkspaces);
    on<CreateWorkspaceSubmitted>(_onCreateWorkspaceSubmitted);
  }

  Future<void> _onLoadMyWorkspaces(
    LoadMyWorkspaces event,
    Emitter<WorkspaceState> emit,
  ) async {
    emit(state.copyWith(status: WorkspaceStatus.loading));
    try {
      // Panggil metode repository yang baru
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

  // Handler baru untuk membuat workspace
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
}