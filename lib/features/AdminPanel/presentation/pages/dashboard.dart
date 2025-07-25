import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/adminpanel_bloc.dart';
import '../bloc/adminpanel_event.dart';
import '../bloc/adminpanel_state.dart';
import 'sidebar.dart';

class Dashboard extends StatefulWidget {
  const Dashboard({super.key});

  @override
  State<Dashboard> createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  @override
  void initState() {
    super.initState();
    context.read<AdminPanelBloc>().add(LoadAdminPanel());
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AdminPanelBloc, AdminPanelState>(
      builder: (context, state) {
        String userName = 'Pengguna';
        String userRole = 'Admin';

        if (state is AdminPanelLoaded) {
          userName = state.userName;
          userRole = state.userRole;
        }

        return Scaffold(
          drawer: const Sidebar(),
          appBar: AppBar(
            backgroundColor: const Color(0xFF0175C8),
            foregroundColor: Colors.white,
            centerTitle: true,
            title: const Text('Dashboard'),
            actions: const [
              Padding(
                padding: EdgeInsets.only(right: 16),
                child: Icon(Icons.account_circle, size: 32),
              ),
            ],
          ),
          body: SingleChildScrollView(
            child: Stack(
              alignment: Alignment.topCenter,
              children: [
                // Background biru atas
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

                // Bagian konten putih
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
                          'Halo, $userName!',
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
                                text: '$userRole!',
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
                        const SizedBox(height: 64),
                      ],
                    ),
                  ),
                ),

                // Avatar tepat di garis biru-putih
                Positioned(
                  top: 145, // setengah di biru, setengah di putih
                  child: Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.grey.shade300,
                      boxShadow: const [
                        BoxShadow(
                          color: Colors.black26,
                          blurRadius: 6,
                          offset: Offset(0, 3),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.account_circle_outlined,
                      size: 80,
                      color: Colors.black54,
                    ),
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
