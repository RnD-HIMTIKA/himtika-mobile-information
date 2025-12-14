import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:himtika_mobile_information/features/himtika/presentation/bloc/proker_himtika/proker_bloc.dart';
import 'package:himtika_mobile_information/features/calendar/presentation/pages/notification_page.dart';

// UBAH KE STATEFUL WIDGET
// Agar bisa menyimpan state "mana kartu yang sedang terbuka"
class ProgramKerjaScreen extends StatefulWidget {
  const ProgramKerjaScreen({super.key});

  @override
  State<ProgramKerjaScreen> createState() => _ProgramKerjaScreenState();
}

class _ProgramKerjaScreenState extends State<ProgramKerjaScreen> {
  // Variabel untuk melacak judul program mana yang sedang terbuka.
  // Jika null, berarti semua tertutup.
  String? _expandedProgramTitle;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => ProkerBloc()..add(FetchProkerData()),
      child: Scaffold(
        backgroundColor: Colors.white,
        body: SafeArea(
          top: false,
          child: BlocBuilder<ProkerBloc, ProkerState>(
            builder: (context, state) {
              if (state.status == ProkerStatus.loading ||
                  state.status == ProkerStatus.initial) {
                return const Center(child: CircularProgressIndicator());
              }
              if (state.status == ProkerStatus.failure) {
                return const Center(child: Text('Gagal memuat data.'));
              }

              return Column(
                children: [
                  _buildTopBar(context),
                  Expanded(
                    child: CustomScrollView(
                      slivers: [
                        SliverToBoxAdapter(
                          child: Column(
                            children: [
                              _buildHeroImage(state.heroImagePath),
                              const SizedBox(height: 24),
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 24.0),
                                child: Column(
                                  children: [
                                    _buildHeaderTitle(),
                                    const SizedBox(height: 12),
                                    Text(
                                      state.description,
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                          fontSize: 14,
                                          color: Colors.grey.shade700,
                                          height: 1.5),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 24),
                            ],
                          ),
                        ),

                        // B. Filter Kategori (STICKY / MENEMPEL)
                        SliverPersistentHeader(
                          pinned: true, // Ini yang bikin sticky
                          delegate: _StickyFilterDelegate(
                            child: _buildCategoryFilter(context, state),
                          ),
                        ),

                        // C. Jarak Spasi (Sliver)
                        const SliverToBoxAdapter(child: SizedBox(height: 20)),

                        // D. List Program Kerja (Animasi Geser Halus)
                        SliverToBoxAdapter(
                          child: AnimatedSwitcher(
                            duration: const Duration(milliseconds: 800),
                            switchInCurve: Curves.easeInOut,
                            switchOutCurve: Curves.easeInOut,
                            layoutBuilder: (currentChild, previousChildren) {
                              return Stack(
                                alignment: Alignment.topCenter,
                                children: [
                                  ...previousChildren,
                                  if (currentChild != null) currentChild,
                                ],
                              );
                            },
                            transitionBuilder: (child, animation) {
                              const beginOffset = Offset(0.15, 0.0);
                              return FadeTransition(
                                opacity: animation,
                                child: SlideTransition(
                                  position: Tween<Offset>(
                                    begin: beginOffset,
                                    end: Offset.zero,
                                  ).animate(animation),
                                  child: child,
                                ),
                              );
                            },
                            // Karena ListView ada di dalam SliverToBoxAdapter,
                            // kita gunakan shrinkWrap: true dan physics mati
                            child: ListView.builder(
                              key: ValueKey<String>(state.selectedCategory),
                              padding: EdgeInsets.zero,
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: state.filteredProkerList.length,
                              itemBuilder: (context, index) {
                                final deptData =
                                    state.filteredProkerList[index];
                                return _buildDepartmentSection(deptData);
                              },
                            ),
                          ),
                        ),

                        // E. Spasi Bawah
                        const SliverToBoxAdapter(child: SizedBox(height: 40)),
                      ],
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
  Widget _buildDepartmentSection(Map<String, dynamic> deptData) {
    final String deptNameRaw = deptData['dept'];
    final String deptImagePath = deptData['deptImage'] ?? '';

    final parts = deptNameRaw.split('Dept. ');
    final deptName = parts.length > 1 ? parts[1] : deptNameRaw;

    final List<dynamic> programs = deptData['programs'];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12),
      child: Column(
        children: [
          // Header Dept
          Container(
            width: double.infinity,
            height: 80,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            alignment: Alignment.center,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(30),
              image: DecorationImage(
                image: AssetImage(deptImagePath),
                fit: BoxFit.cover,
              ),
            ),
            child: RichText(
              textAlign: TextAlign.center,
              text: TextSpan(
                style: const TextStyle(
                    color: Colors.black, fontSize: 18, height: 1.2),
                children: [
                  const TextSpan(
                      text: 'Dept. ',
                      style: TextStyle(fontWeight: FontWeight.bold)),
                  WidgetSpan(
                    alignment: PlaceholderAlignment.middle,
                    child: ShaderMask(
                      blendMode: BlendMode.srcIn,
                      shaderCallback: (bounds) => const LinearGradient(
                        colors: [Color(0xFF006EBD), Color(0xFF0095FF)],
                        begin: Alignment.centerLeft,
                        end: Alignment.centerRight,
                      ).createShader(
                        Rect.fromLTWH(0, 0, bounds.width, bounds.height),
                      ),
                      child: Text(
                        deptName,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // List Program Kerja
          ListView.separated(
            padding: EdgeInsets.zero,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: programs.length,
            itemBuilder: (context, index) {
              final program = programs[index];
              final String title = program['title'];

              // PERUBAHAN 2: Logika Accordion
              // Cek apakah kartu ini yang harus dibuka
              final bool isExpanded = _expandedProgramTitle == title;

              return ProgramCardItem(
                title: title,
                imagePath: program['image'],
                description: program['description'] ?? 'Belum ada deskripsi.',
                isExpanded: isExpanded, // Kirim status ke child
                onTap: () {
                  // Update state di Parent (Screen)
                  setState(() {
                    if (isExpanded) {
                      // Kalau diklik lagi saat terbuka, tutup.
                      _expandedProgramTitle = null;
                    } else {
                      // Kalau tertutup, buka ini (dan otomatis yang lain ketutup)
                      _expandedProgramTitle = title;
                    }
                  });
                },
              );
            },
            separatorBuilder: (_, __) => const SizedBox(height: 16),
          ),
        ],
      ),
    );
  }

  Widget _buildHeaderTitle() {
    return RichText(
      textAlign: TextAlign.center,
      text: TextSpan(
        style: const TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.bold,
          color: Colors.black,
          height: 1.4,
        ),
        children: <InlineSpan>[
          const TextSpan(text: 'Apa itu '),
          WidgetSpan(
            alignment: PlaceholderAlignment.middle,
            child: _gradientText('Program'),
          ),
          const TextSpan(text: '\n'),
          WidgetSpan(
            alignment: PlaceholderAlignment.middle,
            child: _gradientText('Kerja?'),
          ),
        ],
      ),
    );
  }

  Widget _gradientText(String text) {
    return ShaderMask(
      blendMode: BlendMode.srcIn,
      shaderCallback: (bounds) => const LinearGradient(
        colors: [Color(0xFF006EBD), Color(0xFF0095FF)],
        begin: Alignment.centerLeft,
        end: Alignment.centerRight,
      ).createShader(Rect.fromLTWH(0, 0, bounds.width, bounds.height)),
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: const TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.bold,
          height: 1.4,
        ),
      ),
    );
  }

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
            const Text(
              'Program Kerja',
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
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

  Widget _buildHeroImage(String imagePath) {
    return Container(
      width: double.infinity,
      height: 300,
      decoration: const BoxDecoration(
        color: Colors.blue,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(50),
          bottomRight: Radius.circular(50),
        ),
      ),
      child: Center(
        child: imagePath.isNotEmpty
            ? Image.asset(
                imagePath,
                width: 220,
                height: 220,
                fit: BoxFit.contain,
              )
            : const SizedBox(),
      ),
    );
  }

  Widget _buildCategoryFilter(BuildContext context, ProkerState state) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(
          vertical: 10), // Padding atas bawah saat sticky
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Row(
          children: state.categories.map((category) {
            final isSelected = state.selectedCategory == category;
            return Padding(
              padding: const EdgeInsets.only(right: 12.0),
              child: InkWell(
                onTap: () {
                  context
                      .read<ProkerBloc>()
                      .add(ChangeProkerCategory(category));
                },
                borderRadius: BorderRadius.circular(20),
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  decoration: BoxDecoration(
                    color: isSelected ? const Color(0xFF007BFF) : Colors.white,
                    borderRadius: BorderRadius.circular(30),
                    border: Border.all(
                      color: isSelected
                          ? Colors.transparent
                          : Colors.grey.shade300,
                    ),
                    boxShadow: isSelected
                        ? [
                            BoxShadow(
                                color: Colors.blue.withOpacity(0.3),
                                blurRadius: 8,
                                offset: const Offset(0, 4))
                          ]
                        : null,
                  ),
                  child: Text(
                    category,
                    style: TextStyle(
                      color: isSelected ? Colors.white : Colors.grey.shade600,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
}

// =======================================================
// KELAS PEMBANTU
// =======================================================
class _StickyFilterDelegate extends SliverPersistentHeaderDelegate {
  final Widget child;

  _StickyFilterDelegate({required this.child});

  @override
  // Tinggi minimum header (saat sticky)
  double get minExtent => 70.0;

  @override
  // Tinggi maksimum header (saat awal)
  double get maxExtent => 70.0;

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    // Penting: Beri warna background agar konten di bawahnya tidak terlihat tembus
    return Container(
      color: Colors.white,
      alignment: Alignment.center,
      child: child,
    );
  }

  @override
  bool shouldRebuild(covariant _StickyFilterDelegate oldDelegate) {
    // Rebuild jika child berubah (misal kategori terpilih ganti warna)
    return true;
  }
}

class ProgramCardItem extends StatelessWidget {
  final String title;
  final String imagePath;
  final String description;
  final bool isExpanded; // Menerima status dari parent
  final VoidCallback onTap; // Callback saat diklik

  const ProgramCardItem({
    super.key,
    required this.title,
    required this.imagePath,
    required this.description,
    required this.isExpanded,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          )
        ],
      ),
      child: Column(
        children: [
          // --- Bagian Header Card (Gambar & Judul) ---
          InkWell(
            onTap: onTap, // Panggil fungsi dari parent
            borderRadius: BorderRadius.circular(15),
            child: Container(
              height: 140,
              width: double.infinity,
              clipBehavior: Clip.antiAlias,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(15),
              ),
              child: Stack(
                children: [
                  // Background Image
                  Positioned.fill(
                    child: Image.asset(
                      imagePath,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(color: Colors.grey.shade300);
                      },
                    ),
                  ),
                  // Overlay Gradient
                  Positioned.fill(
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.bottomCenter,
                          end: Alignment.topCenter,
                          colors: [
                            Colors.black.withOpacity(0.8),
                            Colors.transparent,
                          ],
                        ),
                      ),
                    ),
                  ),
                  // Teks Judul
                  Positioned(
                    bottom: 16,
                    left: 16,
                    right: 60,
                    child: Text(
                      title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  // Tombol Panah (Animasi Rotasi)
                  Positioned(
                    bottom: 16,
                    right: 16,
                    child: AnimatedRotation(
                      turns: isExpanded
                          ? 0.5
                          : 0.0, // Rotasi berdasarkan props dari parent
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeInOutBack,
                      child: Container(
                        width: 32,
                        height: 32,
                        decoration: const BoxDecoration(
                          color: Color(0xFF0095FF),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.keyboard_arrow_down,
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // --- Bagian Dropdown (Deskripsi dengan AnimatedSize) ---
          AnimatedSize(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
            alignment: Alignment.topCenter,
            child: isExpanded
                ? Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Divider(height: 1),
                        const SizedBox(height: 12),
                        Text(
                          "Deskripsi Kegiatan:",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.blue.shade800,
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          description,
                          style: TextStyle(
                            color: Colors.grey.shade800,
                            fontSize: 13,
                            height: 1.5,
                          ),
                        ),
                      ],
                    ),
                  )
                : const SizedBox.shrink(),
          ),
        ],
      ),
    );
  }
}
