import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:himtika_mobile_information/features/AdminPanel/presentation/pages/dashboard.dart';
import 'package:himtika_mobile_information/features/AdminPanel/presentation/bloc/adminpanel_bloc.dart';
import 'core/supabase_config.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SupabaseConfig.init();
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
      ],
      child: MaterialApp(
        title: 'HIMTIKA Mobile Information',
        debugShowCheckedModeBanner: false,
        home: Dashboard(),
      ),
    );
  }
}