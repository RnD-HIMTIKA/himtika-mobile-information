import 'dart:async';
import 'package:flutter/material.dart';
import 'package:sentry_flutter/sentry_flutter.dart';
import 'package:himtika_mobile_information/features/home/presentation/pages/home.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:app_links/app_links.dart';
import 'core/supabase_config.dart';
import 'package:himtika_mobile_information/core/blocs/connectivity_bloc.dart';
import 'package:himtika_mobile_information/core/injection_container.dart';
import 'features/auth/application/auth_controller.dart';
import 'package:himtika_mobile_information/features/AdminPanel/presentation/bloc/adminpanel_bloc.dart';
import 'package:himtika_mobile_information/features/auth/presentation/blocs/login/login_bloc.dart';
import 'package:himtika_mobile_information/features/auth/presentation/pages/splash.dart';
import 'package:himtika_mobile_information/features/auth/presentation/pages/onboarding.dart';
import 'package:himtika_mobile_information/features/calendar/presentation/pages/invitation_handler_page.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_web_plugins/url_strategy.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  usePathUrlStrategy();
  
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  
  // HAPUS BARIS INI:
  // await dotenv.load(fileName: ".env"); 
  
  await SupabaseConfig.init(); // Pastikan ini dipanggil
  await initDependencies();

  // --- PERBAIKAN SENTRY ---
  // Ambil DSN dari environment, BUKAN dari dotenv
  const sentryDsn = String.fromEnvironment('SENTRY_DSN');
  
  if (sentryDsn.isEmpty) { // <-- Ubah pengecekan
     print("PERINGATAN: SENTRY_DSN tidak ditemukan (gunakan --dart-define). Error tidak akan dilaporkan.");
     runApp(const MyApp());
  } else {
    await SentryFlutter.init(
      (options) {
        options.dsn = sentryDsn;
        options.tracesSampleRate = 1.0;
        
        // --- PERBAIKAN OAUTH (YANG KITA DISKUSIKAN SEBELUMNYA) ---
        // Ini tetap disarankan untuk memperbaiki login Google Anda
        options.tracesSampler = (samplingContext) {
          final transactionContext = samplingContext.transactionContext;
          final transactionName = transactionContext?.name;
          // Jika transaksi adalah callback Supabase, JANGAN LACAK
          if (transactionName != null && transactionName.contains('io.supabase.flutter')) {
            print('[Sentry] Mengabaikan trace untuk callback Supabase: $transactionName');
            return null; // <-- Ini akan memperbaiki login Google
          }
          // Lacak semua hal lain
          return 1.0;
        };
        // --- AKHIR PERBAIKAN OAUTH ---
      },
      appRunner: () => runApp(
        const MyApp(),
      ),
    );
  }
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
    // Debug print untuk melihat link yang masuk
    debugPrint('Handling Deep Link: $uri'); 

    // --- PERUBAHAN DI SINI ---
    // Tambahkan kondisi untuk domain Firebase Hosting
    if ((uri.scheme == 'https' && uri.host == 'himtika.cs.unsika.ac.id' && uri.path == '/join-workspace') ||
        (uri.scheme == 'https' && uri.host == 'himfo-app-f52b3.web.app' && uri.path == '/join-workspace') || // <--- BARU
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
        BlocProvider<ConnectivityBloc>(
          create: (_) => sl<ConnectivityBloc>()..add(StartListening()),
        ),
      ],
      child: MaterialApp(
        navigatorKey: navigatorKey,
        title: 'HIMTIKA Mobile Information',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(primarySwatch: Colors.blue),
        // Tambahkan localizationsDelegates dan supportedLocales di sini untuk fix error Quill
        localizationsDelegates: const [
          FlutterQuillLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: const [
          Locale('en', 'US'),
          Locale('id', 'ID'),
        ],
        home: const SplashScreen(),
      ),
    );
  }
}