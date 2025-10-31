import 'dart:io';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:path/path.dart';

abstract class ImageUploadRemoteDatasource {
  Future<String> uploadHicodeImage(File imageFile, String folder);
}

class ImageUploadRemoteDatasourceImpl implements ImageUploadRemoteDatasource {
  final SupabaseClient client;
  ImageUploadRemoteDatasourceImpl({required this.client});

  @override
  Future<String> uploadHicodeImage(File imageFile, String folder) async {
    try {
      final fileName = '${DateTime.now().millisecondsSinceEpoch}_${basename(imageFile.path)}';
      const bucketName = 'hicode_assets'; // Pastikan nama bucket benar
      final filePath = '$folder/$fileName'; // soal/filename.jpg atau opsi/filename.jpg

      await client.storage.from(bucketName).upload(filePath, imageFile);
      return client.storage.from(bucketName).getPublicUrl(filePath);
    } catch (e) {
      throw Exception('Gagal mengunggah gambar hicode ($folder): $e');
    }
  }
}