import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:himtika_mobile_information/features/himtika/domain/entities/himtika_divisi.dart';
import 'package:himtika_mobile_information/features/AdminPanel/presentation/bloc/himtika_management/himtika_management_bloc.dart';
import 'package:himtika_mobile_information/features/AdminPanel/presentation/bloc/himtika_management/himtika_management_event.dart';
import 'package:himtika_mobile_information/features/AdminPanel/presentation/bloc/himtika_management/himtika_management_state.dart';

class HimtikaDivisiTab extends StatefulWidget {
  const HimtikaDivisiTab({super.key});

  @override
  State<HimtikaDivisiTab> createState() => _HimtikaDivisiTabState();
}

class _HimtikaDivisiTabState extends State<HimtikaDivisiTab> {
  final ImagePicker _picker = ImagePicker();

  void _showDivisiDialog(BuildContext context, {HimtikaDivisi? divisi}) {
    final formKey = GlobalKey<FormState>();
    final namaController = TextEditingController(text: divisi?.namaDivisi ?? '');
    final deskripsiController = TextEditingController(text: divisi?.deskripsi ?? '');
    final urutanController = TextEditingController(text: (divisi?.urutan ?? 0).toString());
    File? selectedLogoFile;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            Future<void> pickLogo() async {
              final XFile? picked = await _picker.pickImage(
                source: ImageSource.gallery,
                imageQuality: 85,
              );
              if (picked != null) {
                setDialogState(() {
                  selectedLogoFile = File(picked.path);
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
                    divisi == null ? Icons.add_business : Icons.edit_sharp,
                    color: const Color(0xFF0175C8),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      divisi == null ? 'Tambah Divisi' : 'Edit Divisi',
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              content: SingleChildScrollView(
                child: Form(
                  key: formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Upload Logo Box
                      GestureDetector(
                        onTap: pickLogo,
                        child: Container(
                          width: 90,
                          height: 90,
                          decoration: BoxDecoration(
                            color: Colors.grey.shade100,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: const Color(0xFF0175C8), width: 1.5),
                          ),
                          child: selectedLogoFile != null
                              ? ClipRRect(
                                  borderRadius: BorderRadius.circular(10),
                                  child: Image.file(selectedLogoFile!, fit: BoxFit.cover),
                                )
                              : (divisi?.logoUrl != null && divisi!.logoUrl!.isNotEmpty
                                  ? ClipRRect(
                                      borderRadius: BorderRadius.circular(10),
                                      child: Image.network(
                                        divisi.logoUrl!,
                                        fit: BoxFit.cover,
                                        errorBuilder: (_, __, ___) => const Icon(
                                          Icons.broken_image,
                                          color: Colors.grey,
                                        ),
                                      ),
                                    )
                                  : const Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Icon(Icons.add_a_photo, color: Color(0xFF0175C8), size: 28),
                                        SizedBox(height: 4),
                                        Text('Logo Divisi', style: TextStyle(fontSize: 10, color: Color(0xFF0175C8))),
                                      ],
                                    )),
                        ),
                      ),
                      const SizedBox(height: 16),

                      TextFormField(
                        controller: namaController,
                        decoration: InputDecoration(
                          labelText: 'Nama Divisi *',
                          hintText: 'Contoh: RnD / Kominfo',
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                        validator: (value) => value == null || value.trim().isEmpty ? 'Nama divisi wajib diisi' : null,
                      ),
                      const SizedBox(height: 12),

                      TextFormField(
                        controller: urutanController,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          labelText: 'Urutan Tampil',
                          hintText: '0, 1, 2...',
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                      ),
                      const SizedBox(height: 12),

                      TextFormField(
                        controller: deskripsiController,
                        minLines: 2,
                        maxLines: null,
                        keyboardType: TextInputType.multiline,
                        decoration: InputDecoration(
                          alignLabelWithHint: true,
                          labelText: 'Deskripsi Divisi',
                          hintText: 'Tuliskan deskripsi tugas divisi...',
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
                      if (divisi == null) {
                        final newDivisi = HimtikaDivisi(
                          id: '',
                          namaDivisi: namaController.text.trim(),
                          deskripsi: deskripsiController.text.trim(),
                          urutan: urutanVal,
                        );
                        context.read<HimtikaManagementBloc>().add(
                              CreateDivisiEvent(divisi: newDivisi, logoFile: selectedLogoFile),
                            );
                      } else {
                        final updatedDivisi = divisi.copyWith(
                          namaDivisi: namaController.text.trim(),
                          deskripsi: deskripsiController.text.trim(),
                          urutan: urutanVal,
                        );
                        context.read<HimtikaManagementBloc>().add(
                              UpdateDivisiEvent(divisi: updatedDivisi, logoFile: selectedLogoFile),
                            );
                      }
                      Navigator.pop(dialogContext);
                    }
                  },
                  child: Text(divisi == null ? 'Simpan' : 'Update'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _confirmDeleteDivisi(BuildContext context, HimtikaDivisi divisi) {
    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Konfirmasi Hapus'),
          content: Text('Apakah Anda yakin ingin menghapus divisi "${divisi.namaDivisi}"? Semua pengurus di divisi ini juga akan terhapus.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Batal'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent, foregroundColor: Colors.white),
              onPressed: () {
                context.read<HimtikaManagementBloc>().add(DeleteDivisiEvent(divisiId: divisi.id));
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
        return SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              // Top Bar Header
              Card(
                elevation: 2,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  child: Wrap(
                    alignment: WrapAlignment.spaceBetween,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    spacing: 12,
                    runSpacing: 10,
                    children: [
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.diversity_3, color: Color(0xFF0175C8)),
                          const SizedBox(width: 8),
                          Text(
                            'Daftar Divisi (${state.divisiList.length})',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      ElevatedButton.icon(
                        onPressed: () => _showDivisiDialog(context),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF0175C8),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        ),
                        icon: const Icon(Icons.add, size: 18),
                        label: const Text('Tambah Divisi'),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 14),

              if (state.divisiList.isEmpty)
                Container(
                  padding: const EdgeInsets.all(32),
                  child: const Column(
                    children: [
                      Icon(Icons.layers_clear, size: 48, color: Colors.grey),
                      SizedBox(height: 8),
                      Text('Belum ada divisi terdaftar', style: TextStyle(color: Colors.grey)),
                    ],
                  ),
                )
              else
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: state.divisiList.length,
                  itemBuilder: (context, index) {
                    final divisi = state.divisiList[index];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      elevation: 2,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: ListTile(
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        leading: Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            color: const Color(0xFF0175C8).withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: divisi.logoUrl != null && divisi.logoUrl!.isNotEmpty
                              ? ClipRRect(
                                  borderRadius: BorderRadius.circular(10),
                                  child: Image.network(
                                    divisi.logoUrl!,
                                    fit: BoxFit.cover,
                                    errorBuilder: (_, __, ___) => const Icon(
                                      Icons.business,
                                      color: Color(0xFF0175C8),
                                    ),
                                  ),
                                )
                              : const Icon(
                                  Icons.business,
                                  color: Color(0xFF0175C8),
                                ),
                        ),
                        title: Row(
                          children: [
                            Flexible(
                              child: Text(
                                divisi.namaDivisi,
                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: Colors.grey.shade200,
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                'Urutan: ${divisi.urutan}',
                                style: const TextStyle(fontSize: 11, color: Colors.black87),
                              ),
                            ),
                          ],
                        ),
                        subtitle: Padding(
                          padding: const EdgeInsets.only(top: 4),
                          child: Text(
                            divisi.deskripsi != null && divisi.deskripsi!.isNotEmpty
                                ? divisi.deskripsi!
                                : 'Tidak ada deskripsi',
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(fontSize: 13),
                          ),
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.edit, color: Color(0xFF0175C8)),
                              onPressed: () => _showDivisiDialog(context, divisi: divisi),
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
                              onPressed: () => _confirmDeleteDivisi(context, divisi),
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
