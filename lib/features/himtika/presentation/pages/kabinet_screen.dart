import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
// Sesuaikan path import
import 'package:himtika_mobile_information/features/calendar/presentation/pages/notification_page.dart';
import 'package:himtika_mobile_information/features/himtika/presentation/bloc/kabinet_himtika/kabinet_bloc.dart';
import 'package:himtika_mobile_information/features/himtika/presentation/pages/sejarah_screen.dart';

class KabinetScreen extends StatelessWidget {
  const KabinetScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => KabinetBloc()..add(FetchKabinetData()),
      child: Scaffold(
        backgroundColor: Colors.white,
        body: SafeArea(
          top: false,
          child: BlocBuilder<KabinetBloc, KabinetState>(
            builder: (context, state) {
              if (state.status == KabinetStatus.loading ||
                  state.heroLogoPath.isEmpty) {
                return const Center(child: CircularProgressIndicator());
              }
              if (state.status == KabinetStatus.failure) {
                return const Center(child: Text('Gagal memuat data.'));
              }

              return Column(
                children: [
                  _buildTopBar(context),
                  Expanded(
                    child: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildHeroImage(context, state.heroLogoPath),
                          const SizedBox(height: 24),
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
              icon: Image.asset(
                  'src/features/hicode/icon/kembali.png', // Sesuaikan path
                  width: 32,
                  height: 32,
                  color: Colors.white),
            ),
            Expanded(
              child: Text(
                'Kabinet',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                ),
                overflow: TextOverflow.ellipsis,
              ),
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

  // Hero Image (Konsisten dengan about_himtika_screen)
  Widget _buildHeroImage(BuildContext context, String imagePath) {
    final screenHeight = MediaQuery.of(context).size.height;
    final heroHeight = (screenHeight * 0.32).clamp(180.0, 300.0);
    return Container(
      width: double.infinity,
      height: heroHeight,
      decoration: const BoxDecoration(
        color: Colors.blue,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(50),
          bottomRight: Radius.circular(50),
        ),
      ),
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Image.asset(
            imagePath,
            width: heroHeight * 0.9,
            height: heroHeight * 0.9,
            fit: BoxFit.contain,
          ),
        ),
      ),
    );
  }

  // Konten utama
  Widget _buildContent(BuildContext context, KabinetState state) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // --- Section Apa itu Sinergis ---
          Center(
            child: RichText(
              textAlign: TextAlign.center,
              text: TextSpan(
                style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.black),
                children: <InlineSpan>[
                  const TextSpan(text: 'Apa itu '),
                  WidgetSpan(
                    alignment: PlaceholderAlignment.middle,
                    child: ShaderMask(
                      blendMode: BlendMode.srcIn,
                      shaderCallback: (bounds) => const LinearGradient(
                        colors: [
                          Color(0xFF4D2A7C),
                          Color(0xFF9C4895)
                        ], // Gradient SINERGIS
                        begin: Alignment.topCenter, end: Alignment.bottomCenter,
                      ).createShader(
                          Rect.fromLTWH(0, 0, bounds.width, bounds.height)),
                      child: const Text('Sinergis?',
                          style: TextStyle(
                              fontSize: 24, fontWeight: FontWeight.bold)),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            state.aboutSinergis,
            textAlign: TextAlign.center,
            style: TextStyle(
                color: Colors.grey.shade700, fontSize: 14, height: 1.5),
          ),
          const SizedBox(height: 26),

          // --- Section Kabinet ---
          const Text('Nilai Kabinet',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          ListView.separated(
            padding: EdgeInsets.zero,
            itemCount: state.kabinetCards.length,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemBuilder: (context, index) {
              final card = state.kabinetCards[index];
              return _buildKabinetInfoCard(
                title: card['title']!,
                description: card['description']!,
              );
            },
            separatorBuilder: (context, index) => const SizedBox(height: 16),
          ),
          const SizedBox(height: 26),

          // --- Section Makna Logo ---
          const Text('Makna Logo Kabinet',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          ListView.separated(
            padding: EdgeInsets.zero,
            itemCount: state.logoMeanings.length,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemBuilder: (context, index) {
              final logo = state.logoMeanings[index];
              return _buildLogoMeaningRow(
                logo['icon']!,
                logo['title']!,
                logo['description']!,
              );
            },
            separatorBuilder: (context, index) => const SizedBox(height: 16),
          ),
          const SizedBox(height: 24),

          _buildSejarahCard(context),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildKabinetInfoCard({
    required String title,
    required String description,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
        image: const DecorationImage(
          image: AssetImage('src/features/himtika/icon/pattern.png'),
          fit: BoxFit.none,
          repeat: ImageRepeat.repeat,
          scale: 2.0,
          opacity: 1.0,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.blue,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            description,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.grey.shade800,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }

  // Kartu untuk Makna Logo
  Widget _buildLogoMeaningRow(
      String iconPath, String title, String description) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12.0),
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment:
            CrossAxisAlignment.center,
        children: [
          Image.asset(
            iconPath,
            width: 200,
            height: 100,
            fit: BoxFit.contain,
          ),

          const SizedBox(height: 12),
          Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
              color: Colors.black,
            ),
          ),

          const SizedBox(height: 8),
          Text(
            description,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 13,
              color: Colors.grey.shade600,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }

  // Kartu Sejarah
  Widget _buildSejarahCard(BuildContext context) {
    return InkWell(
      // 2. Bungkus dengan InkWell
      onTap: () {
        // 3. Tambahkan aksi onTap
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
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
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
                                Rect.fromLTWH(
                                    0, 0, bounds.width, bounds.height),
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
}
