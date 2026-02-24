import '../pages/signup&login/page_welcome.dart';
import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:math' as math;

class SplashAnimation extends StatefulWidget {
  const SplashAnimation({super.key});

  @override
  State<SplashAnimation> createState() => _SplashAnimationState();
}

class _SplashAnimationState extends State<SplashAnimation>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _logoOpacity;
  late final Animation<double> _bgScale;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2200),
    );

    // Logo fades in early
    _logoOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: const Interval(0.10, 0.30, curve: Curves.easeIn)),
    );

    // Background green circle scales and continues until it covers the whole screen
    _bgScale = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: const Interval(0.30, 1.0, curve: Curves.easeOut)),
    );

    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        Navigator.of(context).push(
          MyCustomRouteTransition(
            route: const WelcomePage(),
          ),
        );

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
          child: LayoutBuilder(builder: (context, constraints) {
            final screenSize = MediaQuery.of(context).size;
            final availW = constraints.maxWidth.isFinite ? constraints.maxWidth : screenSize.width;
            final availH = constraints.maxHeight.isFinite ? constraints.maxHeight : screenSize.height;
            
            // Circle diameter chosen to cover the full screen diagonal when fully scaled
            final diagonal = math.sqrt(availW * availW + availH * availH);
            final circleDiameter = diagonal * 1.05; // small buffer to ensure full coverage
            return AnimatedBuilder(
              animation: _controller,
              builder: (context, child) {
                return Stack(
                  alignment: Alignment.center,
                  clipBehavior: Clip.none,
                  children: [
                    // Expanding green circular background (scales from 0->1)
                    // Use OverflowBox so the large circle can exceed parent bounds
                    OverflowBox(
                      maxWidth: double.infinity,
                      maxHeight: double.infinity,
                      child: Transform.scale(
                        scale: _bgScale.value,
                        child: Container(
                          width: circleDiameter,
                          height: circleDiameter,
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            color: Color(0xFF1EAA83),
                          ),
                        ),
                      ),
                    ),

                    // Fixed-size circular image that fades in (does not scale)
                    Container(
                      width: 140,
                      height: 140,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                      ),
                      child: FadeTransition(
                        opacity: _logoOpacity,
                        child: Container(
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 8)],
                          ),
                          child: ClipOval(
                            child: Image.asset(
                              'images/homesense-logo.png',
                              fit: BoxFit.cover,
                              width: 140,
                              height: 140,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                );
              },
            );
          }),
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