import '../../domain/entities/role.dart';

class RoleModel extends Role {
  RoleModel ({
    required super.id,
    required super.name,
    required super.groupName,
  });

  factory RoleModel.fromJson (Map<String, dynamic> json) {
    return RoleModel(
      id: json['id'] as String,
      name: json['name'] as String,
      groupName: json['groupName'] as String,
    );
  }
}