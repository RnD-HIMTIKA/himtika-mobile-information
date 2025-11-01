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
    // Parsing content sebagai List<dynamic>
    List<dynamic>? contentList;
    if (map['content'] is List) {
       contentList = map['content'] as List<dynamic>?;
    } else if (map['content'] is Map && (map['content'] as Map).containsKey('blocks')) {
       // Fallback jika format lama {"blocks": [...]} masih ada di DB
       contentList = (map['content'] as Map)['blocks'] as List<dynamic>?;
    }
    return HiCodeChapterModel(
      id: map['id'] as String,
      materialId: map['material_id'] as String,
      title: map['title'] as String,
      content: contentList,
      estimatedReadTime: map['estimated_read_time'] as int?,
      order: map['order'] as int,
      createdAt: DateTime.parse(map['created_at'] as String),
    );
  }

  @override
  Map<String, dynamic> toMap() { // toMap tidak terlalu relevan karena kita kirim ke RPC
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