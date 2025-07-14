import '../../domain/entities/role.dart';
import '../models/role_model.dart';

class RoleMapper {
  static Role toEntitiy(RoleModel model) {
    return Role(
      id: model.id,
      name: model.name,
      groupName: model.groupName,
    );
  }
}