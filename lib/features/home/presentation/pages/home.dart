import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:himtika_mobile_information/features/calendar/presentation/pages/calendar_screen.dart';
import 'package:himtika_mobile_information/features/home/presentation/pages/sidebar_home.dart';
import '../bloc/home_bloc.dart';
import '../bloc/home_event.dart';
import '../bloc/home_state.dart';

// 🔹 Contoh halaman lain
class ChatPage extends StatelessWidget {
  const ChatPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Chat Page")),
      body: const Center(child: Text("Ini halaman Chat")),
    );
  }
}

class MessagePage extends StatelessWidget {
  const MessagePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Message Page")),
      body: const Center(child: Text("Ini halaman Message")),
    );
  }
}

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Profile Page")),
      body: const Center(child: Text("Ini halaman Profile")),
    );
  }
}

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => HomeBloc()..add(LoadHomeData()),
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
                  // Background pattern
                  Opacity(
                    opacity: 0.1,
                    child: Image.asset(
                      "src/features/home/images/pattern.png",
                      fit: BoxFit.cover,
                      width: double.infinity,
                      height: double.infinity,
                    ),
                  ),

                  // Body
                  SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildHeader(context, state.username),
                        const SizedBox(height: 48),
                        _buildTerbaruSection(),
                        const SizedBox(height: 24),
                        _buildMenuGrid(context),
                        const SizedBox(height: 24),
                        _buildDivisiSection(),
                      ],
                    ),
                  ),
                ],
              );
            },
          ),
        ),
        bottomNavigationBar: _buildBottomNavigationBar(context),
      ),
    );
  }

  // ====== WIDGET SECTION ======

  Widget _buildHeader(BuildContext context, String username) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
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
                style: TextStyle(color: Colors.white, fontSize: 14),
              ),
              Text(
                username,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          IconButton(
            icon: const Icon(Icons.menu, color: Colors.white),
            onPressed: () => Scaffold.of(context).openEndDrawer(),
          ),
        ],
      ),
    );
  }

  Widget _buildTerbaruSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            "Terbaru",
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
        ),
        const SizedBox(height: 8),
        SizedBox(
          height: 100,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: 3,
            itemBuilder: (_, index) => Container(
              width: 200,
              margin: const EdgeInsets.only(left: 16),
              decoration: BoxDecoration(
                color: Colors.blue[200],
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMenuGrid(BuildContext context) {
    return Padding(
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
            children: [
              _menuItem("src/features/home/icons/himtika.png", "HIMTIKA",
                  [Color(0xFF32B7FF), Color(0xFF32B7FF)], () {}),
              _menuItem("src/features/home/icons/hicode.svg", "HiCode",
                  [Color(0xFF333C66), Color(0xFF2D365E)], () {}),
              _menuItem("src/features/home/icons/hiconnect.svg", "HiConnect",
                  [Color(0xFFFFC107), Color(0xFFFFC107)], () {}),
              _menuItem("src/features/home/icons/hiagenda.svg", "HiAgenda",
                  [Color(0xFFDBF6BF), Color(0xFFDBF6BF)], () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const CalendarScreen()),
                );
              }),
              _menuItem("src/features/home/icons/hispace.svg", "HiSpace",
                  [Color(0xFF402DAE), Color(0xFFBD63D1)], () {}),
              _menuItem("src/features/home/icons/kontak.svg", "HiLecturer",
                  [Color(0xFFF4BF75), Color(0xFFF4BF75)], () {}),
              _menuItem("src/features/home/icons/event.svg", "Event",
                  [Color(0xFF4CAF50), Color(0xFF4CAF50)], () {}),
              _menuItem("src/features/home/icons/more.svg", "More",
                  [Color(0xFFF7F7F7), Color(0xFFF7F7F7)], () {}),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDivisiSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            "Divisi",
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
        ),
        const SizedBox(height: 8),
        SizedBox(
          height: 100,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: 3,
            itemBuilder: (_, index) => Container(
              width: 200,
              margin: const EdgeInsets.only(left: 16),
              decoration: BoxDecoration(
                color: Colors.blue[100],
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildBottomNavigationBar(BuildContext context) {
    return Container(
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
        type: BottomNavigationBarType.fixed,
        selectedItemColor: Colors.black,
        unselectedItemColor: Colors.black,
        backgroundColor: Colors.transparent,
        elevation: 0,
        showSelectedLabels: false,
        showUnselectedLabels: false,
        onTap: (index) {
          switch (index) {
            case 0:
              break;
            case 1:
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const ChatPage()),
              );
              break;
            case 2:
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const MessagePage()),
              );
              break;
            case 3:
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const ProfilePage()),
              );
              break;
          }
        },
        items: [
          _bottomNavItem("src/features/home/icons/home.png"),
          _bottomNavItem("src/features/home/icons/chat.png"),
          _bottomNavItem("src/features/home/icons/message.png"),
          _bottomNavItem("src/features/home/icons/profile.png"),
        ],
      ),
    );
  }

  BottomNavigationBarItem _bottomNavItem(String assetPath) {
    return BottomNavigationBarItem(
      icon: Image.asset(assetPath, width: 24, height: 24),
      label: "",
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
          Text(label,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 12)),
        ],
      ),
    );
  }

  Widget _buildImage(String assetPath) {
    if (assetPath.toLowerCase().endsWith('.svg')) {
      return SvgPicture.asset(assetPath, fit: BoxFit.contain);
    } else {
      return Image.asset(assetPath, fit: BoxFit.contain);
    }
  }
}
