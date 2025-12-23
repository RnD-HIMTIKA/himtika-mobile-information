abstract class Env {
  // Mengambil URL dari --dart-define, jika tidak ada, kembalikan string kosong
  static const String supabaseUrl = String.fromEnvironment('SUPABASE_URL');
  static const String supabaseAnonKey = String.fromEnvironment('SUPABASE_ANON_KEY');
  static const String sentryDsn = String.fromEnvironment('SENTRY_DSN');

  // Validasi sederhana agar kita tidak lupa memasukkan config
  static void validate() {
    if (supabaseUrl.isEmpty || supabaseAnonKey.isEmpty) {
      throw Exception(
        'CRITICAL ERROR: Supabase config is missing.\n'
        'Please run with --dart-define=SUPABASE_URL=... and --dart-define=SUPABASE_ANON_KEY=...',
      );
    }
  }
}