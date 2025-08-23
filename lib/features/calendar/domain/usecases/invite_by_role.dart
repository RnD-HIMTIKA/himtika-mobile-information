import 'package:himtika_mobile_information/features/roles/domain/entities/role.dart';
import '../repositories/calendar_repository.dart';

class InviteByRole {
  final CalendarRepository repository;

  InviteByRole(this.repository);

  Future<void> call({
    required String workspaceId,
    required List<Role> targetRoles,
    required String roleToGrant,
  }) async {
    // Validasi di sisi klien (sesuai konsep Anda)
    final hasKelas = targetRoles.any((r) => r.groupName == 'Kelas');
    final hasAngkatan = targetRoles.any((r) => r.groupName == 'Angkatan');

    if (hasKelas && !hasAngkatan) {
      throw Exception('Jika memilih Kelas, Anda juga wajib memilih Angkatan.');
    }
    if (targetRoles.isEmpty) {
      throw Exception('Anda harus memilih minimal satu role.');
    }

    // Ubah List<Role> menjadi List<String> berisi ID
    final targetRoleIds = targetRoles.map((r) => r.id).toList();
    
    return await repository.inviteByRole(
      workspaceId: workspaceId,
      targetRoleIds: targetRoleIds,
      roleToGrant: roleToGrant,
    );
  }
}