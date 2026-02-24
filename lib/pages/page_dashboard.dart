import 'dart:async';
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
  bool _showWelcomeBanner = false;
  Timer? _welcomeTimer;
  bool _showStatusPopup = false;

  Color? _colorForValue(double value, double threshold) {
    if (threshold <= 0) return const Color(0xFF1EAA83);
    if (value >= threshold) return Colors.red;
    if (value >= threshold * 0.8) return Colors.amber;
    return null;
  }

  final List<Map<String, double>> _roomSamples = [
    {
      'electricity': 8.6,
      'water': 120.0,
      'temperature': 21.0,
    },
    {
      'electricity': 12.4,
      'water': 180.0,
      'temperature': 23.5,
    },
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
        automaticallyImplyLeading: false,
        backgroundColor: const Color(0xFF1EAA83),
        foregroundColor: Colors.white,
        elevation: 0,
        titleSpacing: 0,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(10)),
        ),
        title: Padding(
          padding: const EdgeInsets.only(left: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: const [
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.wb_sunny, color: Colors.amberAccent),
                  SizedBox(width: 6),
                  Text('28\\u00B0', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
                ],
              ),
              SizedBox(height: 2),
              Text("Today's Weather", style: TextStyle(color: Colors.white70, fontSize: 12)),
            ],
          ),
        ),
        actions: [
          Builder(builder: (context) => IconButton(
                icon: const Icon(Icons.menu, size: 34),
                iconSize: 32,
                padding: const EdgeInsets.all(12),
                onPressed: () => Scaffold.of(context).openEndDrawer(),
                color: Colors.white,
                tooltip: 'Menu',
              )),
        ],
      ),

      endDrawer: WidgetMenuDrawer(
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
        onSettings: () async {
          Navigator.pop(context);
          await Navigator.push(context, MaterialPageRoute(builder: (_) => const SettingsPage()));
          if (!mounted) return;
          setState(() {});
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

      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Stack(
        children: [
          SafeArea(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  SizedBox(height: 20,),
                  
                  // Health block
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.only(top: 12.0),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 6, offset: Offset(0, 2))],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        const SizedBox(height: 6),
                        const Center(
                            child: Text(
                          'Home Health Score',
                          style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.black87),
                        )),
                        const SizedBox(height: 6),
                        Center(child: HomeStatusChart(score: 55)),
                        Container(
                          margin: const EdgeInsets.fromLTRB(16.0, 0.0, 16.0, 24),
                          padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 12.0),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(8.0),
                            boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 6, offset: Offset(0, 2))],
                            border: Border(left: BorderSide(width: 8.0, color: const Color(0xFFFFC107))),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text('Status: Below Optimal', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black)),
                              IconButton(
                                icon: const Icon(Icons.error_outline, color: Color(0xFFFFC107)),
                                onPressed: () => setState(() => _showStatusPopup = true),
                                tooltip: 'Details',
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  // full-width light separator
                  SizedBox(height: 20,),

                  // Rooms section
                  Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 6, offset: Offset(0, 2))],
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 20.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          const Text('My Rooms', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87)),
                          const SizedBox(height: 8),
                          RoomNavBar(selectedIndex: _selectedRoomIndex, onSelected: (i) => setState(() => _selectedRoomIndex = i)),
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
                  ),
                  SizedBox(height: 20,),
                ],
              ),
            ),
          ),

          if (_showWelcomeBanner)
            Positioned(
              top: MediaQuery.of(context).padding.top + 12,
              left: 16,
              right: 16,
              child: Material(
                color: Colors.transparent,
                child: AnimatedOpacity(
                  opacity: _showWelcomeBanner ? 1.0 : 0.0,
                  duration: const Duration(milliseconds: 300),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10),
                      border: Border(left: BorderSide(color: const Color(0xFF1EAA83), width: 6)),
                      boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 6)],
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            'Welcome back, ${UserRepository.instance.currentUser?.fullName ?? ''}',
                            style: const TextStyle(color: Colors.black87, fontWeight: FontWeight.w600),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),

          if (_showStatusPopup)
            Positioned.fill(
              child: Material(
                color: Colors.black54,
                child: GestureDetector(
                  onTap: () {
                    setState(() => _showStatusPopup = false);
                  },
                  child: Stack(
                    children: [
                      Positioned(
                        top: MediaQuery.of(context).padding.top + 80,
                        left: 24,
                        right: 24,
                        child: Material(
                          borderRadius: BorderRadius.circular(12),
                          child: Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    IconButton(
                                      icon: const Icon(Icons.close),
                                      onPressed: () => setState(() => _showStatusPopup = false),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 4),
                                const Text('Home conditions are acceptable, but improvements are recommended.', style: TextStyle(fontSize: 14, color: Colors.black87)),
                                const SizedBox(height: 8),
                              ],
                            ),
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

  @override
  void initState() {
    super.initState();
    // show welcome banner briefly if a user is already logged in
    final repo = UserRepository.instance;
    if (repo.currentUser != null) {
      // schedule showing shortly after build
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        setState(() => _showWelcomeBanner = true);
        _welcomeTimer = Timer(const Duration(seconds: 3), () {
          if (mounted) setState(() => _showWelcomeBanner = false);
        });
      });
    }
  }

  @override
  void dispose() {
    _welcomeTimer?.cancel();
    super.dispose();
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
