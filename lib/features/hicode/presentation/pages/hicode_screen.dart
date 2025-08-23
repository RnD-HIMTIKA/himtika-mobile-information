import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:himtika_mobile_information/features/hicode/presentation/bloc/main_screen/hicode_bloc.dart';
import 'package:himtika_mobile_information/features/hicode/presentation/pages/materi_detail_screen.dart';
import 'package:himtika_mobile_information/features/hicode/presentation/pages/information_screen.dart';
import 'package:himtika_mobile_information/features/home/presentation/pages/home.dart';

class HicodeScreen extends StatelessWidget {
  const HicodeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      // Gunakan BLoC & Event yang baru
      create: (_) => HicodeBloc()..add(HicodeDataFetched()),
      child: Scaffold(
        backgroundColor: Colors.grey[100],
        body: SafeArea(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildTopIconBar(context),
                  const SizedBox(height: 16),

                  // --- Header ---
                  _buildHeader(),
                  const SizedBox(height: 24),

                  // --- Leaderboard ---
                  const _LeaderboardCard(),
                  const SizedBox(height: 24),

                  // --- Kategori ---
                  _buildSectionTitle('Kategori'),
                  const SizedBox(height: 12),
                  _buildCategoryList(),
                  const SizedBox(height: 24),

                  // --- Pilihan Materi ---
                  _buildSectionTitle('Pilihan Materi'),
                  const SizedBox(height: 12),
                  _buildMaterialList(),
                  const SizedBox(height: 24),
                  
                  // --- Ujian Akhir ---
                  BlocBuilder<HicodeBloc, HicodeState>(
                    builder: (context, state) {
                      return _buildFinalExamCard(isExamReady: state.isExamReady);
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
  
  // Method baru untuk membuat baris ikon di bagian atas
  Widget _buildTopIconBar(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: Image.asset(
            'src/features/hicode/icon/kembali.png',
            width: 32, // Atur lebar gambar
            height: 32, // Atur tinggi gambar
          ),
        ),
        
        // --- UBAH BAGIAN INI JUGA ---
        IconButton(
          onPressed: () {
            Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const InformationScreen()),
            );
          },
          icon: Image.asset(
            'src/features/hicode/icon/informasi.png',
            width: 28,
            height: 28,
          ),
        ),
      ],
    );
  }

  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.blue.shade700,
        borderRadius: BorderRadius.circular(15),
        image: const DecorationImage(
          image: AssetImage('src/features/hicode/images/pattern_card.png'),
          fit: BoxFit.contain,
          opacity: 1.0, 
        ),
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Belajar Mudah\nBersama HiCode',
            style: TextStyle(
                color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 8),
          Text(
            'Mulai perjalanan kodingmu bersama kami. Panduan lengkap, materi terarah, dan dukungan setiap langkahnya.',
            style: TextStyle(color: Colors.white, fontSize: 14),
          ),
        ],
      ),
    );
}
  
  Widget _buildSectionTitle(String title) {
    return Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold));
  }
  
  Widget _buildCategoryList() {
    return BlocBuilder<HicodeBloc, HicodeState>(
      builder: (context, state) {
        if (state.status == HicodeStatus.success) {
          return SizedBox(
            height: 120,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: state.categories.length,
              itemBuilder: (context, index) {
                return _CategoryCard(category: state.categories[index]); // Widget kini jadi private class
              },
              separatorBuilder: (context, index) => const SizedBox(width: 16),
            ),
          );
        }
        return const Center(child: CircularProgressIndicator());
      },
    );
  }
  
  Widget _buildMaterialList() {
    return BlocBuilder<HicodeBloc, HicodeState>(
      builder: (context, state) {
        if (state.status == HicodeStatus.success) {
          return ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: state.materials.length,
            itemBuilder: (context, index) {
              // Tambahkan parameter 'index: index,' yang hilang
              return _MaterialCard(
                material: state.materials[index],
                index: index, // Parameter ini wajib ada sekarang
              );
            },
            separatorBuilder: (context, index) => const SizedBox(height: 16),
          );
        }
        return const Center(child: CircularProgressIndicator());
      },
    );
  }
  
 Widget _buildFinalExamCard({required bool isExamReady}) {
    final Color backgroundColor = isExamReady ? Colors.green : Colors.red.shade400;
    final String imagePath = isExamReady
        ? 'src/features/hicode/images/dibuka.png'
        : 'src/features/hicode/images/ditutup.png';
    final String title = isExamReady
        ? 'Yay! Ujian Akhir Siap Dimulai'
        : 'Ujian Akhir Masih Terkunci';
    final String subtitle = isExamReady
        ? 'Kamu sudah selesaikan materi, saatnya tunjukkan kemampuanmu!'
        : 'Selesaikan semua materi terlebih dahulu untuk membuka ujian akhir.';
    final Color arrowColor = isExamReady ? Colors.white : Colors.white54;
    final String buttonText = isExamReady ? "Kerjakan Sekarang" : "Lihat Materi";

    // 2. Bangun UI menggunakan properti yang sudah ditentukan
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(15),
        image: const DecorationImage(
          image: AssetImage('src/features/hicode/images/pattern_exam.png'),
          fit: BoxFit.contain,
          opacity: 1.0,
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Image.asset(
                imagePath,
                width: 40,
                height: 40,
                color: Colors.white,
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 16),
                    ),
                    Text(
                      subtitle,
                      style: const TextStyle(color: Colors.white, fontSize: 12),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          Align(
            alignment: Alignment.centerRight,
            child: Row(
              mainAxisSize: MainAxisSize.min, 
              children: [
                Text(
                  buttonText,
                  style: TextStyle(
                    color: arrowColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(width: 8),
                Icon(
                  Icons.arrow_forward_ios,
                  color: arrowColor,
                  size: 14,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

//==================================================================
// KODE WIDGET YANG DIGABUNGKAN (SEKARANG MENJADI PRIVATE CLASS)
//==================================================================

// --- WIDGET UNTUK LEADERBOARD ---
class _LeaderboardCard extends StatelessWidget {
  const _LeaderboardCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
      ),
      // 1. Widget utama adalah Row (Ikon di kiri, konten di kanan)
      child: IntrinsicHeight(
        child: Row(
          // 2. Ubah crossAxisAlignment menjadi .stretch
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Gambar Aset Anda
            Image.asset(
              'src/features/hicode/images/leaderboard.png',
              width: 90,
              // 3. Hapus 'height' agar gambar bisa meregang
              fit: BoxFit.cover, // 4. Tambahkan 'fit' agar gambar mengisi ruang
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween, // Agar seimbang
                children: [
                  // Grup Teks (Judul dan Paragraf)
                  const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Leaderboard",
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 18)),
                      SizedBox(height: 4),
                      Text(
                          "Lihat kapabilitas yang sudah menyelesaikan tugas akhir dan meraih skor terbaik!",
                          style: TextStyle(color: Colors.grey, fontSize: 12)),
                    ],
                  ),
                  SizedBox(height: 4),
                  // Tombol
                  SizedBox(
                    height: 24,
                    child: ElevatedButton(
                      onPressed: () {},
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        backgroundColor: const Color(0xFF81EAFF),
                        foregroundColor: const Color(0xFF006EBD),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10)),
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                      child: const Text(
                        "Lihat Selengkapnya",
                        style: TextStyle(fontSize: 12),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// --- WIDGET UNTUK CARD KATEGORI ---
class _CategoryCard extends StatelessWidget {
  final Map<String, dynamic> category;
  const _CategoryCard({required this.category});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 85,
          height: 85,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Color(0xFFE0E0E0),
            borderRadius: BorderRadius.circular(15),
          ),
          // 2. Ambil data menggunakan ['key']
          child: Image.asset(category['iconPath'], fit: BoxFit.contain),
        ),
        const SizedBox(height: 8),
        // 3. Ambil data menggunakan ['key']
        Text(category['name']),
      ],
    );
  }
}

// --- WIDGET UNTUK CARD MATERI --- //
class _MaterialCard extends StatelessWidget {
  final Map<String, dynamic> material;
  // 1. Tambahkan 'index' untuk diterima oleh widget
  final int index;

  const _MaterialCard({
    required this.material,
    required this.index, // Tambahkan di constructor
  });

  @override
  Widget build(BuildContext context) {
    // 2. Buat logika untuk menentukan warna berdasarkan index ganjil/genap
    // (index % 2 != 0) berarti ganjil
    final borderColor = (index % 2 != 0)
        ? Colors.blue.shade400
        : Colors.orange.shade600;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        // 3. Gunakan warna yang sudah ditentukan di sini
        border: Border.all(
          color: borderColor,
          width: 2, // Tambahkan ketebalan agar border lebih terlihat
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Baris yang berisi Ikon dan semua Teks
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Ikon Utama (HTML, CSS, dll)
              Image.asset(material['iconPath'], width: 82, height: 82),
              const SizedBox(width: 16),

              // Kolom untuk Teks
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Judul Materi
                    Text(
                      material['title'],
                      style: const TextStyle(
                          fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),

                    // Detail Chapter dan Latihan Soal
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.book_outlined,
                                size: 16, color: Colors.grey),
                            const SizedBox(width: 8),
                            Text(material['chapterProgress'],
                                style: const TextStyle(color: Colors.grey)),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Row(
                          children: [
                            const Icon(Icons.edit_note_outlined,
                                size: 16, color: Colors.grey),
                            const SizedBox(width: 8),
                            Text('${material['exerciseCount']} Latihan Soal',
                                style: const TextStyle(color: Colors.grey)),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),

          // --- 2. TOMBOL DILETAKKAN DI BAWAH SEBAGAI ANAK DARI COLUMN ---
          const SizedBox(height: 16), // Beri jarak antara teks dan tombol
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => MaterialDetailScreen(
                    materialId: material['title'],
                  ),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              backgroundColor: const Color(0xFF81EAFF),
              foregroundColor: const Color(0xFF006EBD),
              elevation: 0,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min, // Agar tombol tidak selebar layar
              children: [
                Text('Pelajari Sekarang', style: TextStyle(fontSize: 12)),
                SizedBox(width: 4),
                Icon(Icons.arrow_forward_ios, size: 12),
              ],
            ),
          ),
        ],
      ),
    );
  }
}