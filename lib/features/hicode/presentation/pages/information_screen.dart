import 'package:flutter/material.dart';

class InformationScreen extends StatelessWidget {
  const InformationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // --- BAGIAN ATAS (TOP BAR) ---
            _buildTopBar(context),

            // --- KONTEN UTAMA (BISA DI-SCROLL) ---
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildSectionTitle('Selamat Datang di HiCode'),
                    _buildParagraph(
                        'HiCode adalah platform pembelajaran interaktif yang dirancang untuk membantumu memahami dasar-dasar pemrograman secara bertahap dan sistematis.'),
                    const SizedBox(height: 24),
                    _buildSectionTitle('Tentang HiCode'),
                    _buildParagraph(
                        'HiCode menyediakan materi pemrograman dasar yang terbagi ke dalam empat topik utama:'),
                    _buildBulletPoint('HTML'),
                    _buildBulletPoint('CSS'),
                    _buildBulletPoint('JavaScript'),
                    _buildBulletPoint('C++'),
                    _buildParagraph(
                        'Setiap topik terdiri dari beberapa bab yang disusun berurutan. Kamu harus menyelesaikan materi dan kuis pada satu bab sebelum dapat membuka bab berikutnya.'),
                    const SizedBox(height: 24),
                    _buildSectionTitle('Sistem Level dan Penguncian'),
                    _buildBulletPoint(
                        'Setiap bab akan terbuka setelah kamu membaca materi sebelumnya dan menyelesaikan kuisnya.'),
                    _buildBulletPoint(
                        'Setelah seluruh bab dalam satu topik selesai, kamu akan mendapatkan akses ke Latihan Soal Final.'),
                    _buildBulletPoint(
                        'Jika semua topik telah diselesaikan, kamu dapat mengikuti Ujian Akhir HiCode.'),
                    const SizedBox(height: 24),
                    _buildSectionTitle('Quiz dan Latihan'),
                    _buildBulletPoint(
                        'Setiap bab dilengkapi dengan kuis singkat (2 soal).'),
                    _buildBulletPoint(
                        'Setelah semua kuis dalam satu topik selesai, kamu dapat mengerjakan Latihan Soal Final (5–10 soal).'),
                    _buildBulletPoint(
                        'Ujian Akhir terdiri dari 20–40 soal yang mencakup semua topik.'),
                    const SizedBox(height: 24),
                    _buildSectionTitle('Penilaian dan Leaderboard'),
                    _buildBulletPoint(
                        'Skor ujian didasarkan pada tingkat kesulitan soal dan kecepatan menjawab.'),
                    _buildBulletPoint(
                        'Leaderboard akan menampilkan peserta dengan skor tertinggi.'),
                    _buildBulletPoint(
                        'Hanya skor tertinggi yang dicatat jika kamu mengulang ujian.'),
                    const SizedBox(height: 24),
                    _buildSectionTitle('Penilaian dan Leaderboard'),
                    _buildParagraph(
                        'Perkembanganmu akan tercatat secara otomatis. Kamu bisa melihat sejauh mana progres yang telah dicapai dan materi mana yang sudah diselesaikan.'),
                    _buildParagraph(
                        'Mulailah dari topik pertama dan ikuti alurnya hingga tuntas. HiCode akan membimbingmu langkah demi langkah untuk menjadi lebih mahir dalam pemrograman.'),

                    const SizedBox(height: 80), // Beri ruang ekstra di bawah
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      // --- TOMBOL MELAYANG DI BAWAH ---
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ElevatedButton(
          onPressed: () => Navigator.pop(context),
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 16),
            backgroundColor: Colors.blue,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(30),
            ),
          ),
          child: const Text('Saya Mengerti'),
        ),
      ),
    );
  }

  // --- WIDGET-WIDGET PEMBANTU ---

  // Widget untuk Top Bar
  Widget _buildTopBar(BuildContext context) {
    return Container(
      color: const Color(0xFFDBF7FF), // 2. Tambahkan warna background Anda
      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
      child: Row(
        children: [
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: Image.asset(
              'src/features/hicode/icon/kembali.png', // Sesuaikan path ikon Anda
              width: 32,
              height: 32,
            ),
          ),
          Expanded(
            child: Text(
              'HiCode Information',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: const Color(0xFF006EBD), // 3. Tambahkan warna teks judul Anda
              ),
            ),
          ),
          // Widget kosong untuk menyeimbangkan Row
          const SizedBox(width: 48),
        ],
      ),
    );
  }

  // Widget untuk judul setiap section
  Widget _buildSectionTitle(String text) {
    return Text(
      text,
      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
    );
  }

  // Widget untuk paragraf biasa
  Widget _buildParagraph(String text) {
    return Padding(
      padding: const EdgeInsets.only(top: 8.0),
      child: Text(
        text,
        style: TextStyle(fontSize: 14, color: Colors.grey.shade700, height: 1.5),
      ),
    );
  }

  // Widget untuk item bullet point
  Widget _buildBulletPoint(String text) {
    return Padding(
      padding: const EdgeInsets.only(top: 8.0, left: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 6.0, right: 8.0),
            child: CircleAvatar(
              radius: 3,
              backgroundColor: Colors.grey.shade700,
            ),
          ),
          Expanded(
            child: Text(
              text,
              style: TextStyle(fontSize: 14, color: Colors.grey.shade700, height: 1.5),
            ),
          ),
        ],
      ),
    );
  }
}