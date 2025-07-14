import '../../domain/entities/permission.dart';
import '../models/permission_model.dart';

class PermissionMapper {
  static Permission toEntity(PermissionModel model) {
    return Permission(
      id: model.id,
      featureName: model.featureName,
      actionName: model.actionName,
    );
  } 

   static PermissionModel toModel(Permission entity) {
    return PermissionModel(
      id: entity.id,
      featureName: entity.featureName,
      actionName: entity.actionName,
    );
   }
}