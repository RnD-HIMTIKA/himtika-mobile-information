import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';

part 'about_himtika_event.dart';
part 'about_himtika_state.dart';

class AboutHimtikaBloc extends Bloc<AboutHimtikaEvent, AboutHimtikaState> {
  AboutHimtikaBloc() : super(const AboutHimtikaState()) {
    on<FetchAboutData>(_onFetchAboutData);
  }

  Future<void> _onFetchAboutData(
      FetchAboutData event, Emitter<AboutHimtikaState> emit) async {
    emit(state.copyWith(status: AboutHimtikaStatus.loading));

    // --- Data Dummy Dipindahkan ke Sini ---
    const heroImagePath = 'src/features/himtika/icon/himtika.png';

    const aboutParagraph =
        'Himtika merupakan Himpunan Mahasiswa Informatika Unsika yang menjadi wadah bagi mahasiswa informatika agar dapat berkembang dan berprestasi.';

    const visiParagraph =
        'Mengembangkan HIMTIKA sebagai sebuah Organisasi aktif yang menaungi dan bersinergi dengan Mahasiswa Informatika UNSIKA untuk Merealisasikan Lingkungan Informatika yang Eksploratif, Kolaboratif, dan Prestatif yang berasaskan rasa kekeluargaan dan profesionalitas.';

    const misiParagraph =
        '1. Menciptakan Sinergi yang berkelanjutan untuk membangun dan meningkatkan semangat berkarya dan berinovasi dalam ranah akademik dan non akademik maupun keorganisasian.\n\n'
        '2. Mengaktualisasikan HIMTIKA sebagai sarana pengembangan akademik dan keilmuan Mahasiswa Informatika UNSIKA guna meningkatkan Eksplorasi, Inovasi, serta Kreatifitas untuk membentuk Mahasiswa yang Berprestasi di Tingkat Nasional maupun Internasional.\n\n'
        '3. Memperkuat semangat kekeluargaan di lingkup internal maupun eksternal yang dijiwai rasa profesionalisme yang berimbang.\n\n'
        '4. Memfasilitasi Mahasiswa Informatika untuk mengembangkan softskill dan hardskill yang diperlukan untuk menunjuang kehidupan perkuliahan Mahasiswa Informatika UNSIKA.\n\n'
        '5. Menjalankan Program Kerja yang relevan dan sesuai dengan kebutuhan Mahasiswa Informatika UNSIKA dan nilai kebermanfaatan bagi kehidupan Mahasiswa Informatika di masa yang akan datang.\n\n'
        '6. Menyelenggarakan dan Mengoptimalkan Kegiatan yang mendukung tercapainya Mahasiswa Informatika yang aktif, memiliki solidaritas yang tinggi, berintegritas serta wawasan dan keterampilan dalam bidang teknologi informasi yang berkompeten.';

    const logoMeanings = [
      {
        'icon': 'src/features/himtika/logo/gear.png',
        'title': 'GEAR',
        'description':
            'Melambangkan suatu makna yaitu terus berputar dan berjalan tanpa lelah dengan memegang teguh pada komitmennya.'
      },
      {
        'icon': 'src/features/himtika/logo/gear.png',
        'title': 'GEAR BERWARNA CYAN',
        'description':
            'Merupakan warna yang menginspirasi kebijaksanaan, kesatuan, loyalitas dan membawa suasana harmonis.'
      },
      {
        'icon': 'src/features/himtika/logo/gear.png',
        'title': 'MATA GEAR BERJUMLAH 9',
        'description': 'Melambangkan berdirinya HIMTIKA UNSIKA di generasi ke-9'
      },
      {
        'icon': 'src/features/himtika/logo/parabola.png',
        'title': 'PARABOLA',
        'description':
            'Melambangkan di dalam HIMTIKA mampu memberikan wawasan yang luas dalam segi keilmuan dan relasi. '
      },
      {
        'icon': 'src/features/himtika/logo/abuabu.png',
        'title': 'WARNA ABU-ABU',
        'description':
            'Merupakan ciri khas/identitas dari Fakultas Ilmu Komputer Universitas Singaperbangsa Karawang.'
      },
      {
        'icon': 'src/features/himtika/logo/sinyal.png',
        'title': 'SINYAL BERWARNA MERAH MAROON',
        'description':
            'Melambangkan semangat untuk tholabul ilmi dan suatu keberanian dalam bereksperimen dan merupakan warna ciri khas dan almamater Universitas Singaperbangsa Karawang.'
      },
      {
        'icon': 'src/features/himtika/logo/if.png',
        'title': 'IF BERWARNA KUNING',
        'description':
            'Menunjukan bahwa HIMTIKA bisa menginspirasi dunia, optimis, ceria, menggerakan dan membawa perubahan khususnya di dunia Informatika.'
      },
      {
        'icon': 'src/features/himtika/logo/garishitam.png',
        'title': 'GARIS HITAM DALAM GEAR',
        'description':
            'Melambangkan penegasan bahwa HIMTIKA itu ada dan berada.'
      },
      {
        'icon': 'src/features/himtika/logo/putih.png',
        'title': 'WARNA PUTIH',
        'description': 'Melambang kesucian terhadap keilmuan Informatika.'
      },
      {
        'icon': 'src/features/himtika/logo/sinyal3.png',
        'title': 'SINYAL 3',
        'description': 'Terbentuknya HIMTIKA di angkatan negeri yang ke-3.'
      },
    ];

    // Simulasikan delay loading
    await Future.delayed(const Duration(milliseconds: 300));

    emit(state.copyWith(
      status: AboutHimtikaStatus.success,
      heroImagePath: heroImagePath,
      aboutParagraph: aboutParagraph,
      visiParagraph: visiParagraph,
      misiParagraph: misiParagraph,
      logoMeanings: logoMeanings,
    ));
  }
}
