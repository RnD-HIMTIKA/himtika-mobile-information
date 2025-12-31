import 'package:flutter/material.dart';
import 'filter_chip.dart'; 

class LecturerFilterSection extends StatelessWidget {
  final String selectedCategory;
  final Function(String) onCategorySelected;

  const LecturerFilterSection({
    super.key,
    required this.selectedCategory, // Wajib diisi parent
    required this.onCategorySelected, // Wajib diisi parent
  });

  @override
  Widget build(BuildContext context) {
    // List kategori hardcode dulu gapapa
    final categories = ["Semua", "Informatika", "Sistem Informasi"];

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Row(
        children: categories.map((category) {
          // Label logic: Kalau "Semua" tetap "Semua Dosen", kalau lain tambah "Dosen..."
          final label = category == "Semua" ? "Semua Dosen" : "Dosen $category";

          return LecturerFilterChip(
            label: label,
            // 2. Logic Aktif: Warnanya biru kalau kategori ini sama dengan yang dipilih
            isActive: selectedCategory == category,
            // 3. Logic Klik: Lapor ke Parent kalau diklik
            onTap: () => onCategorySelected(category),
          );
        }).toList(),
      ),
    );
  }
}
