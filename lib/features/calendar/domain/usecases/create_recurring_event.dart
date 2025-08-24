import '../repositories/calendar_repository.dart';

class CreateRecurringEvent {
  final CalendarRepository repository;

  CreateRecurringEvent(this.repository);

  Future<void> call({
    required String workspaceId,
    required String title,
    String? description,
    required DateTime startTime,
    required DateTime endTime,
    required List<String> byDay, // ['MO', 'WE']
    required DateTime untilDate,
    List<int>? reminderMinutesBefore,
  }) async {
    if (title.trim().isEmpty) {
      throw Exception('Judul event tidak boleh kosong.');
    }
    if (byDay.isEmpty) {
      throw Exception('Pilih minimal satu hari untuk perulangan.');
    }

    return await repository.createRecurringEvent(
      workspaceId: workspaceId,
      title: title,
      description: description,
      startTime: startTime,
      endTime: endTime,
      byDay: byDay,
      untilDate: untilDate,
      reminderMinutesBefore: reminderMinutesBefore,
    );
  }
}