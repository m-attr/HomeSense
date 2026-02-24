import 'package:flutter/material.dart';
import '../widgets/widget_fixedChart.dart';
import '../widgets/widget_qualityDeviceCard.dart';
import '../models/settings.dart';
import '../widgets/qualities/widget_temperatureSection.dart';
import '../widgets/qualities/widget_waterSection.dart';

class QualityDetailPage extends StatelessWidget {
  final String room;
  final String quality;

  const QualityDetailPage({super.key, required this.room, required this.quality});

  @override
  Widget build(BuildContext context) {
    const Color green = Color(0xFF1EAA83);
    // prebuild device cards list to avoid nested inline closures confusing analyzer/editors
    final List<Widget> _deviceWidgets = List<Widget>.generate(3, (i) {
      String unit;
      IconData leftIcon;
      if (quality.toLowerCase().contains('electric')) {
        unit = Settings.instance.energyUnit.split(' ').first;
        leftIcon = Icons.bolt;
      } else if (quality.toLowerCase().contains('water')) {
        unit = Settings.instance.waterUnit.split(' ').first;
        leftIcon = Icons.water;
      } else {
        unit = Settings.instance.temperatureUnit.split(' ').first;
        leftIcon = Icons.thermostat;
      }

      return Padding(
        padding: const EdgeInsets.only(bottom: 12.0),
        child: QualityDeviceCard(
          leftIcon: leftIcon,
          rightIcon: Icons.settings,
          deviceName: '$quality device ${i + 1}',
          deviceCountText: '${(i % 3) + 1} devices',
          valueText: (20 + i).toString(),
          unitText: unit,
          onTap: () {},
        ),
      );
    });
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // App bar: green with rounded bottom corners
            ClipRRect(
              borderRadius: const BorderRadius.only(bottomLeft: Radius.circular(18), bottomRight: Radius.circular(18)),
              child: Container(
                width: double.infinity,
                color: green,
                padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top, left: 4, right: 8, bottom: 12),
                child: SizedBox(
                  height: 56,
                  // Use a Stack so the room text is truly centered in the app bar
                  child: Stack(
                    children: [
                      // left-aligned back controls
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.arrow_back, color: Colors.white),
                              onPressed: () {
                                if (Navigator.canPop(context)) {
                                  Navigator.pop(context);
                                } else {
                                  Navigator.pushReplacementNamed(context, '/dashboard');
                                }
                              },
                            ),
                            Padding(
                              padding: const EdgeInsets.only(left: 6.0),
                              child: const Text('Back', style: TextStyle(color: Colors.white, fontSize: 16)),
                            ),
                          ],
                        ),
                      ),

                      // centered room/location title (will always be centered within the appbar)
                      Center(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 64.0),
                          child: Text(
                            room,
                            textAlign: TextAlign.center,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // Chart area: white background under the app bar
            Container(
              color: Colors.white,
              width: double.infinity,
              child: SizedBox(
                height: 260,
                child: RealTimeChart(label: quality),
              ),
            ),

            // --- 3 quality navigation buttons ---
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: Row(
                children: [
                  _qualityNavButton(
                    context,
                    icon: Icons.bolt,
                    label: 'Electricity',
                    isActive: quality.toLowerCase().contains('electric'),
                    onTap: () {
                      if (!quality.toLowerCase().contains('electric')) {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (_) => QualityDetailPage(room: room, quality: 'Electricity'),
                          ),
                        );
                      }
                    },
                  ),
                  const SizedBox(width: 10),
                  _qualityNavButton(
                    context,
                    icon: Icons.water_drop,
                    label: 'Water',
                    isActive: quality.toLowerCase().contains('water'),
                    onTap: () {
                      if (!quality.toLowerCase().contains('water')) {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (_) => QualityDetailPage(room: room, quality: 'Water'),
                          ),
                        );
                      }
                    },
                  ),
                  const SizedBox(width: 10),
                  _qualityNavButton(
                    context,
                    icon: Icons.thermostat,
                    label: 'Temperature',
                    isActive: quality.toLowerCase().contains('temperature'),
                    onTap: () {
                      if (!quality.toLowerCase().contains('temperature')) {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (_) => QualityDetailPage(room: room, quality: 'Temperature'),
                          ),
                        );
                      }
                    },
                  ),
                ],
              ),
            ),

            // --- Quality-specific section widget ---
            if (quality.toLowerCase().contains('water'))
              const WaterSection()
            else if (quality.toLowerCase().contains('temperature'))
              const TemperatureSection(),

            // Devices section below
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 20),

                  // Devices header
                  const Text(
                    'Device',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),

                  const SizedBox(height: 8),

                  Column(
                    children: _deviceWidgets,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _qualityNavButton(
    BuildContext context, {
    required IconData icon,
    required String label,
    required bool isActive,
    required VoidCallback onTap,
  }) {
    const Color green = Color(0xFF1EAA83);
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isActive ? green : Colors.grey.shade100,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isActive ? green : Colors.grey.shade300,
              width: 1.5,
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 24, color: isActive ? Colors.white : Colors.grey.shade600),
              const SizedBox(height: 4),
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: isActive ? Colors.white : Colors.grey.shade700,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
