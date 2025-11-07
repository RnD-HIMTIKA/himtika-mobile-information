import 'package:himtika_mobile_information/features/calendar/domain/repositories/calendar_repository.dart';

class UpdateMemberRole {
  final CalendarRepository repository;
  UpdateMemberRole(this.repository);

  Future<void> call({
    required String workspaceId,
    required String userIdToUpdate,
    required String newRole,
  }) async {
    if (newRole != 'editor' && newRole != 'viewer') {
      throw Exception('Role tidak valid.');
    }
    return await repository.updateMemberRole(
      workspaceId: workspaceId,
      userIdToUpdate: userIdToUpdate,
      newRole: newRole,
    );
  }
}