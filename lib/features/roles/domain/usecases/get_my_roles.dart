import 'package.himtika_mobile_information/features/auth/domain/usecases/get_current_user.dart';
import '../entities/role.dart';
import '../repositories/roles_repository.dart';

class GetMyRoles {
  final RolesRepository rolesRepository;
  final GetCurrentUser getCurrentUser;

  GetMyRoles({required this.rolesRepository, required this.getCurrentUser});

  Future<List<Role>> call() async {
    final user = await getCurrentUser();
    if (user == null) {
      throw Exception('Pengguna tidak ditemukan.');
    }
    return await rolesRepository.getRolesByUser(user.id);
  }
}