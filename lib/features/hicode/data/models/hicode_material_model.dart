import '../../domain/entities/hicode_material.dart';

class HiCodeMaterialModel extends HiCodeMaterial {
  const HiCodeMaterialModel({
    required super.id,
    required super.title,
    super.imageUrl,
    super.borderColor,
    required super.totalChapters,
    required super.completedChapters,
  });

  factory HiCodeMaterialModel.fromMap(Map<String, dynamic> map) {
    return HiCodeMaterialModel(
      id: map['id'],
      title: map['title'],
      imageUrl: map['image_url'],
      borderColor: map['border_color'],
      totalChapters: (map['total_chapters'] as int?) ?? 0,
      completedChapters: (map['completed_chapters'] as int?) ?? 0,
    );
  }
}