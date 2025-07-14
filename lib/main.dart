import 'package:flutter/material.dart';
import 'package:himtika_mobile_information/features/AdminPanel/presentation/pages/dashboard.dart';
import 'core/supabase_config.dart';
import 'features/AdminPanel/presentation/pages/dashboard.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SupabaseConfig.init();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      title: 'HIMTIKA App',
      home: const Dashboard(), // Ganti nanti dengan halaman utama aplikasi
    );
  }
}