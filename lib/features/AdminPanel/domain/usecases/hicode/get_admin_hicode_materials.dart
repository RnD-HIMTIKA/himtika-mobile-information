import '../../entities/admin_hicode_material.dart';
import '../../repositories/hicode_management_repository.dart';

class GetAdminHiCodeMaterials {
  final HiCodeManagementRepository repository;
  GetAdminHiCodeMaterials(this.repository);

  Future<List<AdminHiCodeMaterial>> call() {
    return repository.getAdminMaterials();
  }
}