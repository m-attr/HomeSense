import 'package:flutter/material.dart';
import 'page_about.dart';
import 'page_settings.dart';
import 'page_editProfile.dart';
import 'signup&login/page_welcome.dart';
import 'page_qualityDetail.dart';
import '../models/user.dart';
import '../widgets/widget_qualityCard.dart';
import '../models/settings.dart';
import '../widgets/widget_menuDrawer.dart';
import '../widgets/widget_homeStatusChart.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  int _selectedRoomIndex = 0;

  Color? _colorForValue(double value, double threshold) {
    if (threshold <= 0) return Color(0xFF1EAA83);
    if (value >= threshold) return Colors.red;
    if (value >= threshold * 0.8) return Colors.amber;
    return null;
  }
  final List<Map<String, double>> _roomSamples = [
    // Living Room
    {
      'electricity': 8.6,
      'water': 120.0,
      'temperature': 21.0,
    },
    // Kitchen
    {
      'electricity': 12.4,
      'water': 180.0,
      'temperature': 23.5,
    },
    // Bedroom
    {
      'electricity': 6.2,
      'water': 95.0,
      'temperature': 20.0,
    },
  ];
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
        actions: [],
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
              Container(
                width: double.infinity,
                decoration: const BoxDecoration(
                  color: Color(0xFF1EAA83),
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(20),
                    bottomRight: Radius.circular(20),
                  ),
                ),

                padding: const EdgeInsets.only(top: 12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const SizedBox(height: 6),
                    const Center(child: Text(
                      'Home Health Score',
                      style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.white),
                    ),),
                    const SizedBox(height: 6),

                    Center(child: HomeStatusChart(score: 71)),

                 
                    Container(
                      margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 0.0),
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
                    const SizedBox(height: 6),
                  ],
                ),
              ),

              // remaining content stays inside the page padding
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [

                    RoomNavBar(
                      selectedIndex: _selectedRoomIndex,
                      onSelected: (i) => setState(() => _selectedRoomIndex = i),
                    ),

                    const SizedBox(height: 12),

                    SizedBox(
                      height: 220,
                      child: ListView(
                        scrollDirection: Axis.horizontal,
                        children: [
                          const SizedBox(width: 8),
                          (() {
                            final idx = _selectedRoomIndex.clamp(0, _roomSamples.length - 1);
                            final current = _roomSamples[idx];
                            final elec = current['electricity'] ?? 0.0;
                            return Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 6.0),
                              child: QualityCard(
                                qualityName: 'Electricity',
                                qualityIcon: Icons.bolt,
                                qualityUnit: Settings.instance.energyUnit.split(' ').first,
                                qualityValue: elec.toStringAsFixed(1),
                                valueColor: _colorForValue(elec, Settings.instance.electricityThreshold),
                                onViewDetails: () {
                                  final rooms = ['Living Room', 'Kitchen', 'Bedroom'];
                                  final room = rooms[_selectedRoomIndex.clamp(0, rooms.length - 1)];
                                  Navigator.push(context, MaterialPageRoute(builder: (_) => QualityDetailPage(room: room, quality: 'Electricity')));
                                },
                              ),
                            );
                          })(),
                      
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 6.0),
                            child: Builder(builder: (context) {
                              final idx = _selectedRoomIndex.clamp(0, _roomSamples.length - 1);
                              final current = _roomSamples[idx];
                              final water = current['water'] ?? 0.0;
                              return QualityCard(
                                qualityName: 'Water',
                                qualityIcon: Icons.water,
                                qualityUnit: Settings.instance.waterUnit.split(' ').first,
                                qualityValue: water.round().toString(),
                                valueColor: _colorForValue(water, Settings.instance.waterThreshold),
                                onViewDetails: () {
                                  final rooms = ['Living Room', 'Kitchen', 'Bedroom'];
                                  final room = rooms[_selectedRoomIndex.clamp(0, rooms.length - 1)];
                                  Navigator.push(context, MaterialPageRoute(builder: (_) => QualityDetailPage(room: room, quality: 'Water')));
                                },
                              );
                            }),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 6.0),
                            child: Builder(builder: (context) {
                              final idx = _selectedRoomIndex.clamp(0, _roomSamples.length - 1);
                              final current = _roomSamples[idx];
                              final temp = current['temperature'] ?? 0.0;
                              return QualityCard(
                                qualityName: 'Temperature',
                                qualityIcon: Icons.thermostat,
                                qualityUnit: Settings.instance.temperatureUnit.split(' ').first,
                                qualityValue: temp.toStringAsFixed(1),
                                valueColor: _colorForValue(temp, Settings.instance.temperatureThreshold),
                                onViewDetails: () {
                                  final rooms = ['Living Room', 'Kitchen', 'Bedroom'];
                                  final room = rooms[_selectedRoomIndex.clamp(0, rooms.length - 1)];
                                  Navigator.push(context, MaterialPageRoute(builder: (_) => QualityDetailPage(room: room, quality: 'Temperature')));
                                },
                              );
                            }),
                          ),
                          const SizedBox(width: 8),
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),
                    
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
