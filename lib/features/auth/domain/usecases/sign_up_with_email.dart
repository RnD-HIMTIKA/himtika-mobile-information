import 'package:supabase_flutter/supabase_flutter.dart';
import '../repositories/auth_repository.dart';

class SignUpWithEmail {
  final AuthRepository repository;
  // Kita butuh SupabaseClient untuk memanggil fungsi RPC
  final SupabaseClient client;

  SignUpWithEmail(this.repository, this.client);

  Future<AuthResponse> call(String email, String password) async {
    // LANGKAH 1: Panggil fungsi 'email_exists' yang kita buat di Supabase
    final bool emailAlreadyExists = await client.rpc(
      'email_exists',
      params: {'p_email': email.trim()},
    );

    // LANGKAH 2: Jika email sudah ada, lemparkan error yang jelas
    if (emailAlreadyExists) {
      throw Exception('Email ini sudah terdaftar. Silakan gunakan email lain.');
    }

    // LANGKAH 3: Jika email belum ada, baru lanjutkan proses pendaftaran
    return await repository.signUp(email, password);
  }
}