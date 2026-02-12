import 'package:flutter/material.dart';
import 'animations/animation_home.dart';

void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: const SplashAnimation(),
      ),
    );

    // return DashboardPage();
  }
}