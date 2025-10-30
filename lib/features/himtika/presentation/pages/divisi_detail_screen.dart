import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:himtika_mobile_information/features/calendar/presentation/pages/notification_page.dart';
import 'package:himtika_mobile_information/features/himtika/presentation/bloc/divisi_detail/divisi_detail_bloc.dart';

class DivisiDetailScreen extends StatelessWidget {
  final String divisiId;
  const DivisiDetailScreen({super.key, required this.divisiId});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) =>
          DivisiDetailBloc()..add(FetchDivisiData(divisiId: divisiId)),
      child: Scaffold(
        backgroundColor: const Color(0xFFF5F5F5),
        body: SafeArea(
          top: false, // Kita atur padding manual
          child: BlocBuilder<DivisiDetailBloc, DivisiDetailState>(
            builder: (context, state) {
              if (state.status == DivisiDetailStatus.loading ||
                  state.title == null) {
                return const Center(child: CircularProgressIndicator());
              }

              // Struktur Column: TopBar (Sticky) + Konten (Scrollable)
              return Column(
                children: [
                  // --- Lapisan 1: Top Bar (Sticky & Konsisten) ---
                  _buildTopBar(context),

                  // --- Lapisan 2: Sisa konten yang bisa di-scroll ---
                  Expanded(
                    child: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // --- Hero Image (Konsisten) ---
                          _buildHeroImage(state.heroLogoPath!),
                          const SizedBox(height: 24),

                          // --- Konten Putih ---
                          _buildContent(context, state),
                          const SizedBox(height: 24), // Jarak di akhir scroll
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
            const Text(
              'DIVISI', // Judul di tengah (SESUAI FIGMA)
              style: TextStyle(
                color: Colors.white,
                fontSize: 30,
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
        child: Image.asset(
          imagePath, // Menggunakan path dinamis dari BLoC
          width: 300,
          height: 300,
          fit: BoxFit.contain,
        ),
      ),
    );
  }

  // _buildContent dengan logika 'if' yang sudah benar
  Widget _buildContent(BuildContext context, DivisiDetailState state) {
    // Ambil judul dari state, gunakan fallback jika null
    String regularTitle = state.title ?? '';
    String gradientTitle = state.gradientTitle ?? '';

    // Jika gradientTitle kosong, gunakan judul utama (untuk divisi lama)
    if (gradientTitle.isEmpty && state.title != null) {
      regularTitle = 'Divisi\n';
      gradientTitle = state.title!;
    } else {
      regularTitle = '$regularTitle\n';
    }

    return Padding(
      padding:
          const EdgeInsets.symmetric(horizontal: 24.0), 
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Judul Divisi
          Center(
            child: RichText(
              textAlign: TextAlign.center,
              text: TextSpan(
                style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.black),
                children: <InlineSpan>[
                  TextSpan(text: regularTitle),
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
                      child: Text(gradientTitle,
                          style: const TextStyle(
                              fontSize: 24, fontWeight: FontWeight.bold)),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 8),

          // Deskripsi (Hanya tampil jika tidak null)
          if (state.description != null)
            Text(
              state.description!,
              textAlign: TextAlign.center,
              style: TextStyle(
                  color: Colors.grey.shade700, fontSize: 14, height: 1.5),
            ),
          if (state.description != null) const SizedBox(height: 24),

          // Ketua Divisi (Hanya tampil jika tidak null)
          if (state.divisionHead != null)
            _buildMemberCard(
              context: context,
              imagePath: state.divisionHead!['image']!,
              position: state.divisionHead!['position']!,
              name: state.divisionHead!['name']!,
            ),
          if (state.divisionHead != null) const SizedBox(height: 24),

          // Column untuk Departemen/Anggota
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Judul Section (Hanya tampil jika BUKAN SC)
              if (divisiId != 'Steering Committee')
                Text('Departemen di ${state.title!}',
                    style: const TextStyle(
                        fontSize: 20, fontWeight: FontWeight.bold)),
              if (divisiId != 'Steering Committee') const SizedBox(height: 16),

              // ListView untuk 'departments'
              ListView.separated(
                padding: EdgeInsets.zero,
                itemCount: state.departments.length,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemBuilder: (context, index) {
                  final department = state.departments[index];
                  final title = department['title'] as String?;
                  final description = department['description'] as String?;
                  final head =
                      department['departmentHead'] as Map<String, String>?;
                  final members =
                      List<Map<String, String>>.from(department['members']);

                  return _buildDepartmentSection(
                    context: context,
                    title: title,
                    description: description,
                    head: head,
                    members: members,
                  );
                },
                separatorBuilder: (context, index) =>
                    const SizedBox(height: 16),
              )
            ],
          )
        ],
      ),
    );
  }

  // _buildDepartmentSection
  Widget _buildDepartmentSection({
    required BuildContext context,
    String? title,
    String? description,
    Map<String, String>? head,
    required List<Map<String, String>> members,
  }) {
    const DecorationImage patternImage = DecorationImage(
      image:
          AssetImage('src/features/himtika/icon/pattern.png'), // Sesuaikan path
      fit: BoxFit.none,
      repeat: ImageRepeat.repeat,
      scale: 2.0,
      opacity: 1.0,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // --- Kartu Deskripsi (Hanya tampil jika title & desc ada) ---
        if (title != null && description != null)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.blue.shade50,
              borderRadius: BorderRadius.circular(15),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.08),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
              image: patternImage, // Terapkan pattern
            ),
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.center, // Pastikan Column rata tengah
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
                  style: TextStyle(color: Colors.grey.shade800, height: 1.4),
                ),
              ],
            ),
          ),

        // Jarak
        if ((title != null || description != null) &&
            (head != null || members.isNotEmpty))
          const SizedBox(height: 16),

        // --- Kartu Ketua Departemen (Hanya tampil jika head ada) ---
        if (head != null)
          _buildMemberCard(
            context: context,
            imagePath: head['image']!,
            position: head['position']!,
            name: head['name']!,
          ),

        // Jarak
        if (head != null && members.isNotEmpty) const SizedBox(height: 16),

        // --- ListView Anggota (Hanya tampil jika members ada) ---
        if (members.isNotEmpty)
          ListView.separated(
            padding: EdgeInsets.zero,
            itemCount: members.length,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemBuilder: (context, index) {
              final member = members[index];
              return _buildMemberCard(
                context: context,
                imagePath: member['image']!,
                position: member['position']!,
                name: member['name']!,
              );
            },
            separatorBuilder: (context, index) => const SizedBox(height: 16),
          ),
      ],
    );
  }

  // Widget untuk kartu anggota (tidak berubah)
  Widget _buildMemberCard({
    required BuildContext context,
    required String imagePath,
    required String position,
    required String name,
  }) {
    // Ambil lebar layar untuk perhitungan
    final screenWidth = MediaQuery.of(context).size.width;

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      clipBehavior: Clip.antiAlias,
      child: Container(
        width: screenWidth * 0.8, // Contoh: 80% dari lebar layar
        height: 220,
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage(imagePath),
            fit: BoxFit.cover,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(position,
                  style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 22)),
              Text(name,
                  style: const TextStyle(
                      fontWeight: FontWeight.w500,
                      color: Colors.white70,
                      fontSize: 18)),
            ],
          ),
        ),
      ),
    );
  }
}
