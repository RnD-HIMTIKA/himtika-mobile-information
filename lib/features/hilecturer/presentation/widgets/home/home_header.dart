// features/hilecturer/presentation/widgets/hilecturer_header.dart
import 'package:flutter/material.dart';

class HomeHeader extends StatelessWidget {
  const HomeHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      // HAPUS margin bottom
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 20), // Padding sesuaikan
      width: double.infinity,
      decoration: const BoxDecoration(
        color: Colors.blue, // Warna Biru
      ),
      child: Column(
        children: [
          const Text(
            "Kenalan sama Dosen Fasilkom yuk!",
            textAlign: TextAlign.center,
            style: TextStyle(
                color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 20),
          Image.asset(
            'src/features/hilecturer/icons/header.png', // Sesuaikan path
            height: 250,
          ),
          const SizedBox(height: 5),
        ],
      ),
    );
  }
}
