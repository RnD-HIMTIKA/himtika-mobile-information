import '../../domain/entities/permission.dart';
import '../models/permission_model.dart';

class PermissionMapper {
  static Permission toEntity(PermissionModel model) {
    return Permission(
      featureName: model.featureName,
      actionName: model.actionName,
    );
  }

  static PermissionModel toModel(Permission entity) {
    return PermissionModel(
      featureName: entity.featureName,
      actionName: entity.actionName,
    );
  }
}