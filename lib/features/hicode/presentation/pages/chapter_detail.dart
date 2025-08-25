import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:himtika_mobile_information/features/hicode/presentation/pages/final_practice_detail.dart';
import 'package:himtika_mobile_information/features/hicode/presentation/pages/sub_chapter_detail.dart';
import 'package:himtika_mobile_information/features/hicode/presentation/pages/information_screen.dart';
import '../bloc/chapter_detail/chapter_detail_bloc.dart';

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
          top: false,
          child: BlocBuilder<MaterialDetailBloc, MaterialDetailState>(
            builder: (context, state) {
              if (state.status == MaterialDetailStatus.loading ||
                  state.title == null) {
                return const Center(child: CircularProgressIndicator());
              }

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // --- BAGIAN HEADER BIRU (YANG DIBUAT KONSISTEN) ---
                  Container(
                    width: double.infinity,
                    decoration: const BoxDecoration(
                      color: Colors.blue,
                      borderRadius: BorderRadius.only(
                        bottomLeft: Radius.circular(30),
                        bottomRight: Radius.circular(30),
                      ),
                      image: DecorationImage(
                        image: AssetImage('src/features/hicode/images/pattern_card.png'), // Sesuaikan path
                        fit: BoxFit.cover,
                        opacity: 1.0,
                      ),
                    ),
                    // 2. Ubah struktur di dalam header
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(height: MediaQuery.of(context).padding.top),
                        _buildTopIconBar(context),
                        Padding(
                          padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildHeader(
                                title: state.title!,
                                description: state.description!,
                              ),
                              const SizedBox(height: 16),
                              _buildSearchBar(),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  // --- BAGIAN KONTEN PUTIH (LIST) ---
                  Expanded(
                    child: state.filteredSubChapters.isEmpty &&
                            state.searchQuery.isNotEmpty
                        ? _buildNotFoundWidget()
                        : ListView.separated(
                            padding: const EdgeInsets.all(16),
                            itemCount: state.filteredSubChapters.length + 1,
                            itemBuilder: (context, index) {
                              if (index < state.filteredSubChapters.length) {
                                return _buildSubChapterItem(context, state, state.filteredSubChapters[index]);
                              } else {
                                return state.searchQuery.isEmpty
                                    ? _buildFinalExamItem(context, state)
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
  // 3. Pastikan _buildTopIconBar menggunakan padding internal yang konsisten
  Widget _buildTopIconBar(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: Image.asset('src/features/hicode/materi/kembali.png', // Sesuaikan path
                width: 32, height: 32, color: Colors.white),
          ),
          IconButton(
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const InformationScreen()),
              );
            },
            icon: Image.asset('src/features/hicode/materi/informasi.png', // Sesuaikan path
                width: 28, height: 28, color: Colors.white),
          ),
        ],
      ),
    );
  }

  // 4. Sederhanakan _buildHeader agar tidak punya padding sendiri
  Widget _buildHeader({required String title, required String description}) {
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

   Widget _buildSubChapterItem(BuildContext context, MaterialDetailState state, Map<String, dynamic> subChapter) {
    final status = subChapter['status'] as SubChapterStatus;
    return InkWell(
      onTap: () {
        if (status == SubChapterStatus.locked) return;
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => SubChapterDetailScreen(subChapterId: subChapter['title']!),
          ),
        );
      },
      borderRadius: BorderRadius.circular(15),
      child: _SubChapterCard(
        iconPath: state.materialIconPath!,
        title: subChapter['title']!,
        details: subChapter['details']!,
        status: status,
      ),
    );
  }

  // Widget untuk card ujian final
  Widget _buildFinalExamItem(BuildContext context, MaterialDetailState state) {
    // Pengecekan null untuk keamanan
    if (state.finalExamStatus == null || state.title == null) {
      return const SizedBox.shrink();
    }

    final finalExamStatus = state.finalExamStatus!['status'] as SubChapterStatus;
    final finalExamIconPath = (finalExamStatus == SubChapterStatus.locked)
        ? 'src/features/hicode/materi/terkunci.png'
        : 'src/features/hicode/materi/selesai.png';
    
    String materialName = 'Materi';
    if (state.title!.contains(' - ')) {
      materialName = state.title!.split(' - ').last;
    }
    
    return InkWell(
      onTap: () {
        if (finalExamStatus == SubChapterStatus.locked) return;

        // --- PASTIKAN BARIS INI BENAR ---
        // Navigator harus mengarah ke FinalExamDetailScreen
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => FinalExamDetailScreen(materialName: materialName),
          ),
        );
      },
      borderRadius: BorderRadius.circular(15),
      child: _SubChapterCard(
        iconPath: finalExamIconPath,
        title: state.finalExamStatus!['title']!,
        details: state.finalExamStatus!['details']!,
        status: finalExamStatus,
      ),
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
            hintText: 'Cari materi...',
            prefixIcon: const Icon(Icons.search),
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
          color: status == SubChapterStatus.locked
              ? Colors.grey.shade300
              : Colors.blue.shade100,
          width: 1.5,
        ),
      ),
      child: Row(
        children: [
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