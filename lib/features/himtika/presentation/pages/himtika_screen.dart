import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:himtika_mobile_information/features/himtika/presentation/bloc/himtika_screen/himtika_bloc.dart';
import 'package:himtika_mobile_information/features/calendar/presentation/pages/notification_page.dart';
import 'package:himtika_mobile_information/features/himtika/presentation/pages/about_himtika_screen.dart';
import 'package:himtika_mobile_information/features/himtika/presentation/pages/divisi_detail_screen.dart';
import 'package:himtika_mobile_information/features/himtika/presentation/pages/sejarah_screen.dart'; 
import 'package:himtika_mobile_information/features/himtika/presentation/pages/kabinet_screen.dart'; 


class HimtikaScreen extends StatelessWidget {
  const HimtikaScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => HimtikaBloc()..add(FetchHimtikaData()),
      child: Scaffold(
        backgroundColor: const Color(0xFFF5F5F5),
        body: SafeArea(
          top: false, 
          child: BlocBuilder<HimtikaBloc, HimtikaState>(
            builder: (context, state) {
              if (state.status == HimtikaStatus.loading) {
                return const Center(child: CircularProgressIndicator());
              }

              return Column(
                children: [
                  // Lapisan 1: Top Bar 
                  _buildTopBar(context),
                  // Lapisan 2: Sisa konten yang bisa di-scroll
                  Expanded(
                    child: SingleChildScrollView(
                      child: Column(
                        children: [
                          _buildBlueHeader(context),
                          _buildContent(context, state),
                        ],
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  // --- WIDGET-WIDGET PEMBANTU ---
  Widget _buildTopBar(BuildContext context) {
    return Container(
      color: Colors.blue,
      padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            IconButton(
              onPressed: () => Navigator.pop(context),
              icon: Image.asset('src/features/hicode/icon/kembali.png',
                  width: 32, height: 32, color: Colors.white),
            ),
            IconButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const NotificationPage()),
                );
              },
              icon: const Icon(Icons.notifications_outlined,
                  color: Colors.white, size: 28),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBlueHeader(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final cardWidth = (screenWidth * 0.9).clamp(280.0, 520.0);
    return Container(
      width: double.infinity,
      color: Colors.blue,
      child: Column(
        children: [
          Transform.translate(
            offset: const Offset(0, 40),
            child: Container(
              width: cardWidth,
              padding: const EdgeInsets.all(20.0),
              decoration: BoxDecoration(
                color: Colors.transparent,
                borderRadius: BorderRadius.circular(30),
                image: const DecorationImage(
                  image:
                      AssetImage('src/features/himtika/images/card_hero.png'),
                  fit: BoxFit.cover,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.1),
                    blurRadius: 10,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  RichText(
                    text: TextSpan(
                      style: const TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                        height: 1.4,
                      ),
                      children: <InlineSpan>[
                        const TextSpan(text: 'Yuk! Kenali '),
                        WidgetSpan(
                          alignment: PlaceholderAlignment.middle,
                          child: ShaderMask(
                            blendMode: BlendMode.srcIn,
                            shaderCallback: (bounds) => const LinearGradient(
                              colors: [Color(0xFF006EBD), Color(0xFF0095FF)],
                            ).createShader(
                              Rect.fromLTWH(0, 0, bounds.width, bounds.height),
                            ),
                            child: const Text(
                              'HIMTIKA',
                              style: TextStyle(
                                fontSize: 28,
                                fontWeight: FontWeight.bold,
                                height: 1.4,
                              ),
                            ),
                          ),
                        ),
                        const TextSpan(text: '\nlebih dekat'),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Mau tahu lebih banyak\ntentang HIMTIKA?',
                    style: TextStyle(color: Colors.black54),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const AboutHimtikaScreen(),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF81EAFF),
                      foregroundColor: Colors.cyan.shade800,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                    child: const Text('Baca Selengkapnya'),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }


  Widget _buildContent(BuildContext context, HimtikaState state) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 30),
          const Text('Kabinet Saat Ini',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          _buildKabinetCard(context),
          const SizedBox(height: 20),
          const Text('Sejarah HIMTIKA',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          _buildSejarahCard(context),
          const SizedBox(height: 28),
          const Text('Bagian Penting dalam HIMTIKA',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          ListView.separated(
            padding: EdgeInsets.zero,
            itemCount: state.importantParts.length,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemBuilder: (context, index) {
              final part = state.importantParts[index];
              return InkWell(
                onTap: () {
                  // 2. Navigasi ke halaman detail dengan ID
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (_) =>
                            DivisiDetailScreen(divisiId: part['title']!)),
                  );
                },
                borderRadius: BorderRadius.circular(20),
                child: _buildDivisiCard(
                  imagePath: part['imagePath']!,
                ),
              );
            },
            separatorBuilder: (context, index) => const SizedBox(height: 16),
          )
        ],
      ),
    );
  }

  Widget _buildKabinetCard(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final logoSize = (screenWidth * 0.22).clamp(60.0, 100.0);
    return InkWell( 
      onTap: () { 
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const KabinetScreen()),
        );
      },
      borderRadius: BorderRadius.circular(15),
      child: Card(
        elevation: 2,
        color: const Color(0xFFF5F9FF),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Image.asset(
                  'src/features/himtika/images/kabinet.png',
                  width: logoSize,
                  height: logoSize,
                  fit: BoxFit.contain,
                ),
                const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ShaderMask(
                          blendMode: BlendMode.srcIn,
                          shaderCallback: (bounds) => const LinearGradient(
                            colors: [
                              Color(0xFF4D2A7C),
                              Color(0xFF9C4895),
                            ],
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                          ).createShader(
                            Rect.fromLTWH(0, 0, bounds.width, bounds.height),
                          ),
                          child: const Text(
                            'SINERGIS',
                            style: TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        SizedBox(height: 8),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding: EdgeInsets.only(top: 2.0, right: 4.0),
                              child:
                                  Icon(Icons.star, color: Colors.amber, size: 14),
                            ),
                            Expanded(
                              child: Text(
                                'Sinergi, Inovatif, Eksplorasi, Responsif, Generalis, Sistematis',
                                style: TextStyle(
                                    color: Colors.black54, fontSize: 10),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const Align(
                      alignment: Alignment.bottomRight,
                      child: Icon(Icons.arrow_forward_ios,
                          color: Colors.blue, size: 20),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSejarahCard(BuildContext context) {
    return InkWell( // 2. Bungkus dengan InkWell
    onTap: () { // 3. Tambahkan aksi onTap
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const SejarahScreen()),
      );
    },
    borderRadius: BorderRadius.circular(15), // Samakan radius
    child: Container(
      // (Container Anda yang sebelumnya utuh di sini)
      width: double.infinity,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: const Color(0xFFFDBF7F), // Warna fallback
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          )
        ],
      ),
      child: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              'src/features/himtika/images/card_sejarah.png', // Sesuaikan path
              fit: BoxFit.cover,
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0), // Transparan
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize
                    .min, // Penting agar Column tidak setinggi Stack
                children: [
                  RichText(
                    text: TextSpan(
                      style: const TextStyle(
                        fontSize: 22,
                        color: Colors.black,
                        height: 1.4,
                        fontWeight: FontWeight.bold,
                      ),
                      children: <InlineSpan>[
                        const TextSpan(text: 'Sejarah '),
                        WidgetSpan(
                          alignment: PlaceholderAlignment.middle,
                          child: ShaderMask(
                            blendMode: BlendMode.srcIn,
                            shaderCallback: (bounds) => const LinearGradient(
                              colors: [
                                Color(0xFF006EBD), // Biru gelap
                                Color(0xFF0095FF), // Biru terang
                              ],
                              begin: Alignment.centerLeft,
                              end: Alignment.centerRight,
                            ).createShader(
                              Rect.fromLTWH(0, 0, bounds.width, bounds.height),
                            ),
                            child: const Text(
                              'HIMTIKA',
                              style: TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                height: 1.4,
                              ),
                            ),
                          ),
                        ),
                        const TextSpan(text: '\nDari Masa ke Masa'),
                      ],
                    ),
                  ),
                  const SizedBox(height: 14),
                  Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: const Color(0xFF81EAFF),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        'Baca Selengkapnya',
                        style: TextStyle(
                            color: Colors.cyan.shade800,
                            fontWeight: FontWeight.w500),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDivisiCard({required String imagePath}) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      clipBehavior: Clip.antiAlias,
      child: Container(
        height: 150,
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage(imagePath),
            fit: BoxFit.cover,
          ),
        ),
      ),
    );
  }
}
