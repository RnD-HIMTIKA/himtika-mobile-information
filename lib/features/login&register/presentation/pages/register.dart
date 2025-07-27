import 'package:flutter/material.dart';
import 'login.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();
  bool _obscurePassword = true;
  bool _agreeTerms = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: LayoutBuilder(
        builder: (context, constraints) {
          return Stack(
            children: [
              // Background atas biru, bawah putih
              Column(
                children: [
                  Container(
                    height: constraints.maxHeight * 0.6,
                    color: const Color(0xFF0175C8),
                  ),
                  Expanded(child: Container(color: Colors.white)),
                ],
              ),

              // Isi konten
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
                        // Tombol back (di kiri atas)
                        // Align(
                        //   alignment: Alignment.topLeft,
                        //   child: Padding(
                        //     padding: const EdgeInsets.only(left: 16),
                        //     child: GestureDetector(
                        //       onTap: () {
                        //         Navigator.pop(context);
                        //       },
                        //       child: Image.asset(
                        //         'src/features/login&register/images/arrow_back.png',
                        //         height: 24,
                        //         width: 24,
                        //         color: Colors.white,
                        //       ),
                        //     ),
                        //   ),
                        // ),

                        const SizedBox(height: 12),

                        // Logo Himtika di tengah
                        Center(
                          child: Image.asset(
                            'src/features/login&register/images/himtika.png',
                            height: 58,
                          ),
                        ),


                        const SizedBox(height: 2),

                        // Judul & bintang
                        Padding(
                          padding: const EdgeInsets.only(top: 16, left: 24, right: 16),
                          child: Stack(
                            children: [
                              Center(
                                child: Column(
                                  children: const [
                                    Text(
                                      'Create your new',
                                      style: TextStyle(
                                        fontSize: 24,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                      ),
                                    ),
                                    Text(
                                      'account',
                                      style: TextStyle(
                                        fontSize: 24,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Positioned(
                                top: 0,
                                right: 0,
                                child: Image.asset(
                                  'src/features/login&register/images/bintang.png',
                                  height: 38,
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 12),
                        const Text(
                          'Sign up to unlock all features',
                          style: TextStyle(color: Colors.white),
                        ),
                        const SizedBox(height: 24),

                        // Card isi form
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
                                  _buildTextField('Nama Lengkap', _nameController, false),
                                  const SizedBox(height: 16),
                                  _buildTextField('Email', _emailController, false),
                                  const SizedBox(height: 16),
                                  _buildTextField('Create Password', _passwordController, true),
                                  const SizedBox(height: 16),
                                  _buildTextField('Confirm Password', _confirmPasswordController, true),
                                  const SizedBox(height: 8),
                                  Row(
                                    children: [
                                      Checkbox(
                                        value: _agreeTerms,
                                        onChanged: (value) {
                                          setState(() {
                                            _agreeTerms = value ?? false;
                                          });
                                        },
                                      ),
                                      const Expanded(
                                        child: Text.rich(
                                          TextSpan(
                                            text: 'Dengan mendaftar, Anda menyetujui ',
                                            children: [
                                              TextSpan(
                                                text: 'Syarat & Ketentuan ',
                                                style: TextStyle(
                                                  color: Colors.blue,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                              TextSpan(text: 'dan '),
                                              TextSpan(
                                                text: 'Kebijakan Privasi',
                                                style: TextStyle(
                                                  color: Colors.blue,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                              TextSpan(text: ' kami.'),
                                            ],
                                          ),
                                          style: TextStyle(fontSize: 12),
                                        ),
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
                                      child: const Text('Sign up'),
                                    ),
                                  ),
                                  const SizedBox(height: 16),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      const Text('Have an account? '),
                                      GestureDetector(
                                        onTap: () {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(builder: (context) => const LoginPage()),
                                          );
                                        },
                                        child: const Text(
                                          'Sign in',
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
