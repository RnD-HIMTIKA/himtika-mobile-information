import 'package:flutter/material.dart';
import '../../../data/models/lecturer_model.dart'; 

import 'lecturer_card.dart';
import '../../pages/lecturer_detail_page.dart';

class ListSection extends StatelessWidget {
  // 1. Variabel Penerima Data (INPUT)
  final List<Lecturer> lecturers;

  const ListSection({
    super.key,
    required this.lecturers, // Wajib diisi parent
  });

  @override
  Widget build(BuildContext context) {
    // Cek kalau data kosong, tampilkan teks "Data Kosong" (Optional tapi bagus)
    if (lecturers.isEmpty) {
      return const Center(child: Padding(
        padding: EdgeInsets.all(20.0),
        child: Text("Tidak ada dosen di kategori ini"),
      ));
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: lecturers.length, // Pakai panjang list data asli
      itemBuilder: (context, index) {
        final lecturer = lecturers[index]; // Ambil data per item

        return LecturerCard(
          name: lecturer.name,
          role: lecturer.role,
          onTap: () {
            // NAVIGASI KE DETAIL PAGE
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) =>
                    LecturerDetailPage(lecturer: lecturer), // Kirim data dosen
              ),
            );
          },
        );
      },
    );
  }
}