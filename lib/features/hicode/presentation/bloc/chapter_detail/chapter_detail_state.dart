part of 'chapter_detail_bloc.dart';

enum MaterialDetailStatus { initial, loading, success, failure }

class MaterialDetailState extends Equatable {
  final MaterialDetailStatus status;
  final String? title;
  final String? description;
  final String? materialIconPath;
  final List<HiCodeChapter> chapters;
  final String? errorMessage;
  final String finalPracticeStatus;
  final int finalPracticeQuestionCount;

  const MaterialDetailState({
    this.status = MaterialDetailStatus.initial,
    this.title,
    this.description,
    this.materialIconPath,
    this.chapters = const [],
    this.errorMessage,
    this.finalPracticeStatus = 'locked',
    this.finalPracticeQuestionCount = 0,
  });

  MaterialDetailState copyWith({
    MaterialDetailStatus? status,
    String? title,
    String? description,
    String? materialIconPath,
    List<HiCodeChapter>? chapters,
    String? errorMessage,
    String? finalPracticeStatus,
    int? finalPracticeQuestionCount,
  }) {
    return MaterialDetailState(
      status: status ?? this.status,
      title: title ?? this.title,
      description: description ?? this.description,
      materialIconPath: materialIconPath ?? this.materialIconPath,
      chapters: chapters ?? this.chapters,
      errorMessage: errorMessage ?? this.errorMessage,
      finalPracticeStatus: finalPracticeStatus ?? this.finalPracticeStatus,
      finalPracticeQuestionCount: finalPracticeQuestionCount ?? this.finalPracticeQuestionCount,
    );
  }

  @override
  List<Object?> get props => [status, title, description, materialIconPath, chapters, errorMessage, finalPracticeStatus, finalPracticeQuestionCount];
}