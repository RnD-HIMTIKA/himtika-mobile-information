import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:himtika_mobile_information/features/calendar/presentation/pages/notification_page.dart';

import 'package:himtika_mobile_information/features/himtika/presentation/bloc/himtika_bloc.dart';

class HimtikaScreen extends StatelessWidget {
  const HimtikaScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => HimtikaBloc()..add(FetchHimtikaData()),
      child: Scaffold(
        backgroundColor: const Color(0xFFF5F5F5),
        body: SafeArea(
          top: false, // Kita atur padding manual
          child: BlocBuilder<HimtikaBloc, HimtikaState>(
            builder: (context, state) {
              if (state.status == HimtikaStatus.loading) {
                return const Center(child: CircularProgressIndicator());
              }

              return Column(
                children: [
                  // Lapisan 1: Top Bar yang Sticky (tetap di atas)
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
              icon: const Icon(Icons.notifications_outlined, color: Colors.white, size: 28),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBlueHeader(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        color: Colors.blue,
      ),
      child: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.center,
        children: [
          // Gambar yang berada di perpotongan
          Positioned(
            top: 20,
            child: Container(
              width: MediaQuery.of(context).size.width * 0.9,
              padding: const EdgeInsets.all(20.0),
              decoration: BoxDecoration(
                color: Colors.transparent, 
                borderRadius: BorderRadius.circular(20),
                image: const DecorationImage(
                  image: AssetImage('src/features/himtika/images/card_hero.png'), 
                  fit: BoxFit.cover,
                  opacity: 1.0, // Buat gambar lebih transparan
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 10,
                    offset: const Offset(0, 5),
                  )
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Yuk! Kenali HIMTIKA\nlebih dekat',
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.black),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Mau tahu lebih banyak\ntentang HIMTIKA?',
                    style: TextStyle(color: Colors.grey),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      // TODO: Navigasi
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.cyan.shade100,
                      foregroundColor: Colors.cyan.shade800,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                    child: const Text('Baca Selengkapnya'),
                  )
                ],
              ),
            ),
          ),
          // SizedBox untuk memberi ruang pada kartu yang menonjol
          const SizedBox(height: 120),
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
          const SizedBox(height: 110),
          const Text('Kabinet Saat Ini', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          _buildKabinetCard(),
          const SizedBox(height: 28),
          const Text('Bagian Penting dalam HIMTIKA', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          ListView.separated(
            padding: EdgeInsets.zero,
            itemCount: state.importantParts.length,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemBuilder: (context, index) {
              final part = state.importantParts[index];
              return _buildDivisiCard(
                imagePath: part['imagePath']!,
              );
            },
            separatorBuilder: (context, index) => const SizedBox(height: 16),
          )
        ],
      ),
    );
  }

  Widget _buildKabinetCard() {
    return Card(
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
              width: 100,
              height: 100,
            ),
            const SizedBox(width: 16),

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
                            fontSize: 22,
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
                            child: Icon(Icons.star, color: Colors.amber, size: 14),
                          ),
                          Expanded(
                            child: Text(
                              'Sinergi, Inovatif, Eksplorasi, Responsif\nGeneralis, Sistematis',
                              style: TextStyle(color: Colors.grey, fontSize: 12),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const Align(
                    alignment: Alignment.bottomRight,
                    child: Icon(Icons.arrow_forward_ios, color: Colors.blue, size: 20),
                  ),
                ],
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