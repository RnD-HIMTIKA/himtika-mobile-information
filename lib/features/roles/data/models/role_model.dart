import '../../domain/entities/role.dart';

class RoleModel extends Role {
  RoleModel({
    required super.id,
    required super.name,
    required super.groupName,
  });

  factory RoleModel.fromJson(Map<String, dynamic> json) {
    return RoleModel(
      id: json['id'] as String,
      name: json['name'] as String,
      groupName: json['group_name'] as String, // perbaikan
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'group_name': groupName,
      };

  Role toEntity() => Role(
        id: id,
        name: name,
        groupName: groupName,
      );
}