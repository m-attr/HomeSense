import 'dart:async';
import 'package:flutter/material.dart';
import '../helpers/nav_helper.dart';
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

  // Dynamic rooms list: each entry has a name and which qualities are enabled
  final List<String> _rooms = ['Living Room', 'Kitchen', 'Bedroom'];
  final List<Set<String>> _roomQualities = [
    {'Electricity', 'Water', 'Temperature'},
    {'Electricity', 'Water', 'Temperature'},
    {'Electricity', 'Water', 'Temperature'},
  ];

  Color? _colorForValue(double value, double threshold) {
    if (threshold <= 0) return const Color(0xFF1EAA83);
    if (value >= threshold) return Colors.red;
    if (value >= threshold * 0.8) return Colors.amber;
    return null;
  }

  String _formattedDate() {
    const months = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December',
    ];
    const days = [
      'Monday',
      'Tuesday',
      'Wednesday',
      'Thursday',
      'Friday',
      'Saturday',
      'Sunday',
    ];
    final now = DateTime.now();
    return '${days[now.weekday - 1]}, ${now.day} ${months[now.month - 1]} ${now.year}';
  }

  final List<Map<String, double>> _roomSamples = [
    {'electricity': 8.6, 'water': 120.0, 'temperature': 21.0},
    {'electricity': 12.4, 'water': 180.0, 'temperature': 23.5},
    {'electricity': 6.2, 'water': 95.0, 'temperature': 20.0},
  ];

  // -------------------------------------------------------
  // Add Location dialog
  // -------------------------------------------------------
  void _showAddLocationDialog() {
    final nameCtrl = TextEditingController();
    final selectedQualities = <String>{'Electricity', 'Water', 'Temperature'};

    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'Add Location',
      barrierColor: Colors.black54,
      transitionDuration: const Duration(milliseconds: 300),
      transitionBuilder: (ctx, a1, a2, child) {
        return FadeTransition(
          opacity: a1,
          child: ScaleTransition(
            scale: CurvedAnimation(parent: a1, curve: Curves.easeOutBack),
            child: child,
          ),
        );
      },
      pageBuilder: (ctx, a1, a2) {
        return StatefulBuilder(
          builder: (ctx, setDialogState) {
            return Center(
              child: Material(
                color: Colors.transparent,
                child: Container(
                  width: MediaQuery.of(ctx).size.width * 0.85,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(color: Colors.black26, blurRadius: 12),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Header row with title + close button
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Add Location',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          GestureDetector(
                            onTap: () => Navigator.pop(ctx),
                            child: Container(
                              padding: const EdgeInsets.all(4),
                              decoration: BoxDecoration(
                                color: Colors.grey.shade200,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.close,
                                size: 20,
                                color: Colors.black54,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),

                      // Room name input
                      const Text(
                        'Room Name',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 6),
                      TextField(
                        controller: nameCtrl,
                        decoration: InputDecoration(
                          hintText: 'e.g. Living Room',
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 12,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: const BorderSide(
                              color: Color(0xFF1EAA83),
                              width: 2,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Quality selection
                      const Text(
                        'Qualities',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 8),
                      ...[
                        {'key': 'Electricity', 'icon': Icons.bolt},
                        {'key': 'Water', 'icon': Icons.water_drop},
                        {'key': 'Temperature', 'icon': Icons.thermostat},
                      ].map((q) {
                        final key = q['key'] as String;
                        final icon = q['icon'] as IconData;
                        final isOn = selectedQualities.contains(key);
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 6),
                          child: GestureDetector(
                            onTap: () {
                              setDialogState(() {
                                if (isOn) {
                                  selectedQualities.remove(key);
                                } else {
                                  selectedQualities.add(key);
                                }
                              });
                            },
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 10,
                              ),
                              decoration: BoxDecoration(
                                color: isOn
                                    ? const Color(0xFF1EAA83).withAlpha(20)
                                    : Colors.grey.shade50,
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(
                                  color: isOn
                                      ? const Color(0xFF1EAA83)
                                      : Colors.grey.shade300,
                                  width: 1.5,
                                ),
                              ),
                              child: Row(
                                children: [
                                  Icon(
                                    icon,
                                    size: 22,
                                    color: isOn
                                        ? const Color(0xFF1EAA83)
                                        : Colors.grey,
                                  ),
                                  const SizedBox(width: 10),
                                  Text(
                                    key,
                                    style: TextStyle(
                                      fontWeight: FontWeight.w500,
                                      color: isOn
                                          ? const Color(0xFF1EAA83)
                                          : Colors.grey.shade700,
                                    ),
                                  ),
                                  const Spacer(),
                                  AnimatedSwitcher(
                                    duration: const Duration(milliseconds: 200),
                                    child: isOn
                                        ? const Icon(
                                            Icons.check_circle,
                                            color: Color(0xFF1EAA83),
                                            key: ValueKey(true),
                                          )
                                        : Icon(
                                            Icons.circle_outlined,
                                            color: Colors.grey.shade400,
                                            key: const ValueKey(false),
                                          ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      }),

                      const SizedBox(height: 16),

                      // Save button bottom-right
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          ElevatedButton(
                            onPressed: () {
                              final name = nameCtrl.text.trim();
                              if (name.isEmpty) return;
                              Navigator.pop(ctx, {
                                'name': name,
                                'qualities': Set<String>.from(
                                  selectedQualities,
                                ),
                              });
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF1EAA83),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 28,
                                vertical: 12,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            child: const Text(
                              'Save',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    ).then((result) {
      if (result == null) return;
      final data = result as Map<String, dynamic>;
      final name = data['name'] as String;
      final qualities = data['qualities'] as Set<String>;
      setState(() {
        _rooms.add(name);
        _roomQualities.add(qualities);
        // New rooms have no sample data — they'll show the empty state
        _selectedRoomIndex = _rooms.length - 1;
      });
    });
  }

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
          decoration: const InputDecoration(
            hintText: 'Enter image URL or asset path',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, controller.text.trim()),
            child: const Text('OK'),
          ),
        ],
      ),
    );

    if (result != null) {
      setState(() {
        if (current != null)
          current.profileImage = result.isEmpty ? null : result;
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
                  Text(
                    '28\u00B0',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 2),
              Text(
                "Today's Weather",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
        actions: [
          Builder(
            builder: (context) => IconButton(
              icon: const Icon(Icons.menu, size: 34),
              iconSize: 32,
              padding: const EdgeInsets.all(12),
              onPressed: () => Scaffold.of(context).openEndDrawer(),
              color: Colors.white,
              tooltip: 'Menu',
            ),
          ),
        ],
      ),

      endDrawer: WidgetMenuDrawer(
        onHome: () {
          navigateNamedWithLoading(
            context,
            routeName: '/dashboard',
            replace: true,
          );
        },
        onProfile: () {
          navigateWithLoading(context, destination: const EditProfilePage());
        },
        onAbout: () {
          navigateWithLoading(context, destination: const AboutPage());
        },
        onSettings: () async {
          await navigateWithLoading(context, destination: const SettingsPage());
          if (!mounted) return;
          setState(() {});
        },
        onLogout: () {
          final repo = UserRepository.instance;
          repo.currentUser = null;
          repo.setLastLoggedInEmail(null);
          navigateWithLoading(
            context,
            destination: const WelcomePage(),
            removeAll: true,
          );
        },
        onChangeProfileImage: () => _changeProfileImage(context),
      ),

      backgroundColor: const Color(0xFFF5F7FA),
      body: Stack(
        children: [
          // Subtle gradient behind the top section
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: 220,
            child: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Color(0xFFE8F5F0), Color(0xFFF5F7FA)],
                ),
              ),
            ),
          ),
          SafeArea(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Greeting + date row
                  Padding(
                    padding: const EdgeInsets.fromLTRB(24, 16, 24, 4),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Hello, ${UserRepository.instance.currentUser?.fullName.split(' ').first ?? 'there'} 👋',
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF2D3142),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _formattedDate(),
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Health block
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20.0),
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.only(top: 12.0),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black12,
                            blurRadius: 6,
                            offset: Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          const SizedBox(height: 6),
                          Center(
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: const [
                                Icon(
                                  Icons.favorite,
                                  color: Color(0xFF1EAA83),
                                  size: 28,
                                ),
                                SizedBox(width: 8),
                                Text(
                                  'Home Health Score',
                                  style: TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF2D3142),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 6),
                          Center(child: HomeStatusChart(score: 55)),
                          Container(
                            margin: const EdgeInsets.fromLTRB(16, 0, 16, 20),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 12,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFFFFC107).withOpacity(0.08),
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(
                                color: const Color(0xFFFFC107).withOpacity(0.3),
                                width: 1.2,
                              ),
                            ),
                            child: Row(
                              children: [
                                Container(
                                  width: 38,
                                  height: 38,
                                  decoration: BoxDecoration(
                                    color: const Color(
                                      0xFFFFC107,
                                    ).withOpacity(0.15),
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(
                                    Icons.warning_amber_rounded,
                                    color: Color(0xFFFFC107),
                                    size: 20,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      const Text(
                                        'Below Optimal',
                                        style: TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w600,
                                          color: Color(0xFFFFC107),
                                        ),
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        'Improvements recommended',
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: Colors.grey.shade600,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                IconButton(
                                  icon: const Icon(
                                    Icons.info_outline,
                                    color: Color(0xFFFFC107),
                                    size: 22,
                                  ),
                                  onPressed: () =>
                                      setState(() => _showStatusPopup = true),
                                  tooltip: 'Details',
                                  padding: EdgeInsets.zero,
                                  constraints: const BoxConstraints(
                                    minWidth: 36,
                                    minHeight: 36,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // full-width light separator
                  SizedBox(height: 20),

                  // Rooms section
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20.0),
                    child: Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black12,
                            blurRadius: 6,
                            offset: Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16.0,
                          vertical: 20.0,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Row(
                              children: const [
                                Icon(
                                  Icons.room_preferences_outlined,
                                  color: Color(0xFF1EAA83),
                                  size: 22,
                                ),
                                SizedBox(width: 8),
                                Text(
                                  'My Rooms',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF2D3142),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            RoomNavBar(
                              rooms: _rooms,
                              selectedIndex: _selectedRoomIndex,
                              onSelected: (i) =>
                                  setState(() => _selectedRoomIndex = i),
                            ),
                            const SizedBox(height: 12),
                            // If this room has no sample data, show cards with '-' for selected qualities
                            if (_selectedRoomIndex >= _roomSamples.length)
                              SizedBox(
                                height: 220,
                                child: ListView(
                                  scrollDirection: Axis.horizontal,
                                  children: [
                                    const SizedBox(width: 8),
                                    ...(() {
                                      final quals =
                                          _selectedRoomIndex <
                                              _roomQualities.length
                                          ? _roomQualities[_selectedRoomIndex]
                                          : <String>{};
                                      final room =
                                          _rooms[_selectedRoomIndex.clamp(
                                            0,
                                            _rooms.length - 1,
                                          )];
                                      final List<Widget> cards = [];
                                      if (quals.contains('Electricity')) {
                                        cards.add(
                                          Padding(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 6.0,
                                            ),
                                            child: QualityCard(
                                              qualityName: 'Electricity',
                                              qualityIcon: Icons.bolt,
                                              qualityUnit: Settings
                                                  .instance
                                                  .energyUnit
                                                  .split(' ')
                                                  .first,
                                              qualityValue: '-',
                                              cardColor: const Color(0xFFF5A623),
                                              onViewDetails: () {
                                                navigateWithLoading(
                                                  context,
                                                  destination:
                                                      QualityDetailPage(
                                                        room: room,
                                                        quality: 'Electricity',
                                                        hasDevices: false,
                                                        availableQualities:
                                                            quals.toList(),
                                                      ),
                                                );
                                              },
                                            ),
                                          ),
                                        );
                                      }
                                      if (quals.contains('Water')) {
                                        cards.add(
                                          Padding(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 6.0,
                                            ),
                                            child: QualityCard(
                                              qualityName: 'Water',
                                              qualityIcon: Icons.water,
                                              qualityUnit: Settings
                                                  .instance
                                                  .waterUnit
                                                  .split(' ')
                                                  .first,
                                              qualityValue: '-',
                                              cardColor: const Color(0xFF42A5F5),
                                              onViewDetails: () {
                                                navigateWithLoading(
                                                  context,
                                                  destination:
                                                      QualityDetailPage(
                                                        room: room,
                                                        quality: 'Water',
                                                        hasDevices: false,
                                                        availableQualities:
                                                            quals.toList(),
                                                      ),
                                                );
                                              },
                                            ),
                                          ),
                                        );
                                      }
                                      if (quals.contains('Temperature')) {
                                        cards.add(
                                          Padding(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 6.0,
                                            ),
                                            child: QualityCard(
                                              qualityName: 'Temperature',
                                              qualityIcon: Icons.thermostat,
                                              qualityUnit: Settings
                                                  .instance
                                                  .temperatureUnit
                                                  .split(' ')
                                                  .first,
                                              qualityValue: '-',
                                              cardColor: const Color(0xFFEF6C57),
                                              onViewDetails: () {
                                                navigateWithLoading(
                                                  context,
                                                  destination:
                                                      QualityDetailPage(
                                                        room: room,
                                                        quality: 'Temperature',
                                                        hasDevices: false,
                                                        availableQualities:
                                                            quals.toList(),
                                                      ),
                                                );
                                              },
                                            ),
                                          ),
                                        );
                                      }
                                      return cards;
                                    })(),
                                    const SizedBox(width: 8),
                                  ],
                                ),
                              )
                            else
                              SizedBox(
                                height: 220,
                                child: ListView(
                                  scrollDirection: Axis.horizontal,
                                  children: [
                                    const SizedBox(width: 8),
                                    (() {
                                      final idx = _selectedRoomIndex.clamp(
                                        0,
                                        _roomSamples.length - 1,
                                      );
                                      final current = _roomSamples[idx];
                                      final elec =
                                          current['electricity'] ?? 0.0;
                                      return Padding(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 6.0,
                                        ),
                                        child: QualityCard(
                                          qualityName: 'Electricity',
                                          qualityIcon: Icons.bolt,
                                          qualityUnit: Settings
                                              .instance
                                              .energyUnit
                                              .split(' ')
                                              .first,
                                          qualityValue: elec.toStringAsFixed(1),
                                          cardColor: const Color(0xFFF5A623),
                                          valueColor: _colorForValue(
                                            elec,
                                            Settings
                                                .instance
                                                .electricityThreshold,
                                          ),
                                          threshold: Settings.instance.electricityThreshold,
                                          onViewDetails: () {
                                            final room =
                                                _rooms[_selectedRoomIndex.clamp(
                                                  0,
                                                  _rooms.length - 1,
                                                )];
                                            navigateWithLoading(
                                              context,
                                              destination: QualityDetailPage(
                                                room: room,
                                                quality: 'Electricity',
                                              ),
                                            );
                                          },
                                        ),
                                      );
                                    })(),
                                    Padding(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 6.0,
                                      ),
                                      child: Builder(
                                        builder: (context) {
                                          final idx = _selectedRoomIndex.clamp(
                                            0,
                                            _roomSamples.length - 1,
                                          );
                                          final current = _roomSamples[idx];
                                          final water = current['water'] ?? 0.0;
                                          return QualityCard(
                                            qualityName: 'Water',
                                            qualityIcon: Icons.water,
                                            qualityUnit: Settings
                                                .instance
                                                .waterUnit
                                                .split(' ')
                                                .first,
                                            qualityValue: water
                                                .round()
                                                .toString(),
                                            cardColor: const Color(0xFF42A5F5),
                                            valueColor: _colorForValue(
                                              water,
                                              Settings.instance.waterThreshold,
                                            ),
                                            threshold: Settings.instance.waterThreshold,
                                            onViewDetails: () {
                                              final room =
                                                  _rooms[_selectedRoomIndex
                                                      .clamp(
                                                        0,
                                                        _rooms.length - 1,
                                                      )];
                                              navigateWithLoading(
                                                context,
                                                destination: QualityDetailPage(
                                                  room: room,
                                                  quality: 'Water',
                                                ),
                                              );
                                            },
                                          );
                                        },
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 6.0,
                                      ),
                                      child: Builder(
                                        builder: (context) {
                                          final idx = _selectedRoomIndex.clamp(
                                            0,
                                            _roomSamples.length - 1,
                                          );
                                          final current = _roomSamples[idx];
                                          final temp =
                                              current['temperature'] ?? 0.0;
                                          return QualityCard(
                                            qualityName: 'Temperature',
                                            qualityIcon: Icons.thermostat,
                                            qualityUnit: Settings
                                                .instance
                                                .temperatureUnit
                                                .split(' ')
                                                .first,
                                            qualityValue: temp.toStringAsFixed(
                                              1,
                                            ),
                                            cardColor: const Color(0xFFEF6C57),
                                            valueColor: _colorForValue(
                                              temp,
                                              Settings
                                                  .instance
                                                  .temperatureThreshold,
                                            ),
                                            threshold: Settings.instance.temperatureThreshold,
                                            onViewDetails: () {
                                              final room =
                                                  _rooms[_selectedRoomIndex
                                                      .clamp(
                                                        0,
                                                        _rooms.length - 1,
                                                      )];
                                              navigateWithLoading(
                                                context,
                                                destination: QualityDetailPage(
                                                  room: room,
                                                  quality: 'Temperature',
                                                ),
                                              );
                                            },
                                          );
                                        },
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                  ],
                                ),
                              ),
                            const SizedBox(height: 24),
                            SizedBox(
                              width: double.infinity,
                              child: OutlinedButton(
                                onPressed: _showAddLocationDialog,
                                style: OutlinedButton.styleFrom(
                                  side: const BorderSide(
                                    color: Color(0xFF1EAA83),
                                    width: 1.5,
                                  ),
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 16,
                                    horizontal: 16,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  backgroundColor: const Color(0xFFE8F5F0),
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: const [
                                    Icon(
                                      Icons.add_circle_outline,
                                      color: Color(0xFF1EAA83),
                                      size: 22,
                                    ),
                                    SizedBox(width: 10),
                                    Text(
                                      'Add Location',
                                      style: TextStyle(
                                        color: Color(0xFF1EAA83),
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Quick Tips card
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20.0),
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFF1EAA83), Color(0xFF15C997)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF1EAA83).withOpacity(0.3),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(
                              Icons.lightbulb_outline,
                              color: Colors.white,
                              size: 28,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: const [
                                Text(
                                  'Quick Tip',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                SizedBox(height: 4),
                                Text(
                                  'Reducing standby power can save up to 10% on your electricity bill.',
                                  style: TextStyle(
                                    color: Colors.white70,
                                    fontSize: 13,
                                    height: 1.4,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
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
                      border: Border(
                        left: BorderSide(
                          color: const Color(0xFF1EAA83),
                          width: 6,
                        ),
                      ),
                      boxShadow: [
                        BoxShadow(color: Colors.black26, blurRadius: 6),
                      ],
                    ),
                    padding: const EdgeInsets.symmetric(
                      vertical: 12,
                      horizontal: 12,
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            'Welcome back, ${UserRepository.instance.currentUser?.fullName ?? ''}',
                            style: const TextStyle(
                              color: Colors.black87,
                              fontWeight: FontWeight.w600,
                            ),
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
                  child: Center(
                    child: GestureDetector(
                      onTap: () {}, // absorb tap on popup itself
                      child: Container(
                        width: 330,
                        margin: const EdgeInsets.symmetric(horizontal: 24),
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.15),
                              blurRadius: 24,
                              offset: const Offset(0, 8),
                            ),
                          ],
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            // Close button
                            Align(
                              alignment: Alignment.topRight,
                              child: GestureDetector(
                                onTap: () =>
                                    setState(() => _showStatusPopup = false),
                                child: Container(
                                  width: 32,
                                  height: 32,
                                  decoration: BoxDecoration(
                                    color: Colors.grey.shade100,
                                    shape: BoxShape.circle,
                                  ),
                                  child: Icon(
                                    Icons.close,
                                    size: 18,
                                    color: Colors.grey.shade600,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 4),
                            // Status icon
                            Container(
                              width: 64,
                              height: 64,
                              decoration: BoxDecoration(
                                color: const Color(
                                  0xFFFFC107,
                                ).withOpacity(0.12),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.warning_amber_rounded,
                                size: 32,
                                color: Color(0xFFFFC107),
                              ),
                            ),
                            const SizedBox(height: 14),
                            const Text(
                              'Below Optimal',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFFFFC107),
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Home Health Score: 55/100',
                              style: TextStyle(
                                fontSize: 15,
                                color: Colors.grey.shade600,
                              ),
                            ),
                            const SizedBox(height: 16),
                            Divider(color: Colors.grey.shade200),
                            const SizedBox(height: 12),
                            // What this means
                            Align(
                              alignment: Alignment.centerLeft,
                              child: Text(
                                'What this means',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.grey.shade800,
                                ),
                              ),
                            ),
                            const SizedBox(height: 6),
                            Align(
                              alignment: Alignment.centerLeft,
                              child: Text(
                                'Your home environment is functional but has room for improvement. Some conditions — such as temperature, humidity, or energy usage — may not be at their ideal levels, affecting comfort and efficiency.',
                                style: TextStyle(
                                  fontSize: 13,
                                  color: Colors.grey.shade600,
                                  height: 1.5,
                                ),
                              ),
                            ),
                            const SizedBox(height: 16),
                            Align(
                              alignment: Alignment.centerLeft,
                              child: Text(
                                'Recommended Actions',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.grey.shade800,
                                ),
                              ),
                            ),
                            const SizedBox(height: 8),
                            _statusTipRow(
                              "Review each room's quality readings for any outliers.",
                              const Color(0xFFFFC107),
                            ),
                            _statusTipRow(
                              'Adjust thermostat settings to maintain 20–26°C.',
                              const Color(0xFFFFC107),
                            ),
                            _statusTipRow(
                              'Check for water leaks or unusual consumption patterns.',
                              const Color(0xFFFFC107),
                            ),
                            _statusTipRow(
                              'Ensure devices are online and reporting correctly.',
                              const Color(0xFFFFC107),
                            ),
                            const SizedBox(height: 8),
                          ],
                        ),
                      ),
                    ),
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

  Widget _statusTipRow(String tip, Color color) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.lightbulb_outline, size: 18, color: color),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              tip,
              style: TextStyle(
                fontSize: 13,
                color: Colors.grey.shade700,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class RoomNavBar extends StatefulWidget {
  final List<String> rooms;
  final int selectedIndex;
  final ValueChanged<int>? onSelected;

  const RoomNavBar({
    super.key,
    required this.rooms,
    this.selectedIndex = 0,
    this.onSelected,
  });

  @override
  State<RoomNavBar> createState() => _RoomNavBarState();
}

class _RoomNavBarState extends State<RoomNavBar> {
  final ScrollController _scrollCtrl = ScrollController();
  static const Color _green = Color(0xFF1EAA83);
  static const Color _dark = Color(0xFF2D3142);

  @override
  void dispose() {
    _scrollCtrl.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(covariant RoomNavBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.selectedIndex != widget.selectedIndex) {
      _ensureVisible(widget.selectedIndex);
    }
  }

  void _ensureVisible(int index) {
    if (!_scrollCtrl.hasClients) return;
    // Rough estimate: each chip is ~120 wide; scroll so selected is centred
    final target = (index * 120.0) - 60.0;
    _scrollCtrl.animateTo(
      target.clamp(0.0, _scrollCtrl.position.maxScrollExtent),
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOut,
    );
  }

  Widget _chip(int i) {
    final bool selected = i == widget.selectedIndex;
    return GestureDetector(
      onTap: () => widget.onSelected?.call(i),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 4),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: selected ? _green : Colors.grey.shade100,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: selected ? _green : Colors.grey.shade300,
            width: 1,
          ),
        ),
        child: Text(
          widget.rooms[i],
          style: TextStyle(
            fontSize: 13,
            fontWeight: selected ? FontWeight.w600 : FontWeight.normal,
            color: selected ? Colors.white : _dark,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // 3 or fewer → display in a single row, centred
    if (widget.rooms.length <= 3) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 6),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(
            widget.rooms.length,
            (i) => _chip(i),
          ),
        ),
      );
    }

    // More than 3 → scrollable, but clip to show a peek of the 4th chip
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: SizedBox(
        height: 40,
        child: ShaderMask(
          shaderCallback: (Rect bounds) {
            return const LinearGradient(
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
              colors: [Colors.white, Colors.white, Colors.white, Colors.transparent],
              stops: [0.0, 0.7, 0.88, 1.0],
            ).createShader(bounds);
          },
          blendMode: BlendMode.dstIn,
          child: ListView.builder(
            controller: _scrollCtrl,
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 4),
            itemCount: widget.rooms.length,
            itemBuilder: (_, i) => _chip(i),
          ),
        ),
      ),
    );
  }
}
