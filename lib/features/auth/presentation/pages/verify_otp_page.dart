import 'package:flutter/material.dart';

class VerifyOtpPage extends StatelessWidget {
  const VerifyOtpPage({super.key});

  @override
  Widget build(BuildContext context) {
    final TextEditingController otpController = TextEditingController();

    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Center(
          child: Card(
            elevation: 4,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'Verify OTP',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  const Text('Please enter the OTP sent to your email'),
                  const SizedBox(height: 16),
                  TextField(
                    controller: otpController,
                    decoration: const InputDecoration(
                      labelText: 'OTP Code',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pushNamed(context, '/reset-password');
                      },
                      child: const Text('Verify'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
