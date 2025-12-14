import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';

part 'proker_event.dart';
part 'proker_state.dart';

class ProkerBloc extends Bloc<ProkerEvent, ProkerState> {
  final List<Map<String, dynamic>> _allData = [
    {
      'category': 'Divisi Internal',
      'dept': 'Dept. Human Resource Development',
      'deptImage': 'src/features/himtika/proker/card_dept.png',
      'programs': [
        {
          'title': 'Dies Natalis HIMTIKA',
          'image': 'src/features/himtika/proker/internal/diesnatalis.png',
          'description': 'Merupakan rangkaian acara dalam memperingati berdirinya organisasi HIMTIKA, dan bertujuan untuk mempererat hubungan tali silaturahmi antar Pengurus dan Anggota HIMTIKA.'
        },
        {
          'title': 'IT Bootcamp : Independent Project',
          'image': 'src/features/himtika/proker/internal/itb.png',
          'description': 'Merupakan serangkaian kegiatan yang diadakan untuk mempersiapkan mahasiswa baru informatika dalam mengembangkan kemampuan di bidang IT dan mempersiapkan diri menghadapi era digital.'
        },
        {
          'title': 'LKMM : Pra Dasar',
          'image': 'src/features/himtika/proker/internal/lkmmpd.png',
          'description': 'Adalah kegiatan mahasiswa baru Informatika yang bertujuan membekali mahasiswa baru dengan keterampilan dasar dalam berkomunikasi, mengenal potensi diri, mengembangkan sifat kritis dan memposisikan diri secara efektif dalam organisasi kemahasiswaan.'
        },
      ]
    },
    {
      'category': 'Divisi Internal',
      'dept': 'Dept. HIMTIKA Care',
      'deptImage': 'src/features/himtika/proker/card_dept.png',
      'programs': [
        {
          'title': 'HIMTIKA Organizing Agenda (HOA)',
          'image': 'src/features/himtika/proker/internal/hoa.png',
          'description': 'Berbagai rangkaian kegiatan untuk mengenalkan visi, misi, tujuan serta nilai nilai HIMTIKA diawal kepengurusan, serta sarana untuk pengembangan terhadap SDM di HIMTIKA seputar pengetahuan organisasi.'          
        },
      ]
    },
    {
      'category': 'Divisi Relasi',
      'dept': 'Dept. Public & Marketing',
      'deptImage': 'src/features/himtika/proker/card_dept.png',
      'programs': [
        {
          'title': 'Corporation',
          'image': 'src/features/himtika/proker/relasi/corporation.png',
          'description': 'Bertujuan untuk memperoleh pemasukan tambahan bagi HIMTIKA. Berfokus pada penggarapan ide dan melakukan produksi membuat produk dan layanan  untuk diperjualbelikan.'          
        },
      ]
    },
    {
      'category': 'Divisi Relasi',
      'dept': 'Dept. Public Relation',
      'deptImage': 'src/features/himtika/proker/card_dept.png',
      'programs': [
        {
          'title': 'HIMTIKA Out Study (HOS)',
          'image': 'src/features/himtika/proker/relasi/hos.png',
          'description': 'Studi banding antara HIMTIKA dan Himpunan lain dengan melibatkan divisi terkait, Ketua dan SCBPH HIMTIKA agar HIMTIKA dapat berkembang dan mampu memberikan wawasan yang luas kepada seluruh anggota HIMTIKA umumnya.'
        },
        {
          'title': 'HIMTIKA Goes To Company (HGTC)',
          'image': 'src/features/himtika/proker/relasi/hgtc.png',
          'description': 'Merupakan kegiatan akademis yang diorganisir oleh HIMTIKA berupa kunjungan mahasiswa ke perusahaan dengan tujuan meningkatkan pemahaman mendalam tentang dunia kerja, dengan menghubungkan teori dan praktik dalam bidang Informatika.'
        },
        {
          'title': 'Kemitraan',
          'image': 'src/features/himtika/proker/relasi/kemitraan.png',
          'description': 'Program kerja yang bertujuan untuk mencari mitra kerja yang diharapkan dapat membantu mengurangi pengeluaran HIMTIKA dengan menjalin kemitraan kerja dengan perusahaan.'
        },
      ]
    },
    {
      'category': 'Divisi RnD',
      'dept': 'Dept. Product Development',
      'deptImage': 'src/features/himtika/proker/card_dept.png',
      'programs': [
        {
          'title': 'HIMTIKA Software Development (HSD)',
          'image': 'src/features/himtika/proker/rnd/hsd.png',
          'description': 'Salah satu program kerja yang bekerja pada pengembangan Software seperti website atau Mobile Apps di HIMTIKA untuk menunjang kebutuhan mahasiswa, khususnya prodi Informatika.'
        },
      ]
    },
    {
      'category': 'Divisi RnD',
      'dept': 'Dept. Riset Development',
      'deptImage': 'src/features/himtika/proker/card_dept.png',
      'programs': [
        {
          'title': 'Software House',
          'image': 'src/features/himtika/proker/rnd/sh.png',
          'description': 'Sebuah program kerja yang fokus pada penelitian dan pengembangan produk digital HIMTIK yang berupa perangkat lunak (web dan mobile apps) yang bertujuan meningkatkan kualitas, fungsionalitas, dan nilai guna untuk memberikan kontribusi nyata melalui produk digital yang bermanfaat untuk HIMTIKA.'
        },
      ]
    },
    {
      'category': 'Divisi Edukasi',
      'dept': 'Dept. College Education',
      'deptImage': 'src/features/himtika/proker/card_dept.png',
      'programs': [
        {
          'title': 'Study Club',
          'image': 'src/features/himtika/proker/edukasi/study_club.png',
          'description': 'Adalah kegiatan belajar bersama mempelajari ilmu pengetahuan di bidang IT. Sehingga dapat dijadikan oleh mahasiswa sebagai wadah pengembangan diri dalam program yang diminati.'
        },
      ]
    },
    {
      'category': 'Divisi Edukasi',
      'dept': 'Dept. Skill Education',
      'deptImage': 'src/features/himtika/proker/card_dept.png',
      'programs': [
        {
          'title': 'Competitive Incubator Center (CIC)',
          'image': 'src/features/himtika/proker/edukasi/cic.png',
          'description': 'Merupakan program kerja yang bertujuan untuk menginkubasi dan menyalurkan kemampuan, skill dan bakat para mahasiswa informatika, yang nantinya dapat disalurkan ke perlombaan-perlombaan IT dan sertifikasi yang bersifat nasional.'
        },
        {
          'title': 'Open Project',
          'image': 'src/features/himtika/proker/edukasi/open_project.png',
          'description': 'Merupakan pewadahan ide-ide project dari mahasiswa informatika UNSIKA, untuk selanjutnya diwujudkan bersama dengan mahasiswa informatika dan pengurus HIMTIKA. Hasilnya bisa dipamerkan ke proker-proker yang ada di HIMTIKA maupun dapat disalurkan ke dalam lomba-lomba yang ada.'
        },
        {
          'title': 'Pekan IT',
          'image': 'src/features/himtika/proker/edukasi/pekan_it.png',
          'description': 'Merupakan kegiatan edukasi dan kompetisi IT secara terbuka. Ada tiga jenis agenda pada Pekan IT yaitu keilmuan melalui seminar yang bernama “Tech Talk”, workshop dan kompetisi atau perlombaan bidang informatika.'
        },
        {
          'title': 'SEMANTIK',
          'image': 'src/features/himtika/proker/edukasi/semantik.png',
          'description': 'Adalah ruang untuk mahasiswa berkreasi melalui ajang kompetisi hardskill dalam bidang informatika yang dikhususkan untuk mahasiswa Informatika UNSIKA.'
        },
      ]
    },
    {
      'category': 'Divisi Infokom',
      'dept': 'Dept. Media Information',
      'deptImage': 'src/features/himtika/proker/card_dept.png',
      'programs': [
        {
          'title': 'Always On',
          'image': 'src/features/himtika/proker/infokom/always_on.png',
          'description': 'Program kerja yang berfokus untuk mengelola dan memberikan segala informasi melalui sosial media dari HIMTIKA, serta mengoptimalkan fungsi sosial media HIMTIKA, sehingga menjadi sumber informasi seputar HIMTIKA dan juga lingkungan informatika.'
        },
        {
          'title': 'Content Writer',
          'image': 'src/features/himtika/proker/infokom/content_Writer.png',
          'description': 'Merupakan sebuah program kerja yang bertanggung jawab untuk merancang dan menyusun konten yang informatif dan interaktif kemudian akan di eksekusi oleh Dept. Media Creative. Menghasilkan kata kata untuk dipaparkan pada sosial media, seperti cation ataupun headline pada sebuah postingan.'
        },
      ]
    },
    {
      'category': 'Divisi Infokom',
      'dept': 'Dept. Media Creative',
      'deptImage': 'src/features/himtika/proker/card_dept.png',
      'programs': [
        {
          'title': 'Desain Komunikasi Visual (DKV)',
          'image': 'src/features/himtika/proker/infokom/dkv.png',
          'description': 'Program kerja yang berfungsi sebagai eksekutor dari segala desain yang menyangkut HIMTIKA yang telah disiapkan oleh content writer agar informasi yang sudah disiapkan dapat divisualisasikan agar mudah dimengerti oleh seluruh audiens yang akan menerima informasi tersebut.'
        },
      ]
    },
  ];

  ProkerBloc() : super(const ProkerState()) {
    on<FetchProkerData>(_onFetchProkerData);
    on<ChangeProkerCategory>(_onChangeProkerCategory);
  }

  Future<void> _onFetchProkerData(
      FetchProkerData event, Emitter<ProkerState> emit) async {
    emit(state.copyWith(status: ProkerStatus.loading));
    try {
      await Future.delayed(const Duration(seconds: 1)); 

      // Data Awal
      const categories = ['Divisi Internal', 'Divisi Relasi', 'Divisi RnD', 'Divisi Edukasi', 'Divisi Infokom'];
      const initialCategory = 'Divisi Internal';

      // Filter awal
      final initialData = _allData
          .where((element) => element['category'] == initialCategory)
          .toList();

      emit(state.copyWith(
        status: ProkerStatus.success,
        heroImagePath: 'src/features/himtika/icon/himtika.png', 
        description:
            'Rancangan terperinci dan sistematis mengenai serangkaian kegiatan (aktivitas) yang akan dilaksanakan dalam satu periode kepengurusan. Menerjemahkan visi dan strategi jangka panjang menjadi tindakan nyata.',
        categories: categories,
        selectedCategory: initialCategory,
        filteredProkerList: initialData,
      ));
    } catch (e) {
      emit(state.copyWith(status: ProkerStatus.failure));
    }
  }

  void _onChangeProkerCategory(
      ChangeProkerCategory event, Emitter<ProkerState> emit) {
    final filteredData = _allData
        .where((element) => element['category'] == event.category)
        .toList();

    emit(state.copyWith(
      selectedCategory: event.category,
      filteredProkerList: filteredData,
    ));
  }
}
