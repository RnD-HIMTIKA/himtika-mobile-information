import 'package:supabase_flutter/supabase_flutter.dart';

abstract class HomeRemoteDatasource {
  Future<List<Map<String, dynamic>>> getBanners();
  Future<List<Map<String, dynamic>>> getDivisions();
}

class HomeRemoteDatasourceImpl implements HomeRemoteDatasource {
  final SupabaseClient client;

  HomeRemoteDatasourceImpl({required this.client});

  @override
  Future<List<Map<String, dynamic>>> getBanners() async {
    final response = await client.from('home_banners').select().order('order');
    return List<Map<String, dynamic>>.from(response);
  }

  @override
  Future<List<Map<String, dynamic>>> getDivisions() async {
    final response = await client.from('divisions').select().order('order');
    return List<Map<String, dynamic>>.from(response);
  }
}