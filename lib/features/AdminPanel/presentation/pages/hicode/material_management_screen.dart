import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:himtika_mobile_information/core/injection_container.dart';
import 'package:himtika_mobile_information/features/AdminPanel/domain/entities/admin_hicode_material.dart';
import 'package:himtika_mobile_information/features/AdminPanel/presentation/bloc/material_management/material_management_bloc.dart';
import 'package:himtika_mobile_information/features/hicode/domain/entities/hicode_category.dart';

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
                      onEdit: () => _showModifyMaterialDialog(context, state.categories, material: material),
                      onDelete: () {
                        // Logika hapus akan ditambahkan di sini
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
              if (state.status == MaterialManagementStatus.success) {
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
            IconButton(icon: Icon(Icons.edit, color: Colors.blue.shade700), onPressed: onEdit),
            IconButton(icon: Icon(Icons.delete_outline, color: Colors.red.shade700), onPressed: onDelete),
          ],
        ),
        onTap: onEdit,
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
}

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
  final _borderColorController = TextEditingController(text: '#');
  String? _selectedCategoryId;
  File? _selectedImageFile;
  final ImagePicker _picker = ImagePicker();

  bool get isEditing => widget.material != null;

  @override
  void initState() {
    super.initState();
    if (isEditing) {
      _titleController.text = widget.material!.title;
      // Logika pre-fill lain akan ditambahkan di sini nanti
    }
  }

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
      });
    }
  }

  void _onSavePressed() {
    if (_formKey.currentState!.validate()) {
      if (_selectedImageFile == null && !isEditing) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Gambar materi wajib diunggah.'), backgroundColor: Colors.orange));
        return;
      }

      if (isEditing) {
        // Logika update akan ditambahkan di sini
      } else {
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
                decoration: BoxDecoration(border: Border.all(color: Colors.grey)),
                child: _selectedImageFile != null
                    ? Image.file(_selectedImageFile!, fit: BoxFit.cover)
                    : const Center(child: Text('Pilih Gambar')),
              ),
              const SizedBox(height: 8),
              ElevatedButton.icon(
                onPressed: _pickImage,
                icon: const Icon(Icons.upload_file),
                label: const Text('Pilih Gambar'),
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