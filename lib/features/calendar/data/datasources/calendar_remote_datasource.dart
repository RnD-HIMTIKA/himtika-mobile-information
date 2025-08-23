import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:himtika_mobile_information/features/auth/domain/usecases/get_current_user.dart';
import 'package:himtika_mobile_information/features/calendar/domain/entities/event.dart';

class CalendarRemoteDatasource {
  final SupabaseClient _client;
  final GetCurrentUser _getCurrentUser;

  CalendarRemoteDatasource(this._client, this._getCurrentUser);

  Future<List<Map<String, dynamic>>> getMyWorkspacesWithMembers() async {
    final data = await _client.rpc('get_my_workspaces_with_members');
    return List<Map<String, dynamic>>.from(data ?? []);
  }

  Future<void> createWorkspace({required String title, required String description}) async {
    await _client.rpc('create_new_workspace', params: {
      'p_title': title,
      'p_description': description,
    });
  }

  //Fungsi untuk mengambil anggota dari satu workspace
  Future<List<Map<String, dynamic>>> getMembersForWorkspace(String workspaceId) async {
    final data = await _client
        .from('workspace_access')
        .select('users(*)') // Ambil semua data user yang berelasi
        .eq('workspace_id', workspaceId);
    return List<Map<String, dynamic>>.from(data);
  }

  // Metode untuk mengambil events
  Future<List<Map<String, dynamic>>> getEvents(String workspaceId) async {
    // RLS akan memastikan pengguna hanya bisa mengambil event dari workspace
    // di mana ia adalah anggota.
    final data = await _client
        .from('events')
        .select()
        .eq('workspace_id', workspaceId)
        .order('start_time', ascending: true);
    return List<Map<String, dynamic>>.from(data);
  }

  // Metode untuk membuat event
  Future<void> createEvent({
    required String workspaceId,
    required String title,
    String? description,
    required DateTime startTime,
    required DateTime endTime,
  }) async {
    final currentUser = await _getCurrentUser();
    if (currentUser == null) throw Exception('Pengguna tidak ditemukan');

    await _client.from('events').insert({
      'workspace_id': workspaceId,
      'created_by': currentUser.id,
      'title': title,
      'description': description,
      'start_time': startTime.toIso8601String(),
      'end_time': endTime.toIso8601String(),
    });
  }

  // Metode untuk mengupdate event
  Future<void> updateEvent(Event event) async {
    await _client
        .from('events')
        .update({
          'title': event.title,
          'description': event.description,
          'start_time': event.startTime.toIso8601String(),
          'end_time': event.endTime.toIso8601String(),
        })
        .match({'id': event.id});
  }

  // Metode untuk menghapus event
  Future<void> deleteEvent(String eventId) async {
    await _client
        .from('events')
        .delete()
        .match({'id': eventId});
  }

  // Metode untuk mengupdate workspace
  Future<void> updateWorkspace({required String workspaceId, required String title, required String description}) async {
    await _client
        .from('user_workspace')
        .update({
          'title': title,
          'description': description,
        })
        .match({'id': workspaceId});
  }

  // Metode untuk menghapus workspace
  Future<void> deleteWorkspace(String workspaceId) async {
    await _client
        .from('user_workspace')
        .delete()
        .match({'id': workspaceId});
  }

  // Metode untuk memanggil fungsi RPC
  Future<void> inviteUserToWorkspace({
    required String workspaceId,
    required String inviteeEmail,
    required String role,
  }) async {
    await _client.rpc('invite_user_to_workspace', params: {
      'p_workspace_id': workspaceId,
      'p_invitee_email': inviteeEmail,
      'p_role_to_grant': role,
    });
  }

  // Metode untuk mengambil undangan yang ditujukan ke pengguna saat ini
  Future<List<Map<String, dynamic>>> getMyInvitations() async {
    final currentUser = await _getCurrentUser();
    if (currentUser == null) throw Exception('Pengguna tidak ditemukan');

    final data = await _client
        .from('workspace_invitations')
        .select('*, inviter:inviter_id(full_name), workspace:workspace_id(title)')
        .eq('invitee_id', currentUser.id)
        .eq('status', 'pending');
        
    return List<Map<String, dynamic>>.from(data);
  }

  // Metode untuk memanggil RPC accept
  Future<void> acceptInvitation(String invitationIdOrToken) async {
    await _client.rpc('accept_workspace_invitation', params: {
      // PERBAIKAN DI SINI: ganti 'p_invitation_id' menjadi 'p_invitation_token'
      'p_invitation_token': invitationIdOrToken,
    });
  }

  // Metode untuk memanggil RPC decline
  Future<void> declineInvitation(String invitationId) async {
    await _client.rpc('decline_workspace_invitation', params: {
      'p_invitation_id': invitationId,
    });
  }

  // Metode untuk memanggil RPC search_users
  Future<List<Map<String, dynamic>>> searchUsers(String query) async {
    final data = await _client.rpc('search_users', params: {
      'p_query': query,
    });
    return List<Map<String, dynamic>>.from(data);
  }

  // Metode untuk memanggil RPC create_workspace_invitation_link
  Future<String> createInvitationLink({required String workspaceId, required String role}) async {
    final token = await _client.rpc('create_workspace_invitation_link', params: {
      'p_workspace_id': workspaceId,
      'p_role_to_grant': role,
    });
    return token as String;
  }

  // Metode untuk memanggil RPC invite_users_by_roles
  Future<void> inviteByRole({
    required String workspaceId,
    required List<String> targetRoleIds,
    required String roleToGrant,
  }) async {
    await _client.rpc('invite_users_by_roles', params: {
      'p_workspace_id': workspaceId,
      'p_target_role_ids': targetRoleIds,
      'p_role_to_grant': roleToGrant,
    });
  }
}