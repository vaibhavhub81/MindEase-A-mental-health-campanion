import 'dart:async';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();

    // Delay for splash duration then navigate
    Timer(const Duration(seconds: 4), () {
      Navigator.pushReplacementNamed(context, '/onboarding');
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1C1C1E), // dark background
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Lottie.asset(
              'assets/animations/splash_loader.json',
              height: 200,
              repeat: true,
            ),
            const SizedBox(height: 30),
            const Text(
              'Mindease',
              style: TextStyle(
                fontSize: 32,
                color: Color(0xFF8ECAE6),
                fontWeight: FontWeight.bold,
                letterSpacing: 1.5,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Your calm, your space',
              style: TextStyle(
                fontSize: 16,
                color: Colors.white70,
                letterSpacing: 1.1,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
