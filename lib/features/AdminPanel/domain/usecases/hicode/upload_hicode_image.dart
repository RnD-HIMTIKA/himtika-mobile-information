import 'dart:io';
import '../../repositories/image_upload_repository.dart';

class UploadHicodeImage {
  final ImageUploadRepository repository;
  UploadHicodeImage(this.repository);

  Future<String> call(File imageFile, String folder) async {
    // Izinkan juga folder 'materi_konten'
    if (folder != 'soal' && folder != 'opsi' && folder != 'materi_konten') {
       throw Exception("Folder tujuan upload tidak valid ('soal', 'opsi', atau 'materi_konten').");
    }
    // TODO: Tambahkan validasi ukuran file jika perlu
    return await repository.uploadHicodeImage(imageFile, folder);
  }
}