import 'package:equatable/equatable.dart';
import 'package:himtika_mobile_information/features/auth/domain/entities/user.dart';
import 'workspace.dart';

// Entity yang menggabungkan Workspace dengan anggota-anggotanya
class WorkspaceWithMembers extends Equatable {
  final Workspace workspace;
  final List<User> members;

  const WorkspaceWithMembers({
    required this.workspace,
    required this.members,
  });

  @override
  List<Object?> get props => [workspace, members];
}