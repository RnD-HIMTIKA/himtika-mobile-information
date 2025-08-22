import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';

part 'material_detail_event.dart';
part 'material_detail_state.dart';

enum SubChapterStatus { locked, available, completed }

class MaterialDetailBloc
    extends Bloc<MaterialDetailEvent, MaterialDetailState> {
  MaterialDetailBloc() : super(const MaterialDetailState()) {
    on<FetchDetailData>(_onFetchDetailData);
  }

  void _onFetchDetailData(
      FetchDetailData event, Emitter<MaterialDetailState> emit) {
    emit(state.copyWith(status: MaterialDetailStatus.loading));

    // --- TAMBAHKAN LOGIKA PEMILIHAN IKON DI SINI ---
    String iconPath = 'assets/icons/default.png'; // Ikon default jika tidak ketemu
    if (event.materialId.contains('HTML')) {
      iconPath = 'src/features/hicode/materi/html.png';
    } else if (event.materialId.contains('CSS')) {
      iconPath = 'src/features/hicode/materi/css.png';
    } else if (event.materialId.contains('JavaScript')) {
      iconPath = 'src/features/hicode/materi/js.png';
    } else if (event.materialId.contains('C++')) {
      iconPath = 'src/features/hicode/materi/cpp.png';
    }

    // Data Dummy
    final dummySubChapters = [
      {
        'title': '1. Pengenalan CSS',
        'details': '2 Soal Quiz',
        'status': SubChapterStatus.completed, // Selesai
      },
      {
        'title': '2. Pengenalan CSS',
        'details': '2 Soal Quiz',
        'status': SubChapterStatus.completed, // Selesai
      },
      {
        'title': '3. Pengenalan CSS',
        'details': '2 Soal Quiz',
        'status': SubChapterStatus.available, // Tersedia/Bisa dikerjakan
      },
      {
        'title': '4. Pengenalan CSS',
        'details': '2 Soal Quiz',
        'status': SubChapterStatus.locked, // Terkunci
      },
    ];

    final dummyFinalExam = {
      'title': 'Latihan Soal Final',
      'details': '10 Soal • Belum Dapat Dikerjakan',
      'status': SubChapterStatus.locked,
    };

    emit(state.copyWith(
      status: MaterialDetailStatus.success,
      title: event.materialId, // Menggunakan ID sebagai judul
      description:
          'Materi ini membahas dasar-dasar dari ${event.materialId}.',
      subChapters: dummySubChapters,
      finalExamStatus: dummyFinalExam,
      materialIconPath: iconPath, // Kirim path ikon yang sudah ditentukan ke state
    ));
  }
}