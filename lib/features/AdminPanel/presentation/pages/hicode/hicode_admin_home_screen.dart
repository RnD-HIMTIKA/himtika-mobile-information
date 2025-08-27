import 'package:flutter/material.dart';
import 'package:himtika_mobile_information/features/AdminPanel/presentation/pages/sidebar.dart';
import 'category_management_screen.dart'; 
import 'material_management_screen.dart';
// import 'question_bank_screen.dart';

class HicodeAdminHomeScreen extends StatelessWidget {
  const HicodeAdminHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const Sidebar(),
      appBar: AppBar(
        title: const Text('Dashboard Manajemen HiCode'),
        backgroundColor: const Color(0xFF0175C8),
        foregroundColor: Colors.white,
      ),
      backgroundColor: Colors.grey[200],
      body: SingleChildScrollView( // <-- TAMBAHKAN WIDGET INI
        child: GridView.count(
          shrinkWrap: true, // <-- PENTING: Tambahkan ini agar GridView tidak mengambil tinggi tak terbatas
          physics: const NeverScrollableScrollPhysics(), // <-- PENTING: Matikan scroll internal GridView
          padding: const EdgeInsets.all(16.0),
          crossAxisCount: 2,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          childAspectRatio: 1.2,
          children: [
          _buildMenuCard(
            context: context,
            icon: Icons.category,
            title: 'Kelola Kategori',
            subtitle: 'Atur kategori materi (HTML, CSS, dll)',
            onTap: () {
              Navigator.push(context, MaterialPageRoute(builder: (_) => const CategoryManagementScreen()));
            },
          ),
          _buildMenuCard(
            context: context,
            icon: Icons.article,
            title: 'Kelola Materi',
            subtitle: 'Atur materi dan chapter di setiap kategori',
            onTap: () {
              Navigator.push(context, MaterialPageRoute(builder: (_) => const MaterialManagementScreen()));
            },
          ),
          _buildMenuCard(
            context: context,
            icon: Icons.question_answer,
            title: 'Bank Soal',
            subtitle: 'Kelola semua soal untuk kuis dan ujian',
            onTap: () {
              // Navigator.push(context, MaterialPageRoute(builder: (_) => const QuestionBankScreen()));
            },
          ),
          _buildMenuCard(
            context: context,
            icon: Icons.leaderboard,
            title: 'Leaderboard & Progress',
            subtitle: 'Lihat progres dan peringkat pengguna',
            onTap: () {
              // Halaman ini bisa dibuat di masa depan
            },
          ),
        ],
      ),
    )
  );
}

  Widget _buildMenuCard({
    required BuildContext context,
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(icon, size: 40, color: Theme.of(context).primaryColor),
              const SizedBox(height: 12),
              Text(
                title,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}