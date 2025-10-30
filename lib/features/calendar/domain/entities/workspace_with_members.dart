import 'package:equatable/equatable.dart';
import 'package:himtika_mobile_information/features/calendar/domain/entities/workspace_member.dart'; // Import
import 'workspace.dart';

class WorkspaceWithMembers extends Equatable {
  final Workspace workspace;
  final List<WorkspaceMember> members;
  final String currentUserRole;

  const WorkspaceWithMembers({
    required this.workspace,
    required this.members,
    required this.currentUserRole,
  });

  @override
  List<Object?> get props => [workspace, members, currentUserRole];
}