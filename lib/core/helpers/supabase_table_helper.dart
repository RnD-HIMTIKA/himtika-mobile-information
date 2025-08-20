import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseTableHelper {
  static final _client = Supabase.instance.client;

  static SupabaseQueryBuilder table(String tableName) {
    return _client.from(tableName);
  }
}