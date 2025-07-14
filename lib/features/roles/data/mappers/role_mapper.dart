import '../../domain/entities/role.dart';
import '../models/role_model.dart';

class RoleMapper {
  static Role toEntity(RoleModel model) {
    return Role(
      id: model.id,
      name: model.name,
      groupName: model.groupName,
    );
  }

  static RoleModel toModel(Role entity) {
    return RoleModel(
      id: entity.id,
      name: entity.name,
      groupName: entity.groupName,
    );
  }
}