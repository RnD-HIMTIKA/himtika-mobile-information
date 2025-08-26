import 'package:flutter/material.dart';

class MaterialManagementScreen extends StatelessWidget {
  const MaterialManagementScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Kelola Materi')),
      body: const Center(child: Text('Halaman untuk mengelola materi dan chapter.')),
    );
  }
}