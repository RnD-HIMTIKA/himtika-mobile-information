import 'package:flutter/material.dart';
import 'splash.dart';
import 'register.dart';
import 'continue_with_google.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _obscurePassword = true;
  bool _rememberMe = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
                  physics: const NeverScrollableScrollPhysics(),
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

                              // Tombol Back
                              Align(
                                alignment: Alignment.topLeft,
                                child: Padding(
                                  padding: const EdgeInsets.all(4),
                                  child: GestureDetector(
                                    onTap: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(builder: (context) => const SplashPage()),
                                      );
                                    },
                                    child: Image.asset(
                                      'src/features/login&register/images/arrow_back.png',
                                      height: 24,
                                      width: 24,
                                    ),
                                  ),
                                ),
                              ),

                              const SizedBox(height: 2),
                              // Logo HIMTIKA
                              Center(
                                child: Image.asset(
                                  'src/features/login&register/images/himtika.png',
                                  height: 58,
                                ),
                              ),

                              // Ganti bagian judul dan bintang
                              const SizedBox(height: 4),
                              Stack(
                                children: [
                                  Center(
                                    child: Column(
                                      children: const [
                                        Text(
                                          'Sign in to your',
                                          style: TextStyle(
                                            fontSize: 24,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.white,
                                          ),
                                        ),
                                        Text(
                                          'Account',
                                          style: TextStyle(
                                            fontSize: 24,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.white,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),

                                  // Bintang di pojok kanan
                                  Positioned(
                                    right: 24,
                                    top: 0,
                                    child: Image.asset(
                                      'src/features/login&register/images/bintang.png',
                                      height: 36,
                                    ),
                                  ),
                                ],
                              ),

                              const SizedBox(height: 12),
                              const Text(
                                'Enter your email and password to log in',
                                textAlign: TextAlign.center,
                                style: TextStyle(fontSize: 14, color: Colors.white),
                              ),

                              const SizedBox(height: 12),
                              // Card abu-abu
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
                                        _buildGoogleButton(),
                                        const SizedBox(height: 16),
                                        const Text('Or Login With'),
                                        const SizedBox(height: 16),
                                        _buildTextField('Email', _emailController, false),
                                        const SizedBox(height: 16),
                                        _buildTextField('Password', _passwordController, true),
                                        const SizedBox(height: 8),
                                        Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          children: [
                                            Row(
                                              children: [
                                                Checkbox(
                                                  value: _rememberMe,
                                                  onChanged: (value) {
                                                    setState(() {
                                                      _rememberMe = value ?? false;
                                                    });
                                                  },
                                                ),
                                                const Text('Remember me'),
                                              ],
                                            ),
                                            TextButton(
                                              onPressed: () {},
                                              child: const Text('Forgot Password?'),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 16),
                                        SizedBox(
                                          width: double.infinity,
                                          child: ElevatedButton(
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor: const Color(0xFF1791E4),
                                              foregroundColor: Colors.white,
                                              padding: const EdgeInsets.symmetric(vertical: 16),
                                              shape: RoundedRectangleBorder(
                                                borderRadius: BorderRadius.circular(12),
                                              ),
                                            ),
                                            onPressed: () {},
                                            child: const Text('Log In'),
                                          ),
                                        ),
                                        const SizedBox(height: 16),
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
                                                'Sign up',
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
    );
  }

  Widget _buildGoogleButton() {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton.icon(
        icon: Image.asset('src/features/login&register/images/google.png', height: 20),
        label: const Text('Continue with Google'),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const ContinueWithGoogle()),
          );
        },
        style: OutlinedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(String label, TextEditingController controller, bool isPassword) {
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
                onPressed: () {
                  setState(() {
                    _obscurePassword = !_obscurePassword;
                  });
                },
              )
            : null,
      ),
    );
  }
}
