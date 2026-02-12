import 'package:flutter/material.dart';
import 'page_about.dart';
import 'page_insights.dart';
import 'page_notifications.dart';
import 'page_settings.dart';
import 'page_editProfile.dart';
import '../widgets/widget_qualityCard.dart';
import '../widgets/widget_realTimeChart.dart';

class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
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
                backgroundImage: AssetImage('images/homesense-logo.png'),
                radius: 18,
              ),
            ),
          ],
        ),
        drawer: Drawer(
          child: ListView(
            padding: EdgeInsets.zero,
            children: [
              DrawerHeader(
                decoration: const BoxDecoration(
                  color: Color(0xFF1EAA83),
                ),
                child: const Text(
                  'Menu',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                  ),
                ),
              ),
              ListTile(
                leading: const Icon(Icons.home),
                title: const Text('Home'),
                selected: true,
                onTap: () {
                  Navigator.pop(context);
                },
              ),
              ListTile(
                leading: const Icon(Icons.person),
                title: const Text('MyProfile'),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(context, MaterialPageRoute(builder: (_) => const EditProfilePage()));
                },
              ),
              ListTile(
                leading: const Icon(Icons.info_outline),
                title: const Text('About'),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(context, MaterialPageRoute(builder: (_) => const AboutPage()));
                },
              ),
              ListTile(
                leading: const Icon(Icons.show_chart),
                title: const Text('Insights'),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(context, MaterialPageRoute(builder: (_) => const InsightsPage()));
                },
              ),
              ListTile(
                leading: const Icon(Icons.notifications),
                title: const Text('Notifications'),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(context, MaterialPageRoute(builder: (_) => const NotificationsPage()));
                },
              ),
              ListTile(
                leading: const Icon(Icons.settings),
                title: const Text('Settings'),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(context, MaterialPageRoute(builder: (_) => const SettingsPage()));
                },
              ),
            ],
          ),
        ),
        backgroundColor: Color(0xFF1EAA83),
        body: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
            Padding(
              padding: const EdgeInsets.all(24),
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
            Padding(
              padding: const EdgeInsets.all(24.0),
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
        ), // Column
      ), // SafeArea
    ), // Scaffold
  ); // MaterialApp
  }
}