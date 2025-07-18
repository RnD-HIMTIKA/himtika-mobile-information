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
        String userName = '';
        String userRole = '';

        if (state is AdminPanelLoaded) {
          userName = state.userName;
          userRole = state.userRole;
        }

        return Scaffold(
          backgroundColor: const Color(0xFF0175C8),
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
          body: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const CircleAvatar(
                    radius: 60,
                    backgroundColor: Colors.white,
                    child:
                        Icon(Icons.person, size: 64, color: Colors.black45),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'Halo, $userName!',
                    style: const TextStyle(
                      fontSize: 24,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  RichText(
                    textAlign: TextAlign.center,
                    text: TextSpan(
                      style:
                          const TextStyle(color: Colors.white, fontSize: 14),
                      children: [
                        const TextSpan(text: 'Selamat datang di '),
                        const TextSpan(
                          text: 'Dashboard Admin',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        const TextSpan(
                            text: ', saat ini anda memiliki roles '),
                        TextSpan(
                          text: '$userRole!',
                          style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.white),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
