import 'package:flutter/material.dart';

class DetailHeader extends StatelessWidget {
  final String photoUrl; // Kita butuh url fotonya

  const DetailHeader({super.key, required this.photoUrl});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 190, // Tinggi total area header
      child: Stack(
        alignment: Alignment.topCenter,
        children: [
          // A. LENGKUNGAN BIRU
          Container(
            height: 130,
            decoration: const BoxDecoration(
              color: Colors.blue,
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(40),
                bottomRight: Radius.circular(40),
              ),
            ),
          ),

          // B. FOTO PROFIL
          Positioned(
            bottom: 0,
            child: Container(
              padding: const EdgeInsets.all(4), // Border Putih
              decoration: const BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
              ),
              child: CircleAvatar(
                radius: 60,
                backgroundColor: Colors.grey.shade200,
                // Pastikan path asset benar atau pakai NetworkImage kalau dari API
                backgroundImage: const AssetImage(
                    'src/features/hilecturer/icons/header.png'),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
