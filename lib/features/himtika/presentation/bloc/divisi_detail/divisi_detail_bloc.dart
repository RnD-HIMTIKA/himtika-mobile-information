import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';

part 'divisi_detail_event.dart';
part 'divisi_detail_state.dart';

// --- DATABASE DUMMY UNTUK SETIAP HALAMAN DIVISI ---
final Map<String, Map<String, dynamic>> _divisiDatabase = {
  'Steering Committee': {
    'title': 'Steering', 
    'gradientTitle': 'Committee', 
    'description': null, 
    'heroLogoPath': 'src/features/himtika/icon/himtika.png', 
    'divisionHead': null, 
    'departments': [
      {
        'title': 'Steering Committee',
        'description':
            'Merupakan jajaran pimpinan yang berfungsi sebagai pengarah strategis organisasi. Mereka memastikan seluruh kegiatan, kebijakan, dan keputusan selaras dengan visi-misi serta berjalan tertib secara administratif dan finansial.',
        'departmentHead': null,
        'members': []
      },
      {
        'title': null,
        'description': null,
        'departmentHead': null,
        'members': [
          {
            'name': 'Iqbal Umar Kadafi',
            'position': 'Ketua Himpunan',
            'image': 'src/features/himtika/divisi/sc/kahim.png'
          },
          {
            'name': 'Wanda Lionita Leilmutasya',
            'position': 'Wakil Ketua Himpunan',
            'image': 'src/features/himtika/divisi/sc/wahim.png'
          },
          {
            'name': 'Erizka Nia Ramadhani',
            'position': 'Sekretaris Umum',
            'image': 'src/features/himtika/divisi/sc/sekum.png'
          },
          {
            'name': 'Alia Hamzah',
            'position': 'Wakil Sekretaris Umum',
            'image': 'src/features/himtika/divisi/sc/wasekum.png'
          },
          {
            'name': 'Putra Raka Pratama',
            'position': 'Bendahara Umum',
            'image': 'src/features/himtika/divisi/sc/bendum.png'
          },
          {
            'name': 'Anisa Diyah Ayu Lestari',
            'position': 'Wakil Bendahara Umum',
            'image': 'src/features/himtika/divisi/sc/wabendum.png'
          },
        ]
      },
      {
        'title': 'Badan Pengurus Harian',
        'description':
            'Merupakan para ketua dari divisi yang ada di HIMTIKA. Bertugas mengawasi dan membimbing bidang yang dibawahinya dalam menjalankan proker. Mencari informasi dari eksternal HIMTIKA untuk menjadi masukan dalam bidang, melaporkan kabar bidang terkini kepada Ketua Umum dan Wakil Ketua Umum HIMTIKA UNSIKA sebagai jembatan informasi antar bidang yang lain.',
        'departmentHead': null,
        'members': []
      },
      {
        'title': null,
        'description': null,
        'departmentHead': null,
        'members': [
          {
            'name': 'Indira Ayu Anggraeni',
            'position': 'Ketua Divisi Internal',
            'image': 'src/features/himtika/divisi/internal/ketua.png'
          },
          {
            'name': 'Naufal Syafiq Fadillah',
            'position': 'Ketua Divisi RnD',
            'image': 'src/features/himtika/divisi/rnd/ketua.png'
          },
          {
            'name': 'Haliza Adzikia Sukarno',
            'position': 'Ketua Divisi Relasi',
            'image': 'src/features/himtika/divisi/relasi/ketua.png'
          },
          {
            'name': 'Ahmad Zulkarnaen',
            'position': 'Ketua Divisi Edukasi',
            'image': 'src/features/himtika/divisi/edukasi/ketua.png'
          },
          {
            'name': 'Wahyu Widi Widayat',
            'position': 'Ketua Divisi Infokom',
            'image': 'src/features/himtika/divisi/infokom/ketua.png'
          },
        ]
      }
    ]
  },

  // DIVISI-DIVISI
  'Divisi Internal': {
    'title': 'Internal',
    'description':
      'Hadir sebagai jantung dari proses kaderisasi dan pengembangan sumber daya manusia di HIMTIKA. Hadir untuk membentuk suasana kerja yang harmonis, memperkuat solidaritas, dan membina generasi Informatika yang tangguh serta berkarakter.',
    'heroLogoPath':
      'src/features/himtika/icon/himtika.png',
    'divisionHead': {
      'position': 'Ketua Divisi Internal',
      'name': 'Indira Ayu Anggraeni',
      'image': 'src/features/himtika/divisi/internal/ketua.png'
    },
    // Daftar Departemen di dalam divisi ini
    'departments': [
      {
        'title': 'Dept. Human Resource Development',
        'description': 'Bertugas mengelola motivasi dan pengembangan potensi seluruh pengurus HIMTIKA baik dari sisi softskill maupun hardskill. HRD juga memastikan lingkungan kerja tetap harmonis dan penuh kekeluargaan. Serta melakukan pemantauan kinerja guna mendukung tumbuhnya karakter pengurus yang sesuai dengan nilai-nilai HIMTIKA.',
        'departmentHead': {
          'position': 'Ketua Dept. HRD',
          'name': 'Anya Sabrina Narulita',
          'image': 'src/features/himtika/divisi/internal/kadepHRD.png' 
        },
        'members': [
          {
            'position': 'Anggota Dept. HRD',
            'name': 'Indyra Putri Pratama',
            'image': 'src/features/himtika/divisi/internal/indira.png'
          },
          {
            'position': 'Anggota Dept. HRD',
            'name': 'Andhika Subagja',
            'image': 'src/features/himtika/divisi/internal/bagja.png'
          },
          {
            'position': 'Anggota Dept. HRD',
            'name': 'Ambar Triyasmin',
            'image': 'src/features/himtika/divisi/internal/yasmin.png'
          },
        ]
      },
      {
        'title': 'Dept. HIMTIKA Care',
        'description': 'Berperan dalam menjaga dan merawat hubungan internal antar fungsionaris HIMTIKA. Dengan empati dan rasa peduli yang tinggi, departemen ini fokus pada pembinaan, dan kontrol organisasi.',
        'departmentHead': {
          'name': 'Nazla Arina Nurfia Sofa',
          'position': 'Ketua Dept. HC',
          'image': 'src/features/himtika/divisi/internal/kadepHC.png' 
        },
        'members': [
          {
            'name': 'Andhika Sukma Jiwatama',
            'position': 'Anggota Dept. HC',
            'image': 'src/features/himtika/divisi/internal/sukma.png'
          },
          {
            'name': 'Hanna Fadillah Septiana',
            'position': 'Anggota Dept. HC',
            'image': 'src/features/himtika/divisi/internal/hanna.png'
          },
          {
            'name': 'Imas Anisa',
            'position': 'Anggota Dept. HC',
            'image': 'src/features/himtika/divisi/internal/sasa.png'
          },
        ]
      },
    ],
  },
  'Divisi RnD': {
    'title': 'RnD',
    'description':
      'Hadir sebagai ujung tombak dalam penerapan teknologi informasi. Divisi ini fokus pada peningkatan kualitas di lingkungan HIMTIKA dan program studi Informatika UNSIKA. Selain itu, Research and Development juga berperan sebagai IT Support untuk mendukung optimalisasi kinerja HIMTIKA.',
    'heroLogoPath':
      'src/features/himtika/icon/himtika.png',
    'divisionHead': {
      'name': 'Naufal Syafiq Fadillah',
      'position': 'Ketua Divisi RnD',
      'image': 'src/features/himtika/divisi/rnd/ketua.png'
    },
    // Daftar Departemen di dalam divisi ini
    'departments': [
      {
        'title': 'Dept. Product Development',
        'description': 'Merupakan tim yang bertanggung jawab dalam pembuatan dan pengembangan produk digital HIMTIKA. Mulai dari pengelolaan website HIMTIKA, kolaborasi dengan tim Software House, Open Project, hingga pengembangan aplikasi berbasis kebutuhan mahasiswa. Tin ini juga menjadi penopang utama dalam penerapan IT di HIMTIKA.',
        'departmentHead': {
          'name': 'Ferdi Yansah',
          'position': 'Ketua Dept. Product',
          'image': 'src/features/himtika/divisi/rnd/kadepProduct.png'
        },
        'members': [
          {
            'name': 'Geral Tritama Wahyuady',
            'position': 'Anggota Dept. Product',
            'image': 'src/features/himtika/divisi/rnd/geral.png'
          },
          {
            'name': 'Raika Maulana Dwi Putra',
            'position': 'Anggota Dept. Product',
            'image': 'src/features/himtika/divisi/rnd/raika.png'
          },
          {
            'name': 'Muhammad Jibran Tariq',
            'position': 'Anggota Dept. Product',
            'image': 'src/features/himtika/divisi/rnd/jibran.png'
          },
        ]
      },
      {
        'title': 'Dept. Riset Development',
        'description': 'Berfokus pada riset dan identifikasi permasalahan di lingkungan Informatika UNSIKA yang dapat diselesaikan melalui pendekatan teknologi. Departemen ini juga bertugas mengumpulkan kebutuhan mahasiswa, lalu mengawal proses pengembangan produk digital hingga rilis, bekerja sama dengan tim developer dan marketing.',
        'departmentHead': {
          'name': 'Mahesa Muhamad Nabil',
          'position': 'Ketua Dept. Riset',
          'image': 'src/features/himtika/divisi/rnd/kadepRiset.png' 
        },
        'members': [
          {'name': 'Muhammad Rizky Dermawan', 'position': 'Anggota Dept. Riset', 'image': 'src/features/himtika/divisi/rnd/menrey.png'},
        ]
      },
    ],
  },
  'Divisi Relasi': {
    'title': 'Relasi',
    'description':
      'Hadir sebagai jembatan antara HIMTIKA dengan dunia luar baik di dalam maupun di luar lingkungan kampus. Kami membangun dan memelihara kerja sama strategis dengan organisasi internal kampus. Divisi ini juga memiliki peran penting dalam hal komunikasi eksternal, sponsorship, dan pendanaan kegiatan dengan tujuan menciptakan kolaborasi yang saling menguntungkan.',
    'heroLogoPath':
      'src/features/himtika/icon/himtika.png',
    'divisionHead': {
      'name': 'Haliza Adzikia Sukarno',
      'position': 'Ketua Divisi Relasi',
      'image': 'src/features/himtika/divisi/relasi/ketua.png'
    },
    // Daftar Departemen di dalam divisi ini
    'departments': [
      {
        'title': 'Dept. Public & Marketing',
        'description': 'Fokus pada branding dan pendanaan HIMTIKA. Departemen ini bertugas membuat berbagai tools marketing. Tak hanya itu, mereka juga mencari sumber dana potensial melalui kreativitas dan inisiatif dalam bidang teknologi informasi, khususnya untuk mendukung kegiatan internal Fasilkom UNSIKA.',
        'departmentHead': {
          'name': 'Halvina Farras Savitri',
          'position': 'Ketua Dept. PM',
          'image': 'src/features/himtika/divisi/relasi/kadepPM.png'
        },
        'members': [
          {
            'name': 'Martin Ekaputra A.',
            'position': 'Anggota Dept. PM',
            'image': 'src/features/himtika/divisi/relasi/martin.png'
          },
          {
            'name': 'Rois Alif Pradipa',
            'position': 'Anggota Dept. PM',
            'image': 'src/features/himtika/divisi/relasi/rois.png'
          },
        ]
      },
      {
        'title': 'Dept. Public Relation',
        'description':
            'Bertugas menjalin dan menjaga hubungan baik dengan himpunan organisasi, serta instansi eksternal. Selain itu, departemen ini juga menyampaikan informasi kegiatan HIMTIKA kepada mahasiswa, memastikan komunikasi tetap terbuka dan terarah.',
        'departmentHead': {
          'name': 'M. Akmal Fauzan Nur R.',
          'position': 'Ketua Dept. PR',
          'image': 'src/features/himtika/divisi/relasi/kadepPR.png' 
        },
        'members': [
          {
            'name': 'Helmi Zain Fakhruriza D.',
            'position': 'Anggota Dept. PR',
            'image': 'src/features/himtika/divisi/relasi/zain.png'
          },
          {
            'name': 'Dewa Putu Atma D.',
            'position': 'Anggota Dept. PR',
            'image': 'src/features/himtika/divisi/relasi/dewa.png'
          },
          {
            'name': 'Refi Abdillah',
            'position': 'Anggota Dept. PR',
            'image': 'src/features/himtika/divisi/relasi/refi.png'
          },
        ]
      },
    ],
  },
  'Divisi Edukasi': {
    'title': 'Edukasi',
    'description':
      'Bertugas untuk mengelola dan mempererat hubungan antar anggota di dalam Himpunan Mahasiswa Teknik Informatika (HIMTIKA), serta menjaga keharmonisan organisasi.Hadir sebagai ruang pengembangan akademik, prestasi, dan intelektualitas mahasiswa Informatika UNSIKA. Kami mewadahi berbagai kegiatan edukatif yang membangun semangat belajar, eksplorasi, dan pengembangan diri di bidang IT. Divisi Edukasi juga aktif menginisiasi program-program yang mendukung minat, bakat, serta pencapaian akademik mahasiswa.',
    'heroLogoPath':
      'src/features/himtika/icon/himtika.png',
    'divisionHead': {
      'name': 'Ahmad Zulkarnaen',
      'position': 'Ketua Divisi Edukasi',
      'image': 'src/features/himtika/divisi/edukasi/ketua.png'
    },
    // Daftar Departemen di dalam divisi ini
    'departments': [
      {
        'title': 'Dept. College Education',
        'description': 'Berperan sebagai pembina mahasiswa yang akan mengikuti perlombaan di bidang ilmu pengetahuan IT. Departemen ini memberikan dukungan, pengayaan materi, hingga menyelenggarakan kelas belajar sebagai bentuk pendampingan dengan tujuan membekali mahasiswa dengan pengetahuan dan kepercayaan diri untuk tampil unggul di berbagai kompetisi',
        'departmentHead': {
          'name': 'Zakki Khairul Abdulaziz',
          'position': 'Ketua Dept. College Edu',
          'image': 'src/features/himtika/divisi/edukasi/kadepCollege.png'
        },
        'members': [
          {
            'name': 'Rifqy Kurniawan Fattahillah',
            'position': 'Anggota Dept. College Edu',
            'image': 'src/features/himtika/divisi/edukasi/rifqy.png'
          },
          {
            'name': 'Shidqy Khairu Dwijaya',
            'position': 'Anggota Dept. College Edu',
            'image': 'src/features/himtika/divisi/edukasi/shidqy.png'
          },
          {
            'name': 'Nadrina Pratama Hilyawanti',
            'position': 'Anggota Dept. College Edu',
            'image': 'src/features/himtika/divisi/edukasi/nadrina.png'
          },
        ]
      },
      {
        'title': 'Dept. Skill Education',
        'description':
            'Bertugas sebagai penggerak semangat berprestasi di kalangan mahasiswa. Departemen ini menjadi penyalur informasi lomba dan pelatihan, serta menyelenggarakan kegiatan yang mendorong lahirnya karya-karya teknologi.',
        'departmentHead': {
          'name': 'Inong Muliya Zahra',
          'position': 'Ketua Dept. Skill Edu',
          'image': 'src/features/himtika/divisi/edukasi/kadepSkill.png' 
        },
        'members': [
          {
            'name': 'Anggun Permata Sari',
            'position': 'Anggota Dept. Skill Edu',
            'image': 'src/features/himtika/divisi/edukasi/anggun.png'
          },
          {
            'name': 'Nugraha Adani',
            'position': 'Anggota Dept. Skill Edu',
            'image': 'src/features/himtika/divisi/edukasi/nugi.png'
          },
          {
            'name': 'Bahrul Alakin',
            'position': 'Anggota Dept. Skill Edu',
            'image': 'src/features/himtika/divisi/edukasi/bahrul.png'
          },
          {
            'name': 'Ori Suhana',
            'position': 'Anggota Dept. Skill Edu',
            'image': 'src/features/himtika/divisi/edukasi/ori.png'
          },
        ]
      },
    ],
  },
  'Divisi Infokom': {
    'title': 'Infokom',
    'description':
      'Hadir sebagai pusat informasi, komunikasi, dan media digital dalam tubuh HIMTIKA. Di balik setiap postingan, desain, hingga dokumentasi kegiatan, ada kami yang bekerja memastikan setiap informasi sampai dengan tepat dan menarik.',
    'heroLogoPath':
      'src/features/himtika/icon/himtika.png',
    'divisionHead': {
      'name': 'Wahyu Widi Widayat',
      'position': 'Ketua Divisi Infokom',
      'image': 'src/features/himtika/divisi/infokom/ketua.png'
    },
    // Daftar Departemen di dalam divisi ini
    'departments': [
      {
        'title': 'Dept. Media Creative',
        'description': 'Bertanggung jawab dalam pembuatan desain grafis untuk company profile dan materi informasi lainnya. Selain itu, departemen ini juga mengelola pembuatan konten video seperti video rewind, dokumentasi, dan media visual lainnya yang mendukung penyebaran informasi HIMTIKA.',
        'departmentHead': {
          'name': 'Nafhan Haqiqi',
          'position': 'Ketua Dept. MC',
          'image': 'src/features/himtika/divisi/infokom/kadepMC.png'
        },
        'members': [
          {
            'name': 'Farel Darmawan',
            'position': 'Anggota Dept. MC',
            'image': 'src/features/himtika/divisi/infokom/farel.png'
          },
          {
            'name': 'Syahid Ahmad Yasin',
            'position': 'Anggota Dept. MC',
            'image': 'src/features/himtika/divisi/infokom/syahid.png'
          },
          {
            'name': 'M. Zidane Akbari',
            'position': 'Anggota Dept. MC',
            'image': 'src/features/himtika/divisi/infokom/zidane.png'
          },
          {
            'name': 'Rizki Isma Ramadhani',
            'position': 'Anggota Dept. MC',
            'image': 'src/features/himtika/divisi/infokom/isma.png'
          },
          {
            'name': 'Dwiyandra Raysha P. S.',
            'position': 'Anggota Dept. MC',
            'image': 'src/features/himtika/divisi/infokom/raysha.png'
          },
        ]
      },
      {
        'title': 'Dept. Media Information',
        'description':
            'Fokus pada strategi publikasi HIMTIKA. Mulai dari menjadwalkan dan mempublikasikan agenda kegiatan, mengelola media sosial, membentuk branding digital HIMTIKA, hingga merancang konten publikasi yang tepat sasaran.',
        'departmentHead': {
          'name': 'Raihan Febriahdi',
          'position': 'Ketua Dept. MI',
          'image': 'src/features/himtika/divisi/infokom/kadepMI.png' 
        },
        'members': [
          {
            'name': 'Atika Sari Ramadhani',
            'position': 'Anggota Dept. MI',
            'image': 'src/features/himtika/divisi/infokom/tika.png'
          },
          {
            'name': 'Arsya Apricia Purnomo',
            'position': 'Anggota Dept. MI',
            'image': 'src/features/himtika/divisi/infokom/arsya.png'
          },
        ]
      },
    ],
  },
};

class DivisiDetailBloc extends Bloc<DivisiDetailEvent, DivisiDetailState> {
  DivisiDetailBloc() : super(const DivisiDetailState()) {
    on<FetchDivisiData>(_onFetchDivisiData);
  }

  Future<void> _onFetchDivisiData(
      FetchDivisiData event, Emitter<DivisiDetailState> emit) async {
    emit(state.copyWith(status: DivisiDetailStatus.loading));
    await Future.delayed(const Duration(milliseconds: 300));

    final data = _divisiDatabase[event.divisiId];

    if (data != null) {
      final divisionHeadData = data['divisionHead'] as Map<String, dynamic>?;
      emit(state.copyWith(
        status: DivisiDetailStatus.success,
        title: data['title'],
        gradientTitle: data['gradientTitle'],
        description: data['description'],
        heroLogoPath: data['heroLogoPath'],
        divisionHead: divisionHeadData != null ? Map<String, String>.from(divisionHeadData) : null,
        departments: List<Map<String, dynamic>>.from(data['departments']),
      ));
    } else {
      emit(state.copyWith(status: DivisiDetailStatus.failure));
    }
  }
}
