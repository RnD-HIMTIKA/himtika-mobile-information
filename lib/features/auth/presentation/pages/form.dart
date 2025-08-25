import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:himtika_mobile_information/core/injection_container.dart';
import '../blocs/profile_form/form_bloc.dart';
import '../blocs/profile_form/form_event.dart';
import '../blocs/profile_form/form_state.dart';

import 'register_success.dart';

// Widget ini sekarang hanya bertanggung jawab untuk menyediakan BLoC.
class ContinueWithGoogle extends StatelessWidget {
  final bool fromOAuth;
  const ContinueWithGoogle({super.key, required this.fromOAuth});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<ProfileFormBloc>(),
      child: _FormContent(fromOAuth: fromOAuth),
    );
  }
}

// Semua UI dan stateful logic berada di dalam widget ini.
class _FormContent extends StatefulWidget {
  final bool fromOAuth;
  const _FormContent({required this.fromOAuth});

  @override
  State<_FormContent> createState() => _FormContentState();
}

class _FormContentState extends State<_FormContent> {
  // Semua controller dan state yang sebelumnya ada, dikembalikan ke sini.
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneNumberController = TextEditingController();
  final TextEditingController _dateOfBirthController = TextEditingController();

  final TextEditingController _angkatanController = TextEditingController();
  final TextEditingController _fakultasController = TextEditingController();
  final TextEditingController _prodiController = TextEditingController();
  String? _selectedKelas;
  
  final _formStep1Key = GlobalKey<FormState>();
  final _formStep2Key = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    // Perbaikan error: event dipanggil setelah frame pertama selesai di-render.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        context.read<ProfileFormBloc>().add(const ProfileFormStarted());
      }
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _usernameController.dispose();
    _emailController.dispose();
    _phoneNumberController.dispose();
    _dateOfBirthController.dispose();
    _angkatanController.dispose();
    _fakultasController.dispose();
    _prodiController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime(2000),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );

    if (picked != null) {
      setState(() {
        _dateOfBirthController.text = '${picked.day}/${picked.month}/${picked.year}';
      });
      // Memvalidasi ulang form setelah tanggal dipilih.
      _formStep1Key.currentState?.validate();
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<ProfileFormBloc, ProfileFormState>(
      // listenWhen membuat listener lebih efisien, hanya berjalan saat kondisi terpenuhi.
      listenWhen: (previous, current) {
        // Jalankan listener jika status berubah ATAU jika ada pesan error baru.
        return previous.status != current.status || (current.errorMessage != null && previous.errorMessage != current.errorMessage);
      },
      listener: (context, state) {
        // 1. Logika prefill data
        if (state.status == ProfileFormStatus.loaded) {
          _emailController.text = state.email ?? '';
          _angkatanController.text = state.angkatan ?? '';
          _fakultasController.text = state.fakultas ?? '';
          _prodiController.text = state.prodi ?? '';
          
          // Jaga agar username yang diketik pengguna tidak terhapus
          if (_usernameController.text.isEmpty) {
            _usernameController.text = state.username ?? '';
          }
        }

        // 2. Logika menampilkan pesan error
        // Tampilkan SnackBar setiap kali ada errorMessage di state.
        if (state.errorMessage != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.errorMessage!),
              backgroundColor: Colors.red,
            ),
          );
        }

        // 3. Logika navigasi saat sukses
        if (state.status == ProfileFormStatus.success) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => RegisterSuccess(fromOAuth: widget.fromOAuth)),
          );
        }
      },
      builder: (context, state) {
        final isProcessing = state.status == ProfileFormStatus.loading;

        return Scaffold(
          body: LayoutBuilder(
            builder: (context, constraints) {
              return Stack(
                children: [
                  Column(
                    children: [
                      Container(
                        height: constraints.maxHeight * 0.6,
                        color: const Color(0xFF0175C8),
                      ),
                      Expanded(child: Container(color: Colors.white)),
                    ],
                  ),
                  SafeArea(
                    child: SingleChildScrollView(
                      child: Padding(
                        padding: EdgeInsets.only(
                          left: 16,
                          right: 16,
                          bottom: MediaQuery.of(context).viewInsets.bottom + 16,
                        ),
                        child: Column(
                          children: [
                            const SizedBox(height: 16),
                            _buildHeader(),
                            const SizedBox(height: 24),
                            ConstrainedBox(
                              constraints: const BoxConstraints(maxWidth: 400),
                              child: LinearProgressIndicator(
                                value: state.totalSteps == 0 ? 0 : ((state.currentStep + 1) / state.totalSteps),
                                minHeight: 6,
                                color: Colors.white,
                                backgroundColor: Colors.white24,
                              ),
                            ),
                            const SizedBox(height: 8),
                            ConstrainedBox(
                              constraints: BoxConstraints(
                                maxWidth: 400,
                                maxHeight: MediaQuery.of(context).size.height * 0.65,
                              ),
                              child: Card(
                                color: Colors.grey[100],
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                elevation: 4,
                                child: Padding(
                                  padding: const EdgeInsets.all(24),
                                  child: isProcessing
                                      ? const Center(child: CircularProgressIndicator())
                                      : Stepper(
                                          controlsBuilder: (BuildContext context, ControlsDetails details) {
                                            final formState = context.watch<ProfileFormBloc>().state;
                                            
                                            // Tampilkan loading jika sedang validasi ATAU submit
                                            if (formState.status == ProfileFormStatus.validating ||
                                                formState.status == ProfileFormStatus.submitting) {
                                              return const Center(child: Padding(
                                                padding: EdgeInsets.all(8.0),
                                                child: CircularProgressIndicator(),
                                              ));
                                            }
                                            
                                            // Jika tidak loading, tampilkan tombol seperti biasa
                                            return Row(
                                              mainAxisAlignment: MainAxisAlignment.end,
                                              children: <Widget>[
                                                if (formState.currentStep > 0)
                                                  TextButton(
                                                    onPressed: details.onStepCancel,
                                                    child: const Text('KEMBALI'),
                                                  ),
                                                const SizedBox(width: 12),
                                                ElevatedButton(
                                                  onPressed: details.onStepContinue,
                                                  child: Text(formState.currentStep == _getSteps(context, formState).length - 1 ? 'SIMPAN' : 'LANJUT'),
                                                ),
                                              ],
                                            );
                                          },
                                          type: StepperType.vertical,
                                          currentStep: state.currentStep,
                                          onStepContinue: () {
                                            final state = context.read<ProfileFormBloc>().state;
                                            final isLastStep = state.currentStep == _getSteps(context, state).length - 1;

                                            // Jika ini adalah langkah terakhir (baik untuk user Unsika di hal 2, maupun non-Unsika di hal 1)
                                            if (isLastStep) {
                                              // Validasi form lokal untuk langkah terakhir terlebih dahulu
                                              if (state.isFromUnsika) {
                                                if (!(_formStep2Key.currentState?.validate() ?? false)) return;
                                              } else {
                                                if (!(_formStep1Key.currentState?.validate() ?? false)) return;
                                              }
                                              
                                              // Jika valid, langsung panggil event submit
                                              context.read<ProfileFormBloc>().add(
                                                    ProfileFormSubmitted(
                                                      fullName: _nameController.text,
                                                      username: _usernameController.text,
                                                      email: _emailController.text,
                                                      phone: _phoneNumberController.text,
                                                      dob: _dateOfBirthController.text,
                                                      kelas: _selectedKelas,
                                                    ),
                                                  );
                                            } 
                                            // Jika ini BUKAN langkah terakhir (hanya mungkin untuk user Unsika di hal 1)
                                            else {
                                              // Panggil event untuk validasi lengkap (termasuk cek duplikasi ke server)
                                              context.read<ProfileFormBloc>().add(
                                                    ProfileFormValidateStep1(
                                                      fullName: _nameController.text,
                                                      username: _usernameController.text,
                                                      phone: _phoneNumberController.text,
                                                      dob: _dateOfBirthController.text,
                                                    ),
                                                  );
                                            }
                                          },
                                          onStepCancel: () {
                                            if (state.currentStep > 0) {
                                              context.read<ProfileFormBloc>().add(const ProfileFormPrevStep());
                                            }
                                          },
                                          steps: _getSteps(context, state),
                                        ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        );
      },
    );
  }

  // Semua metode pembantu UI dikembalikan ke sini.
  List<Step> _getSteps(BuildContext context, ProfileFormState state) {
    final steps = <Step>[
      Step(
        title: const Text('Identitas Diri'),
        content: Form(
          key: _formStep1Key,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildTextFormField('Nama Lengkap', _nameController),
              const SizedBox(height: 16),
              _buildTextFormField('Username', _usernameController),
              const SizedBox(height: 16),
              _buildTextFormField(
                'Email',
                _emailController,
                keyboardType: TextInputType.emailAddress,
                readOnly: true, // Email dibuat read-only
                validator: null,
              ),
              const SizedBox(height: 16),
              _buildTextFormField(
                'Phone Number',
                _phoneNumberController,
                keyboardType: TextInputType.phone,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _dateOfBirthController,
                readOnly: true,
                onTap: () => _selectDate(context),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Tanggal lahir tidak boleh kosong.';
                  }
                  return null;
                },
                decoration: InputDecoration(
                  labelText: 'Date of Birth',
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  suffixIcon: const Icon(Icons.calendar_today),
                ),
              ),
            ],
          ),
        ),
        isActive: state.currentStep >= 0,
        state: state.currentStep > 0 ? StepState.complete : StepState.indexed,
      ),
    ];

    if (state.isFromUnsika) {
      steps.add(
        Step(
          title: const Text('Informasi Akademik'),
          content: Form(
            key: _formStep2Key,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildTextField('Angkatan', _angkatanController, readOnly: true),
                const SizedBox(height: 16),
                _buildTextField('Fakultas', _fakultasController, readOnly: true),
                const SizedBox(height: 16),
                _buildTextField('Program Studi', _prodiController, readOnly: true),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  value: _selectedKelas,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Silakan pilih kelas Anda.';
                    }
                    return null;
                  },
                  decoration: InputDecoration(
                    labelText: 'Kelas',
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  items: ['A', 'B', 'C', 'D', 'E', 'F']
                      .map((kelas) => DropdownMenuItem<String>(
                            value: kelas,
                            child: Text(kelas),
                          ))
                      .toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedKelas = value;
                    });
                  },
                ),
              ],
            ),
          ),
          isActive: state.currentStep >= 1,
          state: state.currentStep > 1 ? StepState.complete : StepState.indexed,
        ),
      );
    }
    return steps;
  }

  Widget _buildHeader() {
    return Column(
      children: [
        Align(
          alignment: Alignment.topLeft,
          child: GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Image.asset(
              'src/features/login&register/images/arrow_back.png',
              height: 24,
              width: 24,
              color: Colors.white,
            ),
          ),
        ),
        const SizedBox(height: 12),
        Center(
          child: Image.asset(
            'src/features/login&register/images/himtika.png',
            height: 58,
          ),
        ),
        const SizedBox(height: 12),
        const Text(
          'Let\'s complete your profile so we can tailor your experience!',
          textAlign: TextAlign.center,
          style: TextStyle(color: Colors.white),
        ),
      ],
    );
  }
  
  // Menggunakan TextFormField untuk field yang read-only agar tetap terlihat konsisten
  Widget _buildTextField(
    String label,
    TextEditingController controller, {
    bool readOnly = false,
  }) {
    return TextFormField(
      controller: controller,
      readOnly: readOnly,
      decoration: InputDecoration(
        labelText: label,
        filled: true,
        fillColor: readOnly ? Colors.grey[200] : Colors.white,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  Widget _buildTextFormField(
    String label,
    TextEditingController controller, {
    TextInputType keyboardType = TextInputType.text,
    List<TextInputFormatter>? inputFormatters,
    bool readOnly = false,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      inputFormatters: inputFormatters,
      readOnly: readOnly,
      validator: validator ??
          (value) {
            if (value == null || value.trim().isEmpty) {
              return '$label tidak boleh kosong.';
            }
            return null;
          },
      decoration: InputDecoration(
        labelText: label,
        filled: true,
        fillColor: readOnly ? Colors.grey[200] : Colors.white,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }
}