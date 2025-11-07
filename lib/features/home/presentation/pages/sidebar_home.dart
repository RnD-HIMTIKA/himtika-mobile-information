import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:himtika_mobile_information/features/AdminPanel/presentation/pages/dashboard.dart';
import 'package:himtika_mobile_information/core/injection_container.dart';
import 'package:himtika_mobile_information/features/auth/application/auth_controller.dart';
import 'package:himtika_mobile_information/features/home/presentation/bloc/home_bloc.dart';
import 'package:himtika_mobile_information/features/home/presentation/bloc/home_state.dart';

class SidebarHome extends StatelessWidget {
  const SidebarHome({super.key});

  @override
  Widget build(BuildContext context) {
    final authController = sl<AuthController>();

    return BlocBuilder<HomeBloc, HomeState>(
      builder: (context, state) {
        return Theme(
          data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
          child: Drawer(
            child: Stack(
              children: [
                Container(
                  padding: const EdgeInsets.only(top: 60),
                  color: const Color.fromARGB(255, 255, 255, 255),
                  child: ListView(
                    children: [
                      // Menu
                      ListTile(
                        leading: const Icon(Icons.person, color: Colors.black),
                        title: const Text('Profil',
                            style: TextStyle(color: Colors.black)),
                        onTap: () {},
                      ),
                      // Tombol Admin Kondisional
                      if (state.isPengurus)
                        ListTile(
                          leading: Stack(
                            clipBehavior: Clip.none,
                            children: [
                              const Icon(Icons.person,
                                  color: Colors.black, size: 28),
                              const Positioned(
                                right: -2,
                                bottom: -2,
                                child: Icon(Icons.lock,
                                    color: Colors.black54, size: 14),
                              ),
                            ],
                          ),
                          title: const Text(
                            'Admin',
                            style: TextStyle(color: Colors.black),
                          ),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => const Dashboard()),
                            );
                          },
                        ),

                      ListTile(
                        leading:
                            const Icon(Icons.logout, color: Colors.redAccent),
                        title: const Text('Sign Out',
                            style: TextStyle(color: Colors.redAccent)),
                        onTap: () {
                          Navigator.pop(context);
                          authController.signOut();
                        },
                      ),
                    ],
                  ),
                ),

                // Tombol Close
                Positioned(
                  top: 26,
                  left: 8,
                  child: IconButton(
                    icon: const Icon(Icons.close, color: Colors.black),
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
