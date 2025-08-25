import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:himtika_mobile_information/features/hicode/presentation/pages/leaderboard_screen.dart';
import 'dart:async';

class ScoreScreen extends StatefulWidget {
  final int score;
  final int totalQuestions;
  final Duration timeTaken;

  const ScoreScreen({
    super.key,
    required this.score,
    required this.totalQuestions,
    required this.timeTaken,
  });

  @override
  State<ScoreScreen> createState() => _ScoreScreenState();
}

class _ScoreScreenState extends State<ScoreScreen> {
  bool _isLoading = true;

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
    final int finalScore = widget.totalQuestions > 0
        ? (widget.score * 550) ~/ widget.totalQuestions
        : 0;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: SingleChildScrollView(
        child: Column(
          children: [
            _buildScoreHeader(context, finalScore),
            _buildScoreDetails(
              correct: widget.score,
              wrong: wrongAnswers,
              total: widget.totalQuestions,
            ),
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
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
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
                      MaterialPageRoute(builder: (_) => const LeaderboardScreen()),
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

  Widget _buildScoreDetails(
    {required int correct, required int wrong, required int total}) {
    // Gunakan Column untuk menyusun Row kartu dan kartu Waktu Pengerjaan
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 0), // Atur padding
      child: Column(
        children: [
          // Baris pertama berisi Jawaban Benar dan Jawaban Salah
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  title: 'Jawaban Benar',
                  value: '$correct',
                  progress: total > 0 ? correct / total : 0,
                  color: Colors.green,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildStatCard(
                  title: 'Jawaban Salah',
                  value: '$wrong',
                  progress: total > 0 ? wrong / total : 0,
                  color: Colors.red,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Baris kedua hanya berisi kartu Waktu Pengerjaan
          _buildStatCard(
            title: 'Waktu Pengerjaan',
            value: _formatDuration(widget.timeTaken),
            color: Colors.orange,
            progress: 1.0,
          ),
        ],
      ),
    );
  }

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
            style:
                const TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
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
        Expanded(child: Text(text, style: TextStyle(color: Colors.grey.shade700))),
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
              onPressed: () => Navigator.of(context).popUntil((route) => route.isFirst),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
              ),
              child: const Text('Kembali ke Beranda'),
            ),
          ),
          const SizedBox(width: 16),
          IconButton(
            onPressed: () {},
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