import '../../domain/entities/hicode_category.dart';

class HiCodeCategoryModel extends HiCodeCategory {
  const HiCodeCategoryModel({
    required super.id,
    required super.name,
    required super.iconUrl,
  });

  factory HiCodeCategoryModel.fromMap(Map<String, dynamic> map) {
    return HiCodeCategoryModel(
      id: map['id'],
      name: map['name'],
      iconUrl: map['icon_url'],
    );
  }
}