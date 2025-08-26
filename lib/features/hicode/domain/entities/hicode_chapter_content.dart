import 'package:equatable/equatable.dart';

class HiCodeChapterContent extends Equatable {
  final String title;
  final String readTime;
  final String quizCount;
  final List<Map<String, dynamic>> contentBlocks;

  const HiCodeChapterContent({
    required this.title,
    required this.readTime,
    required this.quizCount,
    required this.contentBlocks,
  });

  @override
  List<Object?> get props => [title, readTime, quizCount, contentBlocks];
}