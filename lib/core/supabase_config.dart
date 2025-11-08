import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseConfig {
  static Future<void> init({String? url, String? anonKey}) async {
    final supaUrl = url ?? const String.fromEnvironment('SUPABASE_URL');
    final supaAnonKey =
        anonKey ?? const String.fromEnvironment('SUPABASE_ANON_KEY');

    if (supaUrl.isEmpty || supaAnonKey.isEmpty) {
      throw Exception(
        'SUPABASE_URL atau SUPABASE_ANON_KEY tidak ditemukan. '
        'Pastikan Anda menggunakan --dart-define saat build.',
      );
    }

    await Supabase.initialize(
      url: supaUrl,
      anonKey: supaAnonKey,
    );
  }

  static SupabaseClient get client => Supabase.instance.client;
}
