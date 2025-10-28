import 'dart:async'; // Import Timer
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:himtika_mobile_information/core/injection_container.dart';
import 'package:himtika_mobile_information/features/auth/domain/usecases/get_current_user.dart'; // Import GetCurrentUser
import 'package:himtika_mobile_information/features/hicode/presentation/bloc/sub_chapter_detail/sub_chapter_detail_bloc.dart';
import 'package:himtika_mobile_information/features/hicode/presentation/pages/information_screen.dart';
import 'package:himtika_mobile_information/features/hicode/presentation/pages/quiz_screen.dart';
import 'package:himtika_mobile_information/features/hicode/domain/usecases/update_scroll_position.dart';
import 'package:himtika_mobile_information/core/theme/app_colors.dart';

// 1. Ubah menjadi StatefulWidget
class SubChapterDetailScreen extends StatefulWidget {
  final String subChapterId;

  const SubChapterDetailScreen({super.key, required this.subChapterId});

  @override
  State<SubChapterDetailScreen> createState() => _SubChapterDetailScreenState();
}

class _SubChapterDetailScreenState extends State<SubChapterDetailScreen> {
  final ScrollController _scrollController = ScrollController();
  Timer? _debounceTimer;
  final UpdateScrollPosition _updateScrollPosition = sl<UpdateScrollPosition>();
  final GetCurrentUser _getCurrentUser = sl<GetCurrentUser>();
  String? _currentUserId;
  double _lastSavedScrollPosition = 0.0;
  late SubChapterDetailBloc _bloc;

  @override
  void initState() {
    super.initState();
    _bloc = context.read<SubChapterDetailBloc>();
    // Ambil User ID saat init
    _getCurrentUser().then((user) {
       if (mounted && user != null) {
          setState(() {
            _currentUserId = user.id;
          });
          // Panggil FetchSubChapterData setelah user ID didapat
          context.read<SubChapterDetailBloc>().add(FetchSubChapterData(subChapterId: widget.subChapterId, userId: _currentUserId!));
        }
     });
     _scrollController.addListener(_scrollListener);
   }

  void _scrollListener() {
    _lastSavedScrollPosition = _scrollController.offset;

    // Tentukan apakah sudah mencapai bawah
    final bool currentReachedBottom = _scrollController.position.pixels >= _scrollController.position.maxScrollExtent * 0.95;

    // Dapatkan state BLoC saat ini
    final currentBlocState = _bloc.state;

    // Update hasReachedBottom HANYA JIKA belum pernah true sebelumnya
    final bool newHasReachedBottom = currentBlocState.isQuizUnlocked || currentReachedBottom;

    // Debounce untuk update scroll position
    if (_debounceTimer?.isActive ?? false) _debounceTimer!.cancel();
    _debounceTimer = Timer(const Duration(seconds: 2), () {
      if (mounted && _currentUserId != null) {
        // Kirim status newHasReachedBottom ke backend
        _updateScrollPosition(widget.subChapterId, _lastSavedScrollPosition, newHasReachedBottom);

        // Jika baru saja mencapai bawah, update state BLoC juga
        if (currentReachedBottom && !currentBlocState.isQuizUnlocked) {
           _bloc.add(const QuizManuallyUnlocked());
        }
      }
    });
  }

  @override
  void dispose() {
    _scrollController.removeListener(_scrollListener);
    _debounceTimer?.cancel(); // Batalkan timer sebelum panggil update terakhir

    // Dapatkan state BLoC sebelum dispose
    final currentBlocState = _bloc.state;
    final bool finalHasReachedBottom = currentBlocState.isQuizUnlocked || // Jika sudah unlocked
                                       (_scrollController.hasClients && // Atau jika mencapai bawah saat ini
                                       _scrollController.position.pixels >= _scrollController.position.maxScrollExtent * 0.95);

    if (_currentUserId != null && _lastSavedScrollPosition >= 0) {
       // Kirim status hasReachedBottom terakhir saat dispose
       _updateScrollPosition(widget.subChapterId, _lastSavedScrollPosition, finalHasReachedBottom);
    }
    _scrollController.dispose();
    super.dispose();
  }

  // Helper untuk jump ke posisi awal
  void _jumpToInitialPosition(double position) {
    // Gunakan addPostFrameCallback agar jump dilakukan setelah layout selesai
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.jumpTo(position);
      }
    });
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold( // Scaffold langsung menjadi root
    backgroundColor: const Color(0xFFF5F5F5),
    body: SafeArea(
      top: false,
      child: BlocConsumer<SubChapterDetailBloc, SubChapterDetailState>( // Langsung consume BLoC
        listener: (context, state) {
              // Listener untuk jump ke posisi scroll awal saat data loaded
              if (state.status == SubChapterDetailStatus.success) {
                  _jumpToInitialPosition(state.lastScrollPosition);
              } else if (state.status == SubChapterDetailStatus.failure){
                 ScaffoldMessenger.of(context).showSnackBar(
                   SnackBar(content: Text(state.errorMessage ?? 'Gagal memuat materi.'), backgroundColor: Colors.red),
                 );
              }
            },
            builder: (context, state) {
              // Jika loading atau initial TAPI BELUM ADA USER ID, tampilkan loading juga
              if ((state.status == SubChapterDetailStatus.loading || state.status == SubChapterDetailStatus.initial) || _currentUserId == null) {
                return const Center(child: CircularProgressIndicator());
              }
              // Jika state failure (setelah mencoba load)
              if (state.status == SubChapterDetailStatus.failure) {
                 // Tampilkan pesan error dan tombol retry
                 return Center(
                   child: Column(
                     mainAxisAlignment: MainAxisAlignment.center,
                     children: [
                       Text(state.errorMessage ?? 'Gagal memuat materi.'),
                       const SizedBox(height: 16),
                       ElevatedButton(
                         onPressed: () {
                           if(_currentUserId != null) {
                              context.read<SubChapterDetailBloc>().add(FetchSubChapterData(subChapterId: widget.subChapterId, userId: _currentUserId!));
                           }
                         },
                         child: const Text('Coba Lagi'),
                       )
                     ],
                   ),
                 );
              }

              // Jika success, tampilkan konten
              return Column(
                children: [
                  _buildBlueHeader(context, state),
                  Expanded(
                    // Tambahkan NotificationListener di sini
                    child: NotificationListener<ScrollNotification>(
                      onNotification: (scrollNotification) {
                        // Kita sudah handle logic di _scrollListener, jadi return false
                        return false;
                      },
                      child: ListView.builder(
                        controller: _scrollController, // Pasang controller ke ListView
                        padding: const EdgeInsets.all(24.0),
                        itemCount: state.contentBlocks.length,
                        itemBuilder: (context, index) {
                          return _buildContentBlock(state.contentBlocks[index]);
                        },
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
        bottomNavigationBar:
        BlocBuilder<SubChapterDetailBloc, SubChapterDetailState>(
          builder: (context, state) {
            if (state.status != SubChapterDetailStatus.success) {
              return const SizedBox.shrink();
            }
            // Kirim chapterId ke _buildBottomButton
            return _buildBottomButton(context, state, widget.subChapterId);
          },
        ),
      );
  }

 // --- WIDGET-WIDGET PEMBANTU --- (Tidak berubah, salin dari kode Anda sebelumnya)
 Widget _buildContentBlock(Map<String, dynamic> block) {
    final type = block['type'];
    final data = block['data'];

    switch (type) {
      case 'paragraph':
        // Pastikan data adalah String
        final text = (data is Map && data.containsKey('text')) ? data['text'] as String? ?? '' : data as String? ?? '';
        return Padding(
          padding: const EdgeInsets.only(bottom: 16.0),
          child: Text(text, style: const TextStyle(fontSize: 16, height: 1.6)),
        );
      case 'image':
        // Pastikan data adalah Map dan punya 'url'
        final imageUrl = (data is Map && data.containsKey('url')) ? data['url'] as String? : null;
        if (imageUrl == null || imageUrl.isEmpty) return const SizedBox.shrink();
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 16.0),
          child: Image.network(
            imageUrl,
            // Tambahkan error builder
            errorBuilder: (context, error, stackTrace) => Container(
              height: 100, // Beri tinggi agar tidak collapse
              color: Colors.grey[200],
              child: Center(child: Icon(Icons.broken_image, color: Colors.grey[400]))
            ),
          ),
        );
      case 'code':
        // Pastikan data adalah Map dan punya 'code'
        final codeText = (data is Map && data.containsKey('code')) ? data['code'] as String? ?? '' : data as String? ?? '';
        return Container(
          width: double.infinity, // Pastikan mengambil lebar penuh
          margin: const EdgeInsets.symmetric(vertical: 16.0),
          padding: const EdgeInsets.all(12.0),
          decoration: BoxDecoration(
            color: Colors.grey[900],
            borderRadius: BorderRadius.circular(8),
          ),
          child: SingleChildScrollView( // Agar bisa discroll horizontal jika kode panjang
             scrollDirection: Axis.horizontal,
            child: Text(
              codeText,
              style: const TextStyle(
                fontFamily: 'monospace', // Font monospace
                color: Colors.white,
                fontSize: 14, // Sesuaikan ukuran font
              )
            ),
          ),
        );
        // --- Tambahkan case lain jika ada tipe block baru (misal: header, list) ---
      default:
        // Tampilkan pesan jika tipe block tidak dikenal (untuk debugging)
        // return Text('Tipe block tidak dikenal: $type');
        return const SizedBox.shrink();
    }
  }

  Widget _buildBlueHeader(BuildContext context, SubChapterDetailState state) {
    // ... (kode ini sama seperti sebelumnya)
     return Container(
      padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top),
      decoration: BoxDecoration(
        color: AppColors.himfoBlue, // Gunakan warna global
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(30),
          bottomRight: Radius.circular(30),
        ),
        image: const DecorationImage(
          image: AssetImage('src/features/hicode/images/pattern_card.png'),
          fit: BoxFit.cover,
          opacity: 0.5,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildTopIconBar(context),
          _buildHeaderContent(
            title: state.title ?? 'Memuat...',
            readTime: state.readTime ?? '-',
            quizCount: state.quizCount ?? '-',
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildTopIconBar(BuildContext context) {
    // ... (kode ini sama seperti sebelumnya)
     return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        IconButton(
          onPressed: () => Navigator.of(context).pop(),
          icon: Image.asset('src/features/hicode/materi/kembali.png', width: 32, height: 32, color: Colors.white),
        ),
        IconButton(
          onPressed: () {
            Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const InformationScreen()),
            );
          },
          icon: Image.asset('src/features/hicode/materi/informasi.png', width: 28, height: 28, color: Colors.white),
        ),
      ],
    );
  }

  Widget _buildHeaderContent({required String title, required String readTime, required String quizCount}) {
    // ... (kode ini sama seperti sebelumnya)
     return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold, height: 1.2)),
          const SizedBox(height: 16),
          Row(
            children: [
              Icon(Icons.access_time, color: Colors.white.withOpacity(0.8), size: 20),
              const SizedBox(width: 8),
              Text(readTime, style: TextStyle(color: Colors.white.withOpacity(0.8))),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Icon(Icons.edit_note, color: Colors.white.withOpacity(0.8), size: 20),
              const SizedBox(width: 8),
              Text(quizCount, style: TextStyle(color: Colors.white.withOpacity(0.8))),
            ],
          ),
        ],
      ),
    );
  }

  // Modifikasi _buildBottomButton
  Widget _buildBottomButton(BuildContext context, SubChapterDetailState state, String chapterId) {
    final String chapterTitle = state.title ?? 'Chapter Quiz';

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: ElevatedButton(
        // Enable tombol berdasarkan state.isQuizUnlocked
        onPressed: state.isQuizUnlocked
            ? () {
                 // Navigasi ke QuizScreen dengan quizId yang benar
                 Navigator.of(context).push(
                   MaterialPageRoute(
                    builder: (_) => QuizScreen(quizId: chapterId, chapterTitle: chapterTitle),
                   ),
                 );
              }
            : null, // null akan membuat tombol disable
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 16),
          backgroundColor: AppColors.himfoBlue, // Warna global
          foregroundColor: Colors.white,
          disabledBackgroundColor: Colors.grey.shade400, // Warna saat disable
          disabledForegroundColor: Colors.grey.shade700,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              // Ubah teks tombol berdasarkan state.isQuizUnlocked
              state.isQuizUnlocked ? 'Kerjakan Kuis' : 'Scroll ke Bawah untuk Membuka Kuis',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(width: 8),
            // Tampilkan ikon panah hanya jika kuis unlocked
            if (state.isQuizUnlocked)
              const Icon(Icons.arrow_forward, color: Colors.white),
          ],
        ),
      ),
    );
  }
}