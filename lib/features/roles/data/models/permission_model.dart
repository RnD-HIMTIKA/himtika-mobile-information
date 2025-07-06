import '../../domain/entities/permission.dart';

class PermissionModel extends Permission {
  PermissionModel ({
    required super.featureName,
    required super.actionName,
  });

  factory PermissionModel.fromJson(Map<String, dynamic> json) {
    return PermissionModel(
      featureName: json['featureName'] as String,
      actionName: json['actionName'] as String,
    );
  }
}