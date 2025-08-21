import '../entities/workspace.dart';

abstract class CalendarRepository {
  Future<List<Workspace>> getMyWorkspaces();
  Future<void> createWorkspace({required String title, required String description});
}