import 'package:flutter/material.dart';
// Ganti path ini jika file schedule_detail_screen.dart ada di lokasi lain
import 'schedule_detail_screen.dart';

// ===========================================================================
// HALAMAN 1: CALENDAR SCREEN (DENGAN TATA LETAK TOMBOL DINAMIS)
// ===========================================================================
class CalendarScreen extends StatelessWidget {
  const CalendarScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D47A1), // Warna biru tua sebagai dasar
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: CircleAvatar(
          backgroundColor: Colors.transparent,
          child: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () {},
          ),
        ),
      ),
      extendBodyBehindAppBar: true,
      body: Stack(
        children: [
          // LAYER 1: Background Biru dengan Teks dan Ilustrasi
          const _BackgroundContent(),

          // LAYER 2: Panel Putih yang Bisa Digeser
          const _WorkspaceSheet(),
        ],
      ),
    );
  }
}

// ===========================================================================
// WIDGET-WIDGET LOKAL UNTUK CALENDAR SCREEN
// ===========================================================================

// -- Widget untuk Konten Background --
class _BackgroundContent extends StatelessWidget {
  const _BackgroundContent();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF0D47A1), Color(0xFF1976D2)],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      alignment: Alignment.topCenter,
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: MediaQuery.of(context).padding.top + 70),
            const Text(
              'Plan Your Days, Own Your Time',
              style: TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold, height: 1.2),
            ),
            const SizedBox(height: 12),
            Text(
              'Easily create, manage, and share your schedule—stay organized and never miss a thing.',
              style: TextStyle(color: Colors.white.withOpacity(0.8), fontSize: 16, height: 1.5),
            ),
            const SizedBox(height: 40),
            // Ganti dengan Image.asset('assets/your_illustration.png') jika sudah ada
            const Center(child: Icon(Icons.image_outlined, size: 200, color: Colors.white24)),
          ],
        ),
      ),
    );
  }
}

// -- Widget untuk Panel Workspace Draggable --
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
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
          ),
          // --- PERBAIKAN UTAMA: Menggunakan LayoutBuilder ---
          // Untuk mendeteksi tinggi panel dan mengubah tata letak
          child: LayoutBuilder(
            builder: (context, constraints) {
              // Tentukan ambang batas tinggi untuk mengubah layout
              // (misalnya 30% dari tinggi layar)
              final isExpanded = constraints.maxHeight > MediaQuery.of(context).size.height * 0.3;

              return Stack(
                children: [
                  // KONTEN YANG BISA DI-SCROLL
                  ListView(
                    controller: scrollController,
                    padding: const EdgeInsets.all(24),
                    children: [
                      Center(child: Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(2)))),
                      const SizedBox(height: 16),
                      const Center(child: Text("Workspace Kamu", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold))),
                      const Center(child: Icon(Icons.keyboard_arrow_down, color: Colors.grey)),
                      const SizedBox(height: 24),
                      
                      // Tampilkan daftar hanya jika panel digeser ke atas
                      if (isExpanded)
                        if (dummyWorkspaces.isEmpty)
                          const Padding(
                            padding: EdgeInsets.symmetric(vertical: 40.0),
                            child: Center(child: Text("Kamu belum punya workspace", style: TextStyle(color: Colors.grey, fontSize: 16))),
                          )
                        else
                          ...dummyWorkspaces.map((ws) {
                            return _WorkspaceCard(
                              workspaceId: ws['id'] as String,
                              title: ws['title'] as String,
                              description: ws['description'] as String,
                            );
                          }).toList(),
                      
                      // Beri ruang kosong di bawah agar tidak tertutup tombol
                      if (isExpanded) const SizedBox(height: 80),
                    ],
                  ),

                  // TOMBOL TAMBAH (hanya muncul saat panel digeser ke atas)
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
                          shape: const CircleBorder(),
                          child: const Icon(Icons.add, size: 32),
                        ),
                      ),
                    ),
                ],
              );
            },
          ),
        );
      },
    );
  }
}

// -- Widget untuk Kartu Workspace --
class _WorkspaceCard extends StatelessWidget {
  final String workspaceId;
  final String title;
  final String description;

  const _WorkspaceCard({required this.workspaceId, required this.title, required this.description});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      shadowColor: Colors.grey.withOpacity(0.2),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      margin: const EdgeInsets.only(bottom: 16),
      child: InkWell(
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
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(color: Colors.blue.shade600, borderRadius: BorderRadius.circular(12)),
                    child: const Icon(Icons.calendar_today, color: Colors.white, size: 24),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(description, style: TextStyle(color: Colors.grey.shade600, fontSize: 14)),
              const SizedBox(height: 16),
              Row(
                children: [
                  const CircleAvatar(radius: 12, backgroundColor: Colors.orange),
                  const CircleAvatar(radius: 12, backgroundColor: Colors.green),
                  const CircleAvatar(radius: 12, backgroundColor: Colors.purple),
                  const SizedBox(width: 8),
                  Text("3 Orang bersama anda", style: TextStyle(color: Colors.grey.shade700, fontSize: 12)),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// -- Widget untuk Dialog Buat Workspace --
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
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.shade300)),
              focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Colors.blue)),
            ),
          ),
          const SizedBox(height: 16),
          const Text('Deskripsi', style: TextStyle(fontWeight: FontWeight.w500)),
          const SizedBox(height: 8),
          TextField(
            decoration: InputDecoration(
              hintText: 'Masukkan Deskripsi Workspace',
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.shade300)),
              focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Colors.blue)),
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