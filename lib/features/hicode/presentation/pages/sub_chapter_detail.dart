import 'dart:async'; // Import Timer
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
// --- Import Quill ---
import 'package:flutter_quill/flutter_quill.dart';
import 'package:flutter_quill_extensions/flutter_quill_extensions.dart';
// --------------------
import 'package:himtika_mobile_information/core/injection_container.dart';
import 'package:himtika_mobile_information/features/auth/domain/usecases/get_current_user.dart';
import 'package:himtika_mobile_information/features/hicode/presentation/bloc/sub_chapter_detail/sub_chapter_detail_bloc.dart';
import 'package:himtika_mobile_information/features/hicode/presentation/pages/information_screen.dart';
import 'package:himtika_mobile_information/features/hicode/presentation/pages/quiz_screen.dart';
import 'package:himtika_mobile_information/features/hicode/domain/usecases/update_scroll_position.dart';
import 'package:himtika_mobile_information/core/theme/app_colors.dart';

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

  QuillController? _contentController;
  bool _isControllerReady = false;
  // --- Definisikan FocusNode ---
  final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _bloc = context.read<SubChapterDetailBloc>();
    _getCurrentUser().then((user) {
      if (mounted && user != null) {
        setState(() {
          _currentUserId = user.id;
        });
        _bloc.add(FetchSubChapterData(
            subChapterId: widget.subChapterId, userId: _currentUserId!));
      } else if (mounted) {
        _bloc.add(const FetchSubChapterData(subChapterId: '', userId: ''));
      }
    });
    _scrollController.addListener(_scrollListener);
  }

  void _initializeContentController(List<dynamic> contentJson) {
    if (_contentController != null) return;

    try {
      Document doc;
      // Validasi tambahan untuk memastikan contentJson adalah List
      if (contentJson.isNotEmpty && contentJson is List) {
        doc = Document.fromJson(contentJson);
      } else {
        // Jika formatnya salah (misal Map lama yg tidak terkonversi),
        // atau list kosong, tampilkan pesan default.
        doc = Document.fromJson([
          {'insert': 'Konten belum tersedia atau format tidak didukung.\n'}
        ]);
      }

      _contentController = QuillController(
        document: doc,
        selection: const TextSelection.collapsed(offset: 0),
        readOnly: true, // Set mode baca-saja di constructor controller
      );

      if (mounted) {
        setState(() => _isControllerReady = true);
      }
      print("Konten berhasil dimuat ke QuillEditor read-only.");
    } catch (e) {
      print("Error decoding content for QuillEditor: $e");
      _contentController = QuillController.basic(); // Tanpa readOnly di config
      _contentController!.readOnly = true; // Set via setter setelah dibuat
      if (mounted) {
        setState(() => _isControllerReady = true);
        _contentController!.document.insert(
            0, 'Gagal memuat konten: Format data tidak valid. \nError: $e');
      }
    }
  }

  void _scrollListener() {
    _lastSavedScrollPosition = _scrollController.offset;
    if (!_scrollController.hasClients) return;

    final maxScroll = _scrollController.position.maxScrollExtent;
    final tolerance = 0.95;
    // Anggap tercapai jika konten tidak bisa di-scroll (maxScroll <= 0)
    final bool currentReachedBottom = (maxScroll > 0)
        ? (_scrollController.position.pixels >= maxScroll * tolerance)
        : true;

    final currentBlocState = _bloc.state;
    final bool newHasReachedBottom =
        currentBlocState.isQuizUnlocked || currentReachedBottom;

    if (currentReachedBottom && !currentBlocState.isQuizUnlocked) {
      _bloc.add(const QuizManuallyUnlocked());
    }

    if (_debounceTimer?.isActive ?? false) _debounceTimer!.cancel();
    _debounceTimer = Timer(const Duration(seconds: 2), () {
      if (mounted && _currentUserId != null) {
        _updateScrollPosition(
            widget.subChapterId, _lastSavedScrollPosition, newHasReachedBottom);
      }
    });
  }

  @override
  void dispose() {
    _scrollController.removeListener(_scrollListener);
    _debounceTimer?.cancel();

    // Dapatkan state BLoC sebelum dispose
    final currentBlocState = _bloc.state;
    final bool finalHasReachedBottom = currentBlocState
            .isQuizUnlocked || // Jika sudah unlocked
        (_scrollController.hasClients && // Atau jika mencapai bawah saat ini
            _scrollController.position.pixels >=
                _scrollController.position.maxScrollExtent * 0.95);

    if (_currentUserId != null && _lastSavedScrollPosition >= 0) {
      // Kirim status hasReachedBottom terakhir saat dispose
      _updateScrollPosition(
          widget.subChapterId, _lastSavedScrollPosition, finalHasReachedBottom);
    }

    _contentController?.dispose();
    _scrollController.dispose();
    _focusNode.dispose(); // --- Dispose FocusNode ---
    super.dispose();
  }

  // Helper untuk jump ke posisi awal
  void _jumpToInitialPosition(double position) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        final maxScroll = _scrollController.position.maxScrollExtent;
        final targetPosition =
            (position > maxScroll && maxScroll > 0) ? maxScroll : position;
        if (targetPosition >= 0) {
          _scrollController.jumpTo(targetPosition);
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: SafeArea(
        top: false,
        child: BlocConsumer<SubChapterDetailBloc, SubChapterDetailState>(
          listener: (context, state) {
            if (state.status == SubChapterDetailStatus.success) {
              // Pengecekan tipe data contentBlocks
              if (state.contentBlocks is List && _contentController == null) {
                _initializeContentController(state.contentBlocks);
              } else if (_contentController == null) {
                // Jika state.contentBlocks BUKAN List (karena error parsing di model)
                // Inisialisasi dengan pesan error
                print("Inisialisasi gagal: contentBlocks bukan List.");
                _initializeContentController([
                  {'insert': 'Error: Format data tidak valid (bukan List).\n'}
                ]);
              }
              _jumpToInitialPosition(state.lastScrollPosition);
            } else if (state.status == SubChapterDetailStatus.failure) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                    content: Text(state.errorMessage ?? 'Gagal memuat materi.'),
                    backgroundColor: Colors.red),
              );
            }
          },
          builder: (context, state) {
            // Jika loading atau initial TAPI BELUM ADA USER ID, tampilkan loading juga
            if ((state.status == SubChapterDetailStatus.loading ||
                    state.status == SubChapterDetailStatus.initial) ||
                _currentUserId == null) {
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
                        if (_currentUserId != null) {
                          context.read<SubChapterDetailBloc>().add(
                              FetchSubChapterData(
                                  subChapterId: widget.subChapterId,
                                  userId: _currentUserId!));
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
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16.0, vertical: 8.0),
                    child: !_isControllerReady || _contentController == null
                        ? const Center(child: Text('Memuat konten...'))
                        // --- PERBAIKAN PADA QUILL EDITOR ---
                        : QuillEditor(
                            controller: _contentController!,
                            scrollController: _scrollController,
                            focusNode: _focusNode,
                            config: QuillEditorConfig(
                              padding: const EdgeInsets.all(8),
                              embedBuilders:
                                  FlutterQuillEmbeds.defaultEditorBuilders(),
                            ),
                          ),
                    // ----------------------------------
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
          return _buildBottomButton(context, state, widget.subChapterId);
        },
      ),
    );
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
          icon: Image.asset('src/features/hicode/materi/kembali.png',
              width: 32, height: 32, color: Colors.white),
        ),
        IconButton(
          onPressed: () {
            Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const InformationScreen()),
            );
          },
          icon: Image.asset('src/features/hicode/materi/informasi.png',
              width: 28, height: 28, color: Colors.white),
        ),
      ],
    );
  }

  Widget _buildHeaderContent(
      {required String title,
      required String readTime,
      required String quizCount}) {
    // ... (kode ini sama seperti sebelumnya)
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title,
              style: const TextStyle(
                  color: Colors.white,
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  height: 1.2)),
          const SizedBox(height: 16),
          Row(
            children: [
              Icon(Icons.access_time,
                  color: Colors.white.withOpacity(0.8), size: 20),
              const SizedBox(width: 8),
              Text(readTime,
                  style: TextStyle(color: Colors.white.withOpacity(0.8))),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Icon(Icons.edit_note,
                  color: Colors.white.withOpacity(0.8), size: 20),
              const SizedBox(width: 8),
              Text(quizCount,
                  style: TextStyle(color: Colors.white.withOpacity(0.8))),
            ],
          ),
        ],
      ),
    );
  }

  // Modifikasi _buildBottomButton
  Widget _buildBottomButton(
      BuildContext context, SubChapterDetailState state, String chapterId) {
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
                    builder: (_) => QuizScreen(
                        quizId: chapterId, chapterTitle: chapterTitle),
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
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              // Ubah teks tombol berdasarkan state.isQuizUnlocked
              state.isQuizUnlocked
                  ? 'Kerjakan Kuis'
                  : 'Scroll ke Bawah untuk Membuka Kuis',
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
