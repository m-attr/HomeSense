import 'package:flutter/material.dart';
import '../../helpers/nav_helper.dart';
import 'page_login.dart';
import 'page_signup.dart';

class WelcomePage extends StatelessWidget {
  const WelcomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1EAA83),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              height: 220,
              width: MediaQuery.of(context).size.width * 0.9,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.asset('images/welcome-banner.jpeg', fit: BoxFit.cover),
              ),
            ),

            const SizedBox(height: 24),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                      onPressed: () => navigateWithLoading(context, destination: LoginPage()),
                      child: const Text('Log In', style: TextStyle(color: Color(0xFF1EAA83), fontSize: 18, fontWeight: FontWeight.bold)),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                      onPressed: () => navigateWithLoading(context, destination: SignupPage()),
                      child: const Text('Sign Up', style: TextStyle(color: Color(0xFF1EAA83), fontSize: 18, fontWeight: FontWeight.bold)),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}