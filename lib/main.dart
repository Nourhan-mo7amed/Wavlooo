import 'package:chat/screens/Login_Screen.dart';
import 'package:flutter/material.dart';
import 'package:chat/screens/Welcome_Screen.dart';

void main() async {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: WelcomeScreen(),
      routes: {
        '/login': (context) => const Login_Screen(),
        '/welcome': (context) => const WelcomeScreen(),
      },
    );
  }
}
