import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:himtika_mobile_information/core/injection_container.dart';
import 'package:himtika_mobile_information/features/AdminPanel/presentation/pages/sidebar.dart';
import 'package:himtika_mobile_information/features/AdminPanel/presentation/bloc/himtika_management/himtika_management_bloc.dart';
import 'package:himtika_mobile_information/features/AdminPanel/presentation/bloc/himtika_management/himtika_management_event.dart';
import 'package:himtika_mobile_information/features/AdminPanel/presentation/bloc/himtika_management/himtika_management_state.dart';
import 'tabs/himtika_kabinet_about_tab.dart';
import 'tabs/himtika_divisi_tab.dart';
import 'tabs/himtika_pengurus_tab.dart';

class HimtikaAdminHomeScreen extends StatelessWidget {
  const HimtikaAdminHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<HimtikaManagementBloc>()..add(const FetchHimtikaAdminData()),
      child: const _HimtikaAdminHomeView(),
    );
  }
}

class _HimtikaAdminHomeView extends StatelessWidget {
  const _HimtikaAdminHomeView();

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        drawer: const Sidebar(),
        appBar: AppBar(
          backgroundColor: const Color(0xFF0175C8),
          foregroundColor: Colors.white,
          centerTitle: true,
          title: const Text(
            'Kelola HIMTIKA',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
          ),
          bottom: const TabBar(
            indicatorColor: Colors.white,
            indicatorWeight: 3,
            labelColor: Colors.white,
            unselectedLabelColor: Colors.white70,
            tabs: [
              Tab(
                icon: Icon(Icons.account_balance, size: 20),
                text: 'Kabinet & Profil',
              ),
              Tab(
                icon: Icon(Icons.diversity_3, size: 20),
                text: 'Kelola Divisi',
              ),
              Tab(
                icon: Icon(Icons.people_alt, size: 20),
                text: 'Kelola Pengurus',
              ),
            ],
          ),
        ),
        body: BlocListener<HimtikaManagementBloc, HimtikaManagementState>(
          listenWhen: (previous, current) =>
              previous.successMessage != current.successMessage ||
              previous.errorMessage != current.errorMessage,
          listener: (context, state) {
            if (state.successMessage != null && state.successMessage!.isNotEmpty) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.successMessage!),
                  backgroundColor: Colors.green,
                  behavior: SnackBarBehavior.floating,
                ),
              );
            }
            if (state.errorMessage != null && state.errorMessage!.isNotEmpty) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.errorMessage!),
                  backgroundColor: Colors.redAccent,
                  behavior: SnackBarBehavior.floating,
                ),
              );
            }
          },
          child: BlocBuilder<HimtikaManagementBloc, HimtikaManagementState>(
            builder: (context, state) {
              if (state.status == HimtikaManagementStatus.loading &&
                  state.kabinet == null &&
                  state.divisiList.isEmpty) {
                return const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CircularProgressIndicator(color: Color(0xFF0175C8)),
                      SizedBox(height: 12),
                      Text('Memuat data HIMTIKA...', style: TextStyle(color: Colors.grey)),
                    ],
                  ),
                );
              }

              if (state.status == HimtikaManagementStatus.failure &&
                  state.kabinet == null &&
                  state.divisiList.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.error_outline, size: 48, color: Colors.redAccent),
                      const SizedBox(height: 12),
                      Text(
                        'Gagal memuat data: ${state.errorMessage ?? 'Terjadi kesalahan'}',
                        style: const TextStyle(color: Colors.redAccent),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton.icon(
                        onPressed: () {
                          context
                              .read<HimtikaManagementBloc>()
                              .add(const FetchHimtikaAdminData());
                        },
                        icon: const Icon(Icons.refresh),
                        label: const Text('Coba Lagi'),
                      ),
                    ],
                  ),
                );
              }

              return const TabBarView(
                children: [
                  HimtikaKabinetAboutTab(),
                  HimtikaDivisiTab(),
                  HimtikaPengurusTab(),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}
