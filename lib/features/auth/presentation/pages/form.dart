import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../blocs/profile_form/form_bloc.dart';
import '../blocs/profile_form/form_event.dart';
import '../blocs/profile_form/form_state.dart';

import 'register_success.dart';

class ContinueWithGoogle extends StatefulWidget {
  const ContinueWithGoogle({super.key});

  @override
  State<ContinueWithGoogle> createState() => _ContinueWithGoogleState();
}

class _ContinueWithGoogleState extends State<ContinueWithGoogle> {
  final supabase = Supabase.instance.client;

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneNumberController = TextEditingController();
  final TextEditingController _dateOfBirthController = TextEditingController();

  final TextEditingController _angkatanController = TextEditingController();
  final TextEditingController _fakultasController = TextEditingController();
  final TextEditingController _prodiController = TextEditingController();
  String? _selectedKelas;

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
        _dateOfBirthController.text =
            '${picked.day}/${picked.month}/${picked.year}';
      });
    }
  }

  /// Cek SQL injection sederhana
  bool _hasSQLInjection(String input) {
    final pattern = RegExp(
        r"(?:')|(?:--)|(/\*)|(\*/)|(;)|(\b(SELECT|INSERT|DELETE|UPDATE|DROP|UNION|OR)\b)",
        caseSensitive: false);
    return pattern.hasMatch(input);
  }

  /// Cek email & username unik di Supabase
  Future<String?> _checkDuplicateUser(String email, String username) async {
    final usernameCheck = await supabase
        .from('users')
        .select()
        .eq('username', username)
        .maybeSingle();

    if (usernameCheck != null) {
      return "Username sudah digunakan.";
    }

    return null;
  }

  List<Step> _getSteps(BuildContext context, ProfileFormState state) {
    final steps = <Step>[
      Step(
        title: const Text('Identitas Diri'),
        content: SingleChildScrollView(
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxHeight: MediaQuery.of(context).size.height * 0.5,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildTextField('Nama Lengkap', _nameController),
                const SizedBox(height: 16),
                _buildTextField('Username', _usernameController),
                const SizedBox(height: 16),
                _buildTextField(
                  'Email',
                  _emailController,
                  keyboardType: TextInputType.emailAddress,
                  readOnly: true,
                ),
                const SizedBox(height: 16),
                _buildTextField(
                  'Phone Number',
                  _phoneNumberController,
                  keyboardType: TextInputType.phone,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _dateOfBirthController,
                  readOnly: true,
                  onTap: () => _selectDate(context),
                  decoration: InputDecoration(
                    labelText: 'Date of Birth',
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    suffixIcon: const Icon(Icons.calendar_today),
                  ),
                ),
              ],
            ),
          ),
        ),
        isActive: state.currentStep >= 0,
        state: state.currentStep > 0 ? StepState.complete : StepState.indexed,
      ),
    ];

    if (state.isFromUnsika) {
      steps.add(
        Step(
          title: const Text('Informasi'),
          content: SingleChildScrollView(  // Added for safety if content grows
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
                  decoration: InputDecoration(
                    labelText: 'Kelas',
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
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

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => ProfileFormBloc(supabase)..add(const ProfileFormStarted()),
      child: BlocConsumer<ProfileFormBloc, ProfileFormState>(
        listenWhen: (prev, curr) =>
            prev.status != curr.status ||
            prev.email != curr.email ||
            prev.username != curr.username,
        listener: (context, state) {
          if (state.status == ProfileFormStatus.loaded) {
            _emailController.text = state.email ?? '';
            _usernameController.text = state.username ?? '';
            _angkatanController.text = state.angkatan ?? '';
            _fakultasController.text = state.fakultas ?? '';
            _prodiController.text = state.prodi ?? '';
          }

          if (state.status == ProfileFormStatus.success) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => const RegisterSuccess()),
            );
          }

          if (state.status == ProfileFormStatus.failure &&
              (state.errorMessage ?? '').isNotEmpty) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.errorMessage!)),
            );
          }
        },
        builder: (context, state) {
          final isLoading = state.status == ProfileFormStatus.loading ||
              state.status == ProfileFormStatus.submitting;

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
                                  value: (state.totalSteps ?? 1) == 0
                                      ? 0
                                      : ((state.currentStep + 1) /
                                          (state.totalSteps ?? 1)),
                                  minHeight: 6,
                                  color: Colors.white,
                                  backgroundColor: Colors.white24,
                                ),
                              ),
                              const SizedBox(height: 8),
                              ConstrainedBox(
                                constraints: BoxConstraints(
                                  maxWidth: 400,
                                  maxHeight: MediaQuery.of(context).size.height * 0.6,  // Added to bound Stepper height
                                ),
                                child: Card(
                                  color: Colors.grey[100],
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  elevation: 4,
                                  child: Padding(
                                    padding: const EdgeInsets.all(24),
                                    child: isLoading
                                        ? const Center(child: CircularProgressIndicator())
                                        : Stepper(
                                            type: StepperType.horizontal,
                                            currentStep: state.currentStep,
                                            onStepContinue: () async {
                                              final steps = _getSteps(context, state);
                                              final lastIndex = steps.length - 1;

                                              if (state.currentStep == 0) {
                                                if (_nameController.text.trim().isEmpty ||
                                                    _usernameController.text.trim().isEmpty ||
                                                    _phoneNumberController.text.trim().isEmpty) {
                                                  ScaffoldMessenger.of(context).showSnackBar(
                                                    const SnackBar(
                                                        content: Text('Semua field wajib diisi')),
                                                  );
                                                  return;
                                                }

                                                if (_hasSQLInjection(_nameController.text) ||
                                                    _hasSQLInjection(_usernameController.text)) {
                                                  ScaffoldMessenger.of(context).showSnackBar(
                                                    const SnackBar(
                                                        content: Text('Input terdeteksi tidak aman')),
                                                  );
                                                  return;
                                                }

                                                if (_phoneNumberController.text.length < 10 ||
                                                    _phoneNumberController.text.length > 15) {
                                                  ScaffoldMessenger.of(context).showSnackBar(
                                                    const SnackBar(
                                                        content: Text('Nomor telepon tidak valid')),
                                                  );
                                                  return;
                                                }

                                                final duplicateMsg =
                                                    await _checkDuplicateUser(
                                                        _emailController.text.trim(),
                                                        _usernameController.text.trim());
                                                if (duplicateMsg != null) {
                                                  ScaffoldMessenger.of(context).showSnackBar(
                                                    SnackBar(content: Text(duplicateMsg)),
                                                  );
                                                  return;
                                                }
                                              }

                                              if (state.currentStep < lastIndex) {
                                                context
                                                    .read<ProfileFormBloc>()
                                                    .add(const ProfileFormNextStep());
                                              } else {
                                                context.read<ProfileFormBloc>().add(
                                                      ProfileFormSubmitted(
                                                        fullName:
                                                            _nameController.text.trim(),
                                                        username:
                                                            _usernameController.text.trim(),
                                                        email:
                                                            _emailController.text.trim(),
                                                        phone: _phoneNumberController.text
                                                            .trim(),
                                                        dob: _dateOfBirthController.text
                                                            .trim(),
                                                        kelas: _selectedKelas,
                                                      ),
                                                    );
                                              }
                                            },
                                            onStepCancel: () {
                                              if (state.currentStep > 0) {
                                                context
                                                    .read<ProfileFormBloc>()
                                                    .add(const ProfileFormPrevStep());
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
      ),
    );
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

  Widget _buildTextField(
    String label,
    TextEditingController controller, {
    TextInputType keyboardType = TextInputType.text,
    List<TextInputFormatter>? inputFormatters,
    bool readOnly = false,
  }) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      inputFormatters: inputFormatters,
      readOnly: readOnly,
      decoration: InputDecoration(
        labelText: label,
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }
}