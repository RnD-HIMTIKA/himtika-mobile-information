import '../repositories/calendar_repository.dart';

class CreateWorkspace {
  final CalendarRepository repository;

  CreateWorkspace(this.repository);

  Future<void> call({required String title, required String description}) async {
    // Validasi sederhana di use case
    if (title.trim().isEmpty) {
      throw Exception('Judul workspace tidak boleh kosong.');
    }
    return await repository.createWorkspace(title: title, description: description);
  }
}