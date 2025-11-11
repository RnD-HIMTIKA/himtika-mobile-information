import 'dart:io';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:himtika_mobile_information/core/theme/app_colors.dart';
import 'package:himtika_mobile_information/features/hicode/presentation/pages/leaderboard_screen.dart';
import 'package:share_plus/share_plus.dart';
import 'package:screenshot/screenshot.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'dart:typed_data';

class ScoreScreen extends StatefulWidget {
  final int score;
  final int totalQuestions;
  final Duration timeTaken;
  final int correctAnswers;
  final String userName;

  const ScoreScreen({
    super.key,
    required this.score,
    required this.totalQuestions,
    required this.timeTaken,
    required this.correctAnswers,
    required this.userName,
  });

  @override
  State<ScoreScreen> createState() => _ScoreScreenState();
}

class _ScoreScreenState extends State<ScoreScreen> {
  bool _isLoading = true;
  final ScreenshotController _screenshotController = ScreenshotController();

  @override
  void initState() {
    super.initState();
    // Simulasi jeda untuk menghitung skor (misalnya 2 detik)
    Timer(const Duration(seconds: 2), () {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    });
  }

  Future<void> _onSharePressed() async {
    // 3. UBAH BARIS INI:
    // Hapus: final userName = context.read<HomeBloc>().state.currentUser?.username ?? 'Penantang';
    // Ganti dengan:
    final userName = widget.userName; // <-- Ambil dari parameter widget

    // Tampilkan loading
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(child: CircularProgressIndicator()),
    );

    try {
      // 3. Capture widget _ShareableScoreCard
      final Uint8List? image = await _screenshotController.captureFromWidget(
      // Kita build widget-nya di sini
      _ShareableScoreCard(
        score: widget.score,
        correctAnswers: widget.correctAnswers,
        totalQuestions: widget.totalQuestions,
        userName: userName, // <-- Pastikan ini ter-pass
      ),
      context: context,
    );

      if (image == null) throw Exception('Gagal mengambil gambar');

      // 4. Simpan gambar ke file sementara
      final tempDir = await getTemporaryDirectory();
      final imagePath = '${tempDir.path}/hicode_score.png';
      final file = File(imagePath);
      await file.writeAsBytes(image);

      // Tutup dialog loading
      if (mounted) Navigator.of(context).pop();

      // 5. Bagikan file
      await Share.shareXFiles(
        [XFile(imagePath)],
        text:
            'Saya baru saja menyelesaikan Ujian Akhir HiCode dengan skor ${widget.score} poin! Yuk, coba juga!',
      );
    } catch (e) {
      // Tutup dialog loading
      if (mounted) Navigator.of(context).pop();
      // Tampilkan error
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text('Gagal membagikan: $e'), backgroundColor: Colors.red),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        backgroundColor: Colors.white,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Menggunakan kembali animasi dari QuizLoadingScreen
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(5, (index) {
                  return Container(
                    width: 20,
                    height: 80,
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    decoration: BoxDecoration(
                      color: Colors.blue,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  );
                })
                    .animate(
                      interval: 200.ms,
                      onPlay: (controller) => controller.repeat(),
                    )
                    .rotate(
                      begin: 0,
                      end: -0.2,
                      duration: 600.ms,
                      curve: Curves.easeOutBack,
                    )
                    .then(delay: 400.ms)
                    .rotate(
                      begin: -0.2,
                      end: 0,
                      duration: 600.ms,
                      curve: Curves.easeIn,
                    ),
              ),
              const SizedBox(height: 32),
              const Text('Menghitung Skor...',
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              const Text(
                'Harap tunggu sebentar. Kami sedang\nmempersiapkan hasil ujianmu.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
            ],
          ),
        ),
      );
    }

    // Tampilkan halaman skor jika loading sudah selesai
    final int wrongAnswers = widget.totalQuestions - widget.score;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: SingleChildScrollView(
        child: Column(
          children: [
            _buildScoreHeader(context, widget.score),
            _buildScoreDetails(),
            _buildNotes(),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomButtons(context),
    );
  }

  // --- WIDGET-WIDGET PEMBANTU ---
  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return '$minutes:$seconds';
  }

  Widget _buildScoreHeader(BuildContext context, int finalScore) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.only(bottom: 60),
      decoration: const BoxDecoration(
        color: Colors.blue,
        image: DecorationImage(
          image: AssetImage("src/features/hicode/images/pattern_score.png"),
          fit: BoxFit.contain,
          opacity: 2.0,
        ),
      ),
      child: Column(
        children: [
          // Jarak aman untuk status bar
          SizedBox(height: MediaQuery.of(context).padding.top),
          Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: Image.asset(
                    'src/features/hicode/materi/kembali.png',
                    width: 32,
                    height: 32,
                    color: Colors.white,
                  ),
                ),
                IconButton(
                  onPressed: () {
                    // Navigasi ke halaman Leaderboard
                    Navigator.of(context).push(
                      MaterialPageRoute(
                          builder: (_) => const LeaderboardScreen()),
                    );
                  },
                  icon: Image.asset(
                    'src/features/hicode/images/peringkat.png',
                    width: 28,
                    height: 28,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
          const Text(
            'Skor Kamu',
            style: TextStyle(color: Colors.white70, fontSize: 18),
          ),
          const SizedBox(height: 8),
          Text(
            '$finalScore',
            style: const TextStyle(
                color: Colors.white, fontSize: 80, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.star, color: Colors.yellow, size: 16),
              SizedBox(width: 8),
              Text(
                'Hasil terbaikmu dari Ujian Akhir',
                style: TextStyle(color: Colors.white),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildScoreDetails() {
    // Hapus parameter dari sini
    // Hitung jawaban salah berdasarkan correctAnswers dan totalQuestions dari widget
    final int wrongAnswers = widget.totalQuestions - widget.correctAnswers;
    final int total = widget.totalQuestions; // Ambil total dari widget

    // Pastikan return statement ada dan benar
    return Padding(
      // <- Kemungkinan error ada di sekitar sini atau sebelumnya
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  title: 'Jawaban Benar',
                  value:
                      '${widget.correctAnswers}', // Gunakan widget.correctAnswers
                  progress: total > 0
                      ? widget.correctAnswers / total
                      : 0.0, // Pastikan 0.0 jika total 0
                  color: Colors.green,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildStatCard(
                  title: 'Jawaban Salah',
                  value: '$wrongAnswers', // Gunakan wrongAnswers yang dihitung
                  progress: total > 0
                      ? wrongAnswers / total
                      : 0.0, // Pastikan 0.0 jika total 0
                  color: Colors.red,
                ),
              ),
            ],
          ), // <- Pastikan koma ini ada
          const SizedBox(height: 16),
          _buildStatCard(
            title: 'Waktu Pengerjaan',
            value: _formatDuration(widget.timeTaken), // Ini sudah benar
            color: Colors.orange,
            progress: 1.0,
          ),
        ],
      ), // <- Pastikan kurung tutup Column ada
    ); // <- Pastikan titik koma return Padding ada
  } // <- Pastikan kurung kurawal penutup method ada

  Widget _buildStatCard({
    required String title,
    required String value,
    required double progress,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 5),
          )
        ],
      ),
      child: Column(
        // 1. Ubah alignment menjadi .stretch agar semua anak (termasuk Text)
        //    mengambil lebar penuh dari kartu.
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(5),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 8,
              backgroundColor: color.withOpacity(0.2),
              valueColor: AlwaysStoppedAnimation<Color>(color),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            title,
            // 2. Tambahkan textAlign: TextAlign.center agar teks rata tengah
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 14, color: Colors.grey),
          ),
          Text(
            value,
            // 2. Tambahkan textAlign: TextAlign.center di sini juga
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Widget _buildNotes() {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Catatan:',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          _buildBulletPoint(
              'Skor yang tampil adalah hasil terbaikmu sejauh ini.'),
          _buildBulletPoint('Skor tertinggi akan tercatat di leaderboard.'),
          _buildBulletPoint(
              'Terus asah kemampuanmu dan coba lagi untuk hasil yang lebih tinggi!'),
        ],
      ),
    );
  }

  Widget _buildBulletPoint(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4.0),
      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Padding(
          padding: const EdgeInsets.only(top: 6.0, right: 8.0),
          child: Text('•', style: TextStyle(color: Colors.grey.shade700)),
        ),
        Expanded(
            child: Text(text, style: TextStyle(color: Colors.grey.shade700))),
      ]),
    );
  }

  Widget _buildBottomButtons(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        children: [
          Expanded(
            child: ElevatedButton(
              onPressed: () =>
                  Navigator.of(context).popUntil((route) => route.isFirst),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30)),
              ),
              child: const Text('Kembali ke Beranda'),
            ),
          ),
          const SizedBox(width: 16),
          IconButton(
            onPressed: _onSharePressed, // <-- Panggil fungsi share
            icon: const Icon(Icons.share, color: Colors.blue),
            style: IconButton.styleFrom(
              side: BorderSide(color: Colors.grey.shade300),
            ),
          ),
        ],
      ),
    );
  }
}

class _ShareableScoreCard extends StatelessWidget {
  final int score;
  final int correctAnswers;
  final int totalQuestions;
  final String userName; // Kita butuh nama user

  const _ShareableScoreCard({
    required this.score,
    required this.correctAnswers,
    required this.totalQuestions,
    required this.userName,
  });

  @override
  Widget build(BuildContext context) {
    // Desain kartu ini sesuai keinginan Anda
    // Ini adalah contoh sederhana:
    return Container(
      width: 400, // Lebar gambar
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.blue.shade700, AppColors.himfoBlue],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.white, width: 2),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Header
          Row(
            children: [
              Image.asset('src/features/login&register/images/himtika.png',
                  height: 40),
              const SizedBox(width: 10),
              const Text('HiCode Exam Result',
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold)),
            ],
          ),
          const Divider(color: Colors.white54, height: 24),

          // Nama User
          Text('@$userName',
              style: const TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.bold),
              textAlign: TextAlign.center),
          const Text('Telah Menyelesaikan Ujian Akhir!',
              style: TextStyle(color: Colors.white70, fontSize: 14)),
          const SizedBox(height: 20),

          // Skor
          Text('$score',
              style: const TextStyle(
                  color: Colors.white,
                  fontSize: 72,
                  fontWeight: FontWeight.bold)),
          const Text('POIN',
              style: TextStyle(color: Colors.white, fontSize: 18)),
          const SizedBox(height: 20),

          // Detail
          Text(
            'Jawaban Benar: $correctAnswers / $totalQuestions',
            style: const TextStyle(color: Colors.white, fontSize: 16),
          ),
        ],
      ),
    );
  }
}
