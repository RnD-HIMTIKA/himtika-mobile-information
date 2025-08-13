import 'package:flutter/material.dart';
import 'splash.dart';
import 'login.dart';

class Onboarding extends StatefulWidget {
  const Onboarding({super.key});

  @override
  State<Onboarding> createState() => _OnboardingState();
}

class _OnboardingState extends State<Onboarding> {
  final PageController _controller = PageController();
  int _currentPage = 0;

  final List<Widget> _pages = [];

  @override
  void initState() {
    super.initState();
    _pages.addAll([
      OnboardingPage(
        title: 'Your Informatics\nHub.',
        highlightedWord: 'Informatics',
        description:
            'The ultimate platform designed to enhance your learning, connect you with peers, and provide essential resources for every informatics student.',
        imagePath: 'src/features/login&register/images/ilustrasi1.png',
      ),
      OnboardingPage(
        title: 'Learn & Grow with\nHiCode.',
        highlightedWord: 'HiCode',
        description:
            'Dive into curated HiCode courses to master new skills, and access vital HIMA information to stay ahead in your studies and career.',
        imagePath: 'src/features/login&register/images/ilustrasi2.png',
      ),
      OnboardingPage(
        title: 'Connect, Chill, & Get\nInstant Help.',
        highlightedWord: 'Instant Help.',
        description:
            'Participate in lively discussions, find a relaxed space in the Chill Area, and always have an AI Chatbot ready to assist you.',
        imagePath: 'src/features/login&register/images/ilustrasi3.png',
      ),
      FinalOnboardingPage(
        title: 'Informatics.\nElevated.',
        highlightedWord: 'Informatics',
        description:
            'Connect, learn, chill, and get all your HIMTIKA insights in one place.',
        imagePath: 'src/features/login&register/images/ilustrasi4.png',
        onStarted: () {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const LoginPage()),
          );
        },
      ),
    ]);
  }

  void _nextPage() {
    if (_currentPage < _pages.length - 1) {
      _controller.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.ease,
      );
    }
  }

  void _prevPage() {
    if (_currentPage == 0) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const SplashScreen()),
      );
    } else {
      _controller.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.ease,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          Expanded(
            child: PageView(
              controller: _controller,
              onPageChanged: (index) {
                setState(() => _currentPage = index);
              },
              children: _pages,
            ),
          ),
          if (_currentPage < 3) ...[
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(3, (index) {
                return Container(
                  margin:
                      const EdgeInsets.symmetric(horizontal: 4, vertical: 12),
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: _currentPage == index ? Colors.blue : Colors.grey,
                  ),
                );
              }),
            ),
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 32.0, vertical: 24),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    onPressed: _prevPage,
                    icon: const Icon(Icons.arrow_back_ios),
                  ),
                  IconButton(
                    onPressed: _nextPage,
                    icon: const Icon(Icons.arrow_forward_ios),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class OnboardingPage extends StatelessWidget {
  final String title;
  final String highlightedWord;
  final String description;
  final String imagePath;

  const OnboardingPage({
    super.key,
    required this.title,
    required this.highlightedWord,
    required this.description,
    required this.imagePath,
  });

  @override
  Widget build(BuildContext context) {
    final textStyle =
        const TextStyle(fontSize: 26, fontWeight: FontWeight.bold);
    final parts = title.split(highlightedWord);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          RichText(
            textAlign: TextAlign.center,
            text: TextSpan(
              style: textStyle.copyWith(color: Colors.black),
              children: [
                TextSpan(text: parts[0]),
                TextSpan(
                  text: highlightedWord,
                  style: textStyle.copyWith(color: Colors.blue),
                ),
                TextSpan(text: parts.length > 1 ? parts[1] : ''),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Text(
            description,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 14),
          ),
          const SizedBox(height: 32),
          Image.asset(imagePath, height: 200),
        ],
      ),
    );
  }
}

class FinalOnboardingPage extends StatelessWidget {
  final String title;
  final String highlightedWord;
  final String description;
  final String imagePath;
  final VoidCallback onStarted;

  const FinalOnboardingPage({
    super.key,
    required this.title,
    required this.highlightedWord,
    required this.description,
    required this.imagePath,
    required this.onStarted,
  });

  @override
  Widget build(BuildContext context) {
    final textStyle =
        const TextStyle(fontSize: 26, fontWeight: FontWeight.bold);
    final parts = title.split(highlightedWord);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          RichText(
            textAlign: TextAlign.center,
            text: TextSpan(
              style: textStyle.copyWith(color: Colors.black),
              children: [
                TextSpan(text: parts[0]),
                TextSpan(
                  text: highlightedWord,
                  style: textStyle.copyWith(color: Colors.blue),
                ),
                TextSpan(text: parts.length > 1 ? parts[1] : ''),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Text(
            description,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 14),
          ),
          const SizedBox(height: 32),
          Image.asset(imagePath, height: 200),
          const SizedBox(height: 32),
          ElevatedButton(
            onPressed: onStarted,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
              padding: const EdgeInsets.symmetric(horizontal: 60, vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text(
              'Started',
              style: TextStyle(fontSize: 16, color: Colors.white),
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'terms of service',
            style: TextStyle(fontSize: 12, color: Colors.grey),
          ),
        ],
      ),
    );
  }
}
