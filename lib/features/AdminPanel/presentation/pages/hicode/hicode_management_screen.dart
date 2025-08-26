import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:himtika_mobile_information/core/injection_container.dart';
import 'package:himtika_mobile_information/features/AdminPanel/presentation/bloc/hicode_management/hicode_management_bloc.dart';
import '../sidebar.dart';

class HicodeManagementScreen extends StatelessWidget {
  const HicodeManagementScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<HicodeManagementBloc>()..add(LoadHicodeMaterials()),
      child: Scaffold(
        drawer: const Sidebar(),
        appBar: AppBar(
          title: const Text('Manajemen HiCode'),
          // Anda bisa tambahkan profile picture di sini seperti halaman lain
        ),
        body: BlocBuilder<HicodeManagementBloc, HicodeManagementState>(
          builder: (context, state) {
            if (state.status == HicodeManagementStatus.loading) {
              return const Center(child: CircularProgressIndicator());
            }
            if (state.status == HicodeManagementStatus.failure) {
              return Center(child: Text(state.errorMessage ?? 'Gagal memuat data'));
            }
            return ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: state.materials.length,
              itemBuilder: (context, index) {
                final material = state.materials[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: ListTile(
                    title: Text(material['title']),
                    subtitle: Text('${material['chapter_count']} Chapter'),
                    trailing: const Icon(Icons.edit),
                    onTap: () {
                      // Navigasi ke halaman detail materi (admin)
                    },
                  ),
                );
              },
            );
          },
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            // Buka dialog/halaman untuk menambah materi baru
          },
          child: const Icon(Icons.add),
        ),
      ),
    );
  }
}