import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:himtika_mobile_information/features/AdminPanel/presentation/bloc/adminpanel_bloc.dart';
import 'package:himtika_mobile_information/features/calendar/presentation/pages/calendar_screen.dart';
// import 'package:himtika_mobile_information/features/home/presentation/pages/home.dart';
// import 'core/supabase_config.dart';

// Hapus 'async' karena tidak ada 'await'
void main() {
  // BARIS INI WAJIB DIAKTIFKAN KEMBALI
  WidgetsFlutterBinding.ensureInitialized();

  // Biarkan bagian Supabase tetap nonaktif untuk sekarang
  // await SupabaseConfig.init();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<AdminPanelBloc>(
          create: (context) => AdminPanelBloc(),
        ),
        // Tambahkan BlocProvider lain jika ada di sini
      ],
      child: const MaterialApp(
        title: 'HIMTIKA Mobile Information',
        debugShowCheckedModeBanner: false,
        home: CalendarScreen(),
      ),
    );
  }
}