import '../entities/event.dart';
import '../repositories/calendar_repository.dart';

class UpdateEvent {
  final CalendarRepository repository;

  UpdateEvent(this.repository);

  // Use case ini menerima objek Event lengkap karena bisa jadi semua datanya berubah.
  Future<void> call(Event event) async {
    if (event.title.trim().isEmpty) {
      throw Exception('Judul event tidak boleh kosong.');
    }
    if (event.endTime.isBefore(event.startTime)) {
      throw Exception('Waktu selesai tidak boleh sebelum waktu mulai.');
    }
    return await repository.updateEvent(event);
  }
}