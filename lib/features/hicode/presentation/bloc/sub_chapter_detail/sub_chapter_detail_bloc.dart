import 'package:sentry_flutter/sentry_flutter.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:himtika_mobile_information/features/hicode/domain/usecases/get_chapter_content.dart';

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
    // Pastikan isQuizUnlocked = false saat loading awal
    emit(state.copyWith(status: SubChapterDetailStatus.loading, isQuizUnlocked: false));
    try {
      // Pastikan use case dipanggil dengan 2 argumen
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

    } catch (e, stackTrace) { // <-- UBAH
      // 1. Log Licik
      Sentry.captureException(e, stackTrace: stackTrace);
      // 2. Pesan Profesional
      String message = "Gagal memuat materi chapter.";
      if (e.toString().toLowerCase().contains('socket')) {
        message = "Koneksi gagal. Periksa internet Anda.";
      }
      emit(state.copyWith(
          status: SubChapterDetailStatus.failure,
          errorMessage: message)); // <-- Pesan profesional
    }
  }

  void _onQuizManuallyUnlocked(
    QuizManuallyUnlocked event,
    Emitter<SubChapterDetailState> emit,
  ) {
    // Handler ini hanya mengupdate UI (isQuizUnlocked) secara instan
    if (state.status == SubChapterDetailStatus.success && !state.isQuizUnlocked) {
       emit(state.copyWith(isQuizUnlocked: true));
    }
  }
}
