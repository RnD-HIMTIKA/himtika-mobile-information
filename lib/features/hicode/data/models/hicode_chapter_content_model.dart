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
    
    List<dynamic> parsedContentBlocks = []; // Default list kosong
    final dynamic rawContent = map['content_blocks']; // Ambil data dari RPC

    // --- LOGIKA PERBAIKAN ERROR ---
    if (rawContent is List) {
      // KASUS 1: Data sudah format baru (Delta JSON List)
      // Ini adalah yang kita harapkan dari RPC baru dan data baru
      parsedContentBlocks = rawContent;
    } else if (rawContent is Map && rawContent.containsKey('blocks') && rawContent['blocks'] is List) {
      // KASUS 2: Data masih format lama (Map {"blocks": [...]})
      // Ini terjadi jika RPC masih lama ATAU data di DB masih lama
      parsedContentBlocks = rawContent['blocks'] as List<dynamic>;
    }
    // Jika rawContent adalah Map tapi tidak punya key 'blocks' (sesuai error Anda),
    // atau null, atau format lain, maka parsedContentBlocks akan tetap list kosong.
    // --- AKHIR LOGIKA PERBAIKAN ---

    return HiCodeChapterContentModel(
      title: map['title'] ?? 'Tanpa Judul',
      readTime: map['read_time'] ?? 'Waktu tidak tersedia',
      quizCount: map['quiz_count'] ?? 'Info kuis tidak tersedia',
      contentBlocks: parsedContentBlocks, // <-- Gunakan hasil parsing
      lastScrollPosition: (map['last_scroll_position'] as num?)?.toDouble() ?? 0.0,
      isQuizUnlocked: map['is_quiz_unlocked'] as bool? ?? false,
    );
  }
}