import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';

part 'sejarah_event.dart';
part 'sejarah_state.dart';

class SejarahBloc extends Bloc<SejarahEvent, SejarahState> {
  SejarahBloc() : super(const SejarahState()) {
    on<FetchSejarahData>(_onFetchSejarahData);
  }

  Future<void> _onFetchSejarahData(
      FetchSejarahData event, Emitter<SejarahState> emit) async {
    emit(state.copyWith(status: SejarahStatus.loading));
    await Future.delayed(const Duration(milliseconds: 500));

    const heroImagePath =
        'src/features/himtika/icon/himtika.png'; 
    const initialDescription =
        'Lahir dari semangat mahasiswa pada tahun 2012 dan tumbuh menjadi entitas resmi pada tahun 2017, memimpin dengan inovasi dalam teknologi di dalam kampus';
    const finalDescription =
        'Tanggal 16 Oktober 2017, HIMTIKA secara resmi didirikan di Aula Unsika. Dengan Akhmad Khusaeri sebagai ketua dan Adi Rohmat sebagai wakil ketua. Organisasi ini mulai menata struktur dan mengukuhkan diri sebagai entitas yang siap berkembang dan berkontribusi';

    const historyEntries = [
      {
        'type': 'timeline_start', 
        'title': 'Awal',
        'subTitle': 'Perjalanan',
        'description':
            'Tahun 2012, mahasiswa Teknik Informatika berupaya membentuk sebuah himpunan untuk mewadahi minat dan aspirasi mereka. Upaya awal ini berakhir dengan pendirian sebuah Study Club',
        'iconPath': 'src/features/himtika/icon/flag.png', 
        'alignment': 'left', 
      },
      {
        'type': 'timeline_point',
        'title': 'Inisiasi Pada',
        'subTitle': 'Kepengurusan BEMF', 
        'description':
            'Tahun 2014, selama kepengurusan BEMF, mahasiswa Teknik Informatika menginisiasi langkah penting untuk membentuk himpunan resmi. Langkah ini memperkuat komitmen mereka.',
        'iconPath': 'src/features/himtika/icon/share.png', 
        'alignment': 'right', 
      },
      {
        'type': 'timeline_point',
        'title': 'Musyawarah',
        'subTitle': 'Anggota Pertama',
        'description':
            'Tepat pada 14 Oktober 2017, dilaksanakan Musyawarah Anggota (MUSANG) pertama HIMTIKA. Momentum ini menjadi tonggak penting dalam proses pembentukan organisasi.',
        'iconPath': 'src/features/himtika/icon/users.png', 
        'alignment': 'left', 
      },
    ];

    emit(state.copyWith(
      status: SejarahStatus.success,
      heroImagePath: heroImagePath,
      initialDescription: initialDescription,
      finalDescription: finalDescription,
      historyEntries: historyEntries,
    ));
  }
}
