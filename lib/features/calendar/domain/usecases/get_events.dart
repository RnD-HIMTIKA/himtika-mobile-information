import '../entities/event.dart';
import '../repositories/calendar_repository.dart';

class GetEvents {
  final CalendarRepository repository;

  GetEvents(this.repository);

  // Parameter 'workspaceId' dibutuhkan untuk tahu event mana yang harus diambil
  Future<List<Event>> call(String workspaceId, DateTime startDate, DateTime endDate) async {
    return await repository.getEvents(workspaceId, startDate, endDate);
  }
}