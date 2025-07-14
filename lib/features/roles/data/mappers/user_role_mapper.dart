import '../../domain/entities/user_role.dart';
import '../models/user_role_model.dart';

class UserRoleMapper {
  static UserRole toEntity(UserRoleModel model) {
    return UserRole(
      userId: model.userId,
      roleId: model.roleId,
    );
  }

  static UserRoleModel toModel(UserRole entity) {
    return UserRoleModel(
      userId: entity.userId,
      roleId: entity.roleId,
    );
  }
}