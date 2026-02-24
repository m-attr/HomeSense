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
      home: Scaffold(body: const SplashAnimation()),
      routes: {'/dashboard': (context) => const DashboardPage()},
      onGenerateRoute: (settings) {
        // Apply slide transition to all named routes
        Widget? page;
        switch (settings.name) {
          case '/dashboard':
            page = const DashboardPage();
            break;
        }
        if (page != null) {
          return PageRouteBuilder(
            settings: settings,
            transitionDuration: const Duration(milliseconds: 400),
            reverseTransitionDuration: const Duration(milliseconds: 400),
            pageBuilder: (_, __, ___) => page!,
            transitionsBuilder: (_, animation, secondaryAnimation, child) {
              final inAnim =
                  Tween<Offset>(
                    begin: const Offset(1.0, 0.0),
                    end: Offset.zero,
                  ).animate(
                    CurvedAnimation(parent: animation, curve: Curves.easeInOut),
                  );
              final outAnim =
                  Tween<Offset>(
                    begin: Offset.zero,
                    end: const Offset(-0.3, 0.0),
                  ).animate(
                    CurvedAnimation(
                      parent: secondaryAnimation,
                      curve: Curves.easeInOut,
                    ),
                  );
              return SlideTransition(
                position: outAnim,
                child: SlideTransition(position: inAnim, child: child),
              );
            },
          );
        }
        return null;
      },
    );

    // return DashboardPage();
  }
}
