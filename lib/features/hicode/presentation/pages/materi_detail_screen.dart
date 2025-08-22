import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:himtika_mobile_information/features/hicode/presentation/pages/hicode_screen.dart';
import '../bloc/detail_screen/material_detail_bloc.dart';

class MaterialDetailScreen extends StatelessWidget {
  final String materialId;

  const MaterialDetailScreen({super.key, required this.materialId});

  @override
  Widget build(BuildContext context) {
    // 1. Buat instance BLoC baru khusus untuk halaman ini
    return BlocProvider(
      create: (context) => MaterialDetailBloc()
        ..add(FetchDetailData(materialId: materialId)), // Langsung panggil event
      child: Scaffold(
        backgroundColor: Colors.grey[100],
        body: SafeArea(
          // 2. Gunakan BlocBuilder dengan BLoC yang baru
          child: BlocBuilder<MaterialDetailBloc, MaterialDetailState>(
            builder: (context, state) {
              if (state.status == MaterialDetailStatus.loading) {
                return const Center(child: CircularProgressIndicator());
              }

              if (state.status == MaterialDetailStatus.success) {

                // Variabel dideklarasikan di sini, di luar daftar children
                final finalExamStatus = state.finalExamStatus!['status'] as SubChapterStatus;
                final finalExamIconPath = (finalExamStatus == SubChapterStatus.locked)
                    ? 'src/features/hicode/materi/terkunci.png'
                    : 'src/features/hicode/materi/selesai.png';

                return SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: _buildTopIconBar(context),
                      ),
                      _buildHeader(
                        title: state.title!,
                        description: state.description!,
                      ),
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildSearchBar(),
                            const SizedBox(height: 24),
                            // List Sub Bab
                            ListView.separated(
                              itemCount: state.subChapters.length,
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemBuilder: (context, index) {
                                final subChapter = state.subChapters[index];
                                return _SubChapterCard(
                                  iconPath: state.materialIconPath!,
                                  title: subChapter['title']!,
                                  details: subChapter['details']!,
                                  status: subChapter['status'] as SubChapterStatus,
                                );
                              },
                              separatorBuilder: (context, index) =>
                                  const SizedBox(height: 12),
                            ),
                            const SizedBox(height: 24),

                            // Latihan Soal Final
                            // Gunakan variabel yang sudah dibuat di atas
                            _SubChapterCard(
                              iconPath: finalExamIconPath,
                              title: state.finalExamStatus!['title']!,
                              details: state.finalExamStatus!['details']!,
                              status: finalExamStatus,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              }
              return const SizedBox.shrink(); // Tampilkan widget kosong jika ada error/initial
            },
          ),
        ),
      ),
    );
  }
  // --- WIDGET-WIDGET PEMBANTU ---

  Widget _buildTopIconBar(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        IconButton(
          onPressed: () {
            Navigator.pop(
              context,
              MaterialPageRoute(builder: (context) => const HicodeScreen()),
            );
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
            // Aksi ketika tombol info ditekan
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

  Widget _buildHeader({required String title, required String description}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      color: Colors.blue.shade700, // Warna biru header
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Text(description, style: const TextStyle(color: Colors.white, fontSize: 14)),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return TextField(
      decoration: InputDecoration(
        hintText: 'Search anything...',
        prefixIcon: const Icon(Icons.search),
        suffixIcon: const Icon(Icons.mic),
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }
}

// Widget kustom untuk setiap item di list
class _SubChapterCard extends StatelessWidget {
  final String iconPath;
  final String title;
  final String details;
  final SubChapterStatus status;

  const _SubChapterCard({
    required this.iconPath,
    required this.title,
    required this.details,
    this.status = SubChapterStatus.locked,
  });

  @override
  Widget build(BuildContext context) {
    // Logika untuk UI dinamis
    Color backgroundColor = Colors.white;
    String statusText = '';
    IconData statusIcon = Icons.check_circle;
    Color statusColor = Colors.green;

    switch (status) {
      case SubChapterStatus.locked:
        backgroundColor = Colors.transparent;
        statusText = 'Terkunci';
        statusIcon = Icons.lock;
        statusColor = Colors.grey.shade400;
        break;
      case SubChapterStatus.available:
        backgroundColor = Colors.white;
        statusText = 'Kerjakan Sekarang';
        statusIcon = Icons.play_circle_fill;
        statusColor = Colors.cyan.shade800;
        break;
      case SubChapterStatus.completed:
        backgroundColor = Colors.white;
        statusText = 'Sudah Selesai';
        statusIcon = Icons.check_circle;
        statusColor = Colors.green;
        break;
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(15),
        border: status == SubChapterStatus.locked
            ? Border.all(color: Colors.grey.shade300)
            : null,
      ),
      child: Row(
        children: [
          // --- PERUBAHAN UTAMA DI SINI ---
          // Hapus Container pembungkus, langsung tampilkan Image.asset
          Image.asset(
            iconPath,
            width: 40,  // Sedikit diperbesar agar terlihat bagus
            height: 40,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      details,
                      style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(statusIcon, color: statusColor, size: 14),
                        const SizedBox(width: 4),
                        Text(
                          statusText,
                          style: TextStyle(
                              color: statusColor,
                              fontSize: 12,
                              fontWeight: FontWeight.w500),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
          const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
        ],
      ),
    );
  }
}