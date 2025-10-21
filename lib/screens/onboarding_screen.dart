import 'package:flutter/material.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _controller = PageController();
  bool onLastPage = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1C1C1E),
      body: Stack(
        children: [
          PageView(
            controller: _controller,
            onPageChanged: (index) {
              setState(() {
                onLastPage = index == 3;
              });
            },
            children: const [
              OnboardingSlide(
                title: "Welcome to Mindease",
                subtitle: "Your calm space for stress relief and balance.",
                icon: Icons.self_improvement,
              ),
              OnboardingSlide(
                title: "Mood Tracking",
                subtitle: "Log how you feel daily and get personalized insights.",
                icon: Icons.emoji_emotions_outlined,
              ),
              OnboardingSlide(
                title: "Guided Meditations",
                subtitle: "Use breathing, audio, and reflection tools anytime.",
                icon: Icons.spa,
              ),
              OnboardingSlide(
                title: "Thoughts Room",
                subtitle: "Share your feelings anonymously with supportive peers.",
                icon: Icons.chat_bubble_outline,
              ),
            ],
          ),

          // Indicator & Button
          Positioned(
            bottom: 30,
            left: 20,
            right: 20,
            child: Column(
              children: [
                SmoothPageIndicator(
                  controller: _controller,
                  count: 4,
                  effect: ExpandingDotsEffect(
                    activeDotColor: Color(0xFF8ECAE6),
                    dotColor: Colors.grey.shade700,
                    dotHeight: 10,
                    dotWidth: 10,
                    spacing: 12,
                  ),
                ),
                const SizedBox(height: 20),
                onLastPage
                    ? ElevatedButton(
                  onPressed: () {
                    Navigator.pushReplacementNamed(context, '/login');
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFFB703),
                    padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                  ),
                  child: const Text(
                    'Get Started',
                    style: TextStyle(fontSize: 18, color: Colors.black),
                  ),
                )
                    : TextButton(
                  onPressed: () {
                    _controller.nextPage(duration: const Duration(milliseconds: 400), curve: Curves.easeIn);
                  },
                  child: const Text(
                    'Next',
                    style: TextStyle(color: Colors.white70, fontSize: 16),
                  ),
                )
              ],
            ),
          )
        ],
      ),
    );
  }
}

class OnboardingSlide extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;

  const OnboardingSlide({
    super.key,
    required this.title,
    required this.subtitle,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(40),
      color: const Color(0xFF1C1C1E),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 100, color: Color(0xFF8ECAE6)),
          const SizedBox(height: 40),
          Text(
            title,
            style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              letterSpacing: 1.2,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),
          Text(
            subtitle,
            style: const TextStyle(
              fontSize: 18,
              color: Colors.white70,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
