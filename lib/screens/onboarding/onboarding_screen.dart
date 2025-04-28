// ignore_for_file: depend_on_referenced_packages, use_super_parameters

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({Key? key}) : super(key: key);

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _controller = PageController();
  int _currentPage = 0;

  final List<Map<String, String>> pages = [
    {
      "title": "Scan Your Body Instantly",
      "desc": "Capture your posture and get real-time analysis with a tap.",
      "image": "assets/scan.jpg",
    },
    {
      "title": "AI-Based Suggestions",
      "desc":
          "Let AI tell you how strong or weak you are, and what to improve.",
      "image": "assets/ai.png",
    },
    {
      "title": "Smarter Fitness Journey",
      "desc": "Get personalized meal and workout plans for real results.",
      "image": "assets/meal.webp",
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Expanded(
            child: PageView.builder(
              controller: _controller,
              itemCount: pages.length,
              onPageChanged: (index) => setState(() => _currentPage = index),
              itemBuilder: (context, index) {
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child:
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Image.asset(
                            pages[index]["image"]!,
                            height: 250,
                            fit: BoxFit.contain,
                          ),
                          const SizedBox(height: 30),
                          Text(
                            pages[index]["title"]!,
                            textAlign: TextAlign.center,
                            style: GoogleFonts.poppins(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            pages[index]["desc"]!,
                            textAlign: TextAlign.center,
                            style: GoogleFonts.nunito(fontSize: 16),
                          ),
                        ],
                      ).animate().fadeIn(),
                );
              },
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(
              pages.length,
              (index) => Container(
                margin: const EdgeInsets.symmetric(horizontal: 4),
                width: _currentPage == index ? 16 : 8,
                height: 8,
                decoration: BoxDecoration(
                  color:
                      _currentPage == index ? Colors.green : Colors.grey[300],
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ),
          const SizedBox(height: 20),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: ElevatedButton(
              onPressed: () {
                if (_currentPage == pages.length - 1) {
                  Navigator.pushReplacementNamed(context, '/login');
                } else {
                  _controller.nextPage(
                    duration: const Duration(milliseconds: 400),
                    curve: Curves.easeInOut,
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFFFFFAFB),
                minimumSize: const Size(double.infinity, 50),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
              child: Text(
                _currentPage == pages.length - 1 ? "Get Started" : "Next",
                style: GoogleFonts.poppins(fontSize: 18, color: Colors.black),
              ),
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}
