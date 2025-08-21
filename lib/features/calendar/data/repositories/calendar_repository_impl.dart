import '../../domain/entities/workspace.dart';
import '../../domain/repositories/calendar_repository.dart';
import '../datasources/calendar_remote_datasource.dart';

class CalendarRepositoryImpl implements CalendarRepository {
  final CalendarRemoteDatasource remoteDatasource;

  CalendarRepositoryImpl(this.remoteDatasource);

  @override
  Future<List<Workspace>> getMyWorkspaces() async {
    final data = await remoteDatasource.getMyWorkspaces();
    // Mapping dari data mentah (Map) ke Entity (Workspace)
    return data.map((item) {
      final workspaceData = item['user_workspace'];
      return Workspace(
        id: workspaceData['id'],
        title: workspaceData['title'],
        description: workspaceData['description'],
        ownerId: workspaceData['owner_id'],
        createdAt: DateTime.parse(workspaceData['created_at']),
      );
    }).toList();
  }
}