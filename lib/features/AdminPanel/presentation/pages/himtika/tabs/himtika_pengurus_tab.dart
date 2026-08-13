import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:himtika_mobile_information/features/himtika/domain/entities/himtika_pengurus.dart';
import 'package:himtika_mobile_information/features/himtika/domain/entities/himtika_divisi.dart';
import 'package:himtika_mobile_information/features/AdminPanel/presentation/bloc/himtika_management/himtika_management_bloc.dart';
import 'package:himtika_mobile_information/features/AdminPanel/presentation/bloc/himtika_management/himtika_management_event.dart';
import 'package:himtika_mobile_information/features/AdminPanel/presentation/bloc/himtika_management/himtika_management_state.dart';

class HimtikaPengurusTab extends StatefulWidget {
  const HimtikaPengurusTab({super.key});

  @override
  State<HimtikaPengurusTab> createState() => _HimtikaPengurusTabState();
}

class _HimtikaPengurusTabState extends State<HimtikaPengurusTab> {
  final ImagePicker _picker = ImagePicker();

  void _showPengurusDialog(
    BuildContext context,
    HimtikaManagementState state, {
    HimtikaPengurus? pengurus,
  }) {
    if (state.divisiList.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Silakan buat Divisi terlebih dahulu sebelum menambah pengurus!'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    final formKey = GlobalKey<FormState>();
    final namaController = TextEditingController(text: pengurus?.nama ?? '');
    final jabatanController = TextEditingController(text: pengurus?.jabatan ?? '');
    final urutanController = TextEditingController(text: (pengurus?.urutan ?? 0).toString());

    String selectedDivisiId = pengurus?.divisiId ??
        (state.selectedDivisiId != null && state.selectedDivisiId!.isNotEmpty
            ? state.selectedDivisiId!
            : state.divisiList.first.id);

    File? selectedFotoFile;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            Future<void> pickFoto() async {
              final XFile? picked = await _picker.pickImage(
                source: ImageSource.gallery,
                imageQuality: 85,
              );
              if (picked != null) {
                setDialogState(() {
                  selectedFotoFile = File(picked.path);
                });
              }
            }

            return AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              title: Row(
                children: [
                  Icon(
                    pengurus == null ? Icons.person_add : Icons.edit,
                    color: const Color(0xFF0175C8),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    pengurus == null ? 'Tambah Pengurus' : 'Edit Pengurus',
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              content: SingleChildScrollView(
                child: Form(
                  key: formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Upload Photo Avatar
                      GestureDetector(
                        onTap: pickFoto,
                        child: Stack(
                          children: [
                            CircleAvatar(
                              radius: 42,
                              backgroundColor: const Color(0xFF0175C8).withValues(alpha: 0.1),
                              backgroundImage: selectedFotoFile != null
                                  ? FileImage(selectedFotoFile!)
                                  : (pengurus?.fotoUrl != null && pengurus!.fotoUrl!.isNotEmpty
                                      ? NetworkImage(pengurus.fotoUrl!) as ImageProvider
                                      : null),
                              child: (selectedFotoFile == null &&
                                      (pengurus?.fotoUrl == null || pengurus!.fotoUrl!.isEmpty))
                                  ? const Icon(Icons.person, size: 48, color: Color(0xFF0175C8))
                                  : null,
                            ),
                            Positioned(
                              bottom: 0,
                              right: 0,
                              child: CircleAvatar(
                                radius: 14,
                                backgroundColor: const Color(0xFF0175C8),
                                child: const Icon(Icons.camera_alt, size: 14, color: Colors.white),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Nama Pengurus
                      TextFormField(
                        controller: namaController,
                        decoration: InputDecoration(
                          labelText: 'Nama Lengkap *',
                          hintText: 'Contoh: Ahmad Fajar',
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                        validator: (value) =>
                            value == null || value.trim().isEmpty ? 'Nama wajib diisi' : null,
                      ),
                      const SizedBox(height: 12),

                      // Jabatan
                      TextFormField(
                        controller: jabatanController,
                        decoration: InputDecoration(
                          labelText: 'Jabatan *',
                          hintText: 'Contoh: Ketua Divisi / Anggota',
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                        validator: (value) =>
                            value == null || value.trim().isEmpty ? 'Jabatan wajib diisi' : null,
                      ),
                      const SizedBox(height: 12),

                      // Dropdown Pilih Divisi
                      DropdownButtonFormField<String>(
                        initialValue: selectedDivisiId,
                        decoration: InputDecoration(
                          labelText: 'Divisi *',
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                        items: state.divisiList.map((divisi) {
                          return DropdownMenuItem<String>(
                            value: divisi.id,
                            child: Text(divisi.namaDivisi),
                          );
                        }).toList(),
                        onChanged: (val) {
                          if (val != null) {
                            setDialogState(() {
                              selectedDivisiId = val;
                            });
                          }
                        },
                      ),
                      const SizedBox(height: 12),

                      // Urutan
                      TextFormField(
                        controller: urutanController,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          labelText: 'Urutan Tampil',
                          hintText: '0, 1, 2...',
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(dialogContext),
                  child: const Text('Batal', style: TextStyle(color: Colors.grey)),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0175C8),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  onPressed: () {
                    if (formKey.currentState!.validate()) {
                      final int urutanVal = int.tryParse(urutanController.text.trim()) ?? 0;
                      if (pengurus == null) {
                        final newPengurus = HimtikaPengurus(
                          id: '',
                          divisiId: selectedDivisiId,
                          nama: namaController.text.trim(),
                          jabatan: jabatanController.text.trim(),
                          urutan: urutanVal,
                        );
                        context.read<HimtikaManagementBloc>().add(
                              CreatePengurusEvent(pengurus: newPengurus, fotoFile: selectedFotoFile),
                            );
                      } else {
                        final updatedPengurus = pengurus.copyWith(
                          divisiId: selectedDivisiId,
                          nama: namaController.text.trim(),
                          jabatan: jabatanController.text.trim(),
                          urutan: urutanVal,
                        );
                        context.read<HimtikaManagementBloc>().add(
                              UpdatePengurusEvent(
                                pengurus: updatedPengurus,
                                fotoFile: selectedFotoFile,
                              ),
                            );
                      }
                      Navigator.pop(dialogContext);
                    }
                  },
                  child: Text(pengurus == null ? 'Simpan' : 'Update'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _confirmDeletePengurus(BuildContext context, HimtikaPengurus pengurus) {
    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Konfirmasi Hapus'),
          content: Text('Apakah Anda yakin ingin menghapus data pengurus "${pengurus.nama}"?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Batal'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.redAccent,
                foregroundColor: Colors.white,
              ),
              onPressed: () {
                context
                    .read<HimtikaManagementBloc>()
                    .add(DeletePengurusEvent(pengurusId: pengurus.id));
                Navigator.pop(dialogContext);
              },
              child: const Text('Hapus'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<HimtikaManagementBloc, HimtikaManagementState>(
      builder: (context, state) {
        final filteredList = state.filteredPengurusList;

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              // Filter & Add Button Bar
              Card(
                elevation: 2,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: Padding(
                  padding: const EdgeInsets.all(14.0),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              const Icon(Icons.people_alt, color: Color(0xFF0175C8)),
                              const SizedBox(width: 8),
                              Text(
                                'Pengurus (${filteredList.length})',
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          ElevatedButton.icon(
                            onPressed: () => _showPengurusDialog(context, state),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF0175C8),
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                            ),
                            icon: const Icon(Icons.add, size: 18),
                            label: const Text('Tambah Pengurus'),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),

                      // Filter Dropdown
                      Row(
                        children: [
                          const Text(
                            'Filter Divisi:',
                            style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12),
                              decoration: BoxDecoration(
                                color: Colors.grey.shade100,
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: Colors.grey.shade300),
                              ),
                              child: DropdownButtonHideUnderline(
                                child: DropdownButton<String?>(
                                  value: state.selectedDivisiId,
                                  isExpanded: true,
                                  hint: const Text('Semua Divisi'),
                                  items: [
                                    const DropdownMenuItem<String?>(
                                      value: null,
                                      child: Text('Semua Divisi'),
                                    ),
                                    ...state.divisiList.map((divisi) {
                                      return DropdownMenuItem<String?>(
                                        value: divisi.id,
                                        child: Text(divisi.namaDivisi),
                                      );
                                    }),
                                  ],
                                  onChanged: (val) {
                                    context.read<HimtikaManagementBloc>().add(
                                          SelectDivisiFilterEvent(divisiId: val),
                                        );
                                  },
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 14),

              if (filteredList.isEmpty)
                Container(
                  padding: const EdgeInsets.all(32),
                  child: const Column(
                    children: [
                      Icon(Icons.person_off_outlined, size: 48, color: Colors.grey),
                      SizedBox(height: 8),
                      Text(
                        'Belum ada data pengurus di divisi ini',
                        style: TextStyle(color: Colors.grey),
                      ),
                    ],
                  ),
                )
              else
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: filteredList.length,
                  itemBuilder: (context, index) {
                    final pengurus = filteredList[index];
                    final String namaDivisi = state.divisiList
                        .firstWhere(
                          (d) => d.id == pengurus.divisiId,
                          orElse: () => const HimtikaDivisi(
                            id: '',
                            namaDivisi: 'Umum',
                            urutan: 0,
                          ),
                        )
                        .namaDivisi;

                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      elevation: 2,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: ListTile(
                        contentPadding:
                            const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        leading: CircleAvatar(
                          radius: 24,
                          backgroundColor: const Color(0xFF0175C8).withValues(alpha: 0.1),
                          backgroundImage: pengurus.fotoUrl != null && pengurus.fotoUrl!.isNotEmpty
                              ? NetworkImage(pengurus.fotoUrl!)
                              : null,
                          child: (pengurus.fotoUrl == null || pengurus.fotoUrl!.isEmpty)
                              ? const Icon(Icons.person, color: Color(0xFF0175C8))
                              : null,
                        ),
                        title: Text(
                          pengurus.nama,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 2),
                            Text(
                              pengurus.jabatan,
                              style: const TextStyle(
                                color: Color(0xFF0175C8),
                                fontWeight: FontWeight.w600,
                                fontSize: 13,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              'Divisi: $namaDivisi • Urutan: ${pengurus.urutan}',
                              style: TextStyle(
                                color: Colors.grey.shade600,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.edit, color: Color(0xFF0175C8)),
                              onPressed: () => _showPengurusDialog(
                                context,
                                state,
                                pengurus: pengurus,
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
                              onPressed: () => _confirmDeletePengurus(context, pengurus),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
            ],
          ),
        );
      },
    );
  }
}
