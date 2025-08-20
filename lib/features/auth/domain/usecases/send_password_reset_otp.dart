import 'package:supabase_flutter/supabase_flutter.dart'; // Import
import '../repositories/auth_repository.dart';

class SendPasswordResetOtp {
  final AuthRepository repository;
  final SupabaseClient client; // Tambahkan client

  SendPasswordResetOtp(this.repository, this.client); // Perbarui konstruktor

  Future<void> call(String email) async {
    if (email.isEmpty || !email.contains('@')) {
      throw Exception('Format email tidak valid.');
    }

    // Panggil fungsi RPC untuk validasi
    final String userStatus = await client.rpc(
      'check_user_for_reset',
      params: {'p_email': email},
    );

    // Berikan pesan error yang sesuai berdasarkan status
    if (userStatus == 'not_found') {
      throw Exception('Email tidak terdaftar.');
    }
    if (userStatus == 'is_oauth') {
      throw Exception('Akun ini terdaftar melalui Google. Silakan login dengan Google.');
    }
    
    // Jika statusnya 'can_reset', baru kirim OTP
    return await repository.sendPasswordResetOtp(email);
  }
}