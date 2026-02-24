import 'package:flutter/material.dart';
import '../helpers/nav_helper.dart';
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
    const Color dark = Color(0xFF2D3142);

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Green app bar with rounded bottom corners
            ClipRRect(
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(18),
                bottomRight: Radius.circular(18),
              ),
              child: Container(
                width: double.infinity,
                color: green,
                padding: EdgeInsets.only(
                  top: MediaQuery.of(context).padding.top,
                  left: 4,
                  right: 8,
                  bottom: 12,
                ),
                child: SizedBox(
                  height: 56,
                  child: Stack(
                    children: [
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(
                                Icons.arrow_back,
                                color: Colors.white,
                              ),
                              onPressed: () => navigateNamedWithLoading(
                                context,
                                routeName: '/dashboard',
                                replace: true,
                              ),
                            ),
                            const Padding(
                              padding: EdgeInsets.only(left: 6.0),
                              child: Text(
                                'Back',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Center(
                        child: Text(
                          'About Us',
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            const SizedBox(height: 16),

                  // Header area
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              width: 48,
                              height: 48,
                              decoration: BoxDecoration(
                                color: green.withOpacity(0.12),
                                borderRadius: BorderRadius.circular(14),
                              ),
                              child: const Icon(
                                Icons.home_rounded,
                                color: green,
                                size: 26,
                              ),
                            ),
                            const SizedBox(width: 14),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: const [
                                Text(
                                  'HomeSense',
                                  style: TextStyle(
                                    fontSize: 26,
                                    fontWeight: FontWeight.bold,
                                    color: dark,
                                  ),
                                ),
                                SizedBox(height: 2),
                                Text(
                                  'Version 1.0.0',
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: Colors.grey,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Banner image
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: Image.asset(
                        'images/about-banner.png',
                        width: double.infinity,
                        height: 180,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Section 1: About Us
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: const [
                          BoxShadow(
                            color: Colors.black12,
                            blurRadius: 6,
                            offset: Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: const [
                                Icon(
                                  Icons.info_outline,
                                  color: green,
                                  size: 22,
                                ),
                                SizedBox(width: 8),
                                Text(
                                  'About Us',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: dark,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 14),
                            Text(
                              'HomeSense is an easy-to-use home environment monitoring app that brings real-time insights about energy, water, and air quality into one place.',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey.shade700,
                                height: 1.6,
                              ),
                            ),
                            const SizedBox(height: 10),
                            Text(
                              'We package sensor data and simple recommendations so people can make safer, healthier, and more efficient choices at home.',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey.shade700,
                                height: 1.6,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Section 2: Our Purpose
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: const [
                          BoxShadow(
                            color: Colors.black12,
                            blurRadius: 6,
                            offset: Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: const [
                                Icon(
                                  Icons.lightbulb_outline,
                                  color: green,
                                  size: 22,
                                ),
                                SizedBox(width: 8),
                                Text(
                                  'Our Purpose',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: dark,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 14),
                            Text(
                              'Our purpose is to empower individuals to make informed decisions about their living environment. We provide clear, actionable insights and personalised suggestions so that small improvements at home can add up to better health, lower bills, and a reduced environmental footprint.',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey.shade700,
                                height: 1.6,
                              ),
                            ),
                            const SizedBox(height: 16),
                            // Feature highlights row
                            Row(
                              children: [
                                _featureChip(Icons.bolt, 'Energy'),
                                const SizedBox(width: 10),
                                _featureChip(Icons.water_drop, 'Water'),
                                const SizedBox(width: 10),
                                _featureChip(Icons.thermostat, 'Temperature'),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Section 3: Meet the Team (image placeholders)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: const [
                          BoxShadow(
                            color: Colors.black12,
                            blurRadius: 6,
                            offset: Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: const [
                                Icon(
                                  Icons.people_outline,
                                  color: green,
                                  size: 22,
                                ),
                                SizedBox(width: 8),
                                Text(
                                  'Meet the Team',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: dark,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                _teamMemberPlaceholder('Developer'),
                                _teamMemberPlaceholder('Designer'),
                                _teamMemberPlaceholder('PM'),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Section 4: Contact
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: const [
                          BoxShadow(
                            color: Colors.black12,
                            blurRadius: 6,
                            offset: Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: const [
                                Icon(
                                  Icons.mail_outline,
                                  color: green,
                                  size: 22,
                                ),
                                SizedBox(width: 8),
                                Text(
                                  'Contact',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: dark,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            // Phone
                            _contactTile(
                              icon: Icons.phone_outlined,
                              title: _companyPhone,
                              subtitle: 'Call us for support',
                              onTap: _launchPhone,
                            ),
                            Divider(
                              color: Colors.grey.shade200,
                              height: 24,
                            ),
                            // Email
                            _contactTile(
                              icon: Icons.email_outlined,
                              title: _companyEmail,
                              subtitle: 'Send feedback or report an issue',
                              onTap: _launchEmail,
                            ),
                            Divider(
                              color: Colors.grey.shade200,
                              height: 24,
                            ),
                            // Developer
                            _contactTile(
                              icon: Icons.code,
                              title: _developerName,
                              subtitle: _developerEmail,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Section 5: App info footer
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: green.withOpacity(0.06),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: green.withOpacity(0.15),
                          width: 1,
                        ),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 16,
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                color: green.withOpacity(0.12),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.eco_outlined,
                                color: green,
                                size: 20,
                              ),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Built with care for your home',
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                      color: dark,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    '© 2026 HomeSense. All rights reserved.',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey.shade600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 32),
                ],
              ),
            ),
    );
  }

  Widget _featureChip(IconData icon, String label) {
    const Color green = Color(0xFF1EAA83);
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: green.withOpacity(0.08),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: green.withOpacity(0.2)),
        ),
        child: Column(
          children: [
            Icon(icon, color: green, size: 20),
            const SizedBox(height: 4),
            Text(
              label,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: green,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _teamMemberPlaceholder(String role) {
    return Column(
      children: [
        Container(
          width: 72,
          height: 72,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(
              color: Colors.grey.shade300,
              width: 1.5,
            ),
          ),
          child: ClipOval(
            child: Image.asset(
              'images/nyp-logo.jpg',
              width: 72,
              height: 72,
              fit: BoxFit.cover,
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          role,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: Colors.grey.shade700,
          ),
        ),
      ],
    );
  }

  Widget _contactTile({
    required IconData icon,
    required String title,
    required String subtitle,
    VoidCallback? onTap,
  }) {
    const Color green = Color(0xFF1EAA83);
    return GestureDetector(
      onTap: onTap,
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: green.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: green, size: 20),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF2D3142),
                    decoration:
                        onTap != null ? TextDecoration.underline : null,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ),
          if (onTap != null)
            Icon(
              Icons.arrow_forward_ios,
              size: 14,
              color: Colors.grey.shade400,
            ),
        ],
      ),
    );
  }
}
