import '../repositories/calendar_repository.dart';

class DeleteWorkspace {
  final CalendarRepository repository;

  DeleteWorkspace(this.repository);

  Future<void> call(String workspaceId) async {
    if (workspaceId.isEmpty) {
      throw Exception('ID Workspace tidak valid.');
    }
    return await repository.deleteWorkspace(workspaceId);
  }
}