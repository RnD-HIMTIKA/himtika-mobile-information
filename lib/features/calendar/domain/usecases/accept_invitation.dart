import '../repositories/calendar_repository.dart';

class AcceptInvitation {
  final CalendarRepository repository;
  AcceptInvitation(this.repository);

  // Sekarang menerima token, bukan ID
  Future<void> call(String token) async {
    if (token.isEmpty) {
      throw Exception('Token undangan tidak valid.');
    }
    return await repository.acceptInvitation(token);
  }
}