import 'package:flutter/material.dart';
import 'dart:ui';

class LostsignalScreen extends StatelessWidget {
  const LostsignalScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(
                width: MediaQuery.of(context).size.width * 0.6,
                child: AspectRatio(
                  aspectRatio: 1,
                  child: Stack(
                    alignment: Alignment.center,
                    fit: StackFit.expand,
                    children: [
                      Transform.translate(
                        offset: const Offset(8, 10),
                        child: ImageFiltered(
                          imageFilter: ImageFilter.blur(sigmaX: 4, sigmaY: 4),
                          child: Image.asset(
                            'src/features/utility/signal.png',
                            fit: BoxFit.contain,
                            color: Colors.black.withOpacity(0.3),
                          ),
                        ),
                      ),
                      Image.asset(
                        'src/features/utility/signal.png',
                        fit: BoxFit.contain,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 32),
              ErrorInfo(
                title: "Oh Noo!",
                description: "Sepertinya sinyal kamu kurang bagus nih.",
                btnText: "Kembali ke Halaman Utama",
                press: () {
                  if (Navigator.canPop(context)) {
                    Navigator.pop(context);
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class ErrorInfo extends StatelessWidget {
  const ErrorInfo({
    super.key,
    required this.title,
    required this.description,
    this.button,
    this.btnText,
    required this.press,
  });

  final String title;
  final String description;
  final Widget? button;
  final String? btnText;
  final VoidCallback press;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        constraints: const BoxConstraints(maxWidth: 400),
        alignment: Alignment.center,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              title,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.headlineSmall!.copyWith(
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF007BFF),
                  ),
            ),
            const SizedBox(height: 16),
            Text(
              description,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                    color: Colors.grey.shade700,
                  ),
            ),
            const SizedBox(height: 16 * 2.5),
            button ??
                ElevatedButton(
                  onPressed: press,
                  style: ElevatedButton.styleFrom(
                      minimumSize: const Size(double.infinity, 48),
                      backgroundColor: const Color(0xFF29B6F6),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30))),
                  child: Text(btnText ?? "Retry"),
                ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}
