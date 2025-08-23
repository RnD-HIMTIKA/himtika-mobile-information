import '../repositories/calendar_repository.dart';

// Use case khusus untuk menerima undangan dari deep link (via token)
class AcceptInvitationByToken {
  final CalendarRepository repository;

  AcceptInvitationByToken(this.repository);

  Future<void> call(String token) async {
    if (token.isEmpty) {
      throw Exception('Token undangan tidak valid.');
    }
    return await repository.acceptInvitationByToken(token);
  }
}