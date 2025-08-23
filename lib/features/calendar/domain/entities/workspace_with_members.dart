import 'package:equatable/equatable.dart';
import 'package:himtika_mobile_information/features/auth/domain/entities/user.dart';
import 'workspace.dart';

class WorkspaceWithMembers extends Equatable {
  final Workspace workspace;
  final List<User> members;
  final String currentUserRole;

  const WorkspaceWithMembers({
    required this.workspace,
    required this.members,
    required this.currentUserRole,
  });

  @override
  List<Object?> get props => [workspace, members, currentUserRole];
}