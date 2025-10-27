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

  const MaterialDetailState({
    this.status = MaterialDetailStatus.initial,
    this.title,
    this.description,
    this.materialIconPath,
    this.chapters = const [],
    this.errorMessage,
    this.finalPracticeStatus = 'locked',
  });

  MaterialDetailState copyWith({
    MaterialDetailStatus? status,
    String? title,
    String? description,
    String? materialIconPath,
    List<HiCodeChapter>? chapters,
    String? errorMessage,
    String? finalPracticeStatus,
  }) {
    return MaterialDetailState(
      status: status ?? this.status,
      title: title ?? this.title,
      description: description ?? this.description,
      materialIconPath: materialIconPath ?? this.materialIconPath,
      chapters: chapters ?? this.chapters,
      errorMessage: errorMessage ?? this.errorMessage,
      finalPracticeStatus: finalPracticeStatus ?? this.finalPracticeStatus,
    );
  }

  @override
  List<Object?> get props => [status, title, description, materialIconPath, chapters, errorMessage, finalPracticeStatus];
}