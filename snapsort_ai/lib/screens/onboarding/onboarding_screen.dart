import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../constants/app_constants.dart';
import '../../screens/home/home_screen.dart';
import '../../services/photo_service.dart';
import '../../theme/app_theme.dart';

class _OnboardingPage {
  final String emoji;
  final String title;
  final String body;
  final String cta;
  final Color color;

  const _OnboardingPage({
    required this.emoji,
    required this.title,
    required this.body,
    required this.cta,
    required this.color,
  });
}

const _pages = [
  _OnboardingPage(
    emoji: '📸',
    title: 'Lost in screenshots?',
    body: 'Thousands of screenshots, zero organisation.\nOTPs, bills, memes — all mixed up.',
    cta: 'Show me the fix',
    color: Color(0xFF6C63FF),
  ),
  _OnboardingPage(
    emoji: '🤖',
    title: 'AI sorts them for you',
    body: 'SnapSort reads your screenshots and\nauto-files them into 11 smart folders — instantly.',
    cta: 'That\'s smart',
    color: Color(0xFF06D6A0),
  ),
  _OnboardingPage(
    emoji: '🔒',
    title: '100% on your device',
    body: 'Your screenshots never leave your phone.\nAI runs locally. No cloud. No tracking.',
    cta: 'I trust that',
    color: Color(0xFF118AB2),
  ),
  _OnboardingPage(
    emoji: '✨',
    title: 'Ready to sort 500 free',
    body: 'Free tier: 500 screenshots.\nPro (₹99/mo) unlocks unlimited + export.',
    cta: 'Get started',
    color: Color(0xFFFF9F1C),
  ),
];

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen>
    with TickerProviderStateMixin {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  bool _loading = false;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _advance() async {
    if (_currentPage < _pages.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeInOut,
      );
      return;
    }
    await _finish();
  }

  Future<void> _finish() async {
    setState(() => _loading = true);
    try {
      final photoService = PhotoService();
      await photoService.requestPermission();
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(AppConstants.keyOnboardingComplete, true);
      if (!mounted) return;
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const HomeScreen()),
      );
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final page = _pages[_currentPage];

    return Scaffold(
      backgroundColor: page.color,
      body: SafeArea(
        child: Column(
          children: [
            // Skip button
            Align(
              alignment: Alignment.topRight,
              child: TextButton(
                onPressed: _currentPage < _pages.length - 1 ? _finish : null,
                child: Text(
                  'Skip',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.8),
                    fontSize: 15,
                  ),
                ),
              ),
            ),

            Expanded(
              child: PageView.builder(
                controller: _pageController,
                itemCount: _pages.length,
                onPageChanged: (i) => setState(() => _currentPage = i),
                itemBuilder: (context, index) {
                  final p = _pages[index];
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 32),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(p.emoji,
                            style: const TextStyle(fontSize: 80)),
                        const SizedBox(height: 32),
                        Text(
                          p.title,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                            height: 1.2,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          p.body,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.white.withOpacity(0.85),
                            height: 1.5,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),

            // Page indicators
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(_pages.length, (i) {
                return AnimatedContainer(
                  duration: const Duration(milliseconds: 250),
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  width: i == _currentPage ? 24 : 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: Colors.white
                        .withOpacity(i == _currentPage ? 1.0 : 0.4),
                    borderRadius: BorderRadius.circular(4),
                  ),
                );
              }),
            ),

            const SizedBox(height: 32),

            // CTA button
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: SizedBox(
                width: double.infinity,
                height: 54,
                child: ElevatedButton(
                  onPressed: _loading ? null : _advance,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: page.color,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: _loading
                      ? SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.5,
                            color: page.color,
                          ),
                        )
                      : Text(
                          page.cta,
                          style: const TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                ),
              ),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}
