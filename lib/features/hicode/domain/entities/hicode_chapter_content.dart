import 'package:equatable/equatable.dart';

class HiCodeChapterContent extends Equatable {
  final String title;
  final String readTime;
  final String quizCount;
  final List<dynamic> contentBlocks;
  final double lastScrollPosition;
  final bool isQuizUnlocked;
  final bool isQuizless;

  const HiCodeChapterContent({
    required this.title,
    required this.readTime,
    required this.quizCount,
    required this.contentBlocks,
    required this.lastScrollPosition,
    required this.isQuizUnlocked,
    required this.isQuizless,
  });

  @override
  List<Object?> get props => [title, readTime, quizCount, contentBlocks, lastScrollPosition, isQuizUnlocked, isQuizless];
}