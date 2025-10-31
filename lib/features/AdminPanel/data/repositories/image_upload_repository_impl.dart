import 'dart:io';
import '../datasources/image_upload_remote_datasource.dart'; // Sesuaikan path
import '../../domain/repositories/image_upload_repository.dart'; // Sesuaikan path

class ImageUploadRepositoryImpl implements ImageUploadRepository {
  final ImageUploadRemoteDatasource remoteDatasource;
  ImageUploadRepositoryImpl({required this.remoteDatasource});

  @override
  Future<String> uploadHicodeImage(File imageFile, String folder) {
    return remoteDatasource.uploadHicodeImage(imageFile, folder);
  }
}