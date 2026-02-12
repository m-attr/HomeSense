import 'package:flutter/material.dart';
import 'page_login.dart';
import 'page_welcome.dart';
import '../../models/user.dart';

class SignupPage extends StatefulWidget {
  const SignupPage({super.key});

  @override
  _SignupPageState createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> with SingleTickerProviderStateMixin {
  late final AnimationController _animationController;
  late final Animation<Offset> _slideAnimation;

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmController = TextEditingController();

  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );
    _slideAnimation = Tween<Offset>(begin: const Offset(0, 1), end: Offset.zero).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOutCubic),
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  void _navigateTo(Widget page) {
    _animationController.reverse().then((_) {
      Navigator.push(context, MaterialPageRoute(builder: (context) => page));
    });
  }

  bool _isEmailValid(String email) {
    final regex = RegExp(r"^[\w\.-]+@[\w\.-]+\.\w+");
    return regex.hasMatch(email);
  }

  bool _isPasswordValid(String password) {
    final regex = RegExp(r'^(?=.*[a-z])(?=.*[A-Z])(?=.*\d).{8,}$');
    return regex.hasMatch(password);
  }

  void _submit() {
    setState(() => _errorMessage = null);

    final name = _nameController.text.trim();
    final email = _emailController.text.trim();
    final password = _passwordController.text;
    final confirm = _confirmController.text;

    if (name.isEmpty || email.isEmpty || password.isEmpty || confirm.isEmpty) {
      setState(() => _errorMessage = 'All fields are required.');
      return;
    }

    if (!_isEmailValid(email)) {
      setState(() => _errorMessage = 'Please enter a valid email address.');
      return;
    }

    if (!_isPasswordValid(password)) {
      setState(() => _errorMessage = 'Password must be at least 8 characters, include upper and lower case letters and a number.');
      return;
    }

    if (password != confirm) {
      setState(() => _errorMessage = 'Passwords do not match.');
      return;
    }

    final repo = UserRepository.instance;
    if (repo.findByEmail(email) != null) {
      setState(() => _errorMessage = 'An account with that email already exists.');
      return;
    }

    final newUser = User(fullName: name, email: email, password: password);
    repo.addUser(newUser);

    _animationController.reverse().then((_) {
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => LoginPage(showCreated: true)));
    });
  }

  @override
  Widget build(BuildContext context) {
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
                  Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const WelcomePage()));
                });
              },
              icon: const Icon(Icons.arrow_back, color: Colors.white),
              label: const Text('Back', style: TextStyle(color: Colors.white, fontSize: 16)),
            ),
          ),

          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            height: MediaQuery.of(context).size.height * 0.7,
            child: SlideTransition(
              position: _slideAnimation,
              child: Container(
                padding: const EdgeInsets.fromLTRB(25.0, 40.0, 25.0, 20.0),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(topLeft: Radius.circular(40.0), topRight: Radius.circular(40.0)),
                  boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 10)],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Center(
                      child: Text('Get Started', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFF1EAA83))),
                    ),
                    const SizedBox(height: 20),

                    TextField(
                      controller: _nameController,
                      decoration: InputDecoration(labelText: 'Full Name', border: OutlineInputBorder(borderRadius: BorderRadius.circular(12))),
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      decoration: InputDecoration(labelText: 'Email', border: OutlineInputBorder(borderRadius: BorderRadius.circular(12))),
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: _passwordController,
                      obscureText: true,
                      decoration: InputDecoration(labelText: 'Password', border: OutlineInputBorder(borderRadius: BorderRadius.circular(12))),
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: _confirmController,
                      obscureText: true,
                      decoration: InputDecoration(labelText: 'Confirm Password', border: OutlineInputBorder(borderRadius: BorderRadius.circular(12))),
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: _submit,
                      style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF1EAA83), minimumSize: const Size(double.infinity, 50)),
                      child: const Text('Sign Up', style: TextStyle(color: Colors.white)),
                    ),

                    const SizedBox(height: 12),
                    if (_errorMessage != null) ...[
                      Text(_errorMessage!, style: const TextStyle(color: Colors.red)),
                      const SizedBox(height: 12),
                    ],

                    Center(
                      child: GestureDetector(
                        onTap: () => _navigateTo(const LoginPage()),
                        child: RichText(
                          text: TextSpan(text: 'Already have an account? ', style: TextStyle(color: Colors.grey.shade600), children: const [
                            TextSpan(text: 'Log in', style: TextStyle(color: Color(0xFF1EAA83))),
                          ]),
                        ),
                      ),
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
