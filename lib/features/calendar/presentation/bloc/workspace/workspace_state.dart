part of 'workspace_bloc.dart';

enum WorkspaceStatus { initial, loading, loaded, failure }

class WorkspaceState extends Equatable {
  final WorkspaceStatus status;
  // Ganti tipe data list menjadi WorkspaceWithMembers
  final List<WorkspaceWithMembers> workspaces; 
  final String? errorMessage;

  const WorkspaceState({
    this.status = WorkspaceStatus.initial,
    this.workspaces = const [],
    this.errorMessage,
  });

  WorkspaceState copyWith({
    WorkspaceStatus? status,
    List<WorkspaceWithMembers>? workspaces,
    String? errorMessage,
  }) {
    return WorkspaceState(
      status: status ?? this.status,
      workspaces: workspaces ?? this.workspaces,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [status, workspaces, errorMessage];
}