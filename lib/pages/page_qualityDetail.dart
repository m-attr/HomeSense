import 'package:flutter/material.dart';
import '../widgets/widget_fixedChart.dart';
import '../widgets/widget_qualityDeviceCard.dart';

class QualityDetailPage extends StatelessWidget {
  final String room;
  final String quality;

  const QualityDetailPage({super.key, required this.room, required this.quality});

  @override
  Widget build(BuildContext context) {
    const Color green = Color(0xFF1EAA83);
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Top row: back icon aligned left (returns to home)
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back),
                      color: green,
                      onPressed: () => Navigator.pushReplacementNamed(context, '/dashboard'),
                    ),
                    Text('Back', style: TextStyle(color: Colors.white, fontSize: 16)),
                  ],
                ),

                // Centered header showing the selected room
                const SizedBox(height: 6),
                Center(
                  child: Text(
                    room,
                    style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(height: 16),

                // Real-time / historical chart for the selected quality
                SizedBox(
                  height: 260,
                  child: const RealTimeChart(),
                ),

                const SizedBox(height: 20),

                // Devices header
                const Text(
                  'Device',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),

                const SizedBox(height: 8),

                // Devices list: one device per row
                Column(
                  children: List.generate(3, (i) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12.0),
                      child: QualityDeviceCard(
                        leftIcon: Icons.device_hub,
                        rightIcon: Icons.settings,
                        deviceName: '$quality device ${i + 1}',
                        deviceCountText: '${(i % 3) + 1} devices',
                        valueText: (20 + i).toString(),
                        unitText: 'kW/h',
                        onTap: () {},
                      ),
                    );
                  }),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
