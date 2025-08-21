part of 'workspace_bloc.dart';

abstract class WorkspaceEvent extends Equatable {
  const WorkspaceEvent();
  @override
  List<Object> get props => [];
}

class LoadMyWorkspaces extends WorkspaceEvent {}

// Event untuk membuat workspace

class CreateWorkspaceSubmitted extends WorkspaceEvent {
  final String title;
  final String description;

  const CreateWorkspaceSubmitted({
    required this.title,
    required this.description,
  });

  @override
  List<Object> get props => [title, description];
}