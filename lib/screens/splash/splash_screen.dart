// ignore_for_file: depend_on_referenced_packages, use_build_context_synchronously

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _checkLoginStatus();
  }

  Future<void> _checkLoginStatus() async {
    await Future.delayed(
      const Duration(seconds: 3),
    ); // Optional animation delay

    final user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      Navigator.pushReplacementNamed(context, '/home'); // Logged in
    } else {
      Navigator.pushReplacementNamed(context, '/onboarding'); // Not logged in
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color(0xFFFFFAFB),
              Color(0xFFD1C4E9),
              Color(0xFF7E57C2),
              Color(0xFF512DA8),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Image.asset(
                'assets/logo_2.png',
                height: 200,
                fit: BoxFit.contain,
              ),
              const SizedBox(height: 20),
            ],
          ).animate().fade(duration: 1200.ms),
        ),
      ),
    );
  }
}
