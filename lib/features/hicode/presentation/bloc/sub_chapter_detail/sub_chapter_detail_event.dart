part of 'sub_chapter_detail_bloc.dart';

abstract class SubChapterDetailEvent extends Equatable {
  const SubChapterDetailEvent();
  @override
  List<Object> get props => [];
}

// --- TAMBAHKAN EVENT INI ---
// Event untuk unlock UI secara instan
class QuizManuallyUnlocked extends SubChapterDetailEvent {
  const QuizManuallyUnlocked();
}
// --- END TAMBAHAN ---

class FetchSubChapterData extends SubChapterDetailEvent {
  final String subChapterId;
  final String userId; // Pastikan userId ada
  const FetchSubChapterData({required this.subChapterId, required this.userId});
  @override
  List<Object> get props => [subChapterId, userId];
}
