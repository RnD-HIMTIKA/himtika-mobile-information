import '../repositories/calendar_repository.dart';

class AcceptInvitation {
  final CalendarRepository repository;
  AcceptInvitation(this.repository);

  Future<void> call(String invitationId) async {
    return await repository.acceptInvitation(invitationId);
  }
}