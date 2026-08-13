import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/adminpanel_bloc.dart';
import '../bloc/adminpanel_event.dart';
import '../bloc/adminpanel_state.dart';
import 'sidebar.dart';
import 'himtika/himtika_admin_home_screen.dart';

class Dashboard extends StatefulWidget {
  const Dashboard({super.key});

  @override
  State<Dashboard> createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  @override
  void initState() {
    super.initState();
    // Memastikan data dimuat saat halaman pertama kali dibuka
    if (context.read<AdminPanelBloc>().state is! AdminPanelLoaded) {
      context.read<AdminPanelBloc>().add(LoadAdminPanel());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const Sidebar(),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0175C8),
        foregroundColor: Colors.white,
        centerTitle: true,
        title: const Text('Dashboard'),
        actions: [
          // Widget Profile Picture Dinamis
          BlocBuilder<AdminPanelBloc, AdminPanelState>(
            builder: (context, state) {
              String? profileUrl;
              if (state is AdminPanelLoaded) {
                profileUrl = state.dashboardInfo.profilePictureUrl;
              }
              return Padding(
                padding: const EdgeInsets.only(right: 16),
                child: CircleAvatar(
                  radius: 18,
                  backgroundColor: Colors.white,
                  backgroundImage:
                      profileUrl != null ? NetworkImage(profileUrl) : null,
                  child: profileUrl == null
                      ? const Icon(Icons.account_circle,
                          size: 32, color: Colors.grey)
                      : null,
                ),
              );
            },
          ),
        ],
      ),
      body: BlocBuilder<AdminPanelBloc, AdminPanelState>(
        builder: (context, state) {
          return _buildBody(state);
        },
      ),
    );
  }

  Widget _buildBody(AdminPanelState state) {
    if (state is AdminPanelLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (state is AdminPanelFailure) {
      return Center(child: Text('Gagal memuat data: ${state.message}'));
    }
    if (state is AdminPanelLoaded) {
      final info = state.dashboardInfo;
      final rolesText = info.pengurusRoles.join(', ');

      return SingleChildScrollView(
        child: Stack(
          alignment: Alignment.topCenter,
          children: [
            Container(
              height: 700,
              width: double.infinity,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF0D8EDB), Color(0xFF1791E4)],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
            ),
            Container(
              margin: const EdgeInsets.only(top: 190),
              width: double.infinity,
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(80),
                  topRight: Radius.circular(80),
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 80, 24, 32),
                child: Column(
                  children: [
                    Text(
                      'Halo, ${info.username}!',
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF0D8EDB),
                      ),
                    ),
                    const SizedBox(height: 8),
                    RichText(
                      textAlign: TextAlign.center,
                      text: TextSpan(
                        style: const TextStyle(
                          color: Colors.black87,
                          fontSize: 14,
                        ),
                        children: [
                          const TextSpan(text: 'Selamat datang di '),
                          const TextSpan(
                            text: 'Dashboard Admin',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          const TextSpan(text: ', saat ini anda memiliki roles '),
                          TextSpan(
                            text: '$rolesText!',
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 32),
                    Image.asset(
                      'src/features/AdminPanel/images/dashboard.png',
                      width: 200,
                    ),
                    const SizedBox(height: 32),
                    const Text(
                      'Pantau, kelola, dan kontrol sistem dengan efisien di satu tempat!',
                      style: TextStyle(fontSize: 16, color: Colors.black54),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton.icon(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const HimtikaAdminHomeScreen(),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF0D8EDB),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 12,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      icon: const Icon(Icons.account_balance),
                      label: const Text(
                        'Kelola Data HIMTIKA',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(height: 64),
                  ],
                ),
              ),
            ),
            Positioned(
              top: 145,
              child: CircleAvatar(
                radius: 50,
                backgroundColor: Colors.grey.shade300,
                backgroundImage: info.profilePictureUrl != null
                    ? NetworkImage(info.profilePictureUrl!)
                    : null,
                child: info.profilePictureUrl == null
                    ? Icon(
                        Icons.account_circle_outlined,
                        size: 80,
                        color: Colors.black54,
                      )
                    : null,
              ),
            ),
          ],
        ),
      );
    }
    return const SizedBox.shrink();
  }
}