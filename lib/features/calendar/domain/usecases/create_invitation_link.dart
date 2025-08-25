import '../repositories/calendar_repository.dart';

class CreateInvitationLink {
  final CalendarRepository repository;

  CreateInvitationLink(this.repository);

  // Mengambil ID workspace dan peran, lalu mengembalikan token unik
  Future<String> call({
    required String workspaceId,
    required String role,
  }) async {
    return await repository.createInvitationLink(workspaceId: workspaceId, role: role);
  }
}