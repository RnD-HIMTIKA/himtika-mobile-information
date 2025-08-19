import 'package:supabase_flutter/supabase_flutter.dart';

// Use case ini hanya punya satu tugas: memvalidasi semua data di langkah 1.
class ValidateProfileStep1 {
  final SupabaseClient client;

  ValidateProfileStep1(this.client);

  Future<void> call(ValidateProfileStep1Params params) async {
    // 1. Validasi Kelengkapan Lokal
    if (params.fullName.trim().isEmpty ||
        params.username.trim().isEmpty ||
        params.phone.trim().isEmpty ||
        params.dob.trim().isEmpty) {
      throw Exception('Harap lengkapi semua data identitas diri.');
    }
    
    // 2. Validasi Format Username
    if (!RegExp(r'^[a-zA-Z0-9._]{3,20}$').hasMatch(params.username.trim())) {
      throw Exception('Username hanya boleh berisi huruf, angka, titik, atau underscore (3-20 karakter).');
    }

    // 3. Validasi Duplikasi ke Supabase
    final authUser = client.auth.currentUser;
    if (authUser == null) {
      throw Exception('Sesi tidak valid. Silakan coba lagi.');
    }
    
    // Cek duplikasi username
    final unameDup = await client
        .from('users')
        .select('auth_id')
        .ilike('username', params.username.trim())
        .neq('auth_id', authUser.id)
        .maybeSingle();

    if (unameDup != null) {
      throw Exception('Username ini telah digunakan oleh akun lain.');
    }

    // Normalisasi dan cek duplikasi nomor telepon
    final normalizedPhone = _normalizePhone(params.phone.trim());
     if (normalizedPhone == null) {
      throw Exception('Format nomor telepon tidak valid (10-15 digit, diawali 0).');
    }

    final phoneDup = await client
        .from('users')
        .select('auth_id')
        .eq('phone_number', normalizedPhone)
        .neq('auth_id', authUser.id)
        .maybeSingle();

    if (phoneDup != null) {
      throw Exception('Nomor telepon ini telah digunakan oleh akun lain.');
    }
  }

  String? _normalizePhone(String phone) {
    final clean = phone.replaceAll(RegExp(r'\D'), '');
    if (clean.startsWith('0') && clean.length >= 10 && clean.length <= 15) {
      return '+62${clean.substring(1)}';
    }
    return null;
  }
}

// Class sederhana untuk membungkus parameter yang dibutuhkan oleh use case
class ValidateProfileStep1Params {
  final String fullName;
  final String username;
  final String phone;
  final String dob;

  ValidateProfileStep1Params({
    required this.fullName,
    required this.username,
    required this.phone,
    required this.dob,
  });
}