import '../repositories/calendar_repository.dart';

// Use case ini sekarang spesifik untuk menerima undangan dari notifikasi (via ID)
class AcceptInvitationById {
  final CalendarRepository repository;

  AcceptInvitationById(this.repository);

  Future<void> call(String invitationId) async {
    return await repository.acceptInvitationById(invitationId);
  }
}