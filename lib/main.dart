import 'dart:async';
import 'package:flutter/material.dart';
import 'package:himtika_mobile_information/features/hilecturer/presentation/pages/hilecturer_page.dart';
import 'package:himtika_mobile_information/features/himtika/presentation/bloc/himtika_screen/himtika_bloc.dart';
import 'package:himtika_mobile_information/features/himtika/presentation/pages/himtika_screen.dart';
import 'package:himtika_mobile_information/features/home/presentation/pages/home.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:app_links/app_links.dart';
import 'core/supabase_config.dart';
import 'core/injection_container.dart';
import 'features/auth/application/auth_controller.dart';
import 'package:himtika_mobile_information/features/AdminPanel/presentation/bloc/adminpanel_bloc.dart';
import 'package:himtika_mobile_information/features/auth/presentation/blocs/login/login_bloc.dart';
import 'package:himtika_mobile_information/features/auth/presentation/pages/splash.dart';
import 'package:himtika_mobile_information/features/auth/presentation/pages/onboarding.dart';
import 'package:himtika_mobile_information/features/calendar/presentation/pages/invitation_handler_page.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // inisialisasi Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  
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
  late AppLinks _appLinks;
  StreamSubscription<Uri>? _linkSubscription;

  @override
  void initState() {
    super.initState();
    _setupAuthListener();
    _initDeepLinks();
  }

  @override
  void dispose() {
    _linkSubscription?.cancel();
    super.dispose();
  }

  void _initDeepLinks() {
    _appLinks = AppLinks();

    _linkSubscription = _appLinks.uriLinkStream.listen((uri) {
      debugPrint('Menerima link saat aplikasi berjalan: $uri');
      _handleInvitationLink(uri);
    });

    // PERBAIKAN DI SINI: Ganti getInitialAppLinkUri menjadi getLatestAppLink
    _appLinks.getInitialLink().then((uri) {
      if (uri != null) {
        _handleInvitationLink(uri);
      }
    });
  }

  void _handleInvitationLink(Uri uri) {
    if ((uri.scheme == 'https' && uri.host == 'himtika.cs.unsika.ac.id' && uri.path == '/join-workspace') ||
        (uri.scheme == 'himfo' && uri.host == 'join-workspace')) {
      final token = uri.queryParameters['token'];
      if (token != null) {
        final context = navigatorKey.currentContext;
        if (context != null) {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => InvitationHandlerPage(token: token),
            ),
          );
        }
      }
    }
  }

  void _setupAuthListener() {
    final authController = sl<AuthController>();
    Supabase.instance.client.auth.onAuthStateChange.listen((data) {
      final event = data.event;
      final session = data.session;
      if ((event == AuthChangeEvent.initialSession || event == AuthChangeEvent.signedIn) && session != null) {
        debugPrint('Auth event: $event captured with a valid session. Checking profile...');
        Future.delayed(const Duration(milliseconds: 100), () {
          authController.checkAuthAndNavigate();
        });
      }
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
        BlocProvider(create: (_) => sl<AdminPanelBloc>()),
        BlocProvider(create: (_) => sl<LoginBloc>()),
      ],
      child: MaterialApp(
        navigatorKey: navigatorKey,
        title: 'HIMTIKA Mobile Information',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(primarySwatch: Colors.blue),
        home: const HiLecturerPage(),
      ),
    );
  }
}