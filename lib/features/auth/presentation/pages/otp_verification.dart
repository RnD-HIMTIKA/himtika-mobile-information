import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'dart:async';
import '../../../../core/injection_container.dart';
import '../blocs/otp/otp_bloc.dart';
import 'form.dart'; // Halaman tujuan setelah sukses
import 'register.dart'; // Halaman untuk tombol back

class OTPVerificationPage extends StatefulWidget {
  final String email;
  const OTPVerificationPage({super.key, required this.email});

  @override
  State<OTPVerificationPage> createState() => _OTPVerificationPageState();
}

class _OTPVerificationPageState extends State<OTPVerificationPage> {
  final List<TextEditingController> _controllers = List.generate(6, (_) => TextEditingController());
  final List<FocusNode> _focusNodes = List.generate(6, (_) => FocusNode());
  Timer? _timer;
  int _secondsRemaining = 60;

  @override
  void initState() {
    super.initState();
    _startTimer();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focusNodes[0].requestFocus();
    });
  }

  @override
  void dispose() {
    for (var controller in _controllers) {
      controller.dispose();
    }
    for (var node in _focusNodes) {
      node.dispose();
    }
    _timer?.cancel();
    super.dispose();
  }

  void _startTimer() {
    setState(() => _secondsRemaining = 60);
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      if (_secondsRemaining > 0) {
        setState(() => _secondsRemaining--);
      } else {
        _timer?.cancel();
      }
    });
  }

  void _onOtpSubmitted(BuildContext context) {
    if (context.read<OtpBloc>().state is OtpVerificationLoading) return; // Mencegah submit ganda
    final otp = _controllers.map((c) => c.text).join();
    if (otp.length == 6) {
      context.read<OtpBloc>().add(VerifyOtpButtonPressed(otp: otp, email: widget.email));
    }
  }

  void _onResendPressed(BuildContext context) {
    if (_secondsRemaining == 0) {
      context.read<OtpBloc>().add(ResendOtpButtonPressed(email: widget.email));
      _startTimer();
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => sl<OtpBloc>(),
      child: BlocListener<OtpBloc, OtpState>(
        listener: (context, state) {
          if (state is OtpVerificationSuccess) {
            Navigator.of(context).pushAndRemoveUntil(
              // Alur Mengisi Form (dari OTP) -> Ke Form
              MaterialPageRoute(builder: (context) => const ContinueWithGoogle(fromOAuth: false)), // Tandai BUKAN dari OAuth
              (route) => false,
            );
          } else if (state is OtpVerificationFailure) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Verifikasi Gagal: ${state.error}')),
            );
            for (var controller in _controllers) {
              controller.clear();
            }
            _focusNodes[0].requestFocus();
          } else if (state is OtpResendSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Kode OTP baru telah dikirim.')),
            );
          }
        },
        child: Builder(
          builder: (context) {
            final state = context.watch<OtpBloc>().state;
            return Scaffold(
              body: Container(
                width: double.infinity,
                height: double.infinity,
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Color(0xFF006EBD), Color(0xFF0095FF)],
                  ),
                ),
                child: SafeArea(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 32),
                    child: Column(
                      children: [
                        const SizedBox(height: 24),
                        _buildHeader(context),
                        const SizedBox(height: 12),
                        _buildTitle(),
                        const SizedBox(height: 30),
                        _buildOtpFields(context),
                        const SizedBox(height: 20),
                        _buildSubmitButton(context, state),
                        const SizedBox(height: 20),
                        _buildResendButton(context),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildOtpFields(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(6, (index) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: SizedBox(
            width: 45,
            child: TextField(
              controller: _controllers[index],
              focusNode: _focusNodes[index],
              keyboardType: TextInputType.number,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 20, color: Colors.white),
              maxLength: 1,
              decoration: InputDecoration(
                counterText: '',
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Colors.white, width: 1),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Colors.white, width: 2),
                ),
              ),
              onChanged: (value) {
                // Pindahkan fokus ke field selanjutnya jika ada input
                if (value.isNotEmpty && index < 5) {
                  _focusNodes[index + 1].requestFocus();
                }
                // Pindahkan fokus ke field sebelumnya jika input dihapus
                if (value.isEmpty && index > 0) {
                  _focusNodes[index - 1].requestFocus();
                }
                // Jika field terakhir diisi, otomatis submit
                if (value.isNotEmpty && index == 5) {
                  _focusNodes[index].unfocus(); // Tutup keyboard
                  // Panggil submit dengan context yang benar
                  _onOtpSubmitted(context); 
                }
              },
            ),
          ),
        );
      }),
    );
  }

  Widget _buildSubmitButton(BuildContext context, OtpState state) {
    return SizedBox(
      width: 280,
      child: ElevatedButton(
        onPressed: state is OtpVerificationLoading ? null : () => _onOtpSubmitted(context),
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF32b6fe),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          padding: const EdgeInsets.symmetric(vertical: 14),
        ),
        child: state is OtpVerificationLoading
            ? const SizedBox(height: 24, width: 24, child: CircularProgressIndicator(color: Colors.white))
            : const Text('Submit', style: TextStyle(color: Colors.white, fontSize: 16)),
      ),
    );
  }

  Widget _buildResendButton(BuildContext context) {
    bool canResend = _secondsRemaining == 0;
    return SizedBox(
      height: 40,
      child: Center(
        child: canResend
            ? TextButton(
                onPressed: () => _onResendPressed(context),
                style: TextButton.styleFrom(foregroundColor: Colors.white),
                child: const Text(
                  'Kirim Ulang Kode',
                  style: TextStyle(decoration: TextDecoration.underline, fontSize: 14),
                ),
              )
            : Text(
                'Kirim ulang kode dalam 00:${_secondsRemaining.toString().padLeft(2, '0')}',
                style: const TextStyle(color: Colors.white),
              ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Stack(
      children: [
        Align(
          alignment: Alignment.topLeft,
          child: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () {
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(builder: (context) => const RegisterPage()),
              );
            },
          ),
        ),
        Align(
          alignment: Alignment.topRight,
          child: Padding(
            padding: const EdgeInsets.only(right: 4, top: 24),
            child: Image.asset(
              'src/features/login&register/images/bintang.png',
              height: 36,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTitle() {
    return Column(
      children: [
        Center(
          child: Image.asset(
            'src/features/login&register/images/himtika.png',
            height: 60,
          ),
        ),
        const SizedBox(height: 10),
        const Text(
          'Periksa Email Anda',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold, color: Colors.white),
        ),
        const SizedBox(height: 8),
        Text(
          'Kami telah mengirimkan kode ke\n${widget.email}',
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 14, color: Colors.white),
        ),
      ],
    );
  }
}