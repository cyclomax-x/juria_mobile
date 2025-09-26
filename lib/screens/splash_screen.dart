import 'dart:async';
import 'package:flutter/material.dart';
import 'auth/login_screen.dart';

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {
  @override
  void initState() {
    super.initState();
    // Navigate to login screen after 3 seconds
    Timer(const Duration(seconds: 3), () {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (context) => const LoginScreen(),
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Juria Logo
              Image.asset(
                'assets/images/juria_logo.png',
                height: 120,
                width: 120,
                fit: BoxFit.contain,
              ),
              const SizedBox(height: 60),
              
              // Loading indicator
              const CircularProgressIndicator(
                strokeWidth: 2,
              ),
            ],
          ),
        ),
      ),
    );
  }
}