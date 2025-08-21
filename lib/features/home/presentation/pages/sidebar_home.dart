import 'package:flutter/material.dart';
import 'package:himtika_mobile_information/features/AdminPanel/presentation/pages/dashboard.dart';

import 'package:himtika_mobile_information/core/injection_container.dart'; // Import sl
import 'package:himtika_mobile_information/features/auth/application/auth_controller.dart'; // Import AuthController

class SidebarHome extends StatelessWidget {
  const SidebarHome({super.key});

  @override
  Widget build(BuildContext context) {
    final authController = sl<AuthController>();

    return Theme(
      data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
      child: Drawer(
        child: Stack(
          children: [
            Container(
              padding: const EdgeInsets.only(top: 54),
              color: const Color(0xFF1e1e1e),
              child: ListView(
                padding: EdgeInsets.zero,
                children: [
                  // Logo dan Judul
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 40, 16, 16),
                    child: Row(
                      children: [
                        const Icon(Icons.face, color: Colors.white, size: 32),
                        const SizedBox(width: 12),
                        RichText(
                          text: const TextSpan(
                            children: [
                              TextSpan(
                                text: 'HIM',
                                style: TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.blueAccent,
                                ),
                              ),
                              TextSpan(
                                text: 'FO.',
                                style: TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Menu
                  ListTile(
                    leading: const Icon(Icons.person, color: Colors.white),
                    title: const Text('Profil', style: TextStyle(color: Colors.white)),
                    onTap: () {},
                  ),
                  ListTile(
                    leading: const Icon(Icons.people, color: Colors.white),
                    title: const Text('Admin', style: TextStyle(color: Colors.white)),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const Dashboard()),
                      );
                    },
                  ),

                  const Divider(color: Colors.white30), // Pemisah

                  // TAMBAHKAN TOMBOL SIGN OUT DI SINI
                  ListTile(
                    leading: const Icon(Icons.logout, color: Colors.redAccent),
                    title: const Text('Sign Out', style: TextStyle(color: Colors.redAccent)),
                    onTap: () {
                      // Tutup sidebar dulu
                      Navigator.pop(context); 
                      // Panggil fungsi signOut
                      authController.signOut();
                    },
                  ),
                ],
              ),
            ),

            // Tombol Close di Pojok Kanan Atas 
            Positioned(
              top: 16,
              left: 8,
              child: IconButton(
                icon: const Icon(Icons.close, color: Colors.white),
                onPressed: () {
                  Navigator.pop(context);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
