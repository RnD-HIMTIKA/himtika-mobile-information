import '../repositories/calendar_repository.dart';

class DeleteEvent {
  final CalendarRepository repository;

  DeleteEvent(this.repository);

  Future<void> call(String eventId) async {
    if (eventId.isEmpty) {
      throw Exception('ID Event tidak valid.');
    }
    return await repository.deleteEvent(eventId);
  }
}