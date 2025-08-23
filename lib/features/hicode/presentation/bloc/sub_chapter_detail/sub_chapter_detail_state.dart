part of 'sub_chapter_detail_bloc.dart';

enum SubChapterDetailStatus { initial, loading, success, failure }

class SubChapterDetailState extends Equatable {
  const SubChapterDetailState({
    this.status = SubChapterDetailStatus.initial,
    this.title,
    this.readTime,
    this.quizCount,
    this.content,
  });

  final SubChapterDetailStatus status;
  final String? title;
  final String? readTime;
  final String? quizCount;
  final String? content;

  SubChapterDetailState copyWith({
    SubChapterDetailStatus? status,
    String? title,
    String? readTime,
    String? quizCount,
    String? content,
  }) {
    return SubChapterDetailState(
      status: status ?? this.status,
      title: title ?? this.title,
      readTime: readTime ?? this.readTime,
      quizCount: quizCount ?? this.quizCount,
      content: content ?? this.content,
    );
  }

  @override
  List<Object?> get props => [status, title, readTime, quizCount, content];
}