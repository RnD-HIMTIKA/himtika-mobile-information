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
    on<QuizManuallyUnlocked>(_onQuizManuallyUnlocked);
  }

  Future<void> _onFetchSubChapterData(
      FetchSubChapterData event, Emitter<SubChapterDetailState> emit) async {
    // Set isQuizUnlocked ke false di awal loading
    emit(state.copyWith(status: SubChapterDetailStatus.loading, isQuizUnlocked: false));
    try {
      final content = await _getChapterContent(event.subChapterId, event.userId);

      emit(state.copyWith(
        status: SubChapterDetailStatus.success,
        title: content.title,
        readTime: content.readTime,
        quizCount: content.quizCount,
        contentBlocks: content.contentBlocks,
        // Ambil nilai dari RPC
        lastScrollPosition: content.lastScrollPosition,
        isQuizUnlocked: content.isQuizUnlocked,
      ));

    } catch (e) {
      emit(state.copyWith(status: SubChapterDetailStatus.failure, errorMessage: e.toString()));
    }
  }

  // TAMBAHKAN HANDLER BARU:
  void _onQuizManuallyUnlocked(
    QuizManuallyUnlocked event,
    Emitter<SubChapterDetailState> emit,
  ) {
    // Handler ini hanya mengupdate UI jika diperlukan (misal setelah debounce selesai)
     if (state.status == SubChapterDetailStatus.success && !state.isQuizUnlocked) {
       emit(state.copyWith(isQuizUnlocked: true));
    }
  }
}