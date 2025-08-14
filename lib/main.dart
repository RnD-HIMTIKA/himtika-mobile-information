import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'core/supabase_config.dart';
import 'core/injection_container.dart';
import 'features/auth/application/auth_controller.dart'; // tambahkan ini
import 'package:himtika_mobile_information/features/AdminPanel/presentation/bloc/adminpanel_bloc.dart';
import 'package:himtika_mobile_information/features/auth/presentation/blocs/login/login_bloc.dart';
import 'package:himtika_mobile_information/features/auth/presentation/pages/splash.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await dotenv.load(fileName: ".env");
  await SupabaseConfig.init();
  await initDependencies();
  final authController = AuthController();
  final session = Supabase.instance.client.auth.currentSession;
  print('Current session: $session');
  // ✅ Tambahkan listener Supabase auth
  Supabase.instance.client.auth.onAuthStateChange.listen((data) {
    final event = data.event;
    final session = data.session;
    print('Auth event: $event');

    if (event == AuthChangeEvent.signedIn && session != null) {
      // langsung cek user & redirect sesuai logika di AuthController
      authController.checkAuthSession(navigatorKey.currentContext!);
    }
  });

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<AdminPanelBloc>(
          create: (_) => AdminPanelBloc(),
        ),
        BlocProvider<LoginBloc>(
          create: (_) => sl<LoginBloc>(),
        ),
      ],
      child: MaterialApp(
        navigatorKey: navigatorKey,
        title: 'HIMTIKA Mobile Information',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(primarySwatch: Colors.blue),
        home: const SplashScreen(),
      ),
    );
  }
}