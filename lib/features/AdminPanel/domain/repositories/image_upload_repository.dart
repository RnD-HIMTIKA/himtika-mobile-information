import 'dart:io';

abstract class ImageUploadRepository {
  Future<String> uploadHicodeImage(File imageFile, String folder); // folder: 'soal' atau 'opsi'
}