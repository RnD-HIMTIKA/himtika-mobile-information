import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../domain/usecases/get_chapter_content.dart';

part 'sub_chapter_detail_event.dart';
part 'sub_chapter_detail_state.dart';

class SubChapterDetailBloc extends Bloc<SubChapterDetailEvent, SubChapterDetailState> {
  final GetChapterContent _getChapterContent;

  SubChapterDetailBloc({required GetChapterContent getChapterContent})
      : _getChapterContent = getChapterContent,
        super(const SubChapterDetailState()) {
    on<FetchSubChapterData>(_onFetchSubChapterData);
  }

  Future<void> _onFetchSubChapterData(
      FetchSubChapterData event, Emitter<SubChapterDetailState> emit) async {
    emit(state.copyWith(status: SubChapterDetailStatus.loading));
    try {
      final content = await _getChapterContent(event.subChapterId);
      
      emit(state.copyWith(
        status: SubChapterDetailStatus.success,
        title: content.title,
        readTime: content.readTime,
        quizCount: content.quizCount,
        contentBlocks: content.contentBlocks,
        isQuizUnlocked: true, // Untuk saat ini, kita anggap kuis selalu terbuka
      ));

    } catch (e) {
      emit(state.copyWith(status: SubChapterDetailStatus.failure, errorMessage: e.toString()));
    }
  }
}