import '../pages/signup&login/page_welcome.dart';
import 'package:flutter/material.dart';
import 'dart:async';

class SplashAnimation extends StatefulWidget {
  const SplashAnimation({super.key});

  @override
  State<SplashAnimation> createState() => _SplashAnimationState();
}

class _SplashAnimationState extends State<SplashAnimation>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _scaleAnimation;
  late final Animation<double> _logoOpacity;

  @override
  void initState() {
    super.initState();

    // Single controller with timeline intervals:
    // 0.00-0.20 -> idle (circle shown)
    // 0.20-0.50 -> logo fade in
    // 0.50-0.75 -> hold logo visible
    // 0.75-1.00 -> expand (scale) and then navigate
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2200),
    );

    _logoOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: const Interval(0.20, 0.50, curve: Curves.easeIn)),
    );

    _scaleAnimation = Tween<double>(begin: 1.0, end: 10.0).animate(
      CurvedAnimation(parent: _controller, curve: const Interval(0.75, 1.0, curve: Curves.easeIn)),
    );

    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        // Navigate after the expand animation finishes
        Navigator.of(context).push(
          MyCustomRouteTransition(
            route: const WelcomePage(),
          ),
        );

        // Reset a short while after navigation to allow re-use if necessary
        Timer(const Duration(milliseconds: 500), () {
          _controller.reset();
        });
      }
    });

    // Start after a short pause so the circle is visible first
    Timer(const Duration(milliseconds: 600), () {
      _controller.forward();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: Center(
          child: ScaleTransition(
            scale: _scaleAnimation,
            child: SizedBox(
              width: 96,
              height: 96,
              child: CircleAvatar(
                radius: 48,
                backgroundColor: const Color(0xFF1EAA83),
                child: FadeTransition(
                  opacity: _logoOpacity,
                  // Ensure the logo sits inside the green circle
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Image.asset(
                      'images/homesense-logo.png',
                      fit: BoxFit.contain,
                      width: 48,
                      height: 48,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class MyCustomRouteTransition extends PageRouteBuilder {
  final Widget route;
  MyCustomRouteTransition({required this.route})
      : super(
          pageBuilder: (context, animation, secondaryAnimation) {
            return route;
          },
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            final tween = Tween(
              begin: const Offset(0, -1),
              end: Offset.zero,
            ).animate(
              CurvedAnimation(parent: animation, curve: Curves.easeInOut),
            );
            return SlideTransition(
              position: tween,
              child: child,
            );
          },
        );
}