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
      // Pastikan 'user_workspace' tidak null
      final workspaceData = item['user_workspace'] as Map<String, dynamic>?;
      if (workspaceData == null) {
        // Lewati item ini jika datanya tidak valid
        return null;
      }

      return Workspace(
        id: workspaceData['id'] ?? '', // Beri default jika null
        title: workspaceData['title'] ?? 'Tanpa Judul', // Beri default jika null
        description: workspaceData['description'] ?? '', // Beri default jika null
        ownerId: workspaceData['owner_id'] ?? '', // Beri default jika null
        // Perbaiki nama kolom dan tangani kemungkinan null
        lastUpdated: workspaceData['last_updated'] != null
            ? DateTime.parse(workspaceData['last_updated'])
            : null,
      );
    }).whereType<Workspace>().toList(); // Filter semua hasil null
  }

  @override
  Future<void> createWorkspace({required String title, required String description}) async {
    await remoteDatasource.createWorkspace(title: title, description: description);
  }
}