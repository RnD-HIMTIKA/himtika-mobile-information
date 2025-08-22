part of 'workspace_bloc.dart';

abstract class WorkspaceEvent extends Equatable {
  const WorkspaceEvent();
  @override
  List<Object> get props => [];
}

class LoadMyWorkspaces extends WorkspaceEvent {}

class CreateWorkspaceSubmitted extends WorkspaceEvent {
  final String title;
  final String description;

  const CreateWorkspaceSubmitted({required this.title, required this.description});

  @override
  List<Object> get props => [title, description];
}

// Event baru untuk mengupdate workspace
class UpdateWorkspaceSubmitted extends WorkspaceEvent {
  final String workspaceId;
  final String title;
  final String description;

  const UpdateWorkspaceSubmitted({
    required this.workspaceId,
    required this.title,
    required this.description,
  });

  @override
  List<Object> get props => [workspaceId, title, description];
}

// Event baru untuk menghapus workspace
class DeleteWorkspacePressed extends WorkspaceEvent {
  final String workspaceId;

  const DeleteWorkspacePressed(this.workspaceId);

  @override
  List<Object> get props => [workspaceId];
}