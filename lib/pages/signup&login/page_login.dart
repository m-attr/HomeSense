import 'dart:async';
import 'package:flutter/material.dart';
import '../../helpers/nav_helper.dart';
import 'page_signup.dart';
import 'page_welcome.dart';
import '../../models/user.dart';
import '../page_dashboard.dart' show DashboardPage;

class LoginPage extends StatefulWidget {
  final bool showCreated;
  const LoginPage({super.key, this.showCreated = false});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<Offset> _slideAnimation;
  late AnimationController _swipeController;
  late Animation<Offset> _swipeAnimation;
  bool _rememberMe = false;
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  String? _errorMessage;
  bool _showCreatedBanner = false;
  Timer? _bannerTimer;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 700),
      vsync: this,
    );
    _slideAnimation = Tween<Offset>(begin: const Offset(0, 1), end: Offset.zero)
        .animate(
          CurvedAnimation(
            parent: _animationController,
            curve: Curves.easeInOutCubic,
          ),
        );
    _animationController.forward();
    _swipeController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );
    _swipeAnimation =
        Tween<Offset>(begin: Offset.zero, end: const Offset(-1.0, 0.0)).animate(
          CurvedAnimation(parent: _swipeController, curve: Curves.easeInOut),
        );
    debugPrint('LoginPage.initState showCreated=${widget.showCreated}');

    _showCreatedBanner = widget.showCreated;
    if (_showCreatedBanner) {
      _bannerTimer = Timer(const Duration(seconds: 3), () {
        if (mounted) setState(() => _showCreatedBanner = false);
      });
    }

    final repo = UserRepository.instance;
    if (repo.lastLoggedInEmail != null) {
      _emailController.text = repo.lastLoggedInEmail!;
      _rememberMe = true;
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    _swipeController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _bannerTimer?.cancel();
    super.dispose();
  }

  void _navigateTo(Widget page) {
    _animationController.reverse().then((_) {
      navigateWithLoading(context, destination: page);
    });
  }

  void _dismissCreatedBanner() {
    _bannerTimer?.cancel();
    setState(() => _showCreatedBanner = false);
  }

  @override
  Widget build(BuildContext context) {
    final double _bannerTop = MediaQuery.of(context).padding.top + 12;
    return Scaffold(
      body: Stack(
        children: [
          Container(color: const Color(0xFF1EAA83)),

          Positioned(
            top: 40,
            left: 8,
            child: TextButton.icon(
              onPressed: () {
                _animationController.reverse().then((_) {
                  navigateWithLoading(
                    context,
                    destination: const WelcomePage(),
                    replace: true,
                  );
                });
              },
              icon: const Icon(Icons.arrow_back, color: Colors.white),
              label: const Text(
                'Back',
                style: TextStyle(color: Colors.white, fontSize: 16),
              ),
            ),
          ),

          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            height: MediaQuery.of(context).size.height * 0.78,
            child: SlideTransition(
              position: _swipeAnimation,
              child: SlideTransition(
                position: _slideAnimation,
                child: Container(
                  padding: const EdgeInsets.fromLTRB(32.0, 40.0, 32.0, 20.0),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(40.0),
                      topRight: Radius.circular(40.0),
                    ),
                    boxShadow: [
                      BoxShadow(color: Colors.black26, blurRadius: 10),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Center(
                        child: Text(
                          'Welcome Back',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF1EAA83),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),

                      TextField(
                        controller: _emailController,
                        keyboardType: TextInputType.emailAddress,
                        decoration: InputDecoration(
                          labelText: 'Email',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),

                      TextField(
                        controller: _passwordController,
                        obscureText: true,
                        decoration: InputDecoration(
                          labelText: 'Password',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),

                      Row(
                        children: [
                          Row(
                            children: [
                              Checkbox(
                                value: _rememberMe,
                                onChanged: (v) {
                                  setState(() {
                                    _rememberMe = v ?? false;
                                  });
                                },
                              ),
                              const Text('Remember Me'),
                            ],
                          ),
                        ],
                      ),

                      const SizedBox(height: 8),

                      ElevatedButton(
                        onPressed: () {
                          setState(() {
                            _errorMessage = null;
                          });

                          final email = _emailController.text.trim();
                          final password = _passwordController.text;

                          if (email.isEmpty || password.isEmpty) {
                            setState(
                              () => _errorMessage =
                                  'Email and password are required.',
                            );
                            return;
                          }

                          final repo = UserRepository.instance;
                          if (!repo.validateCredentials(email, password)) {
                            setState(
                              () =>
                                  _errorMessage = 'Invalid email or password.',
                            );
                            return;
                          }

                          repo.currentUser = repo.findByEmail(email);
                          if (_rememberMe) {
                            repo.setLastLoggedInEmail(email);
                          } else {
                            repo.setLastLoggedInEmail(null);
                          }

                          _swipeController.forward();

                          navigateWithLoading(
                            context,
                            destination: const DashboardPage(),
                            replace: true,
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF1EAA83),
                          minimumSize: const Size(double.infinity, 50),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 0,
                        ),
                        child: const Text(
                          'Log in',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),

                      const SizedBox(height: 12),

                      if (_errorMessage != null) ...[
                        Text(
                          _errorMessage!,
                          style: const TextStyle(color: Colors.red),
                        ),
                        const SizedBox(height: 8),
                      ],

                      Center(
                        child: GestureDetector(
                          onTap: () {
                            _navigateTo(const SignupPage());
                          },
                          child: RichText(
                            text: TextSpan(
                              text: "Don't have an account? ",
                              style: TextStyle(color: Colors.grey.shade600),
                              children: [
                                TextSpan(
                                  text: 'Sign up',
                                  style: const TextStyle(
                                    color: Color(0xFF1EAA83),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // draw banner last so it appears on top of other stack children
          if (_showCreatedBanner)
            Positioned(
              top: _bannerTop,
              left: 32,
              right: 32,
              child: Material(
                color: Colors.transparent,
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                    // use the same green-accent used across the app for consistency
                    border: Border(
                      left: BorderSide(
                        color: const Color(0xFF1EAA83),
                        width: 6,
                      ),
                    ),
                    boxShadow: [
                      BoxShadow(color: Colors.black26, blurRadius: 6),
                    ],
                  ),
                  padding: const EdgeInsets.symmetric(
                    vertical: 12,
                    horizontal: 12,
                  ),
                  child: Row(
                    children: [
                      const Expanded(
                        child: Text(
                          'User has been created.',
                          style: TextStyle(
                            color: Colors.black87,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close, size: 20),
                        onPressed: _dismissCreatedBanner,
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
