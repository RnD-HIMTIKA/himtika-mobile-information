part of 'sub_chapter_detail_bloc.dart';

enum SubChapterDetailStatus { initial, loading, success, failure }

class SubChapterDetailState extends Equatable {
  final SubChapterDetailStatus status;
  final String? title;
  final String? readTime;
  final String? quizCount;
  final List<dynamic> contentBlocks;
  final String? errorMessage;
  final bool isQuizUnlocked;
  final double lastScrollPosition;
  final bool isQuizless;

  const SubChapterDetailState({
    this.status = SubChapterDetailStatus.initial,
    this.title,
    this.readTime,
    this.quizCount,
    this.contentBlocks = const [],
    this.errorMessage,
    this.isQuizUnlocked = false,
    this.lastScrollPosition = 0.0,
    this.isQuizless = false,
  });

  SubChapterDetailState copyWith({
    SubChapterDetailStatus? status,
    String? title,
    String? readTime,
    String? quizCount,
    List<dynamic>? contentBlocks,
    String? errorMessage,
    bool? isQuizUnlocked,
    double? lastScrollPosition,
    bool? isQuizless,
  }) {
    return SubChapterDetailState(
      status: status ?? this.status,
      title: title ?? this.title,
      readTime: readTime ?? this.readTime,
      quizCount: quizCount ?? this.quizCount,
      contentBlocks: contentBlocks ?? this.contentBlocks,
      errorMessage: errorMessage ?? this.errorMessage,
      isQuizUnlocked: isQuizUnlocked ?? this.isQuizUnlocked,
      lastScrollPosition: lastScrollPosition ?? this.lastScrollPosition,
      isQuizless: isQuizless ?? this.isQuizless,
    );
  }

  @override
  List<Object?> get props => [status, title, readTime, quizCount, contentBlocks, errorMessage, isQuizUnlocked, lastScrollPosition, isQuizless];
}