import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:himtika_mobile_information/core/injection_container.dart';
import 'package:himtika_mobile_information/features/calendar/presentation/pages/calendar_screen.dart';
import 'package:himtika_mobile_information/features/calendar/presentation/pages/notification_page.dart';
import 'package:himtika_mobile_information/features/hicode/presentation/pages/main_screen.dart';
import 'package:himtika_mobile_information/features/himtika/presentation/pages/himtika_screen.dart';
import 'package:himtika_mobile_information/features/home/presentation/pages/sidebar_home.dart';
import 'package:himtika_mobile_information/utility/undermaintance_screen.dart';
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

  void _onBottomNavTapped(int index) {
    setState(() => _selectedIndex = index);

    switch (index) {
      case 0:
        break;
      case 1:
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const UnderMaintenanceScreen()),
        );
        break;
      case 2:
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const UnderMaintenanceScreen()),
        );
        break;
      case 3:
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const UnderMaintenanceScreen()),
        );
        break;
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
        body: SafeArea(
          child: BlocBuilder<HomeBloc, HomeState>(
            builder: (context, state) {
              if (state.isLoading) {
                return const Center(child: CircularProgressIndicator());
              }

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
                  SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Header
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 20),
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
                                    icon: const Icon(
                                        Icons.notifications_outlined,
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

                        const SizedBox(height: 48),

                        // Terbaru
                        if (state.banners.isNotEmpty)
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Padding(
                                padding: EdgeInsets.symmetric(horizontal: 16),
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
                                          right:
                                              index == state.banners.length - 1
                                                  ? 16
                                                  : 0),
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(12),
                                        image: DecorationImage(
                                          image: NetworkImage(banner.imageUrl),
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
                              padding: const EdgeInsets.all(12.0),
                              child: GridView.count(
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
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
                                                const UnderMaintenanceScreen()),
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
                                                const UnderMaintenanceScreen()),
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
                                                const UnderMaintenanceScreen()),
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
                                                const UnderMaintenanceScreen()),
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
                                                const UnderMaintenanceScreen()),
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
                                padding: EdgeInsets.symmetric(horizontal: 16),
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
                                        borderRadius: BorderRadius.circular(12),
                                        image: DecorationImage(
                                          image: NetworkImage(division.logoUrl),
                                          fit: BoxFit
                                              .contain, // Contain agar logo tidak terpotong
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              ),
                            ],
                          ),
                      ],
                    ),
                  ),
                ],
              );
            },
          ),
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

  Widget _menuItem(String assetPath, String label, List<Color> gradientColors,
      VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
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
