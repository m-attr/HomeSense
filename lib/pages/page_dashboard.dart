import 'package:flutter/material.dart';
import 'page_about.dart';
import 'page_insights.dart';
import 'page_notifications.dart';
import 'page_settings.dart';
import 'page_editProfile.dart';
import 'signup&login/page_welcome.dart';
import '../models/user.dart';
import '../widgets/widget_qualityCard.dart';
import '../widgets/widget_realTimeChart.dart';
import '../widgets/widget_menuDrawer.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
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
      appBar: AppBar(
        backgroundColor: const Color(0xFF1EAA83),
        leading: Builder(
          builder: (context) => IconButton(
            icon: const Icon(Icons.menu),
            onPressed: () => Scaffold.of(context).openDrawer(),
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: CircleAvatar(
              backgroundImage: const AssetImage('images/homesense-logo.png'),
              radius: 18,
            ),
          ),
        ],
      ),

      drawer: WidgetMenuDrawer(
        onHome: () {
          Navigator.pop(context);
          Navigator.pushReplacementNamed(context, '/dashboard');
        },
        onProfile: () {
          Navigator.pop(context);
          Navigator.push(context, MaterialPageRoute(builder: (_) => const EditProfilePage()));
        },
        onAbout: () {
          Navigator.pop(context);
          Navigator.push(context, MaterialPageRoute(builder: (_) => const AboutPage()));
        },
        onInsights: () {
          Navigator.pop(context);
          Navigator.push(context, MaterialPageRoute(builder: (_) => const InsightsPage()));
        },
        onNotifications: () {
          Navigator.pop(context);
          Navigator.push(context, MaterialPageRoute(builder: (_) => const NotificationsPage()));
        },
        onSettings: () {
          Navigator.pop(context);
          Navigator.push(context, MaterialPageRoute(builder: (_) => const SettingsPage()));
        },
        onLogout: () {
          final repo = UserRepository.instance;
          repo.currentUser = null;
          repo.setLastLoggedInEmail(null);
          Navigator.pop(context);
          Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (_) => const WelcomePage()), (route) => false);
        },
        onChangeProfileImage: () => _changeProfileImage(context),
      ),

      backgroundColor: const Color(0xFF1EAA83),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Padding(
              padding: EdgeInsets.all(24),
              child: Text(
                'Hello, User',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),

            SizedBox(
              height: 220,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: 5,
                itemBuilder: (context, index) {
                  List<String> qualityNames = ['Air Quality', 'Temperature', 'Quality 3', 'Quality 4', 'Quality 5'];
                  List<IconData> qualityIcons = [Icons.star, Icons.favorite, Icons.thumb_up, Icons.check_circle, Icons.info];
                  List<String> qualityUnits = ['Unit 1', 'Unit 2', 'Unit 3', 'Unit 4', 'Unit 5'];

                  EdgeInsets cardPadding = index == 0
                      ? const EdgeInsets.only(left: 40.0, right: 8.0)
                      : const EdgeInsets.symmetric(horizontal: 4.0);

                  return Padding(
                    padding: cardPadding,
                    child: QualityCard(
                      qualityName: qualityNames[index],
                      qualityIcon: qualityIcons[index],
                      qualityUnit: qualityUnits[index],
                    ),
                  );
                },
              ),
            ),

            const Padding(
              padding: EdgeInsets.all(24.0),
              child: Text(
                'Summary',
                style: TextStyle(
                  fontSize: 18,
                  color: Colors.white,
                ),
              ),
            ),

            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: const RealTimeChart(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}