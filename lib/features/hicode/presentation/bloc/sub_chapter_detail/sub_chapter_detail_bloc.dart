import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';

part 'sub_chapter_detail_event.dart';
part 'sub_chapter_detail_state.dart';

class SubChapterDetailBloc
    extends Bloc<SubChapterDetailEvent, SubChapterDetailState> {
  SubChapterDetailBloc() : super(const SubChapterDetailState()) {
    on<FetchSubChapterData>(_onFetchSubChapterData);
  }

  Future<void> _onFetchSubChapterData(
      FetchSubChapterData event, Emitter<SubChapterDetailState> emit) async {
    emit(state.copyWith(status: SubChapterDetailStatus.loading));

    await Future.delayed(const Duration(milliseconds: 500));
    final parts = event.subChapterId.split('. '); // Pisahkan nomor dan judul
    final chapterNumber = parts[0]; // "1"
    final chapterTitle = parts[1];  // "Pengenalan CSS"

    final dynamicTitle = '#Chapter $chapterNumber\n$chapterTitle';

    // Sisa data dummy lainnya tetap sama
    const dummyReadTime = '10-15 Menit waktu pembaca';
    const dummyQuizCount = '2 Soal kuis';
    const dummyContent =
        'Lorem ipsum dolor sit amet consectetur adipiscing elit...';

    emit(state.copyWith(
      status: SubChapterDetailStatus.success,
      title: dynamicTitle, // Gunakan judul yang sudah dinamis
      readTime: dummyReadTime,
      quizCount: dummyQuizCount,
      content: dummyContent,
    ));
  }
}
