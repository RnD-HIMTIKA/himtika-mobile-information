import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class SupabaseConfig {
  static Future<void> init({ String? url, String? anonKey }) async {
    // Jika param disediakan, gunakan itu, kalau tidak baca dari dotenv
    final supaUrl = url ?? dotenv.env['SUPABASE_URL'];
    final supaAnonKey = anonKey ?? dotenv.env['SUPABASE_ANON_KEY'];

    if (supaUrl == null || supaAnonKey == null) {
      throw Exception('SUPABASE_URL atau SUPABASE_ANON_KEY tidak ditemukan. Pastikan .env telah di-load dan berisi key yang benar.');
    }

    await Supabase.initialize(
      url: supaUrl,
      anonKey: supaAnonKey,
    );
  }

  static SupabaseClient get client => Supabase.instance.client;
}