import 'package:flutter/material.dart';
import 'login.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  final PageController _controller = PageController();
  int _currentPage = 0;

  final List<Widget> _pages = [
    OnboardingPage(
      title: 'Your Informatics\nHub.',
      highlightedWord: 'Informatics',
      description: 'The ultimate platform designed to enhance your learning, connect you with peers, and provide essential resources for every informatics student.',
      imagePath: 'src/features/login&register/images/splash1.png',
    ),
    OnboardingPage(
      title: 'Learn & Grow with\nHiCode.',
      highlightedWord: 'HiCode',
      description: 'Dive into curated HiCode courses to master new skills, and access vital HIMA information to stay ahead in your studies and career.',
      imagePath: 'src/features/login&register/images/splash2.png',
    ),
    OnboardingPage(
      title: 'Connect, Chill, & Get\nInstant Help.',
      highlightedWord: 'Instant Help.',
      description: 'Participate in lively discussions, find a relaxed space in the Chill Area, and always have an AI Chatbot ready to assist you.',
      imagePath: 'src/features/login&register/images/splash3.png',
      isLast: true,
    ),
  ];

  void _nextPage() {
    if (_currentPage < _pages.length - 1) {
      _controller.nextPage(duration: const Duration(milliseconds: 300), curve: Curves.ease);
    } else {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const LoginPage()),
      );
    }
  }

  void _prevPage() {
    if (_currentPage > 0) {
      _controller.previousPage(duration: const Duration(milliseconds: 300), curve: Curves.ease);
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
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(_pages.length, (index) {
              return Container(
                margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 12),
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
            padding: const EdgeInsets.symmetric(horizontal: 32.0, vertical: 24),
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
      ),
    );
  }
}

// Halaman onboarding individual
class OnboardingPage extends StatelessWidget {
  final String title;
  final String highlightedWord;
  final String description;
  final String imagePath;
  final bool isLast;

  const OnboardingPage({
    super.key,
    required this.title,
    required this.highlightedWord,
    required this.description,
    required this.imagePath,
    this.isLast = false,
  });

  @override
  Widget build(BuildContext context) {
    // Gaya teks dengan highlight biru
    final textStyle = TextStyle(fontSize: 26, fontWeight: FontWeight.bold);
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
