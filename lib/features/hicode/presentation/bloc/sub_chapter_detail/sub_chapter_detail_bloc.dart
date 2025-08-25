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

    // --- LOGIKA DINAMIS YANG SUDAH AMAN ---
    String dynamicTitle;
    final parts = event.subChapterId.split('. ');

    // Cek apakah hasil split memiliki lebih dari 1 elemen
    if (parts.length > 1) {
      // Jika formatnya "Nomor. Judul", proses seperti biasa
      final chapterNumber = parts[0];
      final chapterTitle = parts[1];
      dynamicTitle = '#Chapter $chapterNumber\n$chapterTitle';
    } else {
      // Jika formatnya tidak sesuai, gunakan judul apa adanya
      dynamicTitle = event.subChapterId;
    }

    // Sisa data dummy lainnya tetap sama
    const dummyReadTime = '10-15 Menit waktu pembaca';
    const dummyQuizCount = '2 Soal kuis';
    const dummyContent =
        'Lorem ipsum dolor sit amet consectetur adipiscing elit...';

    emit(state.copyWith(
      status: SubChapterDetailStatus.success,
      title: dynamicTitle, // Gunakan judul yang sudah dinamis dan aman
      readTime: dummyReadTime,
      quizCount: dummyQuizCount,
      content: dummyContent,
    ));
  }
}
