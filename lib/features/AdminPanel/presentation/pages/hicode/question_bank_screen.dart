import 'package:flutter/material.dart';

class QuestionBankScreen extends StatelessWidget {
  const QuestionBankScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Bank Soal')),
      body: const Center(child: Text('Halaman untuk mengelola semua soal.')),
    );
  }
}