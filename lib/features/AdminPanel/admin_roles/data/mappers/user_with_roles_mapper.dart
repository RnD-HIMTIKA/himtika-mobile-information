import '../models/user_with_roles_model.dart';
import '../../domain/entities/user_with_roles.dart';

class UserWithRolesMapper {
  static UserWithRoles fromModel(UserWithRolesModel model) => model.toEntity();
}