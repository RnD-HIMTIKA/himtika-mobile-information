import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../domain/entities/workspace.dart';
import '../../../domain/usecases/get_my_workspaces.dart';

part 'workspace_event.dart';
part 'workspace_state.dart';

class WorkspaceBloc extends Bloc<WorkspaceEvent, WorkspaceState> {
  final GetMyWorkspaces _getMyWorkspaces;

  WorkspaceBloc({required GetMyWorkspaces getMyWorkspaces})
      : _getMyWorkspaces = getMyWorkspaces,
        super(const WorkspaceState()) {
    on<LoadMyWorkspaces>(_onLoadMyWorkspaces);
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
}