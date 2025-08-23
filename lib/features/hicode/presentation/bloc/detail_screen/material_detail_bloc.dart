import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';


part 'material_detail_event.dart';
part 'material_detail_state.dart';

enum SubChapterStatus { locked, available, completed }

class MaterialDetailBloc
    extends Bloc<MaterialDetailEvent, MaterialDetailState> {
  MaterialDetailBloc() : super(const MaterialDetailState()) {
    on<FetchDetailData>(_onFetchDetailData);
    on<SearchQueryChanged>(_onSearchQueryChanged); // 1. Daftarkan event handler baru untuk pencarian
  }

  void _onFetchDetailData(
      FetchDetailData event, Emitter<MaterialDetailState> emit) {
    emit(state.copyWith(status: MaterialDetailStatus.loading));

    // --- LOGIKA PEMILIHAN IKON DAN DESKRIPSI ---
    String iconPath = 'assets/icons/default.png';
    String description = 'Deskripsi materi belum tersedia.';

    if (event.materialId.contains('HTML')) {
      iconPath = 'src/features/hicode/materi/html.png';
      description =
          'Berisi materi pengenalan HTML sebagai bahasa dasar pembuatan halaman web, lengkap dengan contoh elemen dan struktur dasarnya.';
    } else if (event.materialId.contains('CSS')) {
      iconPath = 'src/features/hicode/materi/css.png';
      description =
          'Materi ini membahas dasar penggunaan CSS untuk mengatur tampilan halaman web, mulai dari warna, ukuran, hingga tata letak elemen.';
    } else if (event.materialId.contains('JavaScript')) {
      iconPath = 'src/features/hicode/materi/js.png';
      description =
          'Materi ini mengenalkan dasar JavaScript untuk membuat halaman web menjadi dinamis, seperti menangani aksi pengguna dan memproses data.';
    } else if (event.materialId.contains('C++')) {
      iconPath = 'src/features/hicode/materi/cpp.png';
      description =
          'Materi ini membahas dasar pemrograman C++, mulai dari struktur kode, penggunaan variabel, hingga logika kondisi dan perulangan.';
    }

    // Data Dummy
    final dummySubChapters = [
      {
        'title': '1. Pengantar HTML',
        'details': '2 Soal Quiz',
        'status': SubChapterStatus.completed,
      },
      {
        'title': '2. Selektor dan Properti',
        'details': '3 Soal Quiz',
        'status': SubChapterStatus.completed,
      },
      {
        'title': '3. Pengenalan CSS',
        'details': '2 Soal Quiz',
        'status': SubChapterStatus.available,
      },
      {
        'title': '4. Flexbox',
        'details': '2 Soal Quiz',
        'status': SubChapterStatus.available,
      },
    ];

    final dummyFinalExam = {
      'title': 'Latihan Soal Final',
      'details': '10 Soal',
      'status': SubChapterStatus.available,
    };

    emit(state.copyWith(
      status: MaterialDetailStatus.success,
      title: event.materialId,
      description: description,
      subChapters: dummySubChapters,
      finalExamStatus: dummyFinalExam,
      materialIconPath: iconPath,
      filteredSubChapters: dummySubChapters,
    ));
  }

  // 3. Tambahkan method baru ini untuk logika pemfilteran
  void _onSearchQueryChanged(
      SearchQueryChanged event, Emitter<MaterialDetailState> emit) {
    final query = event.query.toLowerCase();

    final filteredList = state.subChapters.where((subChapter) {
      final title = subChapter['title']!.toLowerCase();
      return title.contains(query);
    }).toList();

    emit(state.copyWith(
      searchQuery: query,
      filteredSubChapters: filteredList,
    ));
  }
}