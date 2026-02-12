import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class AboutPage extends StatefulWidget {
  const AboutPage({super.key});

  @override
  State<AboutPage> createState() => _AboutPageState();
}

class _AboutPageState extends State<AboutPage> {

  // Company contact details (edit as needed)
  static const String _companyPhone = '+15551234567';
  static const String _companyEmail = 'support@homesense.co';
  static const String _developerName = 'HomeSense Dev';
  static const String _developerEmail = 'dev@homesense.co';

  Future<void> _callCompany() async {
    final String uri = 'tel:$_companyPhone';
    try {
      if (await canLaunch(uri)) {
        await launch(uri);
      } else {
        if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Could not open dialer')));
      }
    } catch (_) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Could not open dialer')));
    }
  }

  Future<void> _emailCompany() async {
    final subject = Uri.encodeComponent('Feedback for HomeSense');
    final String uri = 'mailto:$_companyEmail?subject=$subject';
    try {
      if (await canLaunch(uri)) {
        await launch(uri);
      } else {
        if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Could not open mail client')));
      }
    } catch (_) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Could not open mail client')));
    }
  }

  Future<void> _emailDeveloper() async {
    final subject = Uri.encodeComponent('Developer contact - HomeSense');
    final String uri = 'mailto:$_developerEmail?subject=$subject';
    try {
      if (await canLaunch(uri)) {
        await launch(uri);
      } else {
        if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Could not open mail client')));
      }
    } catch (_) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Could not open mail client')));
    }
  }

  @override
  Widget build(BuildContext context) {
    const Color green = Color(0xFF1EAA83);
    return Scaffold(
      backgroundColor: green,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Full-width about banner image placed on a white background (edge-to-edge)
              Container(
                color: Colors.white,
                width: double.infinity,
                child: Image.asset(
                  'images/about-banner.png',
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
              ),

              // Padded content below the banner
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Top-left back control (icon + text)
                    Row(
                      children: [
                        GestureDetector(
                          onTap: () => Navigator.pushReplacementNamed(context, '/dashboard'),
                          child: Row(
                            children: const [
                              Icon(Icons.arrow_back, color: Color(0xFF1EAA83)),
                              SizedBox(width: 6),
                              Text('Back', style: TextStyle(color: Color(0xFF1EAA83), fontSize: 16)),
                            ],
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 18),

                    // Centered column at 85% width containing the About Us content
                    Center(
                      child: FractionallySizedBox(
                        widthFactor: 0.85,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Text(
                              'About Us',
                              style: TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold),
                            ),
                            SizedBox(height: 12),
                            Text(
                              'HomeSense is an easy-to-use home environment monitoring app that brings real-time insights about energy, water, and air quality into one place. We package sensor data and simple recommendations so people can make safer, healthier, and more efficient choices at home.',
                              style: TextStyle(color: Colors.white70, fontSize: 16, height: 1.5),
                            ),
                            SizedBox(height: 18),
                            Text(
                              'Our Purpose',
                              style: TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold),
                            ),
                            SizedBox(height: 12),
                            Text(
                              'Our purpose is to empower individuals to make informed decisions about their living environment. We provide clear, actionable insights and personalized suggestions so that small improvements at home can add up to better health, lower bills, and a reduced environmental footprint. HomeSense supports both everyday users and curious homeowners who want to understand how their home is performing over time.',
                              style: TextStyle(color: Colors.white70, fontSize: 16, height: 1.5),
                            ),
                            SizedBox(height: 20),

                            // Contact section
                            Card(
                              color: Colors.white,
                              elevation: 2,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.stretch,
                                  children: [
                                    const Text('Contact', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87)),
                                    const SizedBox(height: 8),
                                    ListTile(
                                      contentPadding: EdgeInsets.zero,
                                      leading: const Icon(Icons.phone, color: Color(0xFF1EAA83)),
                                      title: Text(_companyPhone, style: const TextStyle(color: Colors.black87, fontWeight: FontWeight.w600)),
                                      subtitle: const Text('Call us for support', style: TextStyle(color: Colors.black54)),
                                      trailing: TextButton(
                                        onPressed: _callCompany,
                                        style: TextButton.styleFrom(foregroundColor: const Color(0xFF1EAA83)),
                                        child: const Text('Call'),
                                      ),
                                      onTap: _callCompany,
                                    ),
                                    const Divider(),
                                    ListTile(
                                      contentPadding: EdgeInsets.zero,
                                      leading: const Icon(Icons.email, color: Color(0xFF1EAA83)),
                                      title: Text(_companyEmail, style: const TextStyle(color: Colors.black87, fontWeight: FontWeight.w600)),
                                      subtitle: const Text('Send feedback or report an issue', style: TextStyle(color: Colors.black54)),
                                      trailing: TextButton(
                                        onPressed: _emailCompany,
                                        style: TextButton.styleFrom(foregroundColor: const Color(0xFF1EAA83)),
                                        child: const Text('Email'),
                                      ),
                                      onTap: _emailCompany,
                                    ),
                                    const SizedBox(height: 8),
                                    const Divider(),
                                    Row(
                                      children: [
                                        const Icon(Icons.code, color: Color(0xFF1EAA83)),
                                        const SizedBox(width: 8),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              const Text('Developer', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                                              const SizedBox(height: 4),
                                              GestureDetector(
                                                onTap: _emailDeveloper,
                                                child: Text('$_developerName — $_developerEmail', style: const TextStyle(color: Color(0xFF1EAA83), decoration: TextDecoration.underline)),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 8),
                                  ],
                                ),
                              ),
                            ),

                            const SizedBox(height: 32),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
