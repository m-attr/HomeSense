import 'package:flutter/material.dart';
import 'animations/animation_home.dart';
import 'pages/page_dashboard.dart';

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
      routes: {
        '/dashboard': (context) => const DashboardPage(),
      },
    );

    // return DashboardPage();
  }
}