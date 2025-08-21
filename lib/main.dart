import 'package:flutter/material.dart';
import 'package:himtika_mobile_information/features/calendar/presentation/pages/calendar_screen.dart';
import 'package:himtika_mobile_information/features/home/presentation/pages/home.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'core/supabase_config.dart';
import 'core/injection_container.dart';
import 'features/auth/application/auth_controller.dart';
import 'package:himtika_mobile_information/features/AdminPanel/presentation/bloc/adminpanel_bloc.dart';
import 'package:himtika_mobile_information/features/auth/presentation/blocs/login/login_bloc.dart';
import 'package:himtika_mobile_information/features/auth/presentation/pages/splash.dart';
import 'package:himtika_mobile_information/features/auth/presentation/pages/onboarding.dart'; // Import Onboarding

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");
  await SupabaseConfig.init();
  await initDependencies();

  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();
    _setupAuthListener();
  }

  void _setupAuthListener() {
    final authController = sl<AuthController>();

    Supabase.instance.client.auth.onAuthStateChange.listen((data) {
      final event = data.event;
      final session = data.session;

      // Kita proses jika ada sesi yang valid, baik itu dari login baru atau sesi yang sudah ada.
      if ((event == AuthChangeEvent.initialSession || event == AuthChangeEvent.signedIn) && session != null) {
        debugPrint('Auth event: $event captured with a valid session. Checking profile...');
        
        // Penundaan tetap penting untuk mengatasi race condition
        Future.delayed(const Duration(milliseconds: 100), () {
          authController.checkAuthAndNavigate();
        });
      }
      // Jika user sign out, arahkan ke halaman onboarding/login
      else if (event == AuthChangeEvent.signedOut) {
         debugPrint('Auth event: signedOut. Navigating to Onboarding.');
         navigatorKey.currentState?.pushAndRemoveUntil(
           MaterialPageRoute(builder: (context) => const Onboarding()),
           (route) => false,
         );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => AdminPanelBloc()),
        BlocProvider(create: (_) => sl<LoginBloc>()),
      ],
      child: MaterialApp(
        navigatorKey: navigatorKey,
        title: 'HIMTIKA Mobile Information',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(primarySwatch: Colors.blue),
        // Kita mulai dari splash, yang akan menunggu keputusan dari listener
        home: const HomePage(),
      ),
    );
  }
}