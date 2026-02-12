import 'package:flutter/material.dart';
import 'page_about.dart';
import 'page_insights.dart';
import 'page_notifications.dart';
import 'page_settings.dart';
import 'page_editProfile.dart';
import 'signup&login/page_welcome.dart';
import 'page_qualityDetail.dart';
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
  int _selectedRoomIndex = 0;

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
        foregroundColor: Colors.white,
        elevation: 0,
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

      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Full-width green header containing title + doughnut. No horizontal padding so it
              // spans the full device width (it sits outside the page content padding).
              Container(
                width: double.infinity,
                decoration: const BoxDecoration(
                  color: Color(0xFF1EAA83),
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(20),
                    bottomRight: Radius.circular(20),
                  ),
                ),
                // Remove horizontal padding here so doughnut reaches edge; keep a small top spacing.
                padding: const EdgeInsets.only(top: 18.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const SizedBox(height: 6),
                    const Center(child: Text(
                      'Home Health Score',
                      style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.white),
                    ),),
                    const SizedBox(height: 18),
                    // Doughnut score (centered) — no extra horizontal padding applied to this container
                    Center(child: _DoughnutScore(score: 71)),

                    // Status container placed inside the green header (inset from the edges)
                    Container(
                      margin: const EdgeInsets.symmetric(horizontal: 16.0),
                      padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 12.0),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8.0),
                        boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 6, offset: Offset(0, 2))],
                        border: Border(
                          left: BorderSide(width: 8.0, color: const Color(0xFFFFC107)),
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: const [
                          Text('Status: Below Optimal', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black)),
                          SizedBox(height: 6),
                          Text('Home conditions are acceptable, but improvements are recommended.', style: TextStyle(fontSize: 12, color: Colors.black87)),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                  ],
                ),
              ),

              // Remaining content stays inside the page padding
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    

                    // Nav bar (full-width within page padding)
                    RoomNavBar(
                      selectedIndex: _selectedRoomIndex,
                      onSelected: (i) => setState(() => _selectedRoomIndex = i),
                    ),

                    const SizedBox(height: 12),

                    // Horizontal list of quality cards (shorter) — reduced to 3: Electricity, Water, Temperature
                    SizedBox(
                      height: 120,
                      child: ListView(
                        scrollDirection: Axis.horizontal,
                        children: [
                          const SizedBox(width: 8),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 6.0),
                            child: QualityCard(
                              qualityName: 'Electricity',
                              qualityIcon: Icons.bolt,
                              qualityUnit: 'kWh',
                              qualityValue: '8.6',
                              onViewDetails: () {
                                final rooms = ['Living Room', 'Kitchen', 'Bedroom'];
                                final room = rooms[_selectedRoomIndex.clamp(0, rooms.length - 1)];
                                Navigator.push(context, MaterialPageRoute(builder: (_) => QualityDetailPage(room: room, quality: 'Electricity')));
                              },
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 6.0),
                            child: QualityCard(
                              qualityName: 'Water',
                              qualityIcon: Icons.water,
                              qualityUnit: 'L',
                              qualityValue: '120',
                              onViewDetails: () {
                                final rooms = ['Living Room', 'Kitchen', 'Bedroom'];
                                final room = rooms[_selectedRoomIndex.clamp(0, rooms.length - 1)];
                                Navigator.push(context, MaterialPageRoute(builder: (_) => QualityDetailPage(room: room, quality: 'Water')));
                              },
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 6.0),
                            child: QualityCard(
                              qualityName: 'Temperature',
                              qualityIcon: Icons.thermostat,
                              qualityUnit: '°C',
                              qualityValue: '21',
                              onViewDetails: () {
                                final rooms = ['Living Room', 'Kitchen', 'Bedroom'];
                                final room = rooms[_selectedRoomIndex.clamp(0, rooms.length - 1)];
                                Navigator.push(context, MaterialPageRoute(builder: (_) => QualityDetailPage(room: room, quality: 'Temperature')));
                              },
                            ),
                          ),
                          const SizedBox(width: 8),
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Full width Add Location button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {},
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF1EAA83),
                          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: const [
                            Icon(Icons.add, color: Colors.white),
                            SizedBox(width: 12),
                            Text('Add Location', style: TextStyle(color: Colors.white, fontSize: 16)),
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

class RoomNavBar extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int>? onSelected;

  const RoomNavBar({super.key, this.selectedIndex = 0, this.onSelected});

  @override
  Widget build(BuildContext context) {
    final List<String> rooms = ['Living Room', 'Kitchen', 'Bedroom'];
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: List.generate(rooms.length, (i) {
          final bool selected = i == selectedIndex;
          return Expanded(
            child: GestureDetector(
              onTap: () => onSelected?.call(i),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: Text(
                      rooms[i],
                      style: TextStyle(
                        color: selected ? const Color(0xFF1EAA83) : Colors.black87,
                        fontWeight: selected ? FontWeight.bold : FontWeight.normal,
                      ),
                    ),
                  ),
                  Container(
                    height: 3,
                    width: 40,
                    decoration: BoxDecoration(
                      color: selected ? const Color(0xFF1EAA83) : Colors.transparent,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ],
              ),
            ),
          );
        }),
      ),
    );
  }
}


/// Simple doughnut-like score widget. Draws a mostly-complete arc with a missing
/// bottom segment to give the upside-down, open-bottom look and shows the
/// numeric score below the curve.
class _DoughnutScore extends StatelessWidget {
  final int score;
  const _DoughnutScore({required this.score});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 240,
      height: 200,
      child: Stack(
        alignment: Alignment.center,
        children: [
          SizedBox(
            width: 220,
            height: 160,
            child: CustomPaint(
              painter: _DoughnutPainter(),
            ),
          ),
          // Score text centered inside the doughnut
          Text(
            '$score',
            style: const TextStyle(fontSize: 48, fontWeight: FontWeight.bold, color: Colors.white),
          ),
        ],
      ),
    );
  }
}

class _DoughnutPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.height * 0.9) / 2;

    final Rect rect = Rect.fromCircle(center: center, radius: radius);

    final Paint background = Paint()
      ..color = Colors.grey.withOpacity(0.12)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 18.0
      ..strokeCap = StrokeCap.round;

    final Paint arcPaint = Paint()
      ..color = const Color(0xFFFFC107) // amber hue
      ..style = PaintingStyle.stroke
      ..strokeWidth = 18.0
      ..strokeCap = StrokeCap.round;

    // Draw a light background (partial semicircle)
    canvas.drawArc(rect, -3.14, 3.14, false, background);

    // Draw the accent arc (omit bottom segment by limiting sweep)
    final double start = -3.14; // start at left
    final double sweep = 2.6; // less than pi to leave bottom gap
    canvas.drawArc(rect, start, sweep, false, arcPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}