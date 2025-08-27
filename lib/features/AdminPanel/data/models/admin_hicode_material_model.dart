import '../../domain/entities/admin_hicode_material.dart';

class AdminHiCodeMaterialModel extends AdminHiCodeMaterial {
  const AdminHiCodeMaterialModel({
    required super.id,
    required super.title,
    super.categoryName,
    required super.chapterCount,
  });

  factory AdminHiCodeMaterialModel.fromMap(Map<String, dynamic> map) {
    return AdminHiCodeMaterialModel(
      id: map['id'],
      title: map['title'],
      categoryName: map['category_name'],
      chapterCount: (map['chapter_count'] as int?) ?? 0,
    );
  }
}