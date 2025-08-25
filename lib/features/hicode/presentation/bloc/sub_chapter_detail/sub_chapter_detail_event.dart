part of 'sub_chapter_detail_bloc.dart';

abstract class SubChapterDetailEvent extends Equatable {
  const SubChapterDetailEvent();
  @override
  List<Object> get props => [];
}

class FetchSubChapterData extends SubChapterDetailEvent {
  final String subChapterId;
  const FetchSubChapterData({required this.subChapterId});
  @override
  List<Object> get props => [subChapterId];
}