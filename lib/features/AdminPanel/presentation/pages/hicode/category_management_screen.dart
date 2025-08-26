import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:himtika_mobile_information/core/injection_container.dart';
import 'package:himtika_mobile_information/features/AdminPanel/presentation/bloc/category_management/category_management_bloc.dart';
import 'package:himtika_mobile_information/features/hicode/domain/entities/hicode_category.dart';

class CategoryManagementScreen extends StatelessWidget {
  const CategoryManagementScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<CategoryManagementBloc>()..add(LoadCategories()),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Kelola Kategori'),
          backgroundColor: const Color(0xFF0175C8),
          foregroundColor: Colors.white,
        ),
        body: BlocConsumer<CategoryManagementBloc, CategoryManagementState>(
          listener: (context, state) {
            if (state.status == CategoryManagementStatus.failure) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.errorMessage ?? 'Terjadi kesalahan'),
                  backgroundColor: Colors.red,
                ),
              );
            }
          },
          builder: (context, state) {
            if (state.status == CategoryManagementStatus.loading) {
              return const Center(child: CircularProgressIndicator());
            }
            if (state.categories.isEmpty) {
              return const Center(
                child: Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Text(
                    'Belum ada kategori. Tekan tombol + untuk menambah.',
                    textAlign: TextAlign.center,
                  ),
                ),
              );
            }
            return ListView.builder(
              padding: const EdgeInsets.all(16.0),
              itemCount: state.categories.length,
              itemBuilder: (context, index) {
                final category = state.categories[index];
                return _buildCategoryCard(
                  context,
                  category: category,
                  onEdit: () => _showModifyCategoryDialog(context, category: category),
                  onDelete: () => _showDeleteConfirmationDialog(context, category),
                );
              },
            );
          },
        ),
        floatingActionButton: Builder(
          builder: (context) => FloatingActionButton(
            onPressed: () => _showModifyCategoryDialog(context),
            backgroundColor: const Color(0xFF0175C8),
            child: const Icon(Icons.add, color: Colors.white),
          ),
        ),
      ),
    );
  }

  Widget _buildCategoryCard(BuildContext context, {required HiCodeCategory category, required VoidCallback onEdit, required VoidCallback onDelete}) {
    return Card(
      elevation: 3,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: Image.network(
          category.iconUrl,
          width: 40,
          height: 40,
          errorBuilder: (c, e, s) => const Icon(Icons.image_not_supported, size: 40),
        ),
        title: Text(category.name, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: GestureDetector(
          onTap: () {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('URL Ikon: ${category.iconUrl}')));
          },
          child: const Text('Ketuk untuk lihat URL', style: TextStyle(color: Colors.blue, fontSize: 12)),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(icon: Icon(Icons.edit, color: Colors.blue.shade700), onPressed: onEdit),
            IconButton(icon: Icon(Icons.delete_outline, color: Colors.red.shade700), onPressed: onDelete),
          ],
        ),
      ),
    );
  }

  void _showModifyCategoryDialog(BuildContext context, {HiCodeCategory? category}) {
    showDialog(
      context: context,
      barrierDismissible: false, // Mencegah dialog tertutup saat diklik di luar
      builder: (dialogContext) {
        // Berikan BLoC yang ada ke dialog
        return BlocProvider.value(
          value: BlocProvider.of<CategoryManagementBloc>(context),
          child: _ModifyCategoryDialog(category: category),
        );
      },
    );
  }

  void _showDeleteConfirmationDialog(BuildContext context, HiCodeCategory category) {
    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Hapus Kategori'),
          content: Text('Anda yakin ingin menghapus kategori "${category.name}"? Semua materi di dalamnya juga akan terhapus.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('Batal'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              onPressed: () {
                context.read<CategoryManagementBloc>().add(DeleteCategoryPressed(id: category.id));
                Navigator.of(dialogContext).pop();
              },
              child: const Text('Hapus', style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }
}

// Dialog ini sekarang menjadi StatefulWidget untuk mengelola state file yang dipilih
class _ModifyCategoryDialog extends StatefulWidget {
  final HiCodeCategory? category;
  const _ModifyCategoryDialog({this.category});

  @override
  State<_ModifyCategoryDialog> createState() => _ModifyCategoryDialogState();
}

class _ModifyCategoryDialogState extends State<_ModifyCategoryDialog> {
  final _nameController = TextEditingController();
  File? _selectedIconFile;
  final ImagePicker _picker = ImagePicker();

  bool get isEditing => widget.category != null;

  @override
  void initState() {
    super.initState();
    if (isEditing) {
      _nameController.text = widget.category!.name;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final XFile? pickedFile = await _picker.pickImage(source: ImageSource.gallery, imageQuality: 80);
    if (pickedFile != null) {
      setState(() {
        _selectedIconFile = File(pickedFile.path);
      });
    }
  }

  void _onSavePressed() {
    final bloc = context.read<CategoryManagementBloc>();

    if (isEditing) {
      // Logika untuk UPDATE
      bloc.add(UpdateCategorySubmitted(
            id: widget.category!.id,
            name: _nameController.text,
            iconFile: _selectedIconFile, // Kirim file jika ada, jika tidak, null
          ));
    } else {
      // Logika untuk CREATE
      if (_selectedIconFile == null) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Harap pilih ikon untuk kategori.'), backgroundColor: Colors.orange));
        return;
      }
      bloc.add(AddCategorySubmitted(
            name: _nameController.text,
            iconFile: _selectedIconFile!,
          ));
    }
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(isEditing ? 'Edit Kategori' : 'Tambah Kategori Baru'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Nama Kategori',
                hintText: 'Contoh: HTML',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            const Text('Ikon Kategori', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Container(
              height: 120,
              width: 120,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey),
                borderRadius: BorderRadius.circular(8),
              ),
              child: _selectedIconFile != null
                  ? Image.file(_selectedIconFile!, fit: BoxFit.cover)
                  : (isEditing && widget.category!.iconUrl.isNotEmpty)
                      ? Image.network(widget.category!.iconUrl, fit: BoxFit.cover, errorBuilder: (c, e, s) => const Icon(Icons.error))
                      : const Center(child: Text('Pilih Gambar')),
            ),
            const SizedBox(height: 8),
            ElevatedButton.icon(
              onPressed: _pickImage,
              icon: const Icon(Icons.upload_file),
              label: Text(isEditing ? 'Ganti Gambar' : 'Pilih Gambar'),
            ),
            const SizedBox(height: 8),
            const Text(
              'Pilih gambar dari galeri. Gambar akan diunggah ke folder "icon" di Supabase Storage.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('Batal')),
        ElevatedButton(
          onPressed: _onSavePressed,
          child: Text(isEditing ? 'Simpan' : 'Tambah'),
        ),
      ],
    );
  }
}