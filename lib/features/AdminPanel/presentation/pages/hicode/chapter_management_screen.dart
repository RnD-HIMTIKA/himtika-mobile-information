import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:himtika_mobile_information/core/injection_container.dart';
import 'package:himtika_mobile_information/features/AdminPanel/domain/entities/hicode_chapter.dart';
import 'package:himtika_mobile_information/features/AdminPanel/presentation/bloc/chapter_management/chapter_management_bloc.dart';
import 'package:himtika_mobile_information/features/AdminPanel/presentation/pages/hicode/widgets/modify_chapter_dialog.dart'; // <-- Buat file ini nanti

class ChapterManagementScreen extends StatelessWidget {
  final String materialId;
  final String materialTitle;

  const ChapterManagementScreen({
    super.key,
    required this.materialId,
    required this.materialTitle,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<ChapterManagementBloc>()..add(LoadChapters(materialId)),
      child: Scaffold(
        appBar: AppBar(
          title: Text('Kelola Chapter - $materialTitle'),
          backgroundColor: const Color(0xFF0175C8),
          foregroundColor: Colors.white,
        ),
        body: BlocConsumer<ChapterManagementBloc, ChapterManagementState>(
          listener: (context, state) {
            if (state.status == ChapterManagementStatus.failure) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.errorMessage ?? 'Terjadi kesalahan'),
                  backgroundColor: Colors.red,
                ),
              );
            }
          },
          builder: (context, state) {
            if (state.status == ChapterManagementStatus.loading && state.chapters.isEmpty) {
              return const Center(child: CircularProgressIndicator());
            }
            if (state.chapters.isEmpty) {
              return const Center(
                child: Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Text('Belum ada chapter. Tekan tombol + untuk menambah.', textAlign: TextAlign.center),
                ),
              );
            }

            // Tampilkan daftar chapter
            return ListView.builder(
              padding: const EdgeInsets.all(16.0),
              itemCount: state.chapters.length,
              itemBuilder: (context, index) {
                final chapter = state.chapters[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: ListTile(
                    leading: CircleAvatar(child: Text('${chapter.order}')), // Tampilkan urutan
                    title: Text(chapter.title),
                    trailing: Row(
                       mainAxisSize: MainAxisSize.min,
                       children: [
                         IconButton(
                           icon: Icon(Icons.edit, color: Colors.blue.shade700),
                           onPressed: () {
                             // TODO: Implementasi edit dialog
                              _showModifyChapterDialog(context, materialId, chapterToEdit: chapter);
                           },
                         ),
                          IconButton(
                           icon: Icon(Icons.delete_outline, color: Colors.red.shade700),
                           onPressed: () {
                             // TODO: Implementasi delete confirmation
                           },
                         ),
                       ],
                    ),
                    onTap: () {
                      // TODO: Implementasi edit dialog
                       _showModifyChapterDialog(context, materialId, chapterToEdit: chapter);
                    },
                  ),
                );
              },
            );
          },
        ),
        // Tombol Tambah Chapter
        floatingActionButton: Builder(
          builder: (context) => FloatingActionButton(
            onPressed: () {
              _showModifyChapterDialog(context, materialId);
            },
            backgroundColor: const Color(0xFF0175C8),
            child: const Icon(Icons.add, color: Colors.white),
          ),
        ),
      ),
    );
  }

  // Fungsi helper untuk menampilkan dialog
  void _showModifyChapterDialog(BuildContext context, String materialId, {HiCodeChapter? chapterToEdit}) {
     showDialog(
       context: context,
       barrierDismissible: false,
       builder: (dialogContext) {
         return BlocProvider.value(
           // Teruskan Bloc yang sudah ada
           value: BlocProvider.of<ChapterManagementBloc>(context),
           child: ModifyChapterDialog(
               materialId: materialId,
               chapterToEdit: chapterToEdit,
           ),
         );
       },
     );
  }
}