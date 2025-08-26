part of 'sub_chapter_detail_bloc.dart';

enum SubChapterDetailStatus { initial, loading, success, failure }

class SubChapterDetailState extends Equatable {
  final SubChapterDetailStatus status;
  final String? title;
  final String? readTime;
  final String? quizCount;
  final List<Map<String, dynamic>> contentBlocks; // Menggunakan List untuk blok konten
  final String? errorMessage;
  final bool isQuizUnlocked;

  const SubChapterDetailState({
    this.status = SubChapterDetailStatus.initial,
    this.title,
    this.readTime,
    this.quizCount,
    this.contentBlocks = const [],
    this.errorMessage,
    this.isQuizUnlocked = false,
  });

  SubChapterDetailState copyWith({
    SubChapterDetailStatus? status,
    String? title,
    String? readTime,
    String? quizCount,
    List<Map<String, dynamic>>? contentBlocks,
    String? errorMessage,
    bool? isQuizUnlocked,
  }) {
    return SubChapterDetailState(
      status: status ?? this.status,
      title: title ?? this.title,
      readTime: readTime ?? this.readTime,
      quizCount: quizCount ?? this.quizCount,
      contentBlocks: contentBlocks ?? this.contentBlocks,
      errorMessage: errorMessage ?? this.errorMessage,
      isQuizUnlocked: isQuizUnlocked ?? this.isQuizUnlocked,
    );
  }

  @override
  List<Object?> get props => [status, title, readTime, quizCount, contentBlocks, errorMessage, isQuizUnlocked];
}