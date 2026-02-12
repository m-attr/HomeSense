import 'package:flutter/material.dart';
import 'page_settings.dart';
import 'page_editProfile.dart';
import 'signup&login/page_welcome.dart';
import '../widgets/widget_menuDrawer.dart';
import '../models/user.dart';

class AboutPage extends StatefulWidget {
  const AboutPage({super.key});

  @override
  State<AboutPage> createState() => _AboutPageState();
}

class _AboutPageState extends State<AboutPage> {
  void _changeProfileImage(BuildContext context) async {
    final repo = UserRepository.instance;
    final current = repo.currentUser;
    String? currentUrl = current?.profileImage ?? '';

    final controller = TextEditingController(text: currentUrl);
    final result = await showDialog<String?>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Change profile picture'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(hintText: 'Enter image URL or asset path'),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          TextButton(onPressed: () => Navigator.pop(context, controller.text.trim()), child: const Text('OK')),
        ],
      ),
    );

    if (result != null) {
      setState(() {
        if (current != null) current.profileImage = result.isEmpty ? null : result;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1EAA83),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1EAA83),
        leading: Builder(
          builder: (context) => IconButton(
            icon: const Icon(Icons.menu),
            onPressed: () => Scaffold.of(context).openDrawer(),
          ),
        ),
        // no back button or text - navigation is via the drawer
      ),

      drawer: WidgetMenuDrawer(
        onHome: () {
          Navigator.pushReplacementNamed(context, '/dashboard');
        },
        onProfile: () {
          Navigator.push(context, MaterialPageRoute(builder: (_) => const EditProfilePage()));
        },
        onAbout: () {
          // already on About - nothing to do
        },
        
        onSettings: () {
          Navigator.push(context, MaterialPageRoute(builder: (_) => const SettingsPage()));
        },
        onLogout: () {
          final repo = UserRepository.instance;
          repo.currentUser = null;
          repo.setLastLoggedInEmail(null);
          Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (_) => const WelcomePage()), (route) => false);
        },
        onChangeProfileImage: () => _changeProfileImage(context),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Full-width about banner image placed on a white background
            Container(
              color: Colors.white,
              width: double.infinity,
              child: Image.asset(
                'images/about-banner.png',
                width: double.infinity,
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(height: 24),

            // Centered column at 85% width containing the About Us content
            Center(
              child: FractionallySizedBox(
                widthFactor: 0.85,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text(
                      'About Us',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 12),
                    Text(
                      'HomeSense is a smart home monitoring solution that helps residents track air quality, temperature, noise levels, and resource usage. Our platform transforms environmental data into clear insights, empowering users to create healthier and more energy-efficient homes.',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 16,
                        height: 1.4,
                      ),
                    ),
                    SizedBox(height: 24),
                    Text(
                      'Our Purpose',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 12),
                    Text(
                      'Our purpose is to empower individuals to make informed decisions about their living environment.\n\nBy providing real-time environmental insights and personalized recommendations, HomeSense encourages healthier lifestyles, promotes energy efficiency, and supports sustainable living habits.\n\nWe believe that small, informed changes at home can lead to meaningful improvements in personal well-being and environmental impact.',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 16,
                        height: 1.5,
                      ),
                    ),
                    SizedBox(height: 32),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
