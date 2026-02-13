import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class AboutPage extends StatefulWidget {
  const AboutPage({super.key});

  @override
  State<AboutPage> createState() => _AboutPageState();
}

class _AboutPageState extends State<AboutPage> {

  static const String _companyPhone = '+15551234567';
  static const String _companyEmail = 'support@homesense.co';
  static const String _developerName = 'HomeSense Dev';
  static const String _developerEmail = 'dev@homesense.co';

  Future<void> _launchPhone() async {
    final uri = Uri(scheme: 'tel', path: _companyPhone);
    try {
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Unable to open dialer')));
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Error opening dialer')));
    }
  }

  Future<void> _launchEmail() async {
    // Try to open Gmail explicitly on Android if available, otherwise fall back to mailto
    final gmailUri = Uri.parse('googlegmail://co?to=$_companyEmail');
    final mailtoUri = Uri(
      scheme: 'mailto',
      path: _companyEmail,
      query: Uri(queryParameters: {'subject': 'HomeSense Support'}).query,
    );

    try {
      if (await canLaunchUrl(gmailUri)) {
        await launchUrl(gmailUri);
        return;
      }
      if (await canLaunchUrl(mailtoUri)) {
        await launchUrl(mailtoUri);
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Unable to open email client')));
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Error opening email client')));
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
              Padding(
                padding: const EdgeInsets.fromLTRB(12.0, 8.0, 12.0, 0.0),
                child: Align(
                  alignment: Alignment.topLeft,
                  child: GestureDetector(
                    onTap: () => Navigator.pushReplacementNamed(context, '/dashboard'),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.arrow_back, color: Color(0xFFFFFFFF), size: 24,),
                        SizedBox(width: 6),
                        Text('Back', style: TextStyle(color: Color(0xFFFFFFFF), fontSize: 16)),
                        SizedBox(height: MediaQuery.of(context).padding.top + 14)
                      ],
                    ),
                  ),
                ),
              ),

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

                            // Contact section (same format as About and Our Purpose)
                            Text(
                              'Contact',
                              style: TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 12),
                            // Details: icon + single-line heading, then a smaller description below
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                GestureDetector(
                                  onTap: _launchPhone,
                                  child: Row(
                                    children: [
                                      const Icon(Icons.phone, color: Color(0xFFFFFFFF)),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: Text('Phone: $_companyPhone', style: const TextStyle(color: Colors.white, fontSize: 16, decoration: TextDecoration.underline), maxLines: 1, overflow: TextOverflow.ellipsis),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text('Call us for support', style: TextStyle(color: Colors.white70, fontSize: 14)),
                                const SizedBox(height: 12),

                                GestureDetector(
                                  onTap: _launchEmail,
                                  child: Row(
                                    children: [
                                      const Icon(Icons.email, color: Color(0xFFFFFFFF)),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: Text('Email: $_companyEmail', style: const TextStyle(color: Colors.white, fontSize: 16, decoration: TextDecoration.underline), maxLines: 1, overflow: TextOverflow.ellipsis),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text('Send feedback or report an issue', style: TextStyle(color: Colors.white70, fontSize: 14)),
                                const SizedBox(height: 12),

                                Row(
                                  children: [
                                    const Icon(Icons.code, color: Color(0xFFFFFFFF)),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Text('Developer: $_developerName', style: const TextStyle(color: Colors.white, fontSize: 16), maxLines: 1, overflow: TextOverflow.ellipsis),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 4),
                                Text('$_developerEmail', style: TextStyle(color: Colors.white70, fontSize: 14)),
                              ],
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
