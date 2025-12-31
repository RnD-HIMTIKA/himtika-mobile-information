import 'package:flutter/material.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String? title;
  final bool showBackButton;
  final bool showNotification;
  final VoidCallback? onNotificationTap;

  const CustomAppBar({
    super.key,
    this.title,
    this.showBackButton = true, 
    this.showNotification = true, 
    this.onNotificationTap,
  });

@override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.blue, // Warna background
      // Kita pakai SafeArea biar otomatis turun dari Poni HP (Notch)
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
          child: Stack(
            alignment: Alignment.center,
            children: [
              // 1. JUDUL (Di Tengah Absolute)
              if (title != null)
                Text(
                  title!,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                ),

              // 2. TOMBOL KIRI & KANAN (Row)
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // --- KIRI: Back Button ---
                  if (showBackButton)
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      // Saran: Pindahkan aset ini ke folder assets/icons umum
                      icon: Image.asset('src/icons/kembali.png',
                          width: 32, height: 32, color: Colors.white),
                    )
                  else
                    const SizedBox(width: 48),

                  // --- KANAN: Notification ---
                  if (showNotification)
                    IconButton(
                      onPressed: onNotificationTap, // Panggil fungsi yg dikirim
                      icon: const Icon(Icons.notifications_outlined,
                          color: Colors.white, size: 28),
                    )
                  else
                    const SizedBox(width: 48), // Spacer penyeimbang
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Ini WAJIB kalau mau dipasang di property appBar: Scaffold
  @override
  Size get preferredSize => const Size.fromHeight(80); // Tinggi custom bar kamu
}
