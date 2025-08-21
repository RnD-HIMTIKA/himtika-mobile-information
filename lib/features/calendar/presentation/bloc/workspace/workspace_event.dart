part of 'workspace_bloc.dart';

abstract class WorkspaceEvent extends Equatable {
  const WorkspaceEvent();
  @override
  List<Object> get props => [];
}

class LoadMyWorkspaces extends WorkspaceEvent {}