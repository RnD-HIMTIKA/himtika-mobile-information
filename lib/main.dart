import 'package:flutter/material.dart';
import 'core/supabase_config.dart';
import 'features/AdminPanel/presentation/pages/roles_page.dart';

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
      home: const RolesPage(), // Ganti nanti dengan halaman utama aplikasi
    );
  }
}