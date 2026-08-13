import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:himtika_mobile_information/features/himtika/domain/entities/himtika_kabinet.dart';
import 'package:himtika_mobile_information/features/himtika/domain/entities/himtika_about.dart';
import 'package:himtika_mobile_information/features/AdminPanel/presentation/bloc/himtika_management/himtika_management_bloc.dart';
import 'package:himtika_mobile_information/features/AdminPanel/presentation/bloc/himtika_management/himtika_management_event.dart';
import 'package:himtika_mobile_information/features/AdminPanel/presentation/bloc/himtika_management/himtika_management_state.dart';

class HimtikaKabinetAboutTab extends StatefulWidget {
  const HimtikaKabinetAboutTab({super.key});

  @override
  State<HimtikaKabinetAboutTab> createState() => _HimtikaKabinetAboutTabState();
}

class _HimtikaKabinetAboutTabState extends State<HimtikaKabinetAboutTab> {
  final _formKeyKabinet = GlobalKey<FormState>();
  final _formKeyAbout = GlobalKey<FormState>();

  late TextEditingController _namaKabinetController;
  late TextEditingController _taglineController;
  late TextEditingController _deskripsiKabinetController;
  late TextEditingController _periodeController;

  late TextEditingController _visiController;
  late TextEditingController _sejarahController;
  final List<TextEditingController> _misiControllers = [];

  File? _selectedLogoFile;
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _namaKabinetController = TextEditingController();
    _taglineController = TextEditingController();
    _deskripsiKabinetController = TextEditingController();
    _periodeController = TextEditingController();

    _visiController = TextEditingController();
    _sejarahController = TextEditingController();

    _initDataFromState(context.read<HimtikaManagementBloc>().state);
  }

  void _initDataFromState(HimtikaManagementState state) {
    if (state.kabinet != null) {
      _namaKabinetController.text = state.kabinet!.namaKabinet;
      _taglineController.text = state.kabinet!.tagline ?? '';
      _deskripsiKabinetController.text = state.kabinet!.deskripsi ?? '';
      _periodeController.text = state.kabinet!.periode;
    }

    if (state.about != null) {
      _visiController.text = state.about!.visi;
      _sejarahController.text = state.about!.sejarahText;

      for (var controller in _misiControllers) {
        controller.dispose();
      }
      _misiControllers.clear();

      for (String item in state.about!.misi) {
        _misiControllers.add(TextEditingController(text: item));
      }
      if (_misiControllers.isEmpty) {
        _misiControllers.add(TextEditingController());
      }
    }
  }

  @override
  void dispose() {
    _namaKabinetController.dispose();
    _taglineController.dispose();
    _deskripsiKabinetController.dispose();
    _periodeController.dispose();

    _visiController.dispose();
    _sejarahController.dispose();
    for (var c in _misiControllers) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _pickLogoImage() async {
    final XFile? picked = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 85,
    );
    if (picked != null) {
      setState(() {
        _selectedLogoFile = File(picked.path);
      });
    }
  }

  void _addMisiField() {
    setState(() {
      _misiControllers.add(TextEditingController());
    });
  }

  void _removeMisiField(int index) {
    if (_misiControllers.length > 1) {
      setState(() {
        _misiControllers[index].dispose();
        _misiControllers.removeAt(index);
      });
    } else {
      _misiControllers[0].clear();
    }
  }

  void _submitKabinet(HimtikaKabinet? currentKabinet) {
    if (_formKeyKabinet.currentState!.validate()) {
      final kabinet = HimtikaKabinet(
        id: currentKabinet?.id ?? '',
        namaKabinet: _namaKabinetController.text.trim(),
        tagline: _taglineController.text.trim(),
        deskripsi: _deskripsiKabinetController.text.trim(),
        logoUrl: currentKabinet?.logoUrl,
        periode: _periodeController.text.trim(),
        isActive: currentKabinet?.isActive ?? true,
      );

      context.read<HimtikaManagementBloc>().add(
            UpdateKabinetEvent(
              kabinet: kabinet,
              logoFile: _selectedLogoFile,
            ),
          );
    }
  }

  void _submitAbout(HimtikaAbout? currentAbout) {
    if (_formKeyAbout.currentState!.validate()) {
      final List<String> misiList = _misiControllers
          .map((c) => c.text.trim())
          .where((text) => text.isNotEmpty)
          .toList();

      final about = HimtikaAbout(
        id: currentAbout?.id ?? '',
        visi: _visiController.text.trim(),
        misi: misiList,
        sejarahText: _sejarahController.text.trim(),
      );

      context.read<HimtikaManagementBloc>().add(
            UpdateAboutEvent(about: about),
          );
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<HimtikaManagementBloc, HimtikaManagementState>(
      listenWhen: (previous, current) =>
          previous.status != current.status ||
          previous.isSubmitting != current.isSubmitting ||
          previous.successMessage != current.successMessage ||
          previous.errorMessage != current.errorMessage,
      listener: (context, state) {
        if (state.kabinet != null && _namaKabinetController.text.isEmpty) {
          _initDataFromState(state);
        }
      },
      child: BlocBuilder<HimtikaManagementBloc, HimtikaManagementState>(
        builder: (context, state) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // SECTION 1: EDIT KABINET
                _buildCardSection(
                  title: 'Informasi Kabinet Aktif',
                  icon: Icons.account_balance,
                  child: Form(
                    key: _formKeyKabinet,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Logo Upload Row
                        Center(
                          child: Column(
                            children: [
                              GestureDetector(
                                onTap: _pickLogoImage,
                                child: Container(
                                  width: 100,
                                  height: 100,
                                  decoration: BoxDecoration(
                                    color: Colors.grey.shade100,
                                    borderRadius: BorderRadius.circular(16),
                                    border: Border.all(
                                      color: const Color(0xFF0175C8),
                                      width: 2,
                                    ),
                                  ),
                                  child: _selectedLogoFile != null
                                      ? ClipRRect(
                                          borderRadius:
                                              BorderRadius.circular(14),
                                          child: Image.file(
                                            _selectedLogoFile!,
                                            fit: BoxFit.cover,
                                          ),
                                        )
                                      : (state.kabinet?.logoUrl != null &&
                                              state.kabinet!.logoUrl!.isNotEmpty
                                          ? ClipRRect(
                                              borderRadius:
                                                  BorderRadius.circular(14),
                                              child: Image.network(
                                                state.kabinet!.logoUrl!,
                                                fit: BoxFit.cover,
                                                errorBuilder:
                                                    (_, __, ___) => const Icon(
                                                        Icons.broken_image,
                                                        size: 40,
                                                        color: Colors.grey),
                                              ),
                                            )
                                          : const Column(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: [
                                                Icon(
                                                  Icons.cloud_upload,
                                                  size: 32,
                                                  color: Color(0xFF0175C8),
                                                ),
                                                SizedBox(height: 4),
                                                Text(
                                                  'Upload Logo',
                                                  style: TextStyle(
                                                    fontSize: 11,
                                                    color: Color(0xFF0175C8),
                                                    fontWeight: FontWeight.w600,
                                                  ),
                                                ),
                                              ],
                                            )),
                                ),
                              ),
                              const SizedBox(height: 8),
                              TextButton.icon(
                                onPressed: _pickLogoImage,
                                icon: const Icon(Icons.photo_library, size: 16),
                                label: const Text('Pilih Logo Kabinet'),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Nama Kabinet
                        TextFormField(
                          controller: _namaKabinetController,
                          decoration: InputDecoration(
                            labelText: 'Nama Kabinet *',
                            hintText: 'Contoh: Kabinet Abhinaya',
                            prefixIcon: const Icon(Icons.title),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          validator: (value) => value == null || value.trim().isEmpty
                              ? 'Nama Kabinet tidak boleh kosong'
                              : null,
                        ),
                        const SizedBox(height: 14),

                        // Tagline
                        TextFormField(
                          controller: _taglineController,
                          decoration: InputDecoration(
                            labelText: 'Tagline',
                            hintText: 'Contoh: Sinergi dalam Karya',
                            prefixIcon: const Icon(Icons.format_quote),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                        ),
                        const SizedBox(height: 14),

                        // Periode
                        TextFormField(
                          controller: _periodeController,
                          decoration: InputDecoration(
                            labelText: 'Periode *',
                            hintText: 'Contoh: 2025/2026',
                            prefixIcon: const Icon(Icons.calendar_today),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          validator: (value) => value == null || value.trim().isEmpty
                              ? 'Periode tidak boleh kosong'
                              : null,
                        ),
                        const SizedBox(height: 14),

                        // Deskripsi Kabinet
                        TextFormField(
                          controller: _deskripsiKabinetController,
                          maxLines: 3,
                          decoration: InputDecoration(
                            labelText: 'Deskripsi Kabinet',
                            hintText: 'Deskripsi singkat mengenai filosofi kabinet...',
                            prefixIcon: const Icon(Icons.description),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),

                        // Save Kabinet Button
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            onPressed: state.isSubmitting
                                ? null
                                : () => _submitKabinet(state.kabinet),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF0175C8),
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            icon: state.isSubmitting
                                ? const SizedBox(
                                    width: 18,
                                    height: 18,
                                    child: CircularProgressIndicator(
                                      color: Colors.white,
                                      strokeWidth: 2,
                                    ),
                                  )
                                : const Icon(Icons.save),
                            label: Text(
                              state.isSubmitting
                                  ? 'Menyimpan...'
                                  : 'Simpan Informasi Kabinet',
                              style: const TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                // SECTION 2: EDIT ABOUT (VISI, MISI, SEJARAH)
                _buildCardSection(
                  title: 'Profil HIMTIKA (Visi, Misi & Sejarah)',
                  icon: Icons.article_outlined,
                  child: Form(
                    key: _formKeyAbout,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Visi
                        TextFormField(
                          controller: _visiController,
                          maxLines: 3,
                          decoration: InputDecoration(
                            labelText: 'Visi HIMTIKA *',
                            hintText: 'Tuliskan visi HIMTIKA...',
                            prefixIcon: const Icon(Icons.visibility),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          validator: (value) => value == null || value.trim().isEmpty
                              ? 'Visi tidak boleh kosong'
                              : null,
                        ),
                        const SizedBox(height: 20),

                        // Dynamic Misi Section
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Misi HIMTIKA',
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF1E1E1E),
                              ),
                            ),
                            TextButton.icon(
                              onPressed: _addMisiField,
                              icon: const Icon(Icons.add_circle, size: 18),
                              label: const Text('Tambah Misi'),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),

                        ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: _misiControllers.length,
                          itemBuilder: (context, index) {
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 10),
                              child: Row(
                                children: [
                                  CircleAvatar(
                                    radius: 14,
                                    backgroundColor: const Color(0xFF0175C8),
                                    child: Text(
                                      '${index + 1}',
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: TextFormField(
                                      controller: _misiControllers[index],
                                      decoration: InputDecoration(
                                        hintText: 'Poin Misi ${index + 1}',
                                        border: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(10),
                                        ),
                                        contentPadding: const EdgeInsets.symmetric(
                                          horizontal: 12,
                                          vertical: 10,
                                        ),
                                      ),
                                    ),
                                  ),
                                  IconButton(
                                    icon: const Icon(
                                      Icons.delete_outline,
                                      color: Colors.redAccent,
                                    ),
                                    onPressed: () => _removeMisiField(index),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),

                        const SizedBox(height: 16),

                        // Sejarah HIMTIKA
                        TextFormField(
                          controller: _sejarahController,
                          maxLines: 6,
                          decoration: InputDecoration(
                            labelText: 'Sejarah HIMTIKA *',
                            hintText: 'Tuliskan sejarah berdirinya HIMTIKA...',
                            prefixIcon: const Icon(Icons.history_edu),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          validator: (value) => value == null || value.trim().isEmpty
                              ? 'Sejarah tidak boleh kosong'
                              : null,
                        ),
                        const SizedBox(height: 20),

                        // Save About Button
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            onPressed: state.isSubmitting
                                ? null
                                : () => _submitAbout(state.about),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF0175C8),
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            icon: state.isSubmitting
                                ? const SizedBox(
                                    width: 18,
                                    height: 18,
                                    child: CircularProgressIndicator(
                                      color: Colors.white,
                                      strokeWidth: 2,
                                    ),
                                  )
                                : const Icon(Icons.save),
                            label: Text(
                              state.isSubmitting
                                  ? 'Menyimpan...'
                                  : 'Simpan Profil HIMTIKA',
                              style: const TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildCardSection({
    required String title,
    required IconData icon,
    required Widget child,
  }) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(18.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: const Color(0xFF0175C8), size: 24),
                const SizedBox(width: 10),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1E1E1E),
                  ),
                ),
              ],
            ),
            const Divider(height: 24, thickness: 1),
            child,
          ],
        ),
      ),
    );
  }
}
