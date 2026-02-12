import 'package:flutter/material.dart';
import '../widgets/widget_realTimeChart.dart';

class QualityDetailPage extends StatelessWidget {
  final String room;
  final String quality;

  const QualityDetailPage({super.key, required this.room, required this.quality});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('$quality — Details'),
        backgroundColor: const Color(0xFF1EAA83),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Centered header showing the selected room
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

                // Placeholder list of devices — real data can be wired later
                Card(
                  child: ListTile(
                    leading: const Icon(Icons.device_hub),
                    title: Text('$quality sensor 1'),
                    subtitle: const Text('Online'),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () {},
                  ),
                ),
                const SizedBox(height: 8),
                Card(
                  child: ListTile(
                    leading: const Icon(Icons.device_hub),
                    title: Text('$quality sensor 2'),
                    subtitle: const Text('Offline'),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () {},
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
