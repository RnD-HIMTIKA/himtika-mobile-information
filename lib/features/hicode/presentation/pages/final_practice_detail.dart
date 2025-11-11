import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:himtika_mobile_information/features/hicode/presentation/pages/quiz_screen.dart'; 
import '../bloc/final_practice_detail/final_practice_detail_bloc.dart';

class FinalExamDetailScreen extends StatelessWidget {
  final String materialName;
  final String materialId;
  final int questionCount;
  final String userName;

  const FinalExamDetailScreen({
    super.key, 
    required this.materialName,
    required this.materialId,
    required this.questionCount,
    required this.userName,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => FinalExamDetailBloc()
        ..add(FetchFinalExamDetails(materialName: materialName)),
      child: Scaffold(
        backgroundColor: const Color(0xFFF5F5F5),
        body: SafeArea(
          top: false,
          child: BlocBuilder<FinalExamDetailBloc, FinalExamDetailState>(
            builder: (context, state) {
              if (state.status == FinalExamDetailStatus.loading || state.title == null) {
                return const Center(child: CircularProgressIndicator());
              }

              // Struktur utama dengan Column untuk memisahkan header dan konten
              return Column(
                children: [
                  // BAGIAN 1: HEADER BIRU (TINGGI TETAP)
                  Container(
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
                                // 1. Batasi lebar SizedBox, misal 85% dari lebar layar
                                width: MediaQuery.of(context).size.width * 0.85, 
                                child: Text(
                                  state.description!,
                                  // Properti Text tidak perlu diubah
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
                  ),

                  // BAGIAN 2: KONTEN PUTIH (SCROLLABLE, MENGISI SISA RUANG)
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.fromLTRB(24, 24, 24, 24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildSectionTitle('Tentang Latihan Ini:'),
                          const SizedBox(height: 16),
                          _buildInfoRow('src/features/hicode/images/timer.png', // Sesuaikan path aset Anda
                              'Tanpa batas waktu pengerjaan'),
                          _buildInfoRow('src/features/hicode/images/document.png', // Sesuaikan path aset Anda
                              '$questionCount Soal Pilihan Ganda'),
                          _buildInfoRow('src/features/hicode/images/badge.png', // Sesuaikan path aset Anda
                              'Minimal 6 jawaban benar untuk lulus'),
                          const SizedBox(height: 24),
                          _buildSectionTitle('Petunjuk:'),
                          const SizedBox(height: 16),
                          _buildBulletPoint(
                              'Baca soal dengan cermat dan pilih jawaban yang paling tepat'),
                          _buildBulletPoint(
                              'Materi soal diambil dari semua Chapter yang telah kamu lalui'),
                          _buildBulletPoint(
                              'Jika kurang dari 6 benar, latihan final akan diulang'),
                          _buildBulletPoint(
                              'Jika kamu lulus latihan soal latihan final ini, maka kamu lulus dari materi ini'),
                        ],
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
        bottomNavigationBar: _buildBottomButton(context, materialName, materialId),
      ),
    );
  }

  // --- WIDGET-WIDGET PEMBANTU ---

  Widget _buildTopIconBar(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
      child: Row(
        children: [
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: Image.asset('src/features/hicode/materi/kembali.png', // Sesuaikan path aset Anda
                width: 32, height: 32, color: Colors.white),
          ),
          const Expanded(
            child: Text(
              'Detail Latihan',
              textAlign: TextAlign.center,
              style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.white),
            ),
          ),
          const SizedBox(width: 48), // Placeholder untuk menyeimbangkan
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

  Widget _buildInfoRow(String iconAssetPath, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(children: [
        Image.asset(iconAssetPath, width: 24, height: 24),
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

  Widget _buildBottomButton(BuildContext context, String materialName, String materialId) { // <-- Tambahkan materialId
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: ElevatedButton(
        onPressed: () async {
          final bool? shouldStart = await _showStartConfirmationDialog(context);
          if (shouldStart == true && context.mounted) {
            Navigator.of(context).push(
              MaterialPageRoute(
                  builder: (_) => QuizScreen( // 3. KIRIM KE QUIZSCREEN
                        quizId: 'FINAL_$materialId', 
                        chapterTitle: 'Latihan Final: $materialName',
                        userName: userName, // <-- INI PERBAIKANNYA
                      )),
            );
          }
        },
        // Samakan style-nya dengan halaman sub_chapter_detail_screen
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 16),
          backgroundColor: Colors.blue,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
        ),
        // Samakan child-nya juga
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
          backgroundColor: const Color(0xFFF5F9FF),
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Mulai Sekarang?',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Kamu harus menjawab minimal 6 soal dengan benar untuk lulus. Kalau tidak, kamu harus mengulang latihan ini.',
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
                      // Tutup dialog dan kembalikan nilai 'true'
                      Navigator.of(context).pop(true);
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
                      // Tutup dialog dan kembalikan nilai 'false'
                      Navigator.of(context).pop(false);
                    },
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      backgroundColor: Color(0xFFE0E0E0),
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