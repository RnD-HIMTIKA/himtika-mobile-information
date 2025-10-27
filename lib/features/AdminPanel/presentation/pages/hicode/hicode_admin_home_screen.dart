import 'package:flutter/material.dart';
import 'package:himtika_mobile_information/features/AdminPanel/presentation/pages/sidebar.dart';
import 'category_management_screen.dart';
import 'material_management_screen.dart';
// import 'question_bank_screen.dart'; // Masih di-comment karena belum siap

// Definisikan warna tema HIMFO
const Color himfoBlue = Color(0xFF0175C8);
const Color himfoLightBlue = Color(0xFF32B7FF);
const Color himfoDarkBlue = Color(0xFF0D8EDB);
const Color himfoAccent = Color(0xFF81EAFF); // Warna aksen cerah

class HicodeAdminHomeScreen extends StatelessWidget {
  const HicodeAdminHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const Sidebar(),
      appBar: AppBar(
        title: const Text('Dashboard Manajemen HiCode'),
        backgroundColor: himfoBlue,
        foregroundColor: Colors.white,
        elevation: 0, // Hilangkan shadow AppBar
      ),
      backgroundColor: Colors.grey[100], // Background sedikit abu-abu
      body: SafeArea( // Pastikan konten tidak tertutup notch/statusbar
        child: ListView( // Ganti GridView ke ListView
          padding: const EdgeInsets.fromLTRB(20.0, 20.0, 20.0, 80.0), // Beri padding bawah
          children: [
            _buildSectionHeader("Pengelolaan Konten"),
            const SizedBox(height: 16),
            _buildMenuCard(
              context: context,
              icon: Icons.category_outlined,
              title: 'Kelola Kategori',
              subtitle: 'Atur pengelompokan materi (HTML, CSS, dll).',
              gradientColors: [himfoLightBlue, himfoBlue],
              onTap: () {
                Navigator.push(context, MaterialPageRoute(builder: (_) => const CategoryManagementScreen()));
              },
            ),
            const SizedBox(height: 16),
             _buildMenuCard(
              context: context,
              icon: Icons.article_outlined,
              title: 'Kelola Materi & Chapter',
              subtitle: 'Buat/edit materi dan susun chapter di dalamnya.',
               gradientColors: [const Color(0xFFFFA07A), const Color(0xFFFF7F50)], // Oranye
              onTap: () {
                // Navigasi ke Material Management (yang nanti bisa lanjut ke Chapter)
                Navigator.push(context, MaterialPageRoute(builder: (_) => const MaterialManagementScreen()));
              },
            ),
            const SizedBox(height: 16),
            _buildMenuCard(
              context: context,
              icon: Icons.quiz_outlined,
              title: 'Bank Soal',
              subtitle: 'Kelola semua soal untuk kuis chapter, latihan final, dan ujian akhir.',
              gradientColors: [const Color(0xFF9370DB), const Color(0xFF8A2BE2)], // Ungu
              onTap: () {
                // Navigator.push(context, MaterialPageRoute(builder: (_) => const QuestionBankScreen()));
                 ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Fitur Bank Soal segera hadir!')),
                );
              },
            ),
             const SizedBox(height: 24), // Jarak antar section
             _buildSectionHeader("Analitik & Pengguna"),
             const SizedBox(height: 16),
            _buildMenuCard(
              context: context,
              icon: Icons.leaderboard_outlined,
              title: 'Leaderboard & Progress',
              subtitle: 'Pantau progres belajar dan peringkat pengguna.',
               gradientColors: [const Color(0xFF3CB371), const Color(0xFF2E8B57)], // Hijau
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Fitur Leaderboard & Progress segera hadir!')),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  // Widget header untuk setiap section
  Widget _buildSectionHeader(String title) {
     return Padding(
       padding: const EdgeInsets.only(bottom: 0, top: 8, left: 4), // Atur padding
       child: Text(
         title,
         style: TextStyle(
           fontSize: 18,
           fontWeight: FontWeight.bold,
           color: Colors.grey[700], // Warna lebih gelap
         ),
       ),
     );
  }

  // Widget kartu menu yang didesain ulang
  Widget _buildMenuCard({
    required BuildContext context,
    required IconData icon,
    required String title,
    required String subtitle,
    required List<Color> gradientColors, // Gunakan gradient
    required VoidCallback onTap,
  }) {
    return Container(
      decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: gradientColors,
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: gradientColors.last.withOpacity(0.3),
              blurRadius: 10,
              offset: const Offset(0, 5), // Shadow lebih halus
            )
          ]),
      child: Material( // Bungkus dengan Material agar InkWell bekerja
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          splashColor: Colors.white.withOpacity(0.2), // Efek splash
          highlightColor: Colors.white.withOpacity(0.1), // Efek highlight
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 24.0), // Padding konsisten
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center, // Pusatkan ikon & teks vertikal
              children: [
                Icon(icon, size: 36, color: Colors.white), // Ikon sedikit lebih besar, putih solid
                const SizedBox(width: 16),
                Expanded( // Agar teks mengambil sisa ruang
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 17,
                          color: Colors.white,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 6),
                      Text(
                        subtitle,
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.white.withOpacity(0.9), // Kontras subtitle ditingkatkan
                        ),
                        maxLines: 2, // Batasi 2 baris
                        overflow: TextOverflow.ellipsis, // Tampilkan '...'
                      ),
                    ],
                  ),
                ),
                // Tambahkan ikon panah kecil di kanan
                Icon(Icons.arrow_forward_ios, color: Colors.white.withOpacity(0.7), size: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }
}