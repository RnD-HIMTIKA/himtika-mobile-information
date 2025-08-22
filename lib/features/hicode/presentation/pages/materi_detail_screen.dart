import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:himtika_mobile_information/features/hicode/presentation/pages/hicode_screen.dart';
import '../bloc/detail_screen/material_detail_bloc.dart';

class MaterialDetailScreen extends StatelessWidget {
  final String materialId;

  const MaterialDetailScreen({super.key, required this.materialId});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => MaterialDetailBloc()
        ..add(FetchDetailData(materialId: materialId)),
      child: Scaffold(
        backgroundColor: const Color(0xFFF5F5F5),
        body: SafeArea(
          child: BlocBuilder<MaterialDetailBloc, MaterialDetailState>(
            builder: (context, state) {
              if (state.status == MaterialDetailStatus.loading || state.title == null) {
                return const Center(child: CircularProgressIndicator());
              }

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // === BAGIAN BIRU DENGAN SUDUT MELENGKUNG DI BAWAH ===
                  Container(
                    decoration: const BoxDecoration(
                      color: Colors.blue,
                      borderRadius: BorderRadius.only(
                        bottomLeft: Radius.circular(30),
                        bottomRight: Radius.circular(30),
                      ),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // --- TAMBAHKAN JARAK DI SINI ---
                          const SizedBox(height: 16), // Memberi jarak atas yang sama

                          _buildTopIconBar(context),
                          const SizedBox(height: 8),
                          _buildHeader(
                            title: state.title!,
                            description: state.description!,
                          ),
                          const SizedBox(height: 16),
                          _buildSearchBar(),
                          const SizedBox(height: 24),
                        ],
                      ),
                    ),
                  ),
                  // === BAGIAN DAFTAR MATERI (SEKARANG MENJADI EXPANDED LISTVIEW) ===                  
                  Expanded(
                    child: state.filteredSubChapters.isEmpty && state.searchQuery.isNotEmpty
                        ? SingleChildScrollView( // 1. Bungkus dengan SingleChildScrollView
                            physics: const BouncingScrollPhysics(),
                            child: Padding(
                              // 2. Beri padding atas agar posisi widget-nya bagus
                              padding: const EdgeInsets.only(top: 64.0, left: 16, right: 16),
                              child: _buildNotFoundWidget(),
                            ),
                          )
                        : ListView.separated(
                            padding: const EdgeInsets.all(16),
                            itemCount: state.filteredSubChapters.length + 1,
                            itemBuilder: (context, index) {
                              if (index < state.filteredSubChapters.length) {
                                final subChapter = state.filteredSubChapters[index];
                                return _SubChapterCard(
                                  iconPath: state.materialIconPath!,
                                  title: subChapter['title']!,
                                  details: subChapter['details']!,
                                  status: subChapter['status'] as SubChapterStatus,
                                );
                              } else {
                                return state.searchQuery.isEmpty
                                    ? _buildFinalExamItem(state)
                                    : const SizedBox.shrink();
                              }
                            },
                            separatorBuilder: (context, index) =>
                                const SizedBox(height: 12),
                          ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  // --- WIDGET-WIDGET PEMBANTU ---
  
  // Widget untuk card ujian final
  Widget _buildFinalExamItem(MaterialDetailState state) {
    final finalExamStatus =
        state.finalExamStatus!['status'] as SubChapterStatus;
    final finalExamIconPath = (finalExamStatus == SubChapterStatus.locked)
        ? 'src/features/hicode/materi/terkunci.png'
        : 'src/features/hicode/materi/selesai.png';
    return _SubChapterCard(
      iconPath: finalExamIconPath,
      title: state.finalExamStatus!['title']!,
      details: state.finalExamStatus!['details']!,
      status: finalExamStatus,
    );
  }

  // Widget untuk UI "Tidak Ditemukan"
  Widget _buildNotFoundWidget() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset(
            'src/features/hicode/materi/empty_box.png',
            width: 150,
          ),
          const SizedBox(height: 16),
          const Text(
            'Materi Tidak Ditemukan',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            'Tidak ada chapter yang sesuai dengan\npencarian Anda.',
            style: TextStyle(color: Colors.grey.shade600),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

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
            'src/features/hicode/materi/kembali.png',
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
            'src/features/hicode/materi/informasi.png',
            width: 28,
            height: 28,
          ),
        ),
      ],
    );
  }

  Widget _buildHeader({required String title, required String description}) {
    // Hapus Container dan color dari sini
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title,
              style: const TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Text(description,
              style: const TextStyle(color: Colors.white, fontSize: 14)),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    // Gunakan BlocBuilder agar bisa mengakses BLoC
    return BlocBuilder<MaterialDetailBloc, MaterialDetailState>(
      builder: (context, state) {
        return TextField(
          onChanged: (query) {
            // Kirim event 'SearchQueryChanged' setiap kali teks berubah
            context
                .read<MaterialDetailBloc>()
                .add(SearchQueryChanged(query: query));
          },
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
      },
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
        border: Border.all(
          // Jika status locked, warna border abu-abu, jika tidak, warna biru bias
          color: status == SubChapterStatus.locked
              ? Colors.grey.shade300
              : Colors.blue.shade100, // Warna "biru bias"
          width: 1.5, // Atur ketebalan border
        ),
      ),
      child: Row(
        children: [
          // --- PERUBAHAN UTAMA DI SINI ---
          Image.asset(
            iconPath,
            width: 40,
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