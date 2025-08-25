import '../entities/invitation.dart';
import '../repositories/calendar_repository.dart';

class GetMyInvitations {
  final CalendarRepository repository;
  GetMyInvitations(this.repository);

  Future<List<Invitation>> call() async {
    return await repository.getMyInvitations();
  }
}