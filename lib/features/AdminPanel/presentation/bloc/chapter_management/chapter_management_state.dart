part of 'chapter_management_bloc.dart';

enum ChapterManagementStatus { initial, loading, success, failure }

class ChapterManagementState extends Equatable {
  final ChapterManagementStatus status;
  final List<HiCodeChapter> chapters;
  final String? errorMessage;
  final String? currentMaterialId;

  const ChapterManagementState({
    this.status = ChapterManagementStatus.initial,
    this.chapters = const [],
    this.errorMessage,
    this.currentMaterialId,
  });

  ChapterManagementState copyWith({
    ChapterManagementStatus? status,
    List<HiCodeChapter>? chapters,
    String? errorMessage,
    String? currentMaterialId,
  }) {
    return ChapterManagementState(
      status: status ?? this.status,
      chapters: chapters ?? this.chapters,
      errorMessage: errorMessage ?? this.errorMessage,
      currentMaterialId: currentMaterialId ?? this.currentMaterialId,
    );
  }

  @override
  List<Object?> get props => [status, chapters, errorMessage, currentMaterialId];
}