// ignore_for_file: use_build_context_synchronously, deprecated_member_use

import 'package:fitlyzer/screens/auth/login_screen.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _controller = PageController();
  bool isLastPage = false;

  void completeOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setBool('hasSeenOnboarding', true);
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const LoginScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final pages = [
      buildPage(
        image: 'assets/scan.jpg',
        title: "Scan Your Body Instantly",
        subtitle: "Capture your posture and get real-time analysis with a tap.",
      ),
      buildPage(
        image: 'assets/ai.jpg',
        title: "AI-Based Suggestions",
        subtitle:
            "Let AI tell you how strong or weak you are, and what to improve.",
      ),
      buildPage(
        image: 'assets/meal_.jpg',
        title: "Smarter Fitness Journey",
        subtitle: "Get personalized meal and workout plans for real results.",
      ),
    ];

    return Scaffold(
      body: Stack(
        children: [
          PageView.builder(
            controller: _controller,
            itemCount: pages.length,
            onPageChanged: (index) {
              setState(() => isLastPage = index == pages.length - 1);
            },
            itemBuilder: (_, index) => pages[index],
          ),
          Positioned(
            bottom: 80,
            left: 20,
            child: SmoothPageIndicator(
              controller: _controller,
              count: pages.length,
              // ignore: prefer_const_constructors
              effect: WormEffect(
                activeDotColor: Colors.green,
                dotHeight: 10,
                dotWidth: 10,
              ),
            ),
          ),
          Positioned(
            top: 60,
            right: 20,
            child: TextButton(
              onPressed: completeOnboarding,
              child: const Text("Skip", style: TextStyle(color: Colors.white)),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.green,
        onPressed: () {
          if (isLastPage) {
            completeOnboarding();
          } else {
            _controller.nextPage(
              duration: const Duration(milliseconds: 500),
              curve: Curves.easeInOut,
            );
          }
        },
        child: Icon(isLastPage ? Icons.check : Icons.arrow_forward),
      ),
    );
  }

  Widget buildPage({
    required String image,
    required String title,
    required String subtitle,
  }) {
    return Container(
      decoration: BoxDecoration(
        image: DecorationImage(
          image: AssetImage(image),
          fit: BoxFit.cover,
          colorFilter: ColorFilter.mode(
            Colors.black.withOpacity(0.72),
            BlendMode.darken,
          ),
        ),
      ),
      padding: const EdgeInsets.all(30),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 32,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 20),
          Text(
            subtitle,
            style: const TextStyle(color: Colors.white70, fontSize: 18),
          ),
        ],
      ),
    );
  }
}
