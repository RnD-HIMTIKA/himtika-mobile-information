import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseConfig {
  static Future<void> init() async {
    await Supabase.initialize(
      url: 'https://kezvxliamqwfvlpuckvm.supabase.co', // URL Supabase Project
      anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImtlenZ4bGlhbXF3ZnZscHVja3ZtIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTE3NzE2MDMsImV4cCI6MjA2NzM0NzYwM30.dhvgAXDyHvCDEfuMR3MHDPzUO5DuyT2T__dxsouXL88', // Anon Key Supabase Project
    );
  }

  static SupabaseClient get client => Supabase.instance.client;
}