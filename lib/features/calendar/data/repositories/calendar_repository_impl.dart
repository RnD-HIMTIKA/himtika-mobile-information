import 'package:himtika_mobile_information/features/auth/data/models/user_model.dart';
import 'package:himtika_mobile_information/features/auth/domain/usecases/get_current_user.dart';
import '../../domain/entities/workspace.dart';
import '../../domain/entities/workspace_with_members.dart';
import '../../domain/repositories/calendar_repository.dart';
import '../datasources/calendar_remote_datasource.dart';
import '../../domain/entities/event.dart';

class CalendarRepositoryImpl implements CalendarRepository {
  final CalendarRemoteDatasource remoteDatasource;
  final GetCurrentUser getCurrentUser; // Tambahkan dependensi ini

  CalendarRepositoryImpl({
    required this.remoteDatasource,
    required this.getCurrentUser, // Perbarui konstruktor
  });

  @override
  Future<List<Workspace>> getMyWorkspaces() async {
    final data = await remoteDatasource.getMyWorkspaces();
    return data.map((item) {
      final workspaceData = item['user_workspace'] as Map<String, dynamic>?;
      if (workspaceData == null) return null;

      return Workspace(
        id: workspaceData['id'] ?? '',
        title: workspaceData['title'] ?? 'Tanpa Judul',
        description: workspaceData['description'] ?? '',
        ownerId: workspaceData['owner_id'] ?? '',
        lastUpdated: workspaceData['last_updated'] != null
            ? DateTime.parse(workspaceData['last_updated'])
            : null,
      );
    }).whereType<Workspace>().toList();
  }

  @override
  Future<void> createWorkspace({required String title, required String description}) async {
    await remoteDatasource.createWorkspace(title: title, description: description);
  }

  @override
  Future<List<WorkspaceWithMembers>> getMyWorkspacesWithMembers() async {
    // Dapatkan siapa pengguna saat ini terlebih dahulu
    final currentUser = await getCurrentUser();
    if (currentUser == null) {
      // Jika karena suatu alasan tidak ada sesi, kembalikan daftar kosong
      return [];
    }

    // 1. Dapatkan semua workspace seperti biasa
    final workspaces = await getMyWorkspaces();
    
    // 2. Untuk setiap workspace, ambil anggotanya dan filter
    final List<WorkspaceWithMembers> result = [];
    for (final ws in workspaces) {
      final membersData = await remoteDatasource.getMembersForWorkspace(ws.id);
      
      final List<UserModel> allMembers = membersData.map((item) {
        final userData = item['users'] as Map<String, dynamic>?;
        return userData != null ? UserModel.fromMap(userData) : null;
      }).whereType<UserModel>().toList();

      // PERBAIKAN UTAMA DI SINI:
      // Saring daftar anggota untuk mengecualikan pengguna saat ini
      final otherMembers = allMembers.where((member) => member.id != currentUser.id).toList();

      result.add(WorkspaceWithMembers(workspace: ws, members: otherMembers));
    }
    
    return result;
  }

  @override
  Future<List<Event>> getEvents(String workspaceId) async {
    final data = await remoteDatasource.getEvents(workspaceId);
    return data.map((json) {
      return Event(
        id: json['id'],
        workspaceId: json['workspace_id'],
        createdBy: json['created_by'],
        title: json['title'],
        description: json['description'],
        startTime: DateTime.parse(json['start_time']),
        endTime: DateTime.parse(json['end_time']),
        createdAt: DateTime.parse(json['created_at']),
      );
    }).toList();
  }

  @override
  Future<void> createEvent({
    required String workspaceId,
    required String title,
    String? description,
    required DateTime startTime,
    required DateTime endTime,
  }) async {
    await remoteDatasource.createEvent(
      workspaceId: workspaceId,
      title: title,
      description: description,
      startTime: startTime,
      endTime: endTime,
    );
  }

  @override
  Future<void> updateEvent(Event event) async {
    await remoteDatasource.updateEvent(event);
  }

  @override
  Future<void> deleteEvent(String eventId) async {
    await remoteDatasource.deleteEvent(eventId);
  }
}