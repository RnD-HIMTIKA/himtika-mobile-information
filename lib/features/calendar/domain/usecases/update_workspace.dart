import '../repositories/calendar_repository.dart';

class UpdateWorkspace {
  final CalendarRepository repository;

  UpdateWorkspace(this.repository);

  Future<void> call({
    required String workspaceId,
    required String title,
    required String description,
  }) async {
    if (title.trim().isEmpty) {
      throw Exception('Judul workspace tidak boleh kosong.');
    }
    return await repository.updateWorkspace(
      workspaceId: workspaceId,
      title: title,
      description: description,
    );
  }
}