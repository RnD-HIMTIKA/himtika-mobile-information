import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:himtika_mobile_information/features/AdminPanel/admin_roles/presentation/pages/roles_page.dart';
import 'package:himtika_mobile_information/features/AdminPanel/admin_roles/presentation/bloc/admin_roles_bloc.dart';
import 'package:himtika_mobile_information/features/AdminPanel/admin_roles/application/admin_roles_controller.dart';
import 'package:himtika_mobile_information/features/AdminPanel/admin_roles/data/repositories/admin_roles_repository_impl.dart';
import 'package:himtika_mobile_information/features/AdminPanel/admin_roles/domain/usecases/get_all_users_with_roles.dart';
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
                        MaterialPageRoute(
                          builder: (_) {
                            final supabase = Supabase.instance.client; // ✅ ambil SupabaseClient
                            final repository = AdminRolesRepositoryImpl(supabase);
                            final getAllUsers = GetAllUsersWithRoles(repository);
                            final controller = AdminRolesController(getAllUsersWithRoles: getAllUsers);

                            return BlocProvider(
                              create: (_) => AdminRolesBloc(controller),
                              child: const RolesPage(),
                            );
                          },
                        ),
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
