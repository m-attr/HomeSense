import 'package:flutter/material.dart';
import '../widgets/widget_fixedChart.dart';
import '../widgets/widget_qualityDeviceCard.dart';
import '../models/settings.dart';

class QualityDetailPage extends StatelessWidget {
  final String room;
  final String quality;

  const QualityDetailPage({super.key, required this.room, required this.quality});

  @override
  Widget build(BuildContext context) {
    const Color green = Color(0xFF1EAA83);
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              width: double.infinity,
              color: green,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  SizedBox(height: MediaQuery.of(context).padding.top + 14),
                  Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.arrow_back),
                        color: Colors.white,
                        onPressed: () => Navigator.pushReplacementNamed(context, '/dashboard'),
                      ),
                      const SizedBox(width: 6),
                      const Text('Back', style: TextStyle(color: Colors.white, fontSize: 16)),
                    ],
                  ),

                  const SizedBox(height: 6),
                  Center(
                    child: Text(
                      room,
                      style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // chart for the selected quality
                  SizedBox(
                    height: 260,
                    child: RealTimeChart(label: quality),
                  ),
                ],
              ),
            ),

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
                    children: List.generate(3, (i) {
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
                    }),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
