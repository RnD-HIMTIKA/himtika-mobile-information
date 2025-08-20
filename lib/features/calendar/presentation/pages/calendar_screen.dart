import 'package:flutter/material.dart';
import 'package:himtika_mobile_information/features/home/presentation/pages/home.dart';
import 'schedule_detail_screen.dart';

// ===========================================================================
// HALAMAN 1: CALENDAR SCREEN (DENGAN TATA LETAK TOMBOL DINAMIS)
// ===========================================================================
class CalendarScreen extends StatelessWidget {
  const CalendarScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent, // Warna biru tua sebagai dasar
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leadingWidth: 72, // kasih ruang lebih
        leading: Padding(
          padding: EdgeInsets.only(
            top: MediaQuery.of(context).padding.top + 25, // tambahin offset biar pas
            left: 4,
          ),
          child: IconButton(
            padding: EdgeInsets.zero, // biar nggak ada jarak tambahan
            icon: Image.asset(
              "src/features/login&register/images/arrow_back.png", 
              color: Color(0xFF31b7fe),           
              width: 32,
              height: 32,
            ),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const HomePage()),
              );
            },
          ),
        ),
      ),
      extendBodyBehindAppBar: true,
      body: Stack(
        children: const [
          // LAYER 1: Background Biru dengan Teks dan Ilustrasi
          _BackgroundContent(),

          // LAYER 2: Panel Putih yang Bisa Digeser
          _WorkspaceSheet(),
        ],
      ),
    );
  }
}

// ===========================================================================
// WIDGET-WIDGET LOKAL UNTUK CALENDAR SCREEN
// ===========================================================================
class _BackgroundContent extends StatelessWidget {
  const _BackgroundContent();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF333C66), Color(0xFF2D365E)],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
        image: DecorationImage(
          image: AssetImage('src/features/calendar/images/pattern.png'),
          fit: BoxFit.cover,
          opacity: 0.5,
        ),
      ),
      alignment: Alignment.topCenter,
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: MediaQuery.of(context).padding.top + 30),
            const Text(
              'Plan Your Days, Own Your Time',
              style: TextStyle(
                color: Colors.white,
                fontSize: 32,
                fontWeight: FontWeight.bold,
                height: 1.2,
              ),
            ),
            const SizedBox(height: 18),
            Text(
              'Easily create, manage, and share your schedule—stay organized and never miss a thing.',
              style: TextStyle(
                color: Colors.white.withValues(alpha:0.8),
                fontSize: 18,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 40),
            Center(
              child: Image.asset('src/features/calendar/images/assets.png'),
            ),
          ],
        ),
      ),
    );
  }
}


// ===========================================================================
// PANEL WORKSPACE (DRAGGABLE + STICKY HEADER)
// ===========================================================================
class _WorkspaceSheet extends StatelessWidget {
  const _WorkspaceSheet();

  @override
  Widget build(BuildContext context) {
    // Data Dummy
    final dummyWorkspaces = [
      {'id': '1', 'title': 'Kuliah', 'description': 'Jadwal mata kuliah kelas 4E Informatika'},
      {'id': '2', 'title': 'Deadline', 'description': 'Deadline Tugas kuliah'},
      {'id': '3', 'title': 'Milestone', 'description': 'Target selesai project'},
    ];

    return DraggableScrollableSheet(
      initialChildSize: 0.2,
      minChildSize: 0.2,
      maxChildSize: 0.9,
      builder: (BuildContext context, ScrollController scrollController) {        
        return ClipRRect(
          borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
          child: Container(
            color: Colors.white,
            child: LayoutBuilder(
              builder: (context, constraints) {
                final isExpanded = constraints.maxHeight >
                    MediaQuery.of(context).size.height * 0.3;

                return Stack(
                  children: [
                    // CustomScrollView + SliverPersistentHeader agar header sticky
                    CustomScrollView(
                      controller: scrollController,
                      slivers: [
                        // HEADER STICKY: saat pinned/overlaps → background solid (putih)
                        SliverPersistentHeader(
                          pinned: true,
                          delegate: _StickyHeaderDelegate(
                            minHeight: 92, // tinggi tetap supaya stabil
                            maxHeight: 92,
                            child: Container(
                              // Konten header + handle
                              padding: const EdgeInsets.only(top: 12, bottom: 8),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  // handle
                                  Container(
                                    width: 40,
                                    height: 4,
                                    decoration: BoxDecoration(
                                      color: Colors.grey[300],
                                      borderRadius: BorderRadius.circular(2),
                                    ),
                                  ),
                                  const SizedBox(height: 12),
                                  const Text(
                                    "Workspace Kamu",
                                    style: TextStyle(
                                      fontSize: 22,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const Icon(Icons.keyboard_arrow_down, color: Colors.grey),
                                ],
                              ),
                            ),
                          ),
                        ),

                        // ISI LIST (muncul saat panel dibuka) — pakai SliverList agar tidak overflow
                        if (isExpanded && dummyWorkspaces.isEmpty)
                          SliverPadding(
                            padding: const EdgeInsets.symmetric(horizontal: 24),
                            sliver: SliverToBoxAdapter(
                              child: Padding(
                                padding: const EdgeInsets.symmetric(vertical: 40.0),
                                child: Center(
                                  child: Text(
                                    "Kamu belum punya workspace",
                                    style: TextStyle(color: Colors.grey, fontSize: 16),
                                  ),
                                ),
                              ),
                            ),
                          )
                        else if (isExpanded)
                          SliverPadding(
                            padding: const EdgeInsets.symmetric(horizontal: 24),
                            sliver: SliverList.separated(
                              itemCount: dummyWorkspaces.length,
                              separatorBuilder: (_, __) => const SizedBox(height: 16),
                              itemBuilder: (context, index) {
                                final ws = dummyWorkspaces[index];
                                return _WorkspaceCard(
                                  workspaceId: ws['id'] as String,
                                  title: ws['title'] as String,
                                  description: ws['description'] as String,
                                );
                              },
                            ),
                          )
                        else
                          const SliverToBoxAdapter(child: SizedBox.shrink()),

                        // Spacer bawah agar tidak ketutup FAB
                        const SliverToBoxAdapter(child: SizedBox(height: 100)),
                      ],
                    ),

                    // TOMBOL TAMBAH (muncul hanya saat panel dibuka)
                    if (isExpanded)
                      Positioned(
                        bottom: 30,
                        left: 24,
                        right: 24,
                        child: Center(
                          child: FloatingActionButton(
                            onPressed: () => showDialog(
                              context: context,
                              builder: (context) => const _CreateWorkspaceDialog(),
                            ),
                            backgroundColor: Colors.blue.shade600,
                            foregroundColor: Colors.white,
                            shape: const CircleBorder(),
                            elevation: 10,
                            child: const Icon(Icons.add, size: 32),
                          ),
                        ),
                      ),
                  ],
                );
              },
            ),
          ),
        );
      },
    );
  }
}

// ===========================================================================
// DELEGATE UNTUK STICKY HEADER (ubah background saat pinned/overlaps)
// ===========================================================================
class _StickyHeaderDelegate extends SliverPersistentHeaderDelegate {
  final double minHeight;
  final double maxHeight;
  final Widget child;

  _StickyHeaderDelegate({
    required this.minHeight,
    required this.maxHeight,
    required this.child,
  });

  @override
  double get minExtent => minHeight;

  @override
  double get maxExtent => maxHeight;

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    final bool pinned = shrinkOffset > 0 || overlapsContent;

    return Container(
      decoration: BoxDecoration(
        color: pinned ? Colors.white : Colors.transparent,
        boxShadow: pinned
            ? [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.06),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ]
            : null,
      ),
      alignment: Alignment.center,
      child: child,
    );
  }

  @override
  bool shouldRebuild(_StickyHeaderDelegate oldDelegate) {
    return maxHeight != oldDelegate.maxHeight ||
        minHeight != oldDelegate.minHeight ||
        child != oldDelegate.child;
  }
}

// ===========================================================================
// KARTU WORKSPACE
// ===========================================================================
class _WorkspaceCard extends StatelessWidget {
  final String workspaceId;
  final String title;
  final String description;

  const _WorkspaceCard({
    required this.workspaceId,
    required this.title,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey.shade200,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha:0.2), // warna shadow
            offset: const Offset(0, 4), // posisi shadow (0 = center, 4 ke bawah)
            blurRadius: 6, // seberapa blur
            spreadRadius: 0, // seberapa luas
          ),
        ],
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ScheduleDetailScreen(
                workspaceId: workspaceId,
                workspaceTitle: title,
              ),
            ),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    title,
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                  ),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.blue.shade600,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.calendar_today, color: Colors.white, size: 24),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              LayoutBuilder(
                builder: (context, constraints) {
                  // kurangi lebar icon + padding dari total width
                  double maxWidth = constraints.maxWidth - 48 - 8; 
                  return ConstrainedBox(
                    constraints: BoxConstraints(maxWidth: maxWidth),
                    child: Text(
                      description,
                      style: TextStyle(color: Colors.black, fontSize: 14),
                      softWrap: true,
                    ),
                  );
                },
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  const CircleAvatar(radius: 12, backgroundColor: Colors.orange),
                  const SizedBox(width: 4),
                  const CircleAvatar(radius: 12, backgroundColor: Colors.green),
                  const SizedBox(width: 4),
                  const CircleAvatar(radius: 12, backgroundColor: Colors.purple),
                  const SizedBox(width: 8),
                  Text(
                    "3 Orang bersama anda",
                    style: TextStyle(color: Colors.grey.shade700, fontSize: 12),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ===========================================================================
// DIALOG BUAT WORKSPACE
// ===========================================================================
class _CreateWorkspaceDialog extends StatelessWidget {
  const _CreateWorkspaceDialog();

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      insetPadding: const EdgeInsets.all(24),
      title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text('Buat Workspace', style: TextStyle(fontWeight: FontWeight.bold)),
          IconButton(icon: const Icon(Icons.close), onPressed: () => Navigator.of(context).pop()),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Judul', style: TextStyle(fontWeight: FontWeight.w500)),
          const SizedBox(height: 8),
          TextField(
            decoration: InputDecoration(
              hintText: 'Masukkan Judul Workspace',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.grey.shade300),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Colors.blue),
              ),
            ),
          ),
          const SizedBox(height: 16),
          const Text('Deskripsi', style: TextStyle(fontWeight: FontWeight.w500)),
          const SizedBox(height: 8),
          TextField(
            decoration: InputDecoration(
              hintText: 'Masukkan Deskripsi Workspace',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.grey.shade300),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Colors.blue),
              ),
            ),
          ),
        ],
      ),
      actionsPadding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
      actions: [
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: () => Navigator.of(context).pop(),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue.shade600,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              elevation: 0,
            ),
            child: const Text('Buat Workspace'),
          ),
        ),
      ],
    );
  }
}
