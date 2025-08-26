import '../../domain/entities/hicode_chapter_content.dart';

class HiCodeChapterContentModel extends HiCodeChapterContent {
  const HiCodeChapterContentModel({
    required super.title,
    required super.readTime,
    required super.quizCount,
    required super.contentBlocks,
  });

  factory HiCodeChapterContentModel.fromMap(Map<String, dynamic> map) {
    return HiCodeChapterContentModel(
      title: map['title'] ?? 'Tanpa Judul',
      readTime: map['read_time'] ?? 'Waktu tidak tersedia',
      quizCount: map['quiz_count'] ?? 'Info kuis tidak tersedia',
      contentBlocks: List<Map<String, dynamic>>.from(map['content_blocks'] ?? []),
    );
  }
}