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

    Timer(const Duration(milliseconds: 400), () {
      setState(() {
        _opacity = 1.0;
      });
    });

    Timer(const Duration(seconds: 4), () {
      Navigator.pushReplacementNamed(context, '/welcome');
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: AnimatedOpacity(
          duration: const Duration(seconds: 3),
          opacity: _opacity,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 200,
                height: 200,
                alignment: Alignment.center,
                child: Image.asset(
                  'assets/Wavlo.png',
                  fit: BoxFit.fill,
                  width: double.infinity,
                ),
              ),
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
      ),
    );
  }
}
