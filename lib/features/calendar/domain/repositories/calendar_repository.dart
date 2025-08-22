import 'package:himtika_mobile_information/features/auth/domain/entities/user.dart';
import '../entities/workspace_with_members.dart';
import '../entities/workspace.dart';

abstract class CalendarRepository {
  Future<List<Workspace>> getMyWorkspaces();
  Future<void> createWorkspace({required String title, required String description});
  Future<List<WorkspaceWithMembers>> getMyWorkspacesWithMembers();
}