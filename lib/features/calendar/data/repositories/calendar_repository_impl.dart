import 'package:himtika_mobile_information/features/auth/data/models/user_model.dart';
import 'package:himtika_mobile_information/features/auth/domain/usecases/get_current_user.dart';
import 'package:himtika_mobile_information/features/calendar/domain/entities/invitation.dart';
import 'package:himtika_mobile_information/features/auth/domain/entities/user.dart';
import '../datasources/calendar_remote_datasource.dart';
import '../../domain/entities/workspace.dart';
import '../../domain/entities/event.dart';
import '../../domain/entities/workspace_member.dart';
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
  Future<void> createWorkspace({required String title, required String description}) async {
    await remoteDatasource.createWorkspace(title: title, description: description);
  }

  @override
  Future<List<WorkspaceWithMembers>> getMyWorkspacesWithMembers() async {
    // Dapatkan siapa pengguna saat ini terlebih dahulu
    final currentUser = await getCurrentUser();
    
    // Ambil data dari RPC
    final data = await remoteDatasource.getMyWorkspacesWithMembers();

    return data.map((item) {
      final workspaceData = item['workspace'] as Map<String, dynamic>;
      final membersData = item['members'] as List<dynamic>? ?? [];
      final currentUserRole = item['currentUserRole'] as String? ?? 'viewer';

      final workspace = Workspace(
        id: workspaceData['id'],
        title: workspaceData['title'] ?? 'Tanpa Judul',
        description: workspaceData['description'] ?? '',
        ownerId: workspaceData['owner_id'],
        lastUpdated: workspaceData['last_updated'] != null ? DateTime.parse(workspaceData['last_updated']) : null,
      );

      // Mapping ke WorkspaceMember
      final allMembers = membersData.map((memberJson) {
        final memberMap = memberJson as Map<String, dynamic>;
        final userData = memberMap['user_data'] as Map<String, dynamic>;
        final role = memberMap['role'] as String;
        
        return WorkspaceMember(
          user: UserModel.fromMap(userData),
          role: role,
        );
      }).toList();

      // PERBAIKAN UTAMA DI SINI:
      // Saring daftar anggota untuk mengecualikan pengguna saat ini
      final otherMembers = allMembers.where((member) => member.user.id != currentUser?.id).toList();

      return WorkspaceWithMembers(
        workspace: workspace,
        members: otherMembers, // Gunakan daftar yang sudah difilter
        currentUserRole: currentUserRole,
      );
    }).toList();
  }

  @override
  Future<List<Event>> getEvents(String workspaceId, DateTime startDate, DateTime endDate) async {
    final data = await remoteDatasource.getEvents(workspaceId, startDate, endDate);
    return data.map((json) {
      // PERBAIKAN UTAMA ADA DI SINI
      // Ambil list dari json
      final remindersRaw = json['reminder_minutes_before'] as List<dynamic>?;
      // Lakukan konversi tipe data dengan aman
      final List<int>? reminders = remindersRaw?.map((item) => item as int).toList();

      return Event(
        id: json['id'],
        workspaceId: json['workspace_id'],
        createdBy: json['created_by'],
        title: json['title'],
        description: json['description'],
        startTime: DateTime.parse(json['start_time']),
        endTime: DateTime.parse(json['end_time']),
        createdAt: DateTime.parse(json['created_at']),
        recurrenceId: json['recurrence_id'],
        reminderMinutesBefore: reminders, // Gunakan list yang sudah dikonversi
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
    List<int>? reminderMinutesBefore,
  }) async {
    await remoteDatasource.createEvent(
      workspaceId: workspaceId,
      title: title,
      description: description,
      startTime: startTime,
      endTime: endTime,
      reminderMinutesBefore: reminderMinutesBefore,
    );
  }

  @override
  Future<void> createRecurringEvent({
    required String workspaceId,
    required String title,
    String? description,
    required DateTime startTime,
    required DateTime endTime,
    required List<String> byDay,
    required DateTime untilDate,
    List<int>? reminderMinutesBefore,
  }) async {
    await remoteDatasource.createRecurringEvent(
      workspaceId: workspaceId,
      title: title,
      description: description,
      startTime: startTime,
      endTime: endTime,
      byDay: byDay,
      untilDate: untilDate,
      reminderMinutesBefore: reminderMinutesBefore,
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
  Future<void> acceptInvitationById(String invitationId) async {
    await remoteDatasource.acceptInvitationById(invitationId);
  }

  @override
  Future<void> acceptInvitationByToken(String token) async {
    await remoteDatasource.acceptInvitationByToken(token);
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

  @override
  Future<void> inviteByRole({
    required String workspaceId,
    required List<String> targetRoleIds,
    required String roleToGrant,
  }) async {
    await remoteDatasource.inviteByRole(
      workspaceId: workspaceId,
      targetRoleIds: targetRoleIds,
      roleToGrant: roleToGrant,
    );
  }

  @override
  Future<void> updateMemberRole({
    required String workspaceId,
    required String userIdToUpdate,
    required String newRole,
  }) {
    return remoteDatasource.updateMemberRole(
      workspaceId: workspaceId,
      userIdToUpdate: userIdToUpdate,
      newRole: newRole,
    );
  }
}