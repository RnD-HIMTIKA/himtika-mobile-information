import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:himtika_mobile_information/features/calendar/presentation/pages/notification_page.dart';
import 'package:himtika_mobile_information/features/himtika/presentation/bloc/sejarah_himtika/sejarah_bloc.dart';

class SejarahScreen extends StatelessWidget {
  const SejarahScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => SejarahBloc()..add(FetchSejarahData()),
      child: Scaffold(
        backgroundColor: Colors.white,
        body: SafeArea(
          top: false,
          child: BlocBuilder<SejarahBloc, SejarahState>(
            builder: (context, state) {
              if (state.status == SejarahStatus.loading ||
                  state.status == SejarahStatus.initial) {
                return const Center(child: CircularProgressIndicator());
              }
              if (state.status == SejarahStatus.failure) {
                return const Center(child: Text('Gagal memuat data.'));
              }
              return Column(
                children: [
                  _buildTopBar(context),
                  Expanded(
                    child: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          _buildHeroImage(context, state.heroImagePath),
                          const SizedBox(height: 24),

                          // --- Judul & Deskripsi Awal ---
                          Padding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 24.0),
                            child: Column(
                              children: [
                                RichText(
                                  textAlign: TextAlign.center,
                                  text: TextSpan(
                                    style: const TextStyle(
                                        fontSize: 28,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.black,
                                        height: 1.4),
                                    children: <InlineSpan>[
                                      const TextSpan(text: 'Perjalanan\n'),
                                      WidgetSpan(
                                        alignment: PlaceholderAlignment.middle,
                                        child: ShaderMask(
                                          blendMode: BlendMode.srcIn,
                                          shaderCallback: (bounds) =>
                                              const LinearGradient(
                                            colors: [
                                              Color(0xFF006EBD),
                                              Color(0xFF0095FF)
                                            ],
                                            begin: Alignment.centerLeft,
                                            end: Alignment.centerRight,
                                          ).createShader(Rect.fromLTWH(0, 0,
                                                  bounds.width, bounds.height)),
                                          child: const Text('HIMTIKA',
                                              style: TextStyle(
                                                  fontSize: 28,
                                                  fontWeight: FontWeight.bold,
                                                  height: 1.4)),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 12),
                                Text(
                                  state.initialDescription,
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                      fontSize: 14,
                                      color: Colors.grey.shade700,
                                      height: 1.5),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 40), // Jarak sebelum timeline

                          // --- TIMELINE UTAMA (ListView) ---
                          ListView.builder(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 24.0),
                            itemCount: state.historyEntries.length,
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemBuilder: (context, index) {
                              final entry = state.historyEntries[index];
                              final isLast =
                                  index == state.historyEntries.length - 1;
                              final alignment = entry['alignment'] as String;

                              // Buat 1 set: Konten + Garis
                              return Column(
                                children: [
                                  // 1. Kotak Hijau (Konten)
                                  _buildTimelineEntry(
                                    context: context,
                                    title: entry['title'] as String,
                                    subTitle: entry['subTitle'] as String?,
                                    description:
                                        entry['description'] as String?,
                                    iconPath: entry['iconPath'] as String,
                                    alignment: alignment,
                                  ),
                                  // 2. Kotak Oranye (Garis putus2 atau Garis Akhir)
                                  if (!isLast)
                                    _buildDottedLine(alignment: alignment)
                                  else
                                    _buildDottedLineEnd(alignment: alignment),
                                ],
                              );
                            },
                          ),

                          // --- Akhir Timeline: Diresmikan! ---
                          _buildFinalTimelinePoint(
                            context: context,
                            title: 'Diresmikan!',
                            iconPath:
                                'src/features/himtika/icon/himtika.png', // Icon di akhir
                            description: state.finalDescription,
                          ),
                          const SizedBox(height: 24), // Jarak akhir
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

  // Hero Image
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

  // Widget untuk setiap entri timeline
  Widget _buildTimelineEntry({
    required BuildContext context,
    required String title,
    String? subTitle,
    String? description,
    required String iconPath,
    required String alignment,
  }) {
    final bool isImageLeft = alignment == 'left';
    final screenWidth = MediaQuery.of(context).size.width;
    final imageWidth = (screenWidth * 0.22).clamp(65.0, 110.0);

    // WIDGET IKON
    final imageWidget = SizedBox(
      width: imageWidth,
      height: imageWidth,
      child: Image.asset(
        iconPath,
        fit: BoxFit.contain,
      ),
    );

    // WIDGET TEKS
    final textWidget = Column(
      crossAxisAlignment:
          isImageLeft ? CrossAxisAlignment.start : CrossAxisAlignment.end,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 18, 
            fontWeight: FontWeight.bold, 
            color: Colors.black 
          ),
          textAlign: isImageLeft ? TextAlign.left : TextAlign.right,
        ),

        if (subTitle != null)
          ShaderMask(
            blendMode: BlendMode.srcIn,
            shaderCallback: (bounds) => const LinearGradient(
              colors: [Color(0xFF006EBD), Color(0xFF0095FF)],
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
            ).createShader(Rect.fromLTWH(0, 0, bounds.width, bounds.height)),
            child: Text(
              subTitle,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold), 
              textAlign: isImageLeft ? TextAlign.left : TextAlign.right,
            ),
          ),
        
        const SizedBox(height: 4),
        if (description != null)
          Text(
            description,
            textAlign: isImageLeft ? TextAlign.left : TextAlign.right,
            style: TextStyle(
                fontSize: 12, color: Colors.grey.shade700, height: 1.4),
          ),
      ],
    );

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          if (isImageLeft)
            SizedBox(
              width: imageWidth,
              child: imageWidget,
            ),

          if (!isImageLeft) Expanded(child: textWidget),

          const SizedBox(width: 12),

          if (isImageLeft) Expanded(child: textWidget),

          if (!isImageLeft)
            SizedBox(
              width: imageWidth,
              child: imageWidget,
            ),
        ],
      ),
    );
  }

  Widget _buildDottedLine({required String alignment}) {
    final String path = alignment == 'left'
        ? 'src/features/himtika/icon/lineLeft.png'
        : 'src/features/himtika/icon/lineRight.png';

    return Container(
      height: 220,
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: Image.asset(
        path,
        fit: BoxFit.fill,
      ),
    );
  }

  Widget _buildDottedLineEnd({required String alignment}) {
    final String path = 'src/features/himtika/icon/lineEnd.png';

    return SizedBox(
      height: 450,
      width: double.infinity,
      child: Image.asset(
        path,
        fit: BoxFit.fill,
      ),
    );
  }

  // Widget untuk poin "Diresmikan!" di akhir timeline
  Widget _buildFinalTimelinePoint({
    required BuildContext context,
    required String title,
    required String iconPath,
    required String description,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        RichText(
          text: TextSpan(
            // Style default (hitam, bold, 22)
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
            children: <InlineSpan>[
              // Bagian 1: "Dires" (hitam)
              const TextSpan(text: 'Dires'),

              // Bagian 2: "mikan" (biru gradien)
              WidgetSpan(
                alignment: PlaceholderAlignment.middle,
                child: ShaderMask(
                  blendMode: BlendMode.srcIn,
                  shaderCallback: (bounds) => const LinearGradient(
                    colors: [Color(0xFF006EBD), Color(0xFF0095FF)],
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                  ).createShader(
                      Rect.fromLTWH(0, 0, bounds.width, bounds.height)),
                  child: const Text(
                    'mikan!', // Teks yang diberi gradien
                    style: TextStyle(
                      fontSize: 22, // Samakan style
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // ICON
        SizedBox(
          width: 200,
          height: 200,
          child: Image.asset(iconPath),
        ),
        const SizedBox(height: 12),

        // 3. Deskripsi
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Text(
            description,
            textAlign: TextAlign.center,
            style: TextStyle(
                fontSize: 14, color: Colors.grey.shade700, height: 1.5),
          ),
        ),
      ],
    );
  }
}
