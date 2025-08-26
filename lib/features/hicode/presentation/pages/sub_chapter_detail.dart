import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:himtika_mobile_information/core/injection_container.dart';
import 'package:himtika_mobile_information/features/hicode/presentation/bloc/sub_chapter_detail/sub_chapter_detail_bloc.dart';
import 'package:himtika_mobile_information/features/hicode/presentation/pages/information_screen.dart';
import 'package:himtika_mobile_information/features/hicode/presentation/pages/quiz_screen.dart';

class SubChapterDetailScreen extends StatelessWidget {
  final String subChapterId;

  const SubChapterDetailScreen({super.key, required this.subChapterId});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => sl<SubChapterDetailBloc>()
        ..add(FetchSubChapterData(subChapterId: subChapterId)),
      child: Scaffold(
        backgroundColor: const Color(0xFFF5F5F5),
        body: SafeArea(
          top: false, // Agar konten bisa masuk ke area status bar
          child: BlocBuilder<SubChapterDetailBloc, SubChapterDetailState>(
            builder: (context, state) {
              if (state.status == SubChapterDetailStatus.loading || state.status == SubChapterDetailStatus.initial) {
                return const Center(child: CircularProgressIndicator());
              }
              if (state.status == SubChapterDetailStatus.failure) {
                return Center(child: Text(state.errorMessage ?? 'Gagal memuat materi.'));
              }

              return Column(
                children: [
                  _buildBlueHeader(context, state),
                  Expanded(
                    child: ListView.builder(
                      padding: const EdgeInsets.all(24.0),
                      itemCount: state.contentBlocks.length,
                      itemBuilder: (context, index) {
                        return _buildContentBlock(state.contentBlocks[index]);
                      },
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
            return _buildBottomButton(context, state);
          },
        ),
      ),
    );
  }

  // WIDGET-WIDGET PEMBANTU
  Widget _buildContentBlock(Map<String, dynamic> block) {
    final type = block['type'];

    switch (type) {
      case 'paragraph':
        return Padding(
          padding: const EdgeInsets.only(bottom: 16.0),
          child: Text(block['data'] ?? '', style: const TextStyle(fontSize: 16, height: 1.6)),
        );
      case 'image':
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 16.0),
          child: Image.network(block['url'] ?? ''),
        );
      case 'code':
        return Container(
          margin: const EdgeInsets.symmetric(vertical: 16.0),
          padding: const EdgeInsets.all(12.0),
          decoration: BoxDecoration(
            color: Colors.grey[900], // Warna gelap untuk blok kode
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            block['data'] ?? '', 
            style: const TextStyle(
              fontFamily: 'monospace',
              color: Colors.white,
            )
          ),
        );
      default:
        return const SizedBox.shrink();
    }
  }
  
  Widget _buildBlueHeader(BuildContext context, SubChapterDetailState state) {
    return Container(
      padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top),
      decoration: const BoxDecoration(
        color: Colors.blue,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(30),
          bottomRight: Radius.circular(30),
        ),
        image: DecorationImage(
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
            title: state.title!,
            readTime: state.readTime!,
            quizCount: state.quizCount!,
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildTopIconBar(BuildContext context) {
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
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold, height: 1.2)),
          const SizedBox(height: 16),
          Row(
            children: [
              const Icon(Icons.access_time, color: Colors.white70, size: 20),
              const SizedBox(width: 8),
              Text(readTime, style: const TextStyle(color: Colors.white70)),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              const Icon(Icons.edit_note, color: Colors.white70, size: 20),
              const SizedBox(width: 8),
              Text(quizCount, style: const TextStyle(color: Colors.white70)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBottomButton(BuildContext context, SubChapterDetailState state) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: ElevatedButton(
        onPressed: state.isQuizUnlocked
            ? () {
                final quizId = state.title!.replaceAll('\n', ' ');
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => QuizScreen(quizId: quizId)),
                );
              }
            : null,
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 16),
          backgroundColor: Colors.blue,
          foregroundColor: Colors.white,
          disabledBackgroundColor: Colors.grey,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              state.isQuizUnlocked ? 'Kerjakan Kuis' : 'Selesaikan Membaca Dahulu',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(width: 8),
            const Icon(Icons.arrow_forward, color: Colors.white),
          ],
        ),
      ),
    );
  }
}