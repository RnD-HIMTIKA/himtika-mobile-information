import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:himtika_mobile_information/core/injection_container.dart';
import 'package:himtika_mobile_information/features/hicode/presentation/bloc/sub_chapter_detail/sub_chapter_detail_bloc.dart';
import 'package:himtika_mobile_information/features/hicode/presentation/bloc/chapter_detail/chapter_detail_bloc.dart';
import 'package:himtika_mobile_information/features/hicode/presentation/pages/final_practice_detail.dart';
import 'package:himtika_mobile_information/features/hicode/presentation/pages/information_screen.dart';
import 'package:himtika_mobile_information/features/hicode/presentation/pages/sub_chapter_detail.dart';
import 'package:himtika_mobile_information/features/hicode/domain/entities/hicode_chapter.dart';

class MaterialDetailScreen extends StatelessWidget {
  final String materialId;

  const MaterialDetailScreen({super.key, required this.materialId});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => sl<MaterialDetailBloc>()
        ..add(FetchDetailData(materialId: materialId)),
      child: Scaffold(
        backgroundColor: const Color(0xFFF5F5F5),
        body: SafeArea(
          top: false,
          child: BlocBuilder<MaterialDetailBloc, MaterialDetailState>(
            builder: (context, state) {
              if (state.status == MaterialDetailStatus.loading) {
                return const Center(child: CircularProgressIndicator());
              }
              if (state.status == MaterialDetailStatus.failure) {
                return Center(
                    child: Text(state.errorMessage ?? 'Gagal memuat data.'));
              }
              if (state.status == MaterialDetailStatus.success) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildBlueHeader(context, state),
                    Expanded(
                      child: state.chapters.isEmpty
                          ? _buildNotFoundWidget()
                          : ListView.separated(
                              padding: const EdgeInsets.all(16),
                              // itemCount sekarang adalah jumlah chapter + 1 (untuk Latihan Final)
                              itemCount: state.chapters.length + 1,
                              itemBuilder: (context, index) {
                                // Jika index < jumlah chapter, tampilkan chapter item
                                if (index < state.chapters.length) {
                                  return _buildSubChapterItem(
                                      context, state.chapters[index]);
                                }
                                // Jika index terakhir, tampilkan Latihan Soal Final
                                else {
                                  // Ambil nama materi dari state (untuk navigasi kuis)
                                  final materialName = state.title ?? 'Materi';
                                  return _buildFinalPracticeItem(
                                    context,
                                    materialName, // Kirim nama materi
                                    state.finalPracticeStatus,
                                    // Anda bisa ambil jumlah soal dari RPC nanti,
                                    // untuk sekarang kita hardcode atau ambil dari details chapter terakhir jika perlu
                                    "10 Soal", // Placeholder
                                  );
                                }
                              },
                              separatorBuilder: (context, index) =>
                                  const SizedBox(height: 12),
                            ),
                    ),
                  ],
                );
              }
              return const SizedBox.shrink();
            },
          ),
        ),
      ),
    );
  }

  Widget _buildBlueHeader(BuildContext context, MaterialDetailState state) {
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        color: Colors.blue,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(30),
          bottomRight: Radius.circular(30),
        ),
        image: DecorationImage(
          image: AssetImage('src/features/hicode/images/pattern_card.png'),
          fit: BoxFit.cover,
          opacity: 1.0,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: MediaQuery.of(context).padding.top),
          _buildTopIconBar(context),
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
            child: _buildHeaderContent(
              title: state.title ?? 'Materi',
              description: state.description ?? 'Deskripsi tidak tersedia.',
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTopIconBar(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: Image.asset('src/features/hicode/materi/kembali.png',
                width: 32, height: 32, color: Colors.white),
          ),
          IconButton(
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const InformationScreen()),
              );
            },
            icon: Image.asset('src/features/hicode/materi/informasi.png',
                width: 28, height: 28, color: Colors.white),
          ),
        ],
      ),
    );
  }

  Widget _buildHeaderContent(
      {required String title, required String description}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title,
            style: const TextStyle(
                color: Colors.white,
                fontSize: 32,
                fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        Text(description,
            style: const TextStyle(
                color: Colors.white, fontSize: 14, height: 1.5)),
      ],
    );
  }

  Widget _buildSubChapterItem(BuildContext context, HiCodeChapter chapter) {
  // Ambil URL ikon materi dari state BLoC
  final String? materialIconUrl = context.read<MaterialDetailBloc>().state.materialIconPath;
  // Ambil materialId dari widget utama untuk refresh
  final materialId = (context.findAncestorWidgetOfExactType<MaterialDetailScreen>())?.materialId;


  // --- Logika status tetap sama ---
  IconData? statusIcon; // Icon untuk overlay (nullable)
  Color statusColor;
  String statusText;
  Color cardColor = Colors.white;
  Color borderColor = Colors.blue.shade100;
  bool isTapEnabled = !chapter.isLocked;

  if (chapter.isLocked) {
    statusIcon = Icons.lock_outline; // Icon gembok untuk overlay
    statusColor = Colors.grey.shade400;
    statusText = 'Terkunci';
    cardColor = Colors.grey.shade100;
    borderColor = Colors.grey.shade300;
  } else if (chapter.isCompleted) {
    statusIcon = Icons.check_circle; // Icon centang untuk overlay
    statusColor = Colors.green;
    statusText = 'Sudah Selesai';
    borderColor = Colors.green.shade200;
  } else {
    statusIcon = Icons.play_circle_outline; // Icon play untuk overlay (jika diinginkan) atau null
    statusColor = Colors.blue.shade600;
    statusText = 'Kerjakan Sekarang';
  }
  // --- End Logika status ---


  return InkWell(
    onTap: isTapEnabled
        ? () async {
            final bool? quizResult = await Navigator.of(context).push<bool>(
              MaterialPageRoute(
                builder: (_) => BlocProvider(
                  create: (context) => sl<SubChapterDetailBloc>(),
                  child: SubChapterDetailScreen(subChapterId: chapter.id),
                ),
              ),
            );

            if (quizResult == true && context.mounted) {
              if (materialId != null) {
                 context.read<MaterialDetailBloc>().add(FetchDetailData(materialId: materialId));
              }
            }
          }
        : null,
    borderRadius: BorderRadius.circular(15),
    child: Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: borderColor, width: 1.5),
      ),
      child: Row(
        children: [
          // --- KEMBALIKAN Stack Gambar + Status ---
          SizedBox(
            width: 40,
            height: 40,
            child: Stack(
              clipBehavior: Clip.none, // Izinkan ikon status keluar
              children: [
                // Gambar Materi
                Container( // Wadah untuk gambar agar bisa diberi background jika error
                   width: 40,
                   height: 40,
                   decoration: BoxDecoration(
                      color: Colors.grey[200], // Background fallback
                      borderRadius: BorderRadius.circular(8),
                   ),
                   child: ClipRRect(
                     borderRadius: BorderRadius.circular(8),
                     child: (materialIconUrl != null && materialIconUrl.isNotEmpty)
                         ? Image.network(
                              materialIconUrl,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) =>
                                Icon(Icons.broken_image, size: 24, color: Colors.grey[400]),
                           )
                         : Icon(Icons.image_not_supported, size: 24, color: Colors.grey[400]), // Placeholder jika URL null/kosong
                   ),
                 ),

                // Ikon Status Overlay (Hanya jika Selesai atau Terkunci)
                if (statusIcon != null && (chapter.isCompleted || chapter.isLocked)) // Tampilkan hanya jika ada ikon & statusnya completed/locked
                  Positioned(
                    bottom: -5, // Sesuaikan posisi
                    right: -5,  // Sesuaikan posisi
                    child: Container(
                      padding: const EdgeInsets.all(2),
                      decoration: BoxDecoration(
                        color: cardColor, // Background sesuai warna kartu
                        shape: BoxShape.circle,
                        // Tambahkan border tipis di sekitar ikon status (opsional)
                        // border: Border.all(color: Colors.white, width: 1)
                      ),
                      child: Icon(
                        statusIcon, // Gembok atau Centang
                        color: statusColor,
                        size: 18,
                      ),
                    ),
                  ),
                // Jika status 'available', kita bisa tampilkan ikon play secara overlay juga (opsional)
                // else if (statusIcon != null && !chapter.isLocked && !chapter.isCompleted)
                //    Positioned(...) // Ikon Play
              ],
            ),
          ),
          // --- END KEMBALIKAN ---

          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(chapter.title, style: const TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                Text(chapter.details, style: TextStyle(color: Colors.grey.shade600, fontSize: 12)),
                const SizedBox(height: 4),
                // Tampilkan status text (Selesai/Kerjakan/Terkunci)
                Text(statusText, style: TextStyle(color: statusColor, fontSize: 12, fontWeight: FontWeight.w500)),
              ],
            ),
          ),
          if (isTapEnabled)
            Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey.shade400),
        ],
      ),
    ),
  );
}

  Widget _buildNotFoundWidget() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset('src/features/hicode/materi/empty_box.png', width: 150),
          const SizedBox(height: 16),
          const Text('Chapter Tidak Ditemukan',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Text('Belum ada chapter untuk materi ini.',
              style: TextStyle(color: Colors.grey.shade600)),
        ],
      ),
    );
  }

  Widget _buildFinalPracticeItem(BuildContext context, String materialName,
      String status, String details) {
    // Tentukan style berdasarkan status ('locked' atau 'unlocked')
    bool isLocked = status == 'locked';
    IconData statusIcon = isLocked
        ? Icons.lock_outline
        : Icons.assignment_turned_in_outlined; // Ganti ikon
    Color statusColor = isLocked
        ? Colors.grey.shade400
        : Colors.orange.shade700; // Warna oranye jika unlocked
    String statusText =
        isLocked ? 'Selesaikan Semua Chapter' : 'Kerjakan Sekarang';
    Color cardColor = isLocked ? Colors.grey.shade100 : Colors.white;
    Color borderColor = isLocked
        ? Colors.grey.shade300
        : Colors.orange.shade200; // Border oranye
    bool isTapEnabled = !isLocked;

    return InkWell(
      onTap: isTapEnabled
        ? () {
            // Navigasi ke halaman detail Latihan Final
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => FinalExamDetailScreen(
                  materialName: materialName,
                  materialId: materialId, // <-- Tambahkan materialId (UUID)
                ),
              ),
            );
          }
        : null,
      borderRadius: BorderRadius.circular(15),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(15),
          border: Border.all(color: borderColor, width: 1.5),
        ),
        child: Row(
          children: [
            Icon(statusIcon, color: statusColor, size: 40),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Latihan Soal Final',
                      style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4),
                  Text(details,
                      style:
                          TextStyle(color: Colors.grey.shade600, fontSize: 12)),
                  const SizedBox(height: 4),
                  Text(statusText,
                      style: TextStyle(
                          color: statusColor,
                          fontSize: 12,
                          fontWeight: FontWeight.w500)),
                ],
              ),
            ),
            if (isTapEnabled)
              Icon(Icons.arrow_forward_ios,
                  size: 16, color: Colors.grey.shade400),
          ],
        ),
      ),
    );
  }
}
