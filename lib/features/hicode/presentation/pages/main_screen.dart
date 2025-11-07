import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:himtika_mobile_information/core/injection_container.dart';
import 'package:himtika_mobile_information/core/helpers/image_optimizer.dart';
import 'package:himtika_mobile_information/features/hicode/presentation/bloc/main_screen/main_screen_bloc.dart';
import 'package:himtika_mobile_information/features/hicode/presentation/pages/chapter_detail.dart';
import 'package:himtika_mobile_information/features/hicode/presentation/pages/information_screen.dart';
import 'package:himtika_mobile_information/features/hicode/presentation/pages/leaderboard_screen.dart';
import 'package:himtika_mobile_information/features/hicode/presentation/pages/overall_exam.dart';
import 'package:himtika_mobile_information/features/hicode/domain/entities/hicode_category.dart';
import 'package:himtika_mobile_information/features/hicode/domain/entities/hicode_material.dart';
import 'package:himtika_mobile_information/core/theme/app_colors.dart';

class HicodeScreen extends StatefulWidget {
  const HicodeScreen({super.key});

  @override
  State<HicodeScreen> createState() => _HicodeScreenState();
}
// --- AKHIR PERBAIKAN 2 ---

class _HicodeScreenState extends State<HicodeScreen> {
  // Pindahkan BLoC provider ke initState agar kita bisa mengakses BLoC-nya
  late HicodeBloc _hicodeBloc;

  @override
  void initState() {
    super.initState();
    _hicodeBloc = sl<HicodeBloc>()..add(HicodeDataFetched());
  }

  // --- TAMBAHKAN FUNGSI REFRESH INI ---
  Future<void> _refreshData() async {
    _hicodeBloc.add(HicodeDataFetched());
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      // <-- Gunakan BlocProvider.value
      value: _hicodeBloc, // <-- Berikan BLoC yang sudah dibuat
      child: Scaffold(
        backgroundColor: Colors.grey[100],
        body: SafeArea(
          child: BlocBuilder<HicodeBloc, HicodeState>(
            builder: (context, state) {
              if (state.status == HicodeStatus.loading &&
                  state.categories.isEmpty) {
                // <-- Edit kondisi loading
                return const Center(child: CircularProgressIndicator());
              }
              if (state.status == HicodeStatus.failure) {
                return Center(
                    child: Text(state.errorMessage ?? 'Gagal memuat data.'));
              }

              // Tampilkan UI utama (success atau loading-refresh)
              return Stack(
                // <-- Tambahkan Stack untuk loading indicator
                children: [
                  // --- TAMBAHKAN REFRESH INDICATOR (PROBLEM 5) ---
                  RefreshIndicator(
                    onRefresh: _refreshData, // <-- Panggil fungsi refresh
                    child: SingleChildScrollView(
                      physics: const AlwaysScrollableScrollPhysics(), // <-- Pastikan bisa di-scroll
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildTopIconBar(context),
                            const SizedBox(height: 16),
                            _buildHeader(),
                            const SizedBox(height: 24),
                            const _LeaderboardCard(),
                            const SizedBox(height: 24),
                            _buildSectionTitle('Kategori'),
                            const SizedBox(height: 12),
                            _buildCategoryList(state),
                            const SizedBox(height: 24),
                            _buildSectionTitle('Pilihan Materi'),
                            const SizedBox(height: 12),
                            _buildMaterialList(state),
                            const SizedBox(height: 24),

                            // --- MODIFIKASI PANGGILAN INI (PROBLEM 4 & 6) ---
                            _buildFinalExamCard(
                              context,
                              allMaterialsComplete: state.allMaterialsComplete,
                              canTakeExamToday: state.canTakeExamToday,
                              nextExamAvailableAt: state.nextExamAvailableAt,
                              // Kirim callback untuk refresh
                              onNavigate: () => _navigateToExamAndRefresh(),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  // Tampilkan loading indicator di atas jika sedang refresh
                  if (state.status == HicodeStatus.loading &&
                      state.categories.isNotEmpty)
                    Container(
                      color: Colors.black.withOpacity(0.1),
                      child: const Center(child: CircularProgressIndicator()),
                    ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  // --- TAMBAHKAN FUNGSI INI (PROBLEM 6) ---
  void _navigateToExamAndRefresh() {
    // Navigasi ke Ujian Akhir
    Navigator.of(context)
        .push(
      MaterialPageRoute(builder: (_) => const OverallExamScreen()),
    )
        .then((_) {
      // .then() akan dieksekusi saat user KEMBALI dari OverallExamScreen/ScoreScreen
      print("Kembali ke MainScreen, memuat ulang data...");
      _refreshData();
    });
  }

  Widget _buildTopIconBar(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        IconButton(
          onPressed: () => Navigator.pop(context),
          icon: Image.asset('src/features/hicode/icon/kembali.png',
              width: 32, height: 32),
        ),
        IconButton(
          onPressed: () {
            Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const InformationScreen()),
            );
          },
          icon: Image.asset('src/features/hicode/icon/informasi.png',
              width: 28, height: 28),
        ),
      ],
    );
  }

  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.blue.shade700,
        borderRadius: BorderRadius.circular(15),
        image: const DecorationImage(
          image: AssetImage('src/features/hicode/images/pattern_card.png'),
          fit: BoxFit.contain,
          opacity: 1.0,
        ),
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Belajar Mudah\nBersama HiCode',
            style: TextStyle(
                color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 8),
          Text(
            'Mulai perjalanan kodingmu bersama kami. Panduan lengkap, materi terarah, dan dukungan setiap langkahnya.',
            style: TextStyle(color: Colors.white, fontSize: 14),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(title,
        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold));
  }

  Widget _buildCategoryList(HicodeState state) {
    return SizedBox(
      height: 120,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: state.categories.length,
        itemBuilder: (context, index) {
          return _CategoryCard(category: state.categories[index]);
        },
        separatorBuilder: (context, index) => const SizedBox(width: 16),
      ),
    );
  }

  Widget _buildMaterialList(HicodeState state) {
    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: state.materials.length,
      itemBuilder: (context, index) {
        return _MaterialCard(
          material: state.materials[index],
          index: index,
        );
      },
      separatorBuilder: (context, index) => const SizedBox(height: 16),
    );
  }

  Widget _buildFinalExamCard(
    BuildContext context, {
    required bool allMaterialsComplete,
    required bool canTakeExamToday,
    DateTime? nextExamAvailableAt,
    required VoidCallback onNavigate, // <-- Terima callback
  }) {
    // Tentukan status UI
    bool isReady = allMaterialsComplete && canTakeExamToday;
    bool isCooldown = allMaterialsComplete && !canTakeExamToday;
    bool isLocked = !allMaterialsComplete;

    // Tentukan style berdasarkan status
    Color backgroundColor;
    String imagePath;
    String title;
    Widget subtitle; // <-- Ganti jadi Widget
    Color arrowColor;
    String buttonText;
    VoidCallback? onTapAction;

    if (isReady) {
      backgroundColor = Colors.green;
      imagePath = 'src/features/hicode/images/dibuka.png';
      title = 'Yay! Ujian Akhir Siap Dimulai';
      subtitle = const Text(
        'Kamu sudah selesaikan materi, saatnya tunjukkan kemampuanmu!',
        style: TextStyle(color: Colors.white, fontSize: 12),
      );
      arrowColor = Colors.white;
      buttonText = "Kerjakan Sekarang";
      onTapAction = onNavigate; // <-- Gunakan callback
    } else if (isCooldown) {
      backgroundColor = Colors.orange.shade700; // Warna Cooldown
      imagePath = 'src/features/hicode/images/ditutup.png'; // Bisa ganti ikon jam
      title = 'Ujian Akhir dalam Cooldown';
      // Gunakan widget countdown
      subtitle = _CountdownTimer(targetTime: nextExamAvailableAt);
      arrowColor = Colors.white54;
      buttonText = "Terkunci";
      onTapAction = () {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Ujian Akhir hanya bisa diambil satu kali per minggu.'),
            backgroundColor: Colors.orange,
          ),
        );
      };
    } else {
      // isLocked
      backgroundColor = Colors.red.shade400;
      imagePath = 'src/features/hicode/images/ditutup.png';
      title = 'Yah, Ujian Belum Bisa Dibuka';
      subtitle = const Text(
        'Selesaikan semua Latihan Final di setiap materi untuk membuka!',
        style: TextStyle(color: Colors.white, fontSize: 12),
      );
      arrowColor = Colors.white54;
      buttonText = "Terkunci";
      onTapAction = () {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
                'Selesaikan semua materi terlebih dahulu untuk membuka Ujian Akhir!'),
            backgroundColor: Colors.orange,
          ),
        );
      };
    }

    return InkWell(
      onTap: onTapAction, // <-- Gunakan onTapAction dinamis
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: backgroundColor,
          // ... (sisa dekorasi, image pattern, dll tetap sama)
          borderRadius: BorderRadius.circular(15),
          image: const DecorationImage(
            image: AssetImage('src/features/hicode/images/pattern_exam.png'),
            fit: BoxFit.contain,
            opacity: 1.0,
          ),
        ),
        child: Column(
          children: [
            Row(
              children: [
                Image.asset(imagePath,
                    width: 40, height: 40, color: Colors.white),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(title,
                          style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 16)),
                      subtitle, // <-- Masukkan widget subtitle
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Align(
              alignment: Alignment.centerRight,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(buttonText,
                      style: TextStyle(
                          color: arrowColor,
                          fontWeight: FontWeight.bold,
                          fontSize: 14)),
                  const SizedBox(width: 8),
                  Icon(Icons.arrow_forward_ios, color: arrowColor, size: 14),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CountdownTimer extends StatefulWidget {
  final DateTime? targetTime;
  const _CountdownTimer({this.targetTime});

  @override
  State<_CountdownTimer> createState() => _CountdownTimerState();
}

class _CountdownTimerState extends State<_CountdownTimer> {
  Timer? _timer;
  Duration _remaining = Duration.zero;

  @override
  void initState() {
    super.initState();
    if (widget.targetTime != null) {
      _remaining = widget.targetTime!.difference(DateTime.now());
      if (_remaining.isNegative) _remaining = Duration.zero;

      _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
        if (_remaining.inSeconds > 0) {
          setState(() {
            _remaining = _remaining - const Duration(seconds: 1);
          });
        } else {
          _timer?.cancel();
          // Opsional: Panggil refresh BLoC di sini agar UI update otomatis
          // context.read<HicodeBloc>().add(HicodeDataFetched());
        }
      });
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  String _formatDuration(Duration d) {
    if (d.isNegative || d.inSeconds == 0) return "Segera...";

    final days = d.inDays;
    final hours = d.inHours.remainder(24);
    final minutes = d.inMinutes.remainder(60);
    final seconds = d.inSeconds.remainder(60);

    if (days > 0) {
      return 'Buka dalam: ${days}h ${hours}j';
    } else if (hours > 0) {
      return 'Buka dalam: ${hours}j ${minutes}m';
    } else {
      return 'Buka dalam: ${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.targetTime == null) {
      return const Text(
        'Menghitung cooldown...',
        style: TextStyle(color: Colors.white, fontSize: 12),
      );
    }
    return Text(
      _formatDuration(_remaining),
      style: const TextStyle(
          color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
    );
  }
}

// Private Widgets
class _LeaderboardCard extends StatelessWidget {
  const _LeaderboardCard();
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
      ),
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Image.asset('src/features/hicode/images/leaderboard.png',
                width: 90, fit: BoxFit.cover),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Leaderboard",
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 18)),
                      SizedBox(height: 4),
                      Text(
                          "Lihat kapabilitas yang sudah menyelesaikan tugas akhir dan meraih skor terbaik!",
                          style: TextStyle(color: Colors.grey, fontSize: 12)),
                    ],
                  ),
                  const SizedBox(height: 4),
                  SizedBox(
                    height: 24,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                              builder: (_) => const LeaderboardScreen()),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        backgroundColor: const Color(0xFF81EAFF),
                        foregroundColor: const Color(0xFF006EBD),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10)),
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                      child: const Text("Lihat Selengkapnya",
                          style: TextStyle(fontSize: 12)),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CategoryCard extends StatelessWidget {
  final HiCodeCategory category;
  const _CategoryCard({required this.category});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 85,
          height: 85,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFFE0E0E0),
            borderRadius: BorderRadius.circular(15),
          ),
          child:
              Image.network(category.iconUrl, fit: BoxFit.contain), // Menggunakan NetworkImage
        ),
        const SizedBox(height: 8),
        Text(category.name),
      ],
    );
  }
}

class _MaterialCard extends StatelessWidget {
  final HiCodeMaterial material;
  final int index;

  const _MaterialCard({required this.material, required this.index});

  @override
  Widget build(BuildContext context) {
    final Color borderColor = material.borderColor != null
        ? Color(int.parse(material.borderColor!.replaceFirst('#', '0xff')))
        : Colors.grey;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15),
          border: Border.all(color: borderColor, width: 2),
          boxShadow: [
            // Tambahkan sedikit shadow
            BoxShadow(
              color: Colors.grey.withOpacity(0.15),
              blurRadius: 8,
              offset: const Offset(0, 4),
            )
          ]),
      child: Column(
        // Konten utama dalam Column
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            // Baris untuk gambar dan info dasar
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (material.imageUrl != null)
                ClipRRect(
                  // Clip gambar agar sesuai border radius card (opsional)
                  borderRadius: BorderRadius.circular(8),
                  child: Image.network(
                    ImageOptimizer.getOptimizedUrl(material.imageUrl,
                        width: 200, quality: 75),
                    width: 82,
                    height: 82,
                    fit: BoxFit.cover, // Gunakan cover agar gambar mengisi area
                    // Tambahkan error builder
                    errorBuilder: (context, error, stackTrace) => Container(
                        width: 82,
                        height: 82,
                        color: Colors.grey[200],
                        child: Icon(Icons.image_not_supported,
                            color: Colors.grey[400])),
                  ),
                ),
              const SizedBox(width: 16),
              Expanded(
                // Teks mengambil sisa ruang
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(material.title,
                        style: const TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(Icons.book_outlined,
                            size: 16, color: Colors.grey[600]),
                        const SizedBox(width: 8),
                        // Tampilkan progress teks
                        Text(
                          '${material.completedChapters}/${material.totalChapters} Chapter Selesai',
                          style:
                              TextStyle(color: Colors.grey[600], fontSize: 13),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6), // Jarak sebelum progress bar
                    // Tampilkan progress bar HANYA JIKA ADA CHAPTERS
                    if (material.totalChapters > 0)
                      ClipRRect(
                        // Clip progress bar agar ujungnya rounded
                        borderRadius: BorderRadius.circular(10),
                        child: LinearProgressIndicator(
                          value:
                              material.completedChapters / material.totalChapters,
                          backgroundColor: Colors.grey[300],
                          valueColor:
                              AlwaysStoppedAnimation<Color>(borderColor),
                          minHeight: 6,
                        ),
                      )
                    else // Tampilkan placeholder jika tidak ada chapter
                      Container(
                        height: 6,
                        decoration: BoxDecoration(
                          color: Colors.grey[200],
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16), // Jarak sebelum tombol
          // Tombol Pelajari Sekarang
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                    builder: (_) => MaterialDetailScreen(materialId: material.id)),
              );
            },
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              backgroundColor:
                  AppColors.himfoAccent.withOpacity(0.8), // Gunakan warna aksen
              foregroundColor:
                  AppColors.himfoDarkBlue, // Warna teks lebih gelap
              elevation: 0,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('Pelajari Sekarang',
                    style:
                        TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                SizedBox(width: 4),
                Icon(Icons.arrow_forward_ios, size: 12),
              ],
            ),
          ),
        ],
      ),
    );
  }
}