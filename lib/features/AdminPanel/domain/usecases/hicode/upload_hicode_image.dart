import 'dart:io';
import '../../repositories/image_upload_repository.dart';

class UploadHicodeImage {
  final ImageUploadRepository repository;
  UploadHicodeImage(this.repository);

  Future<String> call(File imageFile, String folder) async {
    if (folder != 'soal' && folder != 'opsi') {
       throw Exception("Folder tujuan upload tidak valid ('soal' atau 'opsi').");
    }
    // TODO: Tambahkan validasi ukuran file jika perlu
    return await repository.uploadHicodeImage(imageFile, folder);
  }
}