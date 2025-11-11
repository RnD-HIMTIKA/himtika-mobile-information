part of 'chapter_management_bloc.dart';

abstract class ChapterManagementEvent extends Equatable {
  const ChapterManagementEvent();
  @override
  List<Object?> get props => [];
}

class LoadChapters extends ChapterManagementEvent {
  final String materialId;
  const LoadChapters(this.materialId);
  @override
  List<Object?> get props => [materialId];
}

class AddChapterSubmitted extends ChapterManagementEvent {
  final String materialId;
  final String title;
  final List<dynamic>? content;
  final int? estimatedReadTime;
  final bool isQuizless;
  
  const AddChapterSubmitted({
    required this.materialId,
    required this.title,
    required this.content,
    this.estimatedReadTime,
    required this.isQuizless,
  });
  @override
  List<Object?> get props => [materialId, title, content, estimatedReadTime, isQuizless];
}

class UpdateChapterSubmitted extends ChapterManagementEvent {
  final String id;
  final String? title;
  final List<dynamic>? content;
  final int? estimatedReadTime;
  final int? order;
  final bool? isQuizless;
  
  const UpdateChapterSubmitted({
    required this.id,
    this.title,
    this.content,
    this.estimatedReadTime,
    this.order,
    this.isQuizless,
  });
  @override
  List<Object?> get props => [id, title, content, estimatedReadTime, order, isQuizless];
}

class DeleteChapterPressed extends ChapterManagementEvent {
  final String id;
  const DeleteChapterPressed(this.id);
  @override
  List<Object?> get props => [id];
}

class ReorderChapters extends ChapterManagementEvent {
  final String materialId;
  final int oldIndex;
  final int newIndex;
  
  const ReorderChapters(this.materialId, this.oldIndex, this.newIndex);
  @override
  List<Object?> get props => [materialId, oldIndex, newIndex];
}