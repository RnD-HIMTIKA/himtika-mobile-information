import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../../domain/repositories/himtika_repository.dart';

part 'kabinet_event.dart';
part 'kabinet_state.dart';

class KabinetBloc extends Bloc<KabinetEvent, KabinetState> {
  final HimtikaRepository? repository;

  KabinetBloc({this.repository}) : super(const KabinetState()) {
    on<FetchKabinetData>(_onFetchKabinetData);
  }

  Future<void> _onFetchKabinetData(
      FetchKabinetData event, Emitter<KabinetState> emit) async {
    emit(state.copyWith(status: KabinetStatus.loading));

    String namaKabinet = 'Sinergis';
    String heroLogoPath = 'src/features/himtika/images/kabinet.png';
    String aboutSinergis = 'Sinergis mencerminkan nilai-nilai utama yang dijunjung tinggi oleh kami, yaitu Sinergi, Inovatif, Eksplorasi, Responsif, Generalis, dan Sistematis. Setiap elemen dalam logo kami melambangkan komitmen kami untuk memberikan kontribusi nyata pada masyarakat informatika.';

    List<Map<String, String>> kabinetCards = [
      {
        'title': 'Sinergi',
        'description':
            'Mengembangkan HIMTIKA sebagai sebuah Organisasi aktif yang menaungi dan bersinergi dengan Mahasiswa Informatika UNSIKA... Nilai Sinergi ini menjadi hal utama yang diaktualisasikan agar HIMTIKA dapat menghimpun dan Mewadahi Mahasiswa Informatika untuk menjalin rasa kekeluargaan yang solid dan saling mendukung untuk mencapai peningkatan prestasi dan mewujudkan tujuan bersama'
      },
      {
        'title': 'Inovatif',
        'description':
            'Inovatif adalah sesuatu yang bersifat pengembangan dan pembaruan. Maksud dari inovatif HIMTIKA harus mampu menciptakan ruang yang mendukung Inovasi untuk memberikan kesempatan bagi Mahasiswa Informatika mengembangkan ide dan gagasannya'
      },
      {
        'title': 'Eksplorasi',
        'description':
            'Adalah upaya mencari dan mengembangkan ide-ide, pengetahuan, atau cara-cara baru yang dapat mendorong inovasi. Dalam hal ini diharapkan HIMTIKA berkontribusi untuk mendukung Mahasiswa Informatika untuk mencari dan mendapatkan pengetahuan lebih luas dan lebih menyeluruh'
      },
      {
        'title': 'Responsif',
        'description':
            'Adalah kemampuan untuk memberikan tanggapan atau reaksi yang cepat, tepat, dan sesuai terhadap suatu kondisi. Diharapkan HIMTIKA dapat merespon semua kebutuhan dan keinginan Mahasiswa Informatika dengan cepat dan tepat, khususnya yang berkaitan dengan bidang Keilmuan dan Akademik'
      },
      {
        'title': 'Generalis',
        'description':
            'Diartikan sebagai sesuatu hal yang mencakup banyak bidang. Berdasarkan hal ini HIMTIKA harus berhasil mewadahi setiap aspek potensial Mahasiswa dalam berbagai bidang, dan memahami atau menangani berbagai topik ataupun permasalahan yang relevan'
      },
      {
        'title': 'Sistematis',
        'description':
            'Merujuk pada cara berpikir atau cara bekerja yang mengikuti urutan yang logis, terencana, dan konsisten. HIMTIKA akan mengadaptasi struktural yang lebih terorganisir dan terencana untuk menjalankan sebuah Organisasi yang berjalan dengan cara yang efisien, terkoordinir, dan terarah pada tujuan yang jelas'
      },
    ];

    try {
      if (repository != null) {
        final activeKabinet = await repository!.getActiveKabinet();
        if (activeKabinet != null) {
          if (activeKabinet.namaKabinet.isNotEmpty) {
            namaKabinet = activeKabinet.namaKabinet;
          }
          if (activeKabinet.logoUrl != null && activeKabinet.logoUrl!.isNotEmpty) {
            heroLogoPath = activeKabinet.logoUrl!;
          }
          if (activeKabinet.deskripsi != null && activeKabinet.deskripsi!.isNotEmpty) {
            aboutSinergis = activeKabinet.deskripsi!;
          }
          if (activeKabinet.nilaiKabinet.isNotEmpty) {
            kabinetCards = activeKabinet.nilaiKabinet;
          }
        }
      }
    } catch (_) {
      // Fallback to initial dummy data on error
    }

    const logoMeanings = [
      {
        'icon': 'src/features/himtika/kabinet/angsa.png',
        'title': 'Angsa',
        'description': 'Melambangkan harmoni yang diharapkan dapat dirasakan dan dipelihara serta dijaga oleh segenap pengurus dan anggota HIMTIKA'
      },
      {
        'icon': 'src/features/himtika/kabinet/teratai.png',
        'title': 'Bunga Teratai',
        'description': '8 Kelopak bunga teratai melambangkan pertumbuhan HIMTIKA yang mencapai generasi ke delapan dan tetap bertumbuh berkembang menjadi organisasi yang bermanfaat'
      }, 
      {
        'icon': 'src/features/himtika/kabinet/daun.png',
        'title': 'Daun',
        'description': '6 daun merefleksikan enam nilai utama yang akan dibangun dalam kepengurusan yaitu Sinergi, Inovatif, Eksplorasi, Responsif, Generalis, dan Sistematis'
      }, 
      {
        'icon': 'src/features/himtika/kabinet/gear.png',
        'title': 'Gear',
        'description': 'Melambangkan teknologi dan keberlanjutan yang dinamis dan terus bergerak membangun sumber daya mahasiswa yang kreatif, kompetitif, dan unggul'
      },
    ];

    emit(state.copyWith(
      status: KabinetStatus.success,
      namaKabinet: namaKabinet,
      heroLogoPath: heroLogoPath,
      aboutSinergis: aboutSinergis,
      kabinetCards: kabinetCards,
      logoMeanings: logoMeanings,
    ));
  }
}
