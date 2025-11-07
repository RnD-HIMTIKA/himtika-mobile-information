import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:himtika_mobile_information/core/injection_container.dart';
import 'package:himtika_mobile_information/features/AdminPanel/presentation/bloc/adminpanel_bloc.dart';
import 'package:himtika_mobile_information/features/AdminPanel/presentation/bloc/adminpanel_state.dart';
import 'package:himtika_mobile_information/features/AdminPanel/presentation/pages/dashboard.dart';
import 'package:himtika_mobile_information/features/AdminPanel/presentation/pages/kontakdosen.dart';
import 'package:himtika_mobile_information/features/AdminPanel/presentation/pages/roles.dart';
import 'package:himtika_mobile_information/features/auth/application/auth_controller.dart';
import 'package:himtika_mobile_information/features/home/presentation/pages/home.dart';
import 'package:himtika_mobile_information/features/AdminPanel/presentation/pages/hicode/hicode_admin_home_screen.dart';

class Sidebar extends StatelessWidget {
  const Sidebar({super.key});

  @override
  Widget build(BuildContext context) {
    final authController = sl<AuthController>();

    // Gunakan BlocBuilder untuk merebuild UI saat state berubah
    return BlocBuilder<AdminPanelBloc, AdminPanelState>(
      builder: (context, state) {
        // Default ke daftar kosong jika state belum loaded
        final roles = state is AdminPanelLoaded ? state.currentUserRoles : [];

        // Definisikan hak akses
        final canAccessDashboard = roles.any((r) => r.groupName == 'Pengurus');
        final canAccessRoles = roles.any((r) =>
            ['Ketua Himpunan', 'Wakil Ketua Himpunan', 'RnD'].contains(r.name));
        final canAccessKontakDosen = canAccessRoles;
        final canAccessHiCode = roles.any((r) =>
            ['Ketua Himpunan', 'Wakil Ketua Himpunan', 'Edukasi', 'RnD']
                .contains(r.name));

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
                            const Icon(Icons.face,
                                color: Colors.white, size: 32),
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

                      // Menu dinamis
                      if (canAccessDashboard)
                        ListTile(
                          leading: const Icon(Icons.dashboard,
                              color: Colors.white),
                          title: const Text('Dashboard',
                              style: TextStyle(color: Colors.white)),
                          onTap: () {
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => const Dashboard()),
                            );
                          },
                        ),
                      if (canAccessRoles)
                        ListTile(
                          leading:
                              const Icon(Icons.people, color: Colors.white),
                          title: const Text('Roles',
                              style: TextStyle(color: Colors.white)),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => const RolesPage()),
                            );
                          },
                        ),
                      if (canAccessKontakDosen)
                        ListTile(
                          leading: const Icon(Icons.contacts,
                              color: Colors.white),
                          title: const Text('Kontak Dosen',
                              style: TextStyle(color: Colors.white)),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => const Kontakdosen()),
                            );
                          },
                        ),
                      if (canAccessHiCode)
                        ListTile(
                          leading:
                              const Icon(Icons.code, color: Colors.white), // Ganti ikon agar lebih relevan
                          title: const Text('Manajemen HiCode', // Ganti teks
                              style: TextStyle(color: Colors.white)),
                          onTap: () {
                            // PERUBAHAN DI SINI: Arahkan ke Halaman Dashboard HiCode
                            Navigator.pushReplacement( // Gunakan pushReplacement jika ini level menu utama
                              context,
                              MaterialPageRoute(
                                  builder: (context) => const HicodeAdminHomeScreen()),
                            );
                          },
                        ),

                      const Divider(color: Colors.white30),

                      ListTile(
                        leading: const Icon(Icons.logout, color: Colors.redAccent),
                        title: const Text('Sign Out', style: TextStyle(color: Colors.redAccent)),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => const HomePage()),
                          );
                        },
                      ),
                    ],
                  ),
                ),
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
      },
    );
  }
}