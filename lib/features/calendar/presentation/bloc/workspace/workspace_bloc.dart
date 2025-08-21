import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../domain/entities/workspace.dart';
import '../../../domain/usecases/get_my_workspaces.dart';
import '../../../domain/usecases/create_workspace.dart';

part 'workspace_event.dart';
part 'workspace_state.dart';

class WorkspaceBloc extends Bloc<WorkspaceEvent, WorkspaceState> {
  final GetMyWorkspaces _getMyWorkspaces;
  final CreateWorkspace _createWorkspace;

  WorkspaceBloc({
    required GetMyWorkspaces getMyWorkspaces,
    required CreateWorkspace createWorkspace, // Tambahkan di konstruktor
  })  : _getMyWorkspaces = getMyWorkspaces,
        _createWorkspace = createWorkspace,
        super(const WorkspaceState()) {
    on<LoadMyWorkspaces>(_onLoadMyWorkspaces);
    on<CreateWorkspaceSubmitted>(_onCreateWorkspaceSubmitted); // Daftarkan handler
  }

  Future<void> _onLoadMyWorkspaces(
    LoadMyWorkspaces event,
    Emitter<WorkspaceState> emit,
  ) async {
    emit(state.copyWith(status: WorkspaceStatus.loading));
    try {
      final workspaces = await _getMyWorkspaces();
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