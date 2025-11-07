import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:himtika_mobile_information/core/helpers/image_optimizer.dart';
import 'package:himtika_mobile_information/core/injection_container.dart';
import 'package:himtika_mobile_information/features/calendar/presentation/bloc/invitation/invitation_bloc.dart';
import 'package:himtika_mobile_information/features/hicode/presentation/bloc/main_screen/main_screen_bloc.dart';
import 'package:himtika_mobile_information/features/calendar/presentation/pages/calendar_screen.dart';
import 'package:himtika_mobile_information/features/calendar/presentation/pages/notification_page.dart';
import 'package:himtika_mobile_information/features/hicode/presentation/pages/main_screen.dart';
import 'package:himtika_mobile_information/features/himtika/presentation/pages/himtika_screen.dart';
import 'package:himtika_mobile_information/features/home/presentation/pages/sidebar_home.dart';
import 'package:himtika_mobile_information/utility/undermaintance_screen.dart';
import 'package:himtika_mobile_information/utility/comingsoon_screen.dart';

import '../bloc/home_bloc.dart';
import '../bloc/home_event.dart';
import '../bloc/home_state.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;
  
  StreamSubscription<ConnectivityResult>? _connectivitySubscription;
  bool _isOffline = false; // Status untuk melacak koneksi

  void _onBottomNavTapped(int index) {
    if (_selectedIndex == index) return;

    setState(() => _selectedIndex = index);

    Future.delayed(const Duration(milliseconds: 100), () {
      switch (index) {
        case 0:
          break;
        case 1:
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const UnderMaintenanceScreen()),
          ).then((_) => setState(() => _selectedIndex = 0));
          break;
        case 2:
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const UnderMaintenanceScreen()),
          ).then((_) => setState(() => _selectedIndex = 0));
          break;
        case 3:
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const UnderMaintenanceScreen()),
          ).then((_) => setState(() => _selectedIndex = 0));
          break;
      }
    });
  }

  @override
  void initState() {
    super.initState();
    _initConnectivityListener();
  }

  void _initConnectivityListener() {
    // Cek status awal
    Connectivity().checkConnectivity().then((result) {
      if (result == ConnectivityResult.none) {
        _isOffline = true;
        _showOfflineBanner(); // Tampilkan banner jika pertama buka sudah offline
      }
    });

    // Dengarkan perubahan
    _connectivitySubscription = Connectivity().onConnectivityChanged.listen((ConnectivityResult result) {
      if (result == ConnectivityResult.none) {
        // --- JARINGAN HILANG ---
        _isOffline = true;
        _showOfflineBanner();
      } else {
        // --- JARINGAN KEMBALI ONLINE ---
        if (_isOffline) {
          // Hanya refresh jika SEBELUMNYA offline
          _isOffline = false; 
          _showOnlineBanner();
          _refreshAllData(); // Panggil fungsi refresh
        }
      }
    });
  }

  // --- 5. TAMBAHKAN FUNGSI dispose ---
  @override
  void dispose() {
    _connectivitySubscription?.cancel(); // Hentikan listener
    super.dispose();
  }
  
  // --- 6. TAMBAHKAN FUNGSI HELPER (Banner & Refresh) ---
  void _showOfflineBanner() {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Koneksi internet terputus.'),
        backgroundColor: Colors.red,
        duration: Duration(seconds: 3),
      ),
    );
  }

  void _showOnlineBanner() {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Kembali online! Menyegarkan data...'),
        backgroundColor: Colors.green,
        duration: Duration(seconds: 2),
      ),
    );
  }

  void _refreshAllData() {
    // Memicu refresh BLoC-BLoC utama.
    // Kita butuh context yang memiliki akses ke BLoC-BLoC ini.
    // Jika BLoC belum ada (karena lazy), kita perlu memastikan BLoC-nya
    // disediakan di atas HomePage, atau kita panggil saat BLoC-nya ada.
    
    // Cara aman: Gunakan context.read()
    // Pastikan BLoC sudah di-provide di main.dart atau di atas HomePage
    
    // Kita refresh HomeBloc (yang sudah pasti ada)
    context.read<HomeBloc>().add(LoadHomeData());
    
    // Kita juga bisa refresh BLoC lain jika sudah di-inject:
    // (Jika BLoC ini di-create di halaman lain, panggilannya tidak akan error
    // tapi tidak akan melakukan apa-apa jika BLoC-nya tidak aktif)
    
    // Coba refresh InvitationBloc (untuk notifikasi)
    if (sl.isRegistered<InvitationBloc>()) {
       // sl<InvitationBloc>().add(LoadMyInvitations()); 
       // Lebih aman lagi jika kita tahu BLoC-nya ada di tree:
       // context.read<InvitationBloc>().add(LoadMyInvitations());
       // Untuk saat ini, kita fokus refresh halaman yang aktif.
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final double gridItemWidth = (screenWidth - 32 - (3 * 8)) / 4;
    final double gridItemHeight = 100;
    final double childAspectRatio = gridItemWidth / gridItemHeight;

    return BlocProvider(
      create: (_) => sl<HomeBloc>()..add(LoadHomeData()),
      child: Scaffold(
        endDrawer: const SidebarHome(),
        body: BlocBuilder<HomeBloc, HomeState>(
          builder: (context, state) {
            if (state.isLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            final double statusBarHeight = MediaQuery.of(context).padding.top;

            return Stack(
              children: [
                Opacity(
                  opacity: 0.1,
                  child: Image.asset(
                    "src/features/home/images/pattern.png",
                    fit: BoxFit.cover,
                    width: double.infinity,
                    height: double.infinity,
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: EdgeInsets.only(
                        top: statusBarHeight + 20,
                        bottom: 20,
                        left: 16,
                        right: 16,
                      ),
                      decoration: const BoxDecoration(
                        color: Colors.blue,
                        borderRadius: BorderRadius.only(
                          bottomLeft: Radius.circular(20),
                          bottomRight: Radius.circular(20),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                "Selamat Datang,",
                                style: TextStyle(
                                    color: Colors.white, fontSize: 14),
                              ),
                              Text(
                                state.currentUser?.fullName ?? 'Pengguna',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          Row(
                            children: [
                              IconButton(
                                icon: const Icon(Icons.notifications_outlined,
                                    color: Colors.white),
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) =>
                                            const NotificationPage()),
                                  );
                                },
                              ),
                              Builder(builder: (context) {
                                return IconButton(
                                  icon: const Icon(Icons.menu,
                                      color: Colors.white),
                                  onPressed: () {
                                    Scaffold.of(context).openEndDrawer();
                                  },
                                );
                              }),
                            ],
                          ),
                        ],
                      ),
                    ),

                    // 2. Konten (Dibungkus Expanded agar bisa di-scroll)
                    Expanded(
                      child: SingleChildScrollView(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // 3. Pindahkan semua sisa konten ke sini
                            const SizedBox(height: 24),

                            // Terbaru
                            if (state.banners.isNotEmpty)
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Padding(
                                    padding:
                                        EdgeInsets.symmetric(horizontal: 16),
                                    child: Text(
                                      "Terbaru",
                                      style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  SizedBox(
                                    height: 100,
                                    child: ListView.builder(
                                      scrollDirection: Axis.horizontal,
                                      itemCount: state.banners.length,
                                      itemBuilder: (_, index) {
                                        final banner = state.banners[index];
                                        return Container(
                                          width: 200,
                                          margin: EdgeInsets.only(
                                              left: index == 0 ? 16 : 8,
                                              right: index ==
                                                      state.banners.length - 1
                                                  ? 16
                                                  : 0),
                                          decoration: BoxDecoration(
                                            borderRadius:
                                                BorderRadius.circular(12),
                                            image: DecorationImage(
                                              image: NetworkImage(ImageOptimizer
                                                  .getOptimizedUrl(
                                                      banner.imageUrl,
                                                      width: 600,
                                                      quality: 80)),
                                              fit: BoxFit.cover,
                                            ),
                                          ),
                                        );
                                      },
                                    ),
                                  ),
                                  const SizedBox(height: 24),
                                ],
                              ),

                            // Menu Grid
                            Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Card(
                                color: Colors.white,
                                elevation: 2,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: Padding(
                                  padding:
                                      const EdgeInsets.fromLTRB(12, 0, 12, 16),
                                  child: GridView.count(
                                    shrinkWrap: true,
                                    physics:
                                        const NeverScrollableScrollPhysics(),
                                    crossAxisCount: 4,
                                    crossAxisSpacing: 8,
                                    mainAxisSpacing: 8,
                                    childAspectRatio: childAspectRatio,
                                    children: [
                                      _menuItem(
                                        "src/features/home/icons/himtika.png",
                                        "HIMTIKA",
                                        [
                                          const Color(0xFF32B7FF),
                                          const Color(0xFF32B7FF)
                                        ],
                                        () {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                                builder: (_) =>
                                                    const HimtikaScreen()),
                                          );
                                        },
                                      ),
                                      _menuItem(
                                        "src/features/home/icons/hicode.svg",
                                        "HiCode",
                                        [Color(0xFF333C66), Color(0xFF2D365E)],
                                        () {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                                builder: (_) =>
                                                    const HicodeScreen()),
                                          );
                                        },
                                      ),
                                      _menuItem(
                                        "src/features/home/icons/hiconnect.svg",
                                        "HiConnect",
                                        [
                                          const Color(0xFFFFC107),
                                          const Color(0xFFFFC107)
                                        ],
                                        () {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                                builder: (_) =>
                                                    const ComingsoonScreen()),
                                          );
                                        },
                                      ),
                                      _menuItem(
                                        "src/features/home/icons/hiagenda.svg",
                                        "HiAgenda",
                                        [
                                          const Color(0xFFDBF6BF),
                                          const Color(0xFFDBF6BF)
                                        ],
                                        () {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                                builder: (_) =>
                                                    const CalendarScreen()),
                                          );
                                        },
                                      ),
                                      _menuItem(
                                        "src/features/home/icons/hispace.svg",
                                        "HiSpace",
                                        [
                                          const Color(0xFF402DAE),
                                          const Color(0xFFBD63D1)
                                        ],
                                        () {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                                builder: (_) =>
                                                    const ComingsoonScreen()),
                                          );
                                        },
                                      ),
                                      _menuItem(
                                        "src/features/home/icons/kontak.svg",
                                        "HiLecturer",
                                        [Color(0xFFF4BF75), Color(0xFFF4BF75)],
                                        () {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                                builder: (_) =>
                                                    const ComingsoonScreen()),
                                          );
                                        },
                                      ),
                                      _menuItem(
                                        "src/features/home/icons/event.svg",
                                        "Event",
                                        [
                                          const Color(0xFF4CAF50),
                                          const Color(0xFF4CAF50)
                                        ],
                                        () {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                                builder: (_) =>
                                                    const ComingsoonScreen()),
                                          );
                                        },
                                      ),
                                      _menuItem(
                                        "src/features/home/icons/more.svg",
                                        "More",
                                        [
                                          const Color(0xFFF7F7F7),
                                          const Color(0xFFF7F7F7)
                                        ],
                                        () {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                                builder: (_) =>
                                                    const ComingsoonScreen()),
                                          );
                                        },
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),

                            const SizedBox(height: 24),

                            // Divisi
                            if (state.divisions.isNotEmpty)
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Padding(
                                    padding:
                                        EdgeInsets.symmetric(horizontal: 16),
                                    child: Text(
                                      "Divisi",
                                      style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  SizedBox(
                                    height: 100,
                                    child: ListView.builder(
                                      scrollDirection: Axis.horizontal,
                                      itemCount: state.divisions.length,
                                      itemBuilder: (_, index) {
                                        final division = state.divisions[index];
                                        return Container(
                                          width: 200,
                                          margin: EdgeInsets.only(
                                              left: index == 0 ? 16 : 8,
                                              right: index ==
                                                      state.divisions.length - 1
                                                  ? 16
                                                  : 0),
                                          decoration: BoxDecoration(
                                            borderRadius:
                                                BorderRadius.circular(12),
                                            image: DecorationImage(
                                              image: NetworkImage(ImageOptimizer
                                                  .getOptimizedUrl(
                                                      division.logoUrl,
                                                      width: 400,
                                                      quality: 80)),
                                              fit: BoxFit.contain,
                                            ),
                                          ),
                                        );
                                      },
                                    ),
                                  ),
                                ],
                              ),

                            const SizedBox(height: 24),
                            // Tambahkan Kartu Bantuan
                            _buildSupportCard(context),
                            const SizedBox(height: 24),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            );
          },
        ),
        bottomNavigationBar: Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20),
            ),
            boxShadow: [
              BoxShadow(color: Colors.black12, spreadRadius: 0, blurRadius: 8),
            ],
          ),
          child: BottomNavigationBar(
            currentIndex: _selectedIndex,
            onTap: _onBottomNavTapped,
            type: BottomNavigationBarType.fixed,
            selectedItemColor: Colors.blue,
            unselectedItemColor: Colors.black,
            backgroundColor: Colors.transparent,
            elevation: 0,
            showSelectedLabels: false,
            showUnselectedLabels: false,
            items: const [
              BottomNavigationBarItem(
                icon: ImageIcon(AssetImage("src/features/home/icons/home.png")),
                label: "",
              ),
              BottomNavigationBarItem(
                icon: ImageIcon(AssetImage("src/features/home/icons/chat.png")),
                label: "",
              ),
              BottomNavigationBarItem(
                icon: ImageIcon(
                    AssetImage("src/features/home/icons/message.png")),
                label: "",
              ),
              BottomNavigationBarItem(
                icon: ImageIcon(
                    AssetImage("src/features/home/icons/profile.png")),
                label: "",
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSupportCard(BuildContext context) {
    return Padding(
      // Padding horizontal agar sejajar dengan Card menu
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Container(
        padding: const EdgeInsets.all(20.0),
        decoration: BoxDecoration(
          color: const Color(0xFFE6F7E9), // Warna hijau muda
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Kolom Kiri: Teks dan Tombol
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Mengalami Gangguan?",
                    style: Theme.of(context).textTheme.headlineSmall!.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                          fontSize: 22, // Sedikit sesuaikan ukuran
                        ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "Tim kami siap membantu anda kapan saja!",
                    style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                          color: Colors.black54,
                          height: 1.5,
                        ),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () async {
                      const phoneNumber = "62859121392342";
                      const message =
                          "Halo, saya mengalami gangguan pada aplikasi HIMTIKA...";

                      final Uri whatsappUrl = Uri.parse(
                        "https://wa.me/$phoneNumber?text=${Uri.encodeComponent(message)}",
                      );

                      try {
                        if (await canLaunchUrl(whatsappUrl)) {
                          await launchUrl(whatsappUrl,
                              mode: LaunchMode.externalApplication);
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                                content: Text('Tidak dapat membuka WhatsApp.')),
                          );
                        }
                      } catch (e) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Gagal membuka link: $e')),
                        );
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor:
                          const Color(0xFF66BB6A), // Warna hijau tombol
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 24, vertical: 12),
                    ),
                    child: const Text("Hubungi Kami"),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 16), // Jarak

            // Kolom Kanan: Gambar
            Image.asset(
              'src/features/home/icons/mailbox.png',
              width: 100,
              height: 100,
              fit: BoxFit.contain,
            ),
          ],
        ),
      ),
    );
  }

  Widget _menuItem(String assetPath, String label, List<Color> gradientColors,
      VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: gradientColors,
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            padding: const EdgeInsets.all(8),
            child: _buildImage(assetPath),
          ),
          const SizedBox(height: 6),
          Text(
            label,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 12),
          ),
        ],
      ),
    );
  }

  Widget _buildImage(String assetPath) {
    if (assetPath.toLowerCase().endsWith('.svg')) {
      return SvgPicture.asset(
        assetPath,
        fit: BoxFit.contain,
      );
    } else {
      return Image.asset(
        assetPath,
        fit: BoxFit.contain,
      );
    }
  }
}
