import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:himtika_mobile_information/features/login&register/forgot_password/presentation/pages/verify_otp_page.dart';
import 'package:himtika_mobile_information/features/login&register/presentation/pages/login.dart';
import 'package:himtika_mobile_information/features/login&register/presentation/pages/register.dart';
import '../bloc/forgot_password_bloc.dart';
import '../bloc/forgot_password_event.dart';
import '../bloc/forgot_password_state.dart';

class ForgotPasswordPage extends StatefulWidget {
  const ForgotPasswordPage({super.key});

  @override
  State<ForgotPasswordPage> createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
  final TextEditingController _emailController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => ForgotPasswordBloc(),
      child: Scaffold(
        body: LayoutBuilder(
          builder: (context, constraints) {
            return Stack(
              children: [
                // Background biru atas dan putih bawah
                Column(
                  children: [
                    Container(
                      height: constraints.maxHeight * 0.5,
                      color: const Color(0xFF0175C8),
                    ),
                    Expanded(
                      child: Container(color: Colors.white),
                    ),
                  ],
                ),

                // Konten utama
                SafeArea(
                  child: SingleChildScrollView(
                    child: ConstrainedBox(
                      constraints: BoxConstraints(minHeight: constraints.maxHeight),
                      child: IntrinsicHeight(
                        child: Center(
                          child: Padding(
                            padding: EdgeInsets.only(
                              left: 16,
                              right: 16,
                              bottom: MediaQuery.of(context).viewInsets.bottom + 16,
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                const SizedBox(height: 16),

                                // Tombol Back & Bintang
                                Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      GestureDetector(
                                        onTap: () {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(builder: (context) => const LoginPage()),
                                          );
                                        },
                                        child: Image.asset(
                                          'src/features/login&register/images/arrow_back.png',
                                          height: 24,
                                          width: 24,
                                        ),
                                      ),
                                      Image.asset(
                                        'src/features/login&register/images/bintang.png',
                                        height: 36,
                                      ),
                                    ],
                                  ),
                                ),

                                const SizedBox(height: 16),

                                // Judul dan deskripsi
                                Column(
                                  children: const [
                                    Text(
                                      'Forgot Password?',
                                      style: TextStyle(
                                        fontSize: 24,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                      ),
                                    ),
                                    SizedBox(height: 4),
                                    Text(
                                      'Don\'t worry! It happens. Please enter the\nemail associated with your account.',
                                      textAlign: TextAlign.center,
                                      style: TextStyle(fontSize: 14, color: Colors.white),
                                    ),
                                  ],
                                ),

                                const SizedBox(height: 24),

                                // Kartu email input + tombol + sign up
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
                                          TextField(
                                            controller: _emailController,
                                            keyboardType: TextInputType.emailAddress,
                                            decoration: const InputDecoration(
                                              labelText: 'Enter Email',
                                              border: OutlineInputBorder(),
                                            ),
                                          ),
                                          const SizedBox(height: 24),

                                          // Button submit
                                          BlocConsumer<ForgotPasswordBloc, ForgotPasswordState>(
                                            listener: (context, state) {
                                              if (state is ForgotPasswordSuccess) {
                                                Navigator.push(
                                                  context,
                                                  MaterialPageRoute(builder: (context) => const VerifyOtpPage()),
                                                );
                                              } else if (state is ForgotPasswordFailure) {
                                                ScaffoldMessenger.of(context).showSnackBar(
                                                  SnackBar(content: Text(state.message)),
                                                );
                                              }
                                            },
                                            builder: (context, state) {
                                              return SizedBox(
                                                width: double.infinity,
                                                height: 48,
                                                child: ElevatedButton(
                                                  onPressed: state is ForgotPasswordLoading
                                                      ? null
                                                      : () {
                                                          final email = _emailController.text.trim();
                                                          context.read<ForgotPasswordBloc>().add(
                                                                ForgotPasswordSubmitted(email),
                                                              );
                                                        },
                                                  style: ElevatedButton.styleFrom(
                                                    backgroundColor: const Color(0xFF1791E4),
                                                    shape: RoundedRectangleBorder(
                                                      borderRadius: BorderRadius.circular(12),
                                                    ),
                                                  ),
                                                  child: state is ForgotPasswordLoading
                                                      ? const CircularProgressIndicator(
                                                          color: Colors.white,
                                                        )
                                                      : const Text(
                                                          "Submit",
                                                          style: TextStyle(
                                                            fontWeight: FontWeight.bold,
                                                            color: Colors.white,
                                                          ),
                                                        ),
                                                ),
                                              );
                                            },
                                          ),

                                          const SizedBox(height: 16),

                                          // Sign up DITEMPATKAN DI DALAM CARD
                                          Row(
                                            mainAxisAlignment: MainAxisAlignment.center,
                                            children: [
                                              const Text("Don't have an account? "),
                                              GestureDetector(
                                                onTap: () {
                                                  Navigator.push(
                                                    context,
                                                    MaterialPageRoute(builder: (context) => const RegisterPage()),
                                                  );
                                                },
                                                child: const Text(
                                                  'Sign Up',
                                                  style: TextStyle(
                                                    color: Colors.blueAccent,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),

                                const Spacer(),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }
}
