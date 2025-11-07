import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:himtika_mobile_information/core/injection_container.dart';
import 'package:himtika_mobile_information/features/AdminPanel/domain/entities/admin_hicode_material.dart';
import 'package:himtika_mobile_information/features/AdminPanel/presentation/bloc/material_management/material_management_bloc.dart';
import 'package:himtika_mobile_information/features/hicode/domain/entities/hicode_category.dart';
import 'package:himtika_mobile_information/features/AdminPanel/presentation/pages/hicode/chapter_management_screen.dart';
// Import Supabase client untuk fetch detail
import 'package:supabase_flutter/supabase_flutter.dart'; 


class MaterialManagementScreen extends StatelessWidget {
  const MaterialManagementScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<MaterialManagementBloc>()..add(LoadAdminMaterials()),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Kelola Materi'),
          backgroundColor: const Color(0xFF0175C8),
          foregroundColor: Colors.white,
        ),
        body: BlocConsumer<MaterialManagementBloc, MaterialManagementState>(
          listener: (context, state) {
            if (state.status == MaterialManagementStatus.failure && state.errorMessage != null) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.errorMessage!),
                  backgroundColor: Colors.red,
                ),
              );
            }
          },
          builder: (context, state) {
            if (state.status == MaterialManagementStatus.loading && state.materials.isEmpty) {
              return const Center(child: CircularProgressIndicator());
            }
            if (state.materials.isEmpty) {
              return const Center(
                child: Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Text('Belum ada materi. Tekan tombol + untuk menambah.', textAlign: TextAlign.center),
                ),
              );
            }
            return Stack(
              children: [
                ListView.builder(
                  padding: const EdgeInsets.all(16.0),
                  itemCount: state.materials.length,
                  itemBuilder: (context, index) {
                    final material = state.materials[index];
                    return _buildMaterialCard(
                      context,
                      material: material,
                      // --- PERBAIKAN: Kirim data yang ada ke dialog ---
                      onEdit: () => _showModifyMaterialDialog(
                        context, 
                        state.categories, // Kirim daftar kategori
                        material: material, // Kirim data materi
                      ),
                      // --- PERBAIKAN: Panggil dialog hapus ---
                      onDelete: () {
                        _showDeleteConfirmationDialog(context, material);
                      },
                    );
                  },
                ),
                if (state.status == MaterialManagementStatus.loading && state.materials.isNotEmpty)
                  Container(
                    color: Colors.black.withOpacity(0.3),
                    child: const Center(child: CircularProgressIndicator()),
                  ),
              ],
            );
          },
        ),
        floatingActionButton: Builder(
          builder: (context) => FloatingActionButton(
            onPressed: () {
              final state = context.read<MaterialManagementBloc>().state;
              // Izinkan tambah jika state success ATAU jika sudah ada data (meski sedang error)
              if (state.status == MaterialManagementStatus.success || state.materials.isNotEmpty) { 
                if (state.categories.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Buat kategori terlebih dahulu sebelum menambah materi.'), backgroundColor: Colors.orange),
                  );
                  return;
                }
                _showModifyMaterialDialog(context, state.categories);
              }
            },
            backgroundColor: const Color(0xFF0175C8),
            child: const Icon(Icons.add, color: Colors.white),
          ),
        ),
      ),
    );
  }

  Widget _buildMaterialCard(BuildContext context, {required AdminHiCodeMaterial material, required VoidCallback onEdit, required VoidCallback onDelete}) {
    return Card(
      elevation: 3,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        title: Text(material.title, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text('Kategori: ${material.categoryName ?? "N/A"} | ${material.chapterCount} Chapter'),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Tooltip(
            message: 'Edit Info Materi',
            child: IconButton(icon: Icon(Icons.edit_note, color: Colors.blue.shade700), onPressed: onEdit),
          ),
          Tooltip(
            message: 'Kelola Chapter',
            child: IconButton(
              icon: Icon(Icons.list_alt, color: Colors.green.shade700),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => ChapterManagementScreen(
                      materialId: material.id,
                      materialTitle: material.title,
                    ),
                  ),
                );
              },
            ),
          ),
          Tooltip(
            message: 'Hapus Materi',
            child: IconButton(icon: Icon(Icons.delete_outline, color: Colors.red.shade700), onPressed: onDelete),
          ),
        ],
      ),
      onTap: () {
         Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => ChapterManagementScreen(
                materialId: material.id,
                materialTitle: material.title,
              ),
            ),
          );
      },
    ),
  );
}

  void _showModifyMaterialDialog(BuildContext context, List<HiCodeCategory> categories, {AdminHiCodeMaterial? material}) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return BlocProvider.value(
          value: BlocProvider.of<MaterialManagementBloc>(context),
          child: _ModifyMaterialDialog(material: material, categories: categories),
        );
      },
    );
  }

  // --- FUNGSI BARU UNTUK KONFIRMASI HAPUS ---
  void _showDeleteConfirmationDialog(BuildContext context, AdminHiCodeMaterial material) {
    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Hapus Materi'),
          content: Text('Anda yakin ingin menghapus materi "${material.title}"? Semua chapter dan soal kuis di dalamnya juga akan terhapus.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('Batal'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              onPressed: () {
                context.read<MaterialManagementBloc>().add(DeleteMaterialPressed(id: material.id));
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

// --- MODIFIKASI BESAR DI _ModifyMaterialDialog ---
class _ModifyMaterialDialog extends StatefulWidget {
  final AdminHiCodeMaterial? material;
  final List<HiCodeCategory> categories;
  const _ModifyMaterialDialog({this.material, required this.categories});

  @override
  State<_ModifyMaterialDialog> createState() => _ModifyMaterialDialogState();
}

class _ModifyMaterialDialogState extends State<_ModifyMaterialDialog> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _borderColorController = TextEditingController();
  String? _selectedCategoryId;
  File? _selectedImageFile;
  String? _existingImageUrl;
  final ImagePicker _picker = ImagePicker();
  bool _isLoadingDetails = false; // <-- State loading untuk fetch detail

  bool get isEditing => widget.material != null;

  @override
  void initState() {
    super.initState();
    if (isEditing) {
      // Panggil fungsi fetch detail saat mode edit
      _fetchMaterialDetailsForEdit();
    } else {
      // Set default border color untuk Add
      _borderColorController.text = '#';
    }
  }

  // --- FUNGSI BARU UNTUK FETCH DETAIL ---
  Future<void> _fetchMaterialDetailsForEdit() async {
    if (widget.material == null) return;
    
    setState(() => _isLoadingDetails = true); // Tampilkan loading
    
    try {
      final client = sl<SupabaseClient>();
      // Panggil RPC get_material_details (RPC-59)
      final data = await client.rpc('get_material_details', params: {
        'p_material_id': widget.material!.id,
      });

      if (mounted && data != null) {
        setState(() {
          _titleController.text = data['title'] ?? widget.material!.title;
          _descriptionController.text = data['description'] ?? '';
          _borderColorController.text = data['border_color'] ?? '#';
          _selectedCategoryId = data['category_id'];
          _existingImageUrl = data['image_url'];
          _isLoadingDetails = false; // Sembunyikan loading
        });
      }
    } catch (e) {
      if (mounted) {
         setState(() => _isLoadingDetails = false);
         // Setidaknya pre-fill nama jika gagal
         _titleController.text = widget.material!.title;
         // Cari categoryId berdasarkan nama (fallback)
         _selectedCategoryId = widget.categories.firstWhere(
            (c) => c.name == widget.material!.categoryName,
            orElse: () => const HiCodeCategory(id: '', name: '', iconUrl: '')
         ).id;
         
         ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Gagal memuat detail materi: $e'), backgroundColor: Colors.orange),
          );
      }
    }
  }
  // --- AKHIR FUNGSI BARU ---


  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _borderColorController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final XFile? pickedFile = await _picker.pickImage(source: ImageSource.gallery, imageQuality: 80);
    if (pickedFile != null) {
      setState(() {
        _selectedImageFile = File(pickedFile.path);
        _existingImageUrl = null;
      });
    }
  }

  void _onSavePressed() {
    if (_formKey.currentState!.validate()) {
      if (_selectedImageFile == null && _existingImageUrl == null) { // Validasi gambar (harus ada salah satu)
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Gambar materi wajib diunggah.'), backgroundColor: Colors.orange));
        return;
      }

      if (isEditing) {
        // --- LOGIKA UPDATE ---
        context.read<MaterialManagementBloc>().add(
          UpdateMaterialSubmitted(
            id: widget.material!.id,
            categoryId: _selectedCategoryId!,
            title: _titleController.text,
            description: _descriptionController.text,
            imageFile: _selectedImageFile, // Kirim file baru (jika ada)
            borderColor: _borderColorController.text,
          ),
        );
      } else {
        // --- LOGIKA ADD ---
        context.read<MaterialManagementBloc>().add(
          AddMaterialSubmitted(
            categoryId: _selectedCategoryId!,
            title: _titleController.text,
            description: _descriptionController.text,
            imageFile: _selectedImageFile!,
            borderColor: _borderColorController.text,
          ),
        );
      }
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    // Tampilkan loading jika sedang fetch detail
    if (_isLoadingDetails) {
       return const Dialog(
         child: Padding(
           padding: EdgeInsets.all(32.0),
           child: Row(
             mainAxisSize: MainAxisSize.min,
             children: [
               CircularProgressIndicator(),
               SizedBox(width: 20),
               Text("Memuat Detail..."),
             ],
           ),
         ),
       );
    }
    
    return AlertDialog(
      title: Text(isEditing ? 'Edit Materi' : 'Tambah Materi Baru'),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              DropdownButtonFormField<String>(
                value: _selectedCategoryId,
                hint: const Text('Pilih Kategori'),
                items: widget.categories.map((category) {
                  return DropdownMenuItem(
                    value: category.id,
                    child: Text(category.name),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedCategoryId = value;
                  });
                },
                decoration: const InputDecoration(border: OutlineInputBorder()),
                validator: (value) => value == null ? 'Kategori wajib dipilih' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(labelText: 'Judul Materi', border: OutlineInputBorder()),
                validator: (value) => (value?.trim().isEmpty ?? true) ? 'Judul tidak boleh kosong' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(labelText: 'Deskripsi Singkat', border: OutlineInputBorder()),
                maxLines: 3,
                validator: (value) => (value?.trim().isEmpty ?? true) ? 'Deskripsi tidak boleh kosong' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _borderColorController,
                decoration: const InputDecoration(labelText: 'Warna Border (Hex)', hintText: '#FF5733', border: OutlineInputBorder()),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) return 'Warna border tidak boleh kosong';
                  if (!value.startsWith('#') || value.length != 7) return 'Format salah (contoh: #RRGGBB)';
                  return null;
                },
              ),
              const SizedBox(height: 16),
              const Text('Gambar Materi', style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Container(
                height: 150,
                width: double.infinity,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  color: Colors.grey[200]
                ),
                child: _selectedImageFile != null
                    ? Image.file(_selectedImageFile!, fit: BoxFit.cover)
                    : (_existingImageUrl != null && _existingImageUrl!.isNotEmpty) // <-- Cek jika URL lama ada
                        ? Image.network(_existingImageUrl!, fit: BoxFit.cover,
                            errorBuilder: (c,e,s) => const Icon(Icons.broken_image, color: Colors.grey))
                        : const Center(child: Text('Pilih Gambar')),
              ),
              const SizedBox(height: 8),
              ElevatedButton.icon(
                onPressed: _pickImage,
                icon: const Icon(Icons.upload_file),
                label: Text(isEditing ? 'Ganti Gambar' : 'Pilih Gambar'),
              ),
            ],
          ),
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