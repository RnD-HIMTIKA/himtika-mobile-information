import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:himtika_mobile_information/features/auth/domain/usecases/get_current_user.dart';

class CalendarRemoteDatasource {
  final SupabaseClient _client;
  // Ganti dependensi dari User menjadi GetCurrentUser use case
  final GetCurrentUser _getCurrentUser;

  CalendarRemoteDatasource(this._client, this._getCurrentUser);

  Future<List<Map<String, dynamic>>> getMyWorkspaces() async {
    // Panggil use case untuk mendapatkan user saat metode ini dijalankan
    final currentUser = await _getCurrentUser();
    if (currentUser == null) {
      throw Exception('Tidak ada pengguna yang login.');
    }

    // Query ini mengambil semua workspace di mana pengguna saat ini memiliki akses.
    // RLS yang sudah kita buat akan memastikan query ini aman.
    final data = await _client
        .from('workspace_access')
        .select('user_workspace(*)')
        .eq('user_id', currentUser.id);
        
    return List<Map<String, dynamic>>.from(data);
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

  // Metode baru untuk mengambil events
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

  // Metode baru untuk membuat event
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
}