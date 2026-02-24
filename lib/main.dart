import 'package:flutter/material.dart';
import 'animations/animation_home.dart';
import 'pages/page_dashboard.dart' show DashboardPage;

void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        scaffoldBackgroundColor: const Color.fromARGB(255, 241, 237, 237),
      ),
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