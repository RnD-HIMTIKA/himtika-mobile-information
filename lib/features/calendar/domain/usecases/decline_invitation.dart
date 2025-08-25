import '../repositories/calendar_repository.dart';

class DeclineInvitation {
  final CalendarRepository repository;
  DeclineInvitation(this.repository);

  Future<void> call(String invitationId) async {
    return await repository.declineInvitation(invitationId);
  }
}