part of 'sub_chapter_detail_bloc.dart';

abstract class SubChapterDetailEvent extends Equatable {
  const SubChapterDetailEvent();
  @override
  List<Object> get props => [];
}

class QuizManuallyUnlocked extends SubChapterDetailEvent { 
  const QuizManuallyUnlocked(); 
}

class FetchSubChapterData extends SubChapterDetailEvent {
  final String subChapterId;
  final String userId; // Tambahkan ini
  const FetchSubChapterData({required this.subChapterId, required this.userId}); // Update constructor
  @override
  List<Object> get props => [subChapterId, userId]; // Update props
}