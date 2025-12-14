import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:page_flip/page_flip.dart';

import 'package:himtika_mobile_information/features/calendar/presentation/pages/notification_page.dart';
import 'package:himtika_mobile_information/features/himtika/presentation/bloc/grand_design/grand_design_bloc.dart';

class GrandDesignScreen extends StatefulWidget {
  const GrandDesignScreen({super.key});

  @override
  State<GrandDesignScreen> createState() => _GrandDesignScreenState();
}

class _GrandDesignScreenState extends State<GrandDesignScreen> {
  bool isReading = false;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => GrandDesignBloc()..add(LoadGrandDesignBook()),
      child: Scaffold(
        backgroundColor: Colors.white,
        body: SafeArea(
          top: false,
          child: BlocBuilder<GrandDesignBloc, GrandDesignState>(
            builder: (context, state) {
              if (state is GrandDesignLoading) {
                return const Center(child: CircularProgressIndicator());
              }

              if (state is GrandDesignLoaded) {
                return isReading
                    ? _buildBookReader(state.pages)
                    : _buildPreview(context, state.pages.first);
              }

              if (state is GrandDesignError) {
                return Center(child: Text(state.message));
              }

              return const SizedBox.shrink();
            },
          ),
        ),
      ),
    );
  }

  // ================= PREVIEW MODE =================
  Widget _buildPreview(BuildContext context, String coverPath) {
    return Column(
      children: [
        _buildTopBar(context),
        _buildHeroImage('src/features/himtika/icon/himtika.png'),
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(16, 24, 16, 32),
            child: Column(
              children: [
                _buildDescription(),
                const SizedBox(height: 16),
                GestureDetector(
                  onTap: () => setState(() => isReading = true),
                  child: _buildPoster(context, coverPath),
                ),
                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ],
    );
  }


  // ================= READER MODE =================
  Widget _buildBookReader(List<String> pages) {
    return Stack(
      children: [
        PageFlipWidget(
          backgroundColor: Colors.grey.shade200,
          children: pages
              .map(
                (path) => Container(
                  color: Colors.white,
                  child: Image.asset(
                    path,
                    fit: BoxFit.contain,
                  ),
                ),
              )
              .toList(),
        ),
        Positioned(
          top: 16,
          left: 16,
          child: IconButton(
            icon: const Icon(Icons.close, size: 28),
            onPressed: () => setState(() => isReading = false),
          ),
        ),
      ],
    );
  }

  // ================= TOP BAR =================
  Widget _buildTopBar(BuildContext context) {
    return Container(
      color: Colors.blue,
      padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            IconButton(
              onPressed: () => Navigator.pop(context),
              icon: Image.asset(
                'src/features/hicode/icon/kembali.png',
                width: 32,
                height: 32,
                color: Colors.white,
              ),
            ),
            const Text(
              'Grand Design',
              style: TextStyle(
                color: Colors.white,
                fontSize: 26,
                fontWeight: FontWeight.bold,
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

  // ================= HERO IMAGE =================
  Widget _buildHeroImage(String imagePath) {
    return Container(
      width: double.infinity,
      height: 280,
      decoration: const BoxDecoration(
        color: Colors.blue,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(50),
          bottomRight: Radius.circular(50),
        ),
      ),
      child: Center(
        child: Image.asset(
          imagePath,
          width: 240,
          height: 240,
          fit: BoxFit.contain,
        ),
      ),
    );
  }

  // ================= DESKRIPSI =================
  Widget _buildDescription() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: double.infinity,
            child: RichText(
              textAlign: TextAlign.center,
              text: TextSpan(
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
                children: <InlineSpan>[
                  const TextSpan(text: 'Apa itu '),
                  WidgetSpan(
                    alignment: PlaceholderAlignment.middle,
                    child: ShaderMask(
                      blendMode: BlendMode.srcIn,
                      shaderCallback: (bounds) => const LinearGradient(
                        colors: [
                          Color(0xFF006EBD),
                          Color(0xFF0095FF),
                        ],
                      ).createShader(
                        Rect.fromLTWH(0, 0, bounds.width, bounds.height),
                      ),
                      child: const Text(
                        'Grand Design?',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Kerangka kerja atau rancangan strategis jangka panjang yang komprehensif, menyeluruh, dan visioner untuk menjadi acuan arah kebijakan dan pengembangan organisasi.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade700,
              height: 1.6,
            ),
          ),
          const SizedBox(height: 24),
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              'Grand Design HIMTIKA',
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 20,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ================= POSTER =================
  Widget _buildPoster(BuildContext context, String coverPath) {
    final width = MediaQuery.of(context).size.width;
    final posterWidth = width > 600 ? 360.0 : width * 0.85;

    return Container(
      width: posterWidth,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.25),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Image.asset(coverPath, fit: BoxFit.cover),
    );
  }
}
