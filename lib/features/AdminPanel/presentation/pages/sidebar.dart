import 'package:flutter/material.dart';
import 'roles.dart';
import 'dashboard.dart';
import 'hicode.dart';
import 'kontakdosen.dart';

class Sidebar extends StatelessWidget {
  const Sidebar({super.key});

  @override
  Widget build(BuildContext context) {
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
                    leading: const Icon(Icons.dashboard, color: Colors.white),
                    title: const Text('Dashboard', style: TextStyle(color: Colors.white)),
                    onTap: () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (context) => const Dashboard()),
                      );
                    },
                  ),
                  ListTile(
                    leading: const Icon(Icons.people, color: Colors.white),
                    title: const Text('Roles', style: TextStyle(color: Colors.white)),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const RolesPage()),
                      );
                    },
                  ),
                  ListTile(
                    leading: const Icon(Icons.contacts, color: Colors.white),
                    title: const Text('Kontak Dosen', style: TextStyle(color: Colors.white)),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const Kontakdosen()),
                      );
                    },
                  ),
                  ListTile(
                    leading: const Icon(Icons.book, color: Colors.white),
                    title: const Text('HiCode', style: TextStyle(color: Colors.white)),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const Hicode()),
                      );
                    },
                  ),
                ],
              ),
            ),

            // Tombol Close di Pojok Kanan Atas
            Positioned(
              top: 16,
              right: 8,
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
