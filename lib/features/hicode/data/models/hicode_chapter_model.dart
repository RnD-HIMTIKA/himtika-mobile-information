import '../../domain/entities/hicode_chapter.dart';

class HiCodeChapterModel extends HiCodeChapter {
  const HiCodeChapterModel({
    required super.id,
    required super.title,
    required super.details,
    required super.isCompleted,
    required super.isLocked,
  });

  factory HiCodeChapterModel.fromMap(Map<String, dynamic> map) {
    return HiCodeChapterModel(
      id: map['id'],
      title: map['title'],
      details: map['details'] ?? 'Info tidak tersedia',
      isCompleted: map['is_completed'] ?? false,
      isLocked: map['is_locked'] ?? true,
    );
  }
}