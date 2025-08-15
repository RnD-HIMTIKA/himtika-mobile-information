import 'package:supabase_flutter/supabase_flutter.dart';
import '../repositories/auth_repository.dart';

// Use case untuk validasi dan submit form
class SubmitProfileForm {
  final AuthRepository repository;
  final SupabaseClient client;

  SubmitProfileForm(this.repository, this.client);

  Future<void> call(SubmitProfileFormParams params) async {
    // 1. Validasi Input
    _validateInputs(params);

    // 2. Normalisasi
    final normalizedUsername = params.username.trim();
    final normalizedPhone = _normalizePhone(params.phone.trim());
    final isoDob = _toIsoDateOrNull(params.dob.trim());
    final kelas = params.isFromUnsika ? (params.kelas ?? '').trim() : null;

    final authUser = client.auth.currentUser;
    if (authUser == null) throw Exception('User not authenticated');

    // 3. Cek Duplikasi Username & Telepon
    await _checkDuplicates(normalizedUsername, normalizedPhone!, authUser.id);

    // 4. Dapatkan User ID dari tabel public.users
    final userRow = await client.from('users').select('id').eq('auth_id', authUser.id).single();
    final String userId = userRow['id'] as String;

    // 5. Handle Role 'Kelas' jika dari Unsika
    if (params.isFromUnsika && kelas != null && kelas.isNotEmpty) {
      await _handleClassRole(userId, kelas);
    }

    // 6. Update tabel 'users'
    final payload = <String, dynamic>{
      'full_name': params.fullName.trim(),
      'username': normalizedUsername,
      'phone_number': normalizedPhone,
    };
    if (isoDob != null) payload['date_of_birth'] = isoDob;

    await repository.updateProfile(authUser.id, payload);
  }

  // Semua helper dipindahkan ke sini
  void _validateInputs(SubmitProfileFormParams p) {
    if (p.fullName.trim().length < 2) throw Exception('Nama lengkap minimal 2 karakter.');
    if (!RegExp(r'^[a-zA-Z0-9._]{3,20}$').hasMatch(p.username.trim())) {
      throw Exception('Username hanya boleh huruf/angka/._ dan 3–20 karakter.');
    }
    final normalizedPhone = _normalizePhone(p.phone.trim());
    if (normalizedPhone == null) {
      throw Exception('Nomor telepon harus 10–15 digit, mulai dengan 0.');
    }
    // FIX: Cek null pada 'kelas' sebelum memanggil .trim()
    if (p.isFromUnsika) {
      final kelas = p.kelas; // Assign ke variabel lokal untuk promosi tipe
      if (kelas == null || kelas.trim().isEmpty) {
        throw Exception('Silakan pilih Kelas.');
      }
    }
  }

  Future<void> _checkDuplicates(String username, String phone, String currentAuthId) async {
    final unameDup = await client.from('users').select('auth_id').ilike('username', username).neq('auth_id', currentAuthId).maybeSingle();
    if (unameDup != null) throw Exception('Username sudah digunakan.');

    final phoneDup = await client.from('users').select('auth_id').eq('phone_number', phone).neq('auth_id', currentAuthId).maybeSingle();
    if (phoneDup != null) throw Exception('Nomor telepon sudah digunakan.');
  }

  Future<void> _handleClassRole(String userId, String kelas) async {
    final roleRow = await client.from('roles').select('id').eq('name', kelas).eq('group_name', 'Kelas').maybeSingle();
    String roleId;
    if (roleRow == null) {
      final newRole = await client.from('roles').insert({'name': kelas, 'group_name': 'Kelas'}).select('id').single();
      roleId = newRole['id'];
    } else {
      roleId = roleRow['id'];
    }
    await client.from('user_roles').upsert({'user_id': userId, 'role_id': roleId});
  }

  String? _normalizePhone(String phone) {
    final clean = phone.replaceAll(RegExp(r'\D'), '');
    if (clean.startsWith('0') && clean.length >= 10 && clean.length <= 15) {
      return '+62${clean.substring(1)}';
    }
    return null;
  }

  String? _toIsoDateOrNull(String ddmmyyyy) {
    final p = ddmmyyyy.split('/');
    if (p.length != 3) return null;
    final d = int.tryParse(p[0]);
    final m = int.tryParse(p[1]);
    final y = int.tryParse(p[2]);
    if (d == null || m == null || y == null) return null;
    return '${y}-${m.toString().padLeft(2, '0')}-${d.toString().padLeft(2, '0')}';
  }
}

// Class untuk menampung parameter yang dibutuhkan use case
class SubmitProfileFormParams {
  final String fullName;
  final String username;
  final String phone;
  final String dob;
  final String? kelas;
  final bool isFromUnsika;

  SubmitProfileFormParams({
    required this.fullName,
    required this.username,
    required this.phone,
    required this.dob,
    this.kelas,
    required this.isFromUnsika,
  });
}