import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:himtika_mobile_information/core/injection_container.dart';
import 'package:himtika_mobile_information/features/hicode/presentation/bloc/main_screen/main_screen_bloc.dart';
import 'package:himtika_mobile_information/features/hicode/presentation/pages/chapter_detail.dart';
import 'package:himtika_mobile_information/features/hicode/presentation/pages/information_screen.dart';
import 'package:himtika_mobile_information/features/hicode/presentation/pages/leaderboard_screen.dart';
import 'package:himtika_mobile_information/features/hicode/presentation/pages/overall_exam.dart';
import 'package:himtika_mobile_information/features/hicode/domain/entities/hicode_category.dart';
import 'package:himtika_mobile_information/features/hicode/domain/entities/hicode_material.dart';

class HicodeScreen extends StatelessWidget {
  const HicodeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<HicodeBloc>()..add(HicodeDataFetched()),
      child: Scaffold(
        backgroundColor: Colors.grey[100],
        body: SafeArea(
          child: BlocBuilder<HicodeBloc, HicodeState>(
            builder: (context, state) {
              if (state.status == HicodeStatus.loading) {
                return const Center(child: CircularProgressIndicator());
              }
              if (state.status == HicodeStatus.failure) {
                return Center(child: Text(state.errorMessage ?? 'Gagal memuat data.'));
              }
              if (state.status == HicodeStatus.success) {
                return SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildTopIconBar(context),
                        const SizedBox(height: 16),
                        _buildHeader(),
                        const SizedBox(height: 24),
                        const _LeaderboardCard(),
                        const SizedBox(height: 24),
                        _buildSectionTitle('Kategori'),
                        const SizedBox(height: 12),
                        _buildCategoryList(state),
                        const SizedBox(height: 24),
                        _buildSectionTitle('Pilihan Materi'),
                        const SizedBox(height: 12),
                        _buildMaterialList(state),
                        const SizedBox(height: 24),
                        _buildFinalExamCard(context, isExamReady: state.isExamReady),
                      ],
                    ),
                  ),
                );
              }
              return const SizedBox.shrink();
            },
          ),
        ),
      ),
    );
  }

  Widget _buildTopIconBar(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        IconButton(
          onPressed: () => Navigator.pop(context),
          icon: Image.asset('src/features/hicode/icon/kembali.png', width: 32, height: 32),
        ),
        IconButton(
          onPressed: () {
            Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const InformationScreen()),
            );
          },
          icon: Image.asset('src/features/hicode/icon/informasi.png', width: 28, height: 28),
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
            style: TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold),
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

  Widget _buildCategoryList(HicodeState state) {
    return SizedBox(
      height: 120,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: state.categories.length,
        itemBuilder: (context, index) {
          return _CategoryCard(category: state.categories[index]);
        },
        separatorBuilder: (context, index) => const SizedBox(width: 16),
      ),
    );
  }

  Widget _buildMaterialList(HicodeState state) {
    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: state.materials.length,
      itemBuilder: (context, index) {
        return _MaterialCard(
          material: state.materials[index],
          index: index,
        );
      },
      separatorBuilder: (context, index) => const SizedBox(height: 16),
    );
  }

  Widget _buildFinalExamCard(BuildContext context, {required bool isExamReady}) {
    final Color backgroundColor = isExamReady ? Colors.green : Colors.red.shade400;
    final String imagePath = isExamReady ? 'src/features/hicode/images/dibuka.png' : 'src/features/hicode/images/ditutup.png';
    final String title = isExamReady ? 'Yay! Ujian Akhir Siap Dimulai' : 'Yah, Ujian Belum Bisa Dibuka';
    final String subtitle = isExamReady ? 'Kamu sudah selesaikan materi, saatnya tunjukkan kemampuanmu!' : 'Selesaikan semua Latihan Final di setiap materi untuk membuka!';
    final Color arrowColor = isExamReady ? Colors.white : Colors.white54;
    final String buttonText = isExamReady ? "Kerjakan Sekarang" : "Terkunci";

    return InkWell(
      onTap: () {
        if (isExamReady) {
          Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => const OverallExamScreen()),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Selesaikan semua materi terlebih dahulu untuk membuka Ujian Akhir!'),
              backgroundColor: Colors.orange,
            ),
          );
        }
      },
      child: Container(
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
                Image.asset(imagePath, width: 40, height: 40, color: Colors.white),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                      Text(subtitle, style: const TextStyle(color: Colors.white, fontSize: 12)),
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
                  Text(buttonText, style: TextStyle(color: arrowColor, fontWeight: FontWeight.bold, fontSize: 14)),
                  const SizedBox(width: 8),
                  Icon(Icons.arrow_forward_ios, color: arrowColor, size: 14),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Private Widgets
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
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Image.asset('src/features/hicode/images/leaderboard.png', width: 90, fit: BoxFit.cover),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Leaderboard", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                      SizedBox(height: 4),
                      Text("Lihat kapabilitas yang sudah menyelesaikan tugas akhir dan meraih skor terbaik!", style: TextStyle(color: Colors.grey, fontSize: 12)),
                    ],
                  ),
                  const SizedBox(height: 4),
                  SizedBox(
                    height: 24,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(builder: (_) => const LeaderboardScreen()),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        backgroundColor: const Color(0xFF81EAFF),
                        foregroundColor: const Color(0xFF006EBD),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                      child: const Text("Lihat Selengkapnya", style: TextStyle(fontSize: 12)),
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

class _CategoryCard extends StatelessWidget {
  final HiCodeCategory category;
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
            color: const Color(0xFFE0E0E0),
            borderRadius: BorderRadius.circular(15),
          ),
          child: Image.network(category.iconUrl, fit: BoxFit.contain), // Menggunakan NetworkImage
        ),
        const SizedBox(height: 8),
        Text(category.name),
      ],
    );
  }
}

class _MaterialCard extends StatelessWidget {
  final HiCodeMaterial material;
  final int index;

  const _MaterialCard({required this.material, required this.index});

  @override
  Widget build(BuildContext context) {
    final Color borderColor = material.borderColor != null
        ? Color(int.parse(material.borderColor!.replaceFirst('#', '0xff')))
        : Colors.grey;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: borderColor, width: 2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (material.imageUrl != null)
                Image.network(material.imageUrl!, width: 82, height: 82),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(material.title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Icon(Icons.book_outlined, size: 16, color: Colors.grey),
                        const SizedBox(width: 8),
                        Text(
                          '${material.completedChapters}/${material.totalChapters} Chapter Selesai', // Tambahkan 'Selesai'
                          style: const TextStyle(color: Colors.grey),
                        ),
                        const SizedBox(height: 4), // Beri sedikit jarak
                        if (material.totalChapters > 0) // Hanya tampilkan jika ada chapter
                          LinearProgressIndicator(
                            value: material.completedChapters / material.totalChapters,
                            backgroundColor: Colors.grey[300],
                            valueColor: AlwaysStoppedAnimation<Color>(borderColor), // Gunakan warna border
                            minHeight: 6, // Atur tinggi progress bar
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => MaterialDetailScreen(materialId: material.id)),
              );
            },
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              backgroundColor: const Color(0xFF81EAFF),
              foregroundColor: const Color(0xFF006EBD),
              elevation: 0,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
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