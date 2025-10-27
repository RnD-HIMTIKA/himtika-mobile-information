import '../../domain/entities/hicode_chapter_content.dart';

class HiCodeChapterContentModel extends HiCodeChapterContent {
  const HiCodeChapterContentModel({
    required super.title,
    required super.readTime,
    required super.quizCount,
    required super.contentBlocks,
    required super.lastScrollPosition,
    required super.isQuizUnlocked,
  });

  factory HiCodeChapterContentModel.fromMap(Map<String, dynamic> map) {
    return HiCodeChapterContentModel(
      title: map['title'] ?? 'Tanpa Judul',
      readTime: map['read_time'] ?? 'Waktu tidak tersedia',
      quizCount: map['quiz_count'] ?? 'Info kuis tidak tersedia',
      contentBlocks: List<Map<String, dynamic>>.from(map['content_blocks'] ?? []),
      lastScrollPosition: (map['last_scroll_position'] as num?)?.toDouble() ?? 0.0,
      isQuizUnlocked: map['is_quiz_unlocked'] as bool? ?? false, // Ambil dari RPC
    );
  }
}