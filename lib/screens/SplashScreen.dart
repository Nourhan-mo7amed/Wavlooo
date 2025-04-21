import 'dart:async';
import 'package:flutter/material.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  double _opacity = 0.0;

  @override
  void initState() {
    super.initState();

    Timer(const Duration(milliseconds: 500), () {
      setState(() {
        _opacity = 1.0;
      });
    });

    Timer(const Duration(seconds: 8), () {
      Navigator.pushReplacementNamed(context, '/welcome');
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: AnimatedOpacity(
        duration: const Duration(seconds: 3),
        opacity: _opacity,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.asset('assets/Wavlo.png', width: 700, height: 700),
            const Text(
              "WAVLO",
              style: TextStyle(
                fontSize: 60,
                fontWeight: FontWeight.bold,
                color: Color(0xFFF37A40),
                fontFamily: 'ADLaMDisplay',
                shadows: [Shadow(blurRadius: 30, color: Colors.grey)],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
