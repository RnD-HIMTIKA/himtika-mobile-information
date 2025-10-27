import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:himtika_mobile_information/features/AdminPanel/domain/entities/hicode_chapter.dart';
import 'package:himtika_mobile_information/features/AdminPanel/presentation/bloc/chapter_management/chapter_management_bloc.dart';

class ModifyChapterDialog extends StatefulWidget {
  final String materialId;
  final HiCodeChapter? chapterToEdit; // Nullable for adding new chapter

  const ModifyChapterDialog({
    super.key,
    required this.materialId,
    this.chapterToEdit,
  });

  @override
  State<ModifyChapterDialog> createState() => _ModifyChapterDialogState();
}

class _ModifyChapterDialogState extends State<ModifyChapterDialog> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _contentController = TextEditingController(); // Simple text for now
  final _readTimeController = TextEditingController();

  bool get isEditing => widget.chapterToEdit != null;

  @override
  void initState() {
    super.initState();
    if (isEditing) {
      _titleController.text = widget.chapterToEdit!.title;
      // TODO: Handle content loading if not simple text later
      _contentController.text = _extractParagraphText(widget.chapterToEdit!.content);
      _readTimeController.text = widget.chapterToEdit!.estimatedReadTime?.toString() ?? '';
    }
  }

   // Helper sementara untuk ekstrak teks dari JSON content sederhana
  String _extractParagraphText(Map<String, dynamic>? content) {
    if (content == null || content['blocks'] == null || (content['blocks'] as List).isEmpty) {
      return '';
    }
    final firstBlock = (content['blocks'] as List).firstWhere(
      (b) => b['type'] == 'paragraph',
      orElse: () => null,
    );
    return firstBlock?['data'] ?? '';
  }


  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    _readTimeController.dispose();
    super.dispose();
  }

  void _onSavePressed() {
    if (_formKey.currentState!.validate()) {
      final title = _titleController.text.trim();
      final contentText = _contentController.text.trim();
      final readTime = int.tryParse(_readTimeController.text.trim());

      // Format content sederhana ke JSON
      final contentJson = {
        "blocks": [
          {"type": "paragraph", "data": contentText}
        ]
      };

      if (isEditing) {
        // Kirim event Update
        context.read<ChapterManagementBloc>().add(
              UpdateChapterSubmitted(
                id: widget.chapterToEdit!.id,
                title: title,
                content: contentJson,
                estimatedReadTime: readTime,
                // Order tidak diubah di sini, perlu fitur reorder terpisah
              ),
            );
      } else {
        // Kirim event Add
        context.read<ChapterManagementBloc>().add(
              AddChapterSubmitted(
                materialId: widget.materialId,
                title: title,
                content: contentJson,
                estimatedReadTime: readTime,
              ),
            );
      }
      Navigator.of(context).pop(); // Tutup dialog
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(isEditing ? 'Edit Chapter' : 'Tambah Chapter Baru'),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(labelText: 'Judul Chapter', border: OutlineInputBorder()),
                validator: (value) => (value?.trim().isEmpty ?? true) ? 'Judul tidak boleh kosong' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _contentController,
                decoration: const InputDecoration(labelText: 'Konten (Teks Sederhana)', border: OutlineInputBorder()),
                maxLines: 5, // Allow multiple lines
                validator: (value) => (value?.trim().isEmpty ?? true) ? 'Konten tidak boleh kosong' : null,
              ),
               const SizedBox(height: 16),
              TextFormField(
                controller: _readTimeController,
                decoration: const InputDecoration(labelText: 'Estimasi Waktu Baca (Menit)', border: OutlineInputBorder()),
                keyboardType: TextInputType.number,
                // Validator opsional, karena waktu baca bisa jadi tidak wajib
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Batal')),
        ElevatedButton(onPressed: _onSavePressed, child: Text(isEditing ? 'Simpan' : 'Tambah')),
      ],
    );
  }
}