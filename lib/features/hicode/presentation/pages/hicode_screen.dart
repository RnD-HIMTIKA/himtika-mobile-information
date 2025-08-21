import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:himtika_mobile_information/features/hicode/presentation/bloc/hicode_bloc.dart';

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
                  // --- Header ---
                  _buildHeader(),
                  const SizedBox(height: 24),

                  // --- Leaderboard ---
                  const _LeaderboardCard(), // Widget kini jadi private class
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
                  _buildFinalExamCard(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.blue.shade700,
        borderRadius: BorderRadius.circular(15),
      ),
      child: const Text(
        'Belajar Mudah Bersama HiCode',
        style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
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
            height: 100,
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
              return _MaterialCard(material: state.materials[index]); // Widget kini jadi private class
            },
            separatorBuilder: (context, index) => const SizedBox(height: 16),
          );
        }
        return const Center(child: CircularProgressIndicator());
      },
    );
  }
  
  Widget _buildFinalExamCard() {
    return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
            color: Colors.green,
            borderRadius: BorderRadius.circular(15)
        ),
        child: const Row(
            children: [
                Icon(Icons.shield, color: Colors.white, size: 40),
                SizedBox(width: 16),
                Expanded(
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                            Text('Yay! Ujian Akhir Siap Dimulai', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                            Text('Kamu sudah selesaikan materi, saatnya tunjukkan kemampuanmu!', style: TextStyle(color: Colors.white, fontSize: 12)),
                        ],
                    )
                ),
                Icon(Icons.arrow_forward_ios, color: Colors.white, size: 16)
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
      child: Row(
        children: [
          // Ganti dengan Image.asset('assets/images/trophy.png') jika ada
          const Icon(Icons.emoji_events, size: 60, color: Colors.amber),
          const SizedBox(width: 16),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Leaderboard", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                SizedBox(height: 4),
                Text("Lihat kapabilitas yang sudah menyelesaikan tugas akhir dan meraih skor terbaik!", style: TextStyle(color: Colors.grey, fontSize: 12)),
              ],
            ),
          ),
          const SizedBox(width: 8),
          ElevatedButton(
            onPressed: () {},
            child: const Text("Lihat"),
          )
        ],
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
          width: 70,
          height: 70,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.grey[200],
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

// --- WIDGET UNTUK CARD MATERI
class _MaterialCard extends StatelessWidget {
  // 1. Ubah tipe data dari 'CourseMaterial' menjadi 'Map<String, dynamic>'
  final Map<String, dynamic> material;
  const _MaterialCard({required this.material});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Column(
        children: [
          Row(
            children: [
              // 2. Ambil data menggunakan ['key']
              Image.asset(material['iconPath'], width: 40, height: 40),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(material['title'],
                        style: const TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Icon(Icons.book_outlined,
                            size: 16, color: Colors.grey),
                        const SizedBox(width: 4),
                        Text(material['chapterProgress'],
                            style: const TextStyle(color: Colors.grey)),
                        const SizedBox(width: 16),
                        const Icon(Icons.edit_note_outlined,
                            size: 16, color: Colors.grey),
                        const SizedBox(width: 4),
                        Text('${material['exerciseCount']} Latihan Soal',
                            style: const TextStyle(color: Colors.grey)),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue.shade50,
                foregroundColor: Colors.blue.shade800,
                elevation: 0,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
              ),
              child: const Text('Pelajari Sekarang'),
            ),
          ),
        ],
      ),
    );
  }
}