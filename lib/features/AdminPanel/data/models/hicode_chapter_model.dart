import '../../domain/entities/hicode_chapter.dart';

class HiCodeChapterModel extends HiCodeChapter {
  const HiCodeChapterModel({
    required super.id,
    required super.materialId,
    required super.title,
    super.content,
    super.estimatedReadTime,
    required super.order,
    required super.createdAt,
  });

  factory HiCodeChapterModel.fromMap(Map<String, dynamic> map) {
    return HiCodeChapterModel(
      id: map['id'] as String,
      materialId: map['material_id'] as String,
      title: map['title'] as String,
      content: map['content'] as Map<String, dynamic>?,
      estimatedReadTime: map['estimated_read_time'] as int?,
      order: map['order'] as int,
      createdAt: DateTime.parse(map['created_at'] as String),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'material_id': materialId,
      'title': title,
      'content': content,
      'estimated_read_time': estimatedReadTime,
      'order': order,
      'created_at': createdAt.toIso8601String(),
    };
  }
}