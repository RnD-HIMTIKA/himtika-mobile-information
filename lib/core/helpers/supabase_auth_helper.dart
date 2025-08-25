import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseAuthHelper {
  static final _client = Supabase.instance.client;

  static SupabaseClient get client => _client;

  static GoTrueClient get auth => _client.auth;
}