import 'package:himtika_mobile_information/features/auth/domain/usecases/get_current_user.dart';
import '../entities/role.dart';
import '../repositories/roles_repository.dart';

class GetMyRoles {
  final RolesRepository rolesRepository;
  final GetCurrentUser getCurrentUser;

  /// FLAG TESTING: Ubah ke `false` jika testing sudah selesai untuk kembali ke mode normal.
  static const bool isTestingBypassAdmin = true;

  GetMyRoles({required this.rolesRepository, required this.getCurrentUser});

  Future<List<Role>> call() async {
    if (isTestingBypassAdmin) {
      return const [
        Role(
          id: 'dev_admin_testing_id',
          name: 'Admin',
          groupName: 'Pengurus',
        ),
      ];
    }

    final user = await getCurrentUser();
    if (user == null) {
      throw Exception('Pengguna tidak ditemukan.');
    }
    return await rolesRepository.getRolesByUser(user.id);
  }
}