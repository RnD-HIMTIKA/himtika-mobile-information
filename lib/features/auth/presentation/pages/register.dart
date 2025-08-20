import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/injection_container.dart';
import '../blocs/registration/registration_bloc.dart';
import 'login.dart';
import 'otp_verification.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();
  bool _obscurePassword = true;
  bool _agreeTerms = false;

  // HAPUS metode _onSignUpPressed() dari sini untuk menghindari kebingungan
  // void _onSignUpPressed() { ... }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<RegistrationBloc>(),
      child: BlocListener<RegistrationBloc, RegistrationState>(
        listener: (context, state) {
          if (state is RegistrationSuccess) {
            // Navigasi ke halaman OTP dengan membawa email
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => OTPVerificationPage(email: state.email)),
            );
          } else if (state is RegistrationFailure) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Registrasi Gagal: ${state.error}')),
            );
          }
        },
        // Widget Builder di sini menyediakan context baru yang bisa melihat BLoC
        child: Builder(
          builder: (context) {
            return Scaffold(
              body: LayoutBuilder(
                builder: (scaffoldContext, constraints) {
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
                                // ... (UI Header Anda tetap sama) ...
                                const SizedBox(height: 46),
                                Center(
                                  child: Image.asset(
                                    'src/features/login&register/images/himtika.png',
                                    height: 58,
                                  ),
                                ),
                                const SizedBox(height: 24),
                                ConstrainedBox(
                                  constraints: const BoxConstraints(maxWidth: 400),
                                  child: Card(
                                    color: Colors.grey[100],
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(16),
                                    ),
                                    elevation: 4,
                                    child: Padding(
                                      padding: const EdgeInsets.all(24),
                                      child: Column(
                                        children: [
                                          _buildTextField('Email', _emailController, false),
                                          const SizedBox(height: 16),
                                          _buildTextField('Create Password', _passwordController, true),
                                          const SizedBox(height: 16),
                                          _buildTextField('Confirm Password', _confirmPasswordController, true),
                                          const SizedBox(height: 8),
                                          _buildTermsCheckbox(),
                                          const SizedBox(height: 16),
                                          // Tombol Sign Up sekarang menggunakan context dari Builder
                                          _buildSignUpButton(context), 
                                          const SizedBox(height: 16),
                                          _buildSignInRedirect(),
                                        ],
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
          }
        ),
      ),
    );
  }

  Widget _buildTermsCheckbox() {
    // ... (kode widget ini tetap sama)
    return Row(
      children: [
        Checkbox(
          value: _agreeTerms,
          onChanged: (value) => setState(() => _agreeTerms = value ?? false),
        ),
        const Expanded(
          child: Text.rich(
            TextSpan(
              text: 'Dengan mendaftar, Anda menyetujui ',
              children: [
                TextSpan(
                  text: 'Syarat & Ketentuan ',
                  style: TextStyle(color: Colors.blue, fontWeight: FontWeight.bold),
                ),
                TextSpan(text: 'dan '),
                TextSpan(
                  text: 'Kebijakan Privasi',
                  style: TextStyle(color: Colors.blue, fontWeight: FontWeight.bold),
                ),
                TextSpan(text: ' kami.'),
              ],
            ),
            style: TextStyle(fontSize: 12),
          ),
        ),
      ],
    );
  }

  // UBAH: Widget ini sekarang menerima BuildContext
  Widget _buildSignUpButton(BuildContext context) {
    return BlocBuilder<RegistrationBloc, RegistrationState>(
      builder: (context, state) {
        return SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF1791E4),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            onPressed: state is RegistrationLoading
                ? null
                : () {
                    // Logika validasi sekarang ada di sini, menggunakan context yang benar
                    if (!_agreeTerms) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Anda harus menyetujui Syarat & Ketentuan.')),
                      );
                      return;
                    }
                    if (_passwordController.text != _confirmPasswordController.text) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Password tidak cocok.')),
                      );
                      return;
                    }
                    context.read<RegistrationBloc>().add(SignUpButtonPressed(
                          email: _emailController.text.trim(),
                          password: _passwordController.text.trim(),
                        ));
                  },
            child: state is RegistrationLoading
                ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white))
                : const Text('Sign up'),
          ),
        );
      },
    );
  }

  Widget _buildSignInRedirect() {
    // ... (kode widget ini tetap sama)
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text('Have an account? '),
        GestureDetector(
          onTap: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const LoginPage()),
            );
          },
          child: const Text(
            'Sign in',
            style: TextStyle(color: Colors.blueAccent, fontWeight: FontWeight.bold),
          ),
        ),
      ],
    );
  }

  Widget _buildTextField(String label, TextEditingController controller, bool isPassword) {
    // ... (kode widget ini tetap sama)
    return TextField(
      controller: controller,
      obscureText: isPassword ? _obscurePassword : false,
      decoration: InputDecoration(
        labelText: label,
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        suffixIcon: isPassword
            ? IconButton(
                icon: Icon(_obscurePassword ? Icons.visibility_off : Icons.visibility),
                onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
              )
            : null,
      ),
    );
  }
}