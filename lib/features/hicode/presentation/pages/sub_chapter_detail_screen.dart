import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:himtika_mobile_information/features/hicode/presentation/bloc/sub_chapter_detail/sub_chapter_detail_bloc.dart';
import 'package:himtika_mobile_information/features/hicode/presentation/pages/information_screen.dart';
import 'package:himtika_mobile_information/features/hicode/presentation/pages/quiz_screen.dart';

class SubChapterDetailScreen extends StatelessWidget {
  final String subChapterId;

  const SubChapterDetailScreen({super.key, required this.subChapterId});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => SubChapterDetailBloc()
        ..add(FetchSubChapterData(subChapterId: subChapterId)),
      child: Scaffold(
        backgroundColor: const Color(0xFFF5F5F5),
        body: SafeArea(
          child: BlocBuilder<SubChapterDetailBloc, SubChapterDetailState>(
            builder: (context, state) {
              if (state.status == SubChapterDetailStatus.loading || state.title == null) {
                return const Center(child: CircularProgressIndicator());
              }

              return Column(
                children: [
                  // --- BAGIAN HEADER BIRU ---
                  _buildBlueHeader(context, state),

                  // --- BAGIAN KONTEN PUTIH ---
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(24.0),
                      child: Text(
                        state.content!,
                        style: const TextStyle(fontSize: 16, height: 1.6),
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
        bottomNavigationBar: BlocBuilder<SubChapterDetailBloc, SubChapterDetailState>(
          builder: (context, state) {
            // Cek jika state belum siap, jangan tampilkan tombol
            if (state.title == null) {
              return const SizedBox.shrink();
            }
            
            return Padding(
              padding: const EdgeInsets.all(16.0),
              child: ElevatedButton(
                onPressed: () {
                  final quizId = state.title!.replaceAll('\n', ' ');
                  
                  // TAMBAHKAN PRINT DI SINI
                  print('--- ID KUIS YANG DIKIRIM: [$quizId]');
                  
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => QuizScreen(quizId: quizId),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('Kerjakan Kuis'),
                    SizedBox(width: 8),
                    Icon(Icons.arrow_forward),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  // Widget untuk keseluruhan blok header biru
  Widget _buildBlueHeader(BuildContext context, SubChapterDetailState state) {
    return Container(
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
            const SizedBox(height: 16),
            _buildTopIconBar(context),
            const SizedBox(height: 8),
            _buildHeaderContent(
              title: state.title!,
              readTime: state.readTime!,
              quizCount: state.quizCount!,
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  // Widget untuk Top Bar (Back & Info)
  Widget _buildTopIconBar(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        IconButton(
          onPressed: () async {
            final bool? shouldExit = await _showExitConfirmationDialog(context);

            // Tambahkan pengecekan 'context.mounted' di sini
            if (shouldExit == true && context.mounted) {
              Navigator.of(context).pop();
            }
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
            Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const InformationScreen()),
            );
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
  
  // Widget untuk konten di dalam header (judul, durasi, kuis)
  Widget _buildHeaderContent(
      {required String title,
      required String readTime,
      required String quizCount}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
                color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              const Icon(Icons.access_time, color: Colors.white, size: 20),
              const SizedBox(width: 8),
              Text(readTime, style: const TextStyle(color: Colors.white)),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              const Icon(Icons.edit_note, color: Colors.white, size: 20),
              const SizedBox(width: 8),
              Text(quizCount, style: const TextStyle(color: Colors.white)),
            ],
          ),
        ],
      ),
    );
  }
}

Future<bool?> _showExitConfirmationDialog(BuildContext context) {
  return showDialog<bool>(
    context: context,
    builder: (context) {
      return Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20.0),
        ),
        backgroundColor: const Color(0xFFF5F9FF),
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min, 
            children: [
              const Text(
                'Keluar dari Materi?',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Anda sedang mengakses materi ini. Keluar sekarang dapat membuat progres belajar Anda tidak tersimpan.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.black54,
                ),
              ),
              const SizedBox(height: 24),              
              // Tombol Kembali ke Beranda
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    // Tutup dialog dan kembalikan nilai 'true'
                    Navigator.of(context).pop(true);
                  },
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                    elevation: 0, // Hilangkan bayangan
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  child: const Text('Kembali ke Beranda'),
                ),
              ),
              const SizedBox(height: 8),
              // Tombol Lanjutkan Belajar
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    // Tutup dialog dan kembalikan nilai 'false'
                    Navigator.of(context).pop(false);
                  },
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    backgroundColor: const Color(0xFFE0E0E0),
                    foregroundColor: Colors.black54,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  child: const Text('Lanjutkan Belajar'),
                ),
              ),             
            ],
          ),
        ),
      );
    },
  );
}