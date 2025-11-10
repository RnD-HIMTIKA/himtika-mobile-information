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
            if (state.status == ChapterManagementStatus.loading &&
                state.chapters.isEmpty) {
              return const Center(child: CircularProgressIndicator());
            }
            if (state.chapters.isEmpty) {
              return const Center(
                child: Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Text(
                      'Belum ada chapter. Tekan tombol + untuk menambah.',
                      textAlign: TextAlign.center),
                ),
              );
            }

            // Tampilkan daftar chapter
            return ReorderableListView.builder(
              padding: const EdgeInsets.all(16.0),
              itemCount: state.chapters.length,
              
              itemBuilder: (context, index) {
                final chapter = state.chapters[index];
                
                return Card(
                  key: ValueKey(chapter.id), 
                  margin: const EdgeInsets.only(bottom: 12),
                  child: ListTile(
                    leading: ReorderableDragStartListener(
                      index: index,
                      // Nonaktifkan drag saat BLoC sedang sibuk
                      enabled: state.status == ChapterManagementStatus.success,
                      child: const Icon(Icons.drag_handle, color: Colors.grey),
                    ),
                    // Tampilkan urutan visual (index + 1)
                    title: Text(chapter.title),
                    subtitle: Text('Urutan di User: ${chapter.order}'),
                    
                    trailing: Row(
                       mainAxisSize: MainAxisSize.min,
                       children: [
                         IconButton(
                           icon: Icon(Icons.edit, color: Colors.blue.shade700),
                           // Nonaktifkan tombol saat BLoC sibuk
                           onPressed: state.status == ChapterManagementStatus.success ? () {
                              _showModifyChapterDialog(context, materialId, chapterToEdit: chapter);
                           } : null,
                         ),
                          IconButton(
                           icon: Icon(Icons.delete_outline, color: Colors.red.shade700),
                           // Nonaktifkan tombol saat BLoC sibuk
                           onPressed: state.status == ChapterManagementStatus.success ? () {
                             _showDeleteConfirmationDialog(context, chapter);
                           } : null,
                         ),
                       ],
                    ),
                    onTap: state.status == ChapterManagementStatus.success ? () {
                       _showModifyChapterDialog(context, materialId, chapterToEdit: chapter);
                    } : null,
                  ),
                );
              },

              // onReorder HANYA MENGIRIM EVENT
              onReorder: (int oldIndex, int newIndex) {
                context.read<ChapterManagementBloc>().add(
                      ReorderChapters(materialId, oldIndex, newIndex),
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
  void _showModifyChapterDialog(BuildContext context, String materialId,
      {HiCodeChapter? chapterToEdit}) {
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

  void _showDeleteConfirmationDialog(
      BuildContext context, HiCodeChapter chapter) {
    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Hapus Chapter'),
          content: Text(
              'Anda yakin ingin menghapus chapter "${chapter.title}"? Aksi ini tidak dapat dibatalkan.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('Batal'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              onPressed: () {
                // Kirim event DeleteChapterPressed ke BLoC
                context
                    .read<ChapterManagementBloc>()
                    .add(DeleteChapterPressed(chapter.id));
                Navigator.of(dialogContext).pop(); // Tutup dialog konfirmasi
              },
              child: const Text('Hapus', style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }
}
