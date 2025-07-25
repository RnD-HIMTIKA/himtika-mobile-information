import '../../domain/entities/permission.dart';

class PermissionModel {
  final String featureName;
  final String actionName;

  PermissionModel({
    required this.featureName,
    required this.actionName,
  });

  factory PermissionModel.fromJson(Map<String, dynamic> json) {
    return PermissionModel(
      featureName: json['feature_name'] as String,
      actionName: json['action_name'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'feature_name': featureName,
      'action_name': actionName,
    };
  }

  Permission toEntity() {
    return Permission(
      featureName: featureName,
      actionName: actionName,
    );
  }

  factory PermissionModel.fromEntity(Permission entity) {
    return PermissionModel(
      featureName: entity.featureName,
      actionName: entity.actionName,
    );
  }
}