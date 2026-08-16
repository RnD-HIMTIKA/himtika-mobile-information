import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:himtika_mobile_information/features/calendar/presentation/pages/notification_page.dart';
import 'package:himtika_mobile_information/features/himtika/presentation/pages/sejarah_screen.dart'; 
import 'package:himtika_mobile_information/features/himtika/presentation/bloc/about_himtika/about_himtika_bloc.dart';

class AboutHimtikaScreen extends StatelessWidget {
  const AboutHimtikaScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // 2. Bungkus Scaffold dengan BlocProvider
    return BlocProvider(
      create: (context) => AboutHimtikaBloc()..add(FetchAboutData()),
      child: Scaffold(
        backgroundColor: Colors.white, // Latar belakang putih
        body: SafeArea(
          top: false,
          // 3. Gunakan BlocBuilder untuk membangun UI berdasarkan state
          child: BlocBuilder<AboutHimtikaBloc, AboutHimtikaState>(
            builder: (context, state) {
              // 4. Tampilkan loading indicator
              if (state.status == AboutHimtikaStatus.loading) {
                return const Center(child: CircularProgressIndicator());
              }

              // 5. Tampilkan konten jika data sukses dimuat
              if (state.status == AboutHimtikaStatus.success) {
                return Column(
                  children: [
                    _buildTopBar(context),
                    Expanded(
                      child: SingleChildScrollView(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // 6. Ambil data 'heroImagePath' dari state
                            _buildHeroImage(context, state.heroImagePath),
                            const SizedBox(height: 24),

                            // Section: Apa itu HIMTIKA?
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 24.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  RichText(
                                    textAlign: TextAlign.center,
                                    text: TextSpan(
                                      style: const TextStyle(
                                          fontSize: 30,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.black),
                                      children: <InlineSpan>[
                                        const TextSpan(text: 'Apa itu '),
                                        WidgetSpan(
                                          alignment:
                                              PlaceholderAlignment.middle,
                                          child: ShaderMask(
                                            blendMode: BlendMode.srcIn,
                                            shaderCallback: (bounds) =>
                                                const LinearGradient(
                                              colors: [
                                                Color(0xFF006EBD),
                                                Color(0xFF0095FF),
                                              ],
                                              begin: Alignment.centerLeft,
                                              end: Alignment.centerRight,
                                            ).createShader(
                                              Rect.fromLTWH(0, 0, bounds.width,
                                                  bounds.height),
                                            ),
                                            child: const Text(
                                              'HIMTIKA?',
                                              style: TextStyle(
                                                fontSize: 30,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.only(top: 8.0),
                                    child: Text(
                                      // 7. Ambil data 'aboutParagraph' dari state
                                      state.aboutParagraph,
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                          fontSize: 14,
                                          color: Colors.grey.shade700,
                                          height: 1.5),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 24),

                            // Section: Visi & Misi
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 16.0),
                              // 8. Kirim 'state' ke method
                              child: _buildVisiMisiSection(state),
                            ),
                            const SizedBox(height: 24),

                            // Section: Makna Logo
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 24.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Makna Logo HIMTIKA',
                                    style: TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.black),
                                  ),
                                  const SizedBox(height: 16),
                                  // 9. Ganti list statis dengan ListView.builder
                                  ListView.builder(
                                    padding: EdgeInsets.zero,
                                    itemCount: state.logoMeanings.length,
                                    shrinkWrap: true,
                                    physics:
                                        const NeverScrollableScrollPhysics(),
                                    itemBuilder: (context, index) {
                                      final logo = state.logoMeanings[index];
                                      return _buildLogoMeaningRow(
                                        logo['icon']!,
                                        logo['title']!,
                                        logo['description']!,
                                      );
                                    },
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 24),

                            // Section: Sejarah HIMTIKA Card
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 16.0),
                              child: _buildSejarahCard(context),
                            ),
                            const SizedBox(height: 24),
                          ],
                        ),
                      ),
                    ),
                  ],
                );
              }
              // Tampilkan jika status 'failure'
              return const Center(child: Text('Gagal memuat data.'));
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
            Expanded(
              child: Text(
                'HIMTIKA',
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

  // 11. Ubah _buildVisiMisiSection untuk menerima state
  Widget _buildVisiMisiSection(AboutHimtikaState state) {
    const TextStyle cardTitleStyle = TextStyle(
        fontSize: 24, fontWeight: FontWeight.bold, color: Colors.black);

    final textGradient = const LinearGradient(
      colors: [Color(0xFF006EBD), Color(0xFF0095FF)],
      begin: Alignment.centerLeft,
      end: Alignment.centerRight,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Visi & Misi HIMTIKA',
          style: TextStyle(
              fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black),
        ),
        const SizedBox(height: 16),
        // Container Visi
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.blue.shade50,
            borderRadius: BorderRadius.circular(15),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.14),
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
              Center(
                child: RichText(
                  text: TextSpan(
                    style: cardTitleStyle,
                    children: <InlineSpan>[
                      const TextSpan(text: 'Visi '),
                      WidgetSpan(
                        alignment: PlaceholderAlignment.middle,
                        child: ShaderMask(
                          blendMode: BlendMode.srcIn,
                          shaderCallback: (bounds) => textGradient.createShader(
                            Rect.fromLTWH(0, 0, bounds.width, bounds.height),
                          ),
                          child: const Text('HIMTIKA', style: cardTitleStyle),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 8),
              ShaderMask(
                blendMode: BlendMode.srcIn,
                shaderCallback: (bounds) => textGradient.createShader(
                  Rect.fromLTWH(0, 0, bounds.width, bounds.height),
                ),
                // 12. Ambil data Visi dari state
                child: Text(
                  state.visiParagraph,
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 14, height: 1.4),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        // Container Misi
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.blue.shade50,
            borderRadius: BorderRadius.circular(15),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.14),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
            image: const DecorationImage(
              image: AssetImage(
                  'src/features/himtika/icon/pattern.png'),
              fit: BoxFit.none,
              repeat: ImageRepeat.repeat,
              scale: 2.5,
              opacity: 0.8,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              RichText(
                text: TextSpan(
                  style: cardTitleStyle,
                  children: <InlineSpan>[
                    const TextSpan(text: 'Misi '),
                    WidgetSpan(
                      alignment: PlaceholderAlignment.middle,
                      child: ShaderMask(
                        blendMode: BlendMode.srcIn,
                        shaderCallback: (bounds) => textGradient.createShader(
                          Rect.fromLTWH(0, 0, bounds.width, bounds.height),
                        ),
                        child: const Text('HIMTIKA', style: cardTitleStyle),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              ShaderMask(
                blendMode: BlendMode.srcIn,
                shaderCallback: (bounds) => textGradient.createShader(
                  Rect.fromLTWH(0, 0, bounds.width, bounds.height),
                ),
                // 13. Ambil data Misi dari state
                child: Text(
                  state.misiParagraph,
                  style: const TextStyle(fontSize: 14, height: 1.4),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // Widget untuk setiap baris makna logo
  Widget _buildLogoMeaningRow(String iconPath, String title, String description) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12.0), // Jarak antar kartu
      padding: const EdgeInsets.all(16.0), // Padding di dalam kartu
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15), // Sudut melengkung
        boxShadow: [
          // 2. Tambahkan shadow
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: IntrinsicHeight(
        // 3. Gunakan IntrinsicHeight untuk menyamakan tinggi
        child: Row(
          crossAxisAlignment:
              CrossAxisAlignment.stretch,
          children: [
            SizedBox(
              width: 57, // Lebar tetap untuk ikon
              child: Center(
                // 5. Pusatkan ikon secara vertikal
                child: Image.asset(iconPath, width: 57, height: 57),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment
                    .center,
                children: [
                  Text(title,
                      style: const TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4),
                  Text(
                    description,
                    style: TextStyle(
                        fontSize: 12, color: Colors.grey.shade600, height: 1.4),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Widget Card Sejarah (salin dari himtika_screen.dart jika perlu)
  Widget _buildSejarahCard(BuildContext context) {
    return Container(
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
                    .min, 
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
                  ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) => const SejarahScreen()),
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
}
