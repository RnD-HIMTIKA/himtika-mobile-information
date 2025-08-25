import 'package:supabase_flutter/supabase_flutter.dart';

abstract class AdminPanelRemoteDatasource {
  Future<Map<String, dynamic>> getDashboardInfo();
}

class AdminPanelRemoteDatasourceImpl implements AdminPanelRemoteDatasource {
  final SupabaseClient client;

  AdminPanelRemoteDatasourceImpl({required this.client});

  @override
  Future<Map<String, dynamic>> getDashboardInfo() async {
    final response = await client.rpc('get_admin_dashboard_info');
    if (response == null) {
      throw Exception('Gagal mengambil data dashboard admin.');
    }
    return response as Map<String, dynamic>;
  }
}