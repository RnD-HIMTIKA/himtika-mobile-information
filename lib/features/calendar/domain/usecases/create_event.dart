import '../repositories/calendar_repository.dart';

class CreateEvent {
  final CalendarRepository repository;

  CreateEvent(this.repository);

  Future<void> call({
    required String workspaceId,
    required String title,
    String? description,
    required DateTime startTime,
    required DateTime endTime,
  }) async {
    if (title.trim().isEmpty) {
      throw Exception('Judul event tidak boleh kosong.');
    }
    if (endTime.isBefore(startTime)) {
      throw Exception('Waktu selesai tidak boleh sebelum waktu mulai.');
    }
    return await repository.createEvent(
      workspaceId: workspaceId,
      title: title,
      description: description,
      startTime: startTime,
      endTime: endTime,
    );
  }
}