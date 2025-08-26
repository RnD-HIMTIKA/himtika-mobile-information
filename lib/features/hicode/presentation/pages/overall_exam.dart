import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
// Sesuaikan path import dengan proyek Anda
import 'package:himtika_mobile_information/features/hicode/presentation/bloc/overall_exam/overall_exam_bloc.dart';
import 'package:himtika_mobile_information/features/hicode/presentation/pages/quiz_screen.dart';

class OverallExamScreen extends StatelessWidget {
  const OverallExamScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => OverallExamBloc()..add(FetchDetails()),
      child: Scaffold(
        backgroundColor: const Color(0xFFF5F5F5),
        body: SafeArea(
          top: false,
          child: BlocBuilder<OverallExamBloc, OverallExamState>(
            builder: (context, state) {
              if (state.status == OverallExamStatus.loading || state.title == null) {
                return const Center(child: CircularProgressIndicator());
              }

              return Column(
                children: [
                  // --- BAGIAN HEADER BIRU (YANG DIBUAT KONSISTEN) ---
                  _buildBlueHeader(context, state),

                  // --- BAGIAN KONTEN PUTIH ---
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.fromLTRB(24, 24, 24, 80),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildSectionTitle('Tentang Ujian Ini:'),
                          const SizedBox(height: 16),
                          _buildInfoRow(Icons.timer_outlined, 'Waktu pengerjaan 30 menit'),
                          _buildInfoRow(Icons.article_outlined, '30 Soal Pilihan Ganda'),
                          _buildInfoRow(Icons.workspace_premium_outlined, 'Minimal 15 jawaban benar untuk lulus'),
                          const SizedBox(height: 24),
                          _buildSectionTitle('Petunjuk:'),
                          const SizedBox(height: 16),
                          _buildBulletPoint('Ujian ini mencakup semua materi: HTML, CSS, JavaScript, dan C++.'),
                          _buildBulletPoint('Pastikan koneksi internet stabil selama mengerjakan.'),
                          _buildBulletPoint('Dilarang membuka tab atau aplikasi lain selama ujian berlangsung.'),
                        ],
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
        bottomNavigationBar: _buildBottomButton(context),
      ),
    );
  }

  // --- WIDGET-WIDGET PEMBANTU ---

  // Perbaiki method ini agar sama dengan final_practice_detail.dart
  Widget _buildBlueHeader(BuildContext context, OverallExamState state) {
    return Container(
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
                const SizedBox(height: 16),
                Text(
                  state.title!,
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 32,
                      fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: MediaQuery.of(context).size.width * 0.85,
                  child: Text(
                    state.description!,
                    style: const TextStyle(
                        color: Colors.white, fontSize: 14, height: 1.5),
                  ),
                ),
                const SizedBox(height: 24),
              ],
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
        children: [
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: Image.asset('src/features/hicode/materi/kembali.png', // Sesuaikan path
                width: 32, height: 32, color: Colors.white),
          ),
          const Expanded(
            child: Text(
              'Ujian Akhir', // Judul disesuaikan
              textAlign: TextAlign.center,
              style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.white),
            ),
          ),
          const SizedBox(width: 48), // Placeholder
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
    );
  }

  Widget _buildInfoRow(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(children: [
        Icon(icon, color: Colors.blue, size: 24),
        const SizedBox(width: 16),
        Expanded(
            child: Text(text,
                style: TextStyle(fontSize: 14, color: Colors.grey.shade700))),
      ]),
    );
  }

  Widget _buildBulletPoint(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Padding(
          padding: const EdgeInsets.only(top: 6.0, right: 12.0),
          child: Text('•',
              style: TextStyle(
                  color: Colors.grey.shade700,
                  fontSize: 16,
                  fontWeight: FontWeight.bold)),
        ),
        Expanded(
            child: Text(text,
                style: TextStyle(
                    fontSize: 14, color: Colors.grey.shade700, height: 1.5))),
      ]),
    );
  }

  Widget _buildBottomButton(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: ElevatedButton(
        onPressed: () async {
          // Panggil dialog dan tunggu hasilnya
          final bool? shouldStart = await _showStartConfirmationDialog(context);

          // Jika pengguna menekan "Mulai Kerjakan" (true)
          if (shouldStart == true && context.mounted) {
            Navigator.of(context).push(
              MaterialPageRoute(
                  builder: (_) => const QuizScreen(quizId: 'OVERALL_EXAM')),
            );
          }
        },
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 16),
          backgroundColor: Colors.blue,
          foregroundColor: Colors.white,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
        ),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Kerjakan Sekarang',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            SizedBox(width: 8),
            Icon(Icons.arrow_forward, color: Colors.white),
          ],
        ),
      ),
    );
  }

  Future<bool?> _showStartConfirmationDialog(BuildContext context) {
    return showDialog<bool>(
      context: context,
      builder: (context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20.0),
          ),
          backgroundColor: const Color(0xFFF5F9FF), // Warna background dialog
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Siap Memulai Ujian?',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Ujian berdurasi 30 menit dengan 30 soal dari semua materi. Waktu langsung berjalan saat kamu mulai.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.black54,
                  ),
                ),
                const SizedBox(height: 24),
                // Tombol Mulai Kerjakan
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).pop(true); // Ya, mulai
                    },
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                    child: const Text('Mulai Kerjakan'),
                  ),
                ),
                const SizedBox(height: 8),
                // Tombol Kembali
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).pop(false); // Batal
                    },
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      backgroundColor: Colors.grey.shade200,
                      foregroundColor: Colors.black54,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                    child: const Text('Kembali'),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}