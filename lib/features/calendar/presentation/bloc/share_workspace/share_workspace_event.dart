part of 'share_workspace_bloc.dart';

abstract class ShareWorkspaceEvent extends Equatable {
  const ShareWorkspaceEvent();
  @override
  List<Object> get props => [];
}

class InviteUserSubmitted extends ShareWorkspaceEvent {
  final String workspaceId;
  final String email;
  final String role; // 'viewer' or 'editor'

  const InviteUserSubmitted({
    required this.workspaceId,
    required this.email,
    required this.role,
  });

  @override
  List<Object> get props => [workspaceId, email, role];
}