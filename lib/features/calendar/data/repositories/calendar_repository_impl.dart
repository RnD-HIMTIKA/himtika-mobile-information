import 'package:himtika_mobile_information/features/auth/data/models/user_model.dart';
import 'package:himtika_mobile_information/features/auth/domain/usecases/get_current_user.dart';
import 'package:himtika_mobile_information/features/calendar/domain/entities/invitation.dart';
import 'package:himtika_mobile_information/features/auth/domain/entities/user.dart';
import '../datasources/calendar_remote_datasource.dart';
import '../../domain/entities/workspace.dart';
import '../../domain/entities/event.dart';
import '../../domain/entities/workspace_with_members.dart';
import '../../domain/repositories/calendar_repository.dart';

class CalendarRepositoryImpl implements CalendarRepository {
  final CalendarRemoteDatasource remoteDatasource;
  final GetCurrentUser getCurrentUser;

  CalendarRepositoryImpl({
    required this.remoteDatasource,
    required this.getCurrentUser,
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
    final currentUser = await getCurrentUser();
    if (currentUser == null) return [];

    final workspaces = await getMyWorkspaces();
    
    final List<WorkspaceWithMembers> result = [];
    for (final ws in workspaces) {
      final membersData = await remoteDatasource.getMembersForWorkspace(ws.id);
      
      final List<UserModel> allMembers = membersData.map((item) {
        final userData = item['users'] as Map<String, dynamic>?;
        return userData != null ? UserModel.fromMap(userData) : null;
      }).whereType<UserModel>().toList();

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

  @override
  Future<void> updateWorkspace({required String workspaceId, required String title, required String description}) async {
    await remoteDatasource.updateWorkspace(workspaceId: workspaceId, title: title, description: description);
  }

  @override
  Future<void> deleteWorkspace(String workspaceId) async {
    await remoteDatasource.deleteWorkspace(workspaceId);
  }

  @override
  Future<void> inviteUserToWorkspace({required String workspaceId, required String inviteeEmail, required String role}) async {
    await remoteDatasource.inviteUserToWorkspace(workspaceId: workspaceId, inviteeEmail: inviteeEmail, role: role);
  }

  @override
  Future<List<Invitation>> getMyInvitations() async {
    final data = await remoteDatasource.getMyInvitations();
    
    // Mapping dari data mentah ke Entitas Invitation dengan penanganan null
    return data.map((json) {
      // Ambil data relasional dengan aman
      final workspaceData = json['workspace'] as Map<String, dynamic>?;
      final inviterData = json['inviter'] as Map<String, dynamic>?;

      return Invitation(
        id: json['id'],
        workspaceId: json['workspace_id'],
        // Berikan nilai default jika data relasional (workspace) null
        workspaceTitle: workspaceData?['title'] ?? 'Workspace Telah Dihapus',
        // Berikan nilai default jika data relasional (inviter) null
        inviterName: inviterData?['full_name'] ?? 'Pengguna Tidak Dikenal',
        roleToGrant: json['role_to_grant'],
        createdAt: DateTime.parse(json['created_at']),
      );
    }).toList();
  }

  @override
  Future<void> acceptInvitation(String invitationId) async {
    await remoteDatasource.acceptInvitation(invitationId);
  }

  @override
  Future<void> declineInvitation(String invitationId) async {
    await remoteDatasource.declineInvitation(invitationId);
  }

  @override
  Future<List<User>> searchUsers(String query) async {
    final data = await remoteDatasource.searchUsers(query);
    // Mapping data mentah ke Entity User
    // Kita perlu UserModel di sini untuk mapping yang mudah
    return data.map((json) => UserModel.fromMap(json)).toList();
  }

  @override
  Future<String> createInvitationLink({required String workspaceId, required String role}) async {
    return await remoteDatasource.createInvitationLink(workspaceId: workspaceId, role: role);
  }
}