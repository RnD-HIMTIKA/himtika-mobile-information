import 'package:flutter/material.dart';
import '../../../../core/shared_widgets/custom_app_bar.dart';
import '../../data/models/lecturer_model.dart';

// Import Widget
import '../widgets/detail/detail_header.dart';
import '../widgets/detail/contact_card.dart';

class LecturerDetailPage extends StatelessWidget {
  final Lecturer lecturer;

  const LecturerDetailPage({super.key, required this.lecturer});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: const CustomAppBar(
        title: "HiLecturer",
        showBackButton: true,
      ),
      body: Stack(
        children: [
          // 1. PATTERN BACKGROUND
          Positioned.fill(
            child: Opacity(
              opacity: 1.0,
              child: Image.asset(
                'src/features/hilecturer/pattern_bg.png',
                width: double.infinity,
                height: double.infinity,
                repeat: ImageRepeat.repeat,
                fit: BoxFit.contain,
              ),
            ),
          ),

          // 2. KONTEN UTAMA
          SingleChildScrollView(
            child: Column(
              children: [
                // --- HEADER SECTION ---
                DetailHeader(photoUrl: lecturer.photoUrl),

                const SizedBox(height: 10),

                // --- INFO NAMA ---
                Text(
                  lecturer.name,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  lecturer.role,
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.grey, fontSize: 14),
                ),

                const SizedBox(height: 30),

                // --- JUDUL KONTAK ---
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 24),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      "Informasi Kontak",
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                // --- CONTACT CARD ---
                ContactCard(lecturer: lecturer),

                const SizedBox(height: 110), 
              ],
            ),
          ),
        ],
      ),
    );
  }
}
