import 'package:flutter/material.dart';
import '../../models/settings.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  // Display dropdown selections
  String _energyUnit = 'kWh (Kilowatt-hour)';
  String _waterUnit = 'Litres (L)';
  String _temperatureUnit = '°C (Celsius)';

  // Comfort targets (selections)
  String _electricityTarget = '10 kWh (Average Household)';
  String _waterUsageTarget = '150 L (Average)';

  // Custom target inputs
  final TextEditingController _electricityCustomController = TextEditingController();
  final TextEditingController _waterCustomController = TextEditingController();

  // Notification toggles
  bool _electricityAlert = false;
  bool _waterAlert = false;
  bool _temperatureAlert = false;

  @override
  Widget build(BuildContext context) {
    const Color green = Color(0xFF1EAA83);
    return Scaffold(
      backgroundColor: green,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Back control
                Row(
                  children: [
                    GestureDetector(
                      onTap: () => Navigator.pushReplacementNamed(context, '/dashboard'),
                      child: Row(
                        children: const [
                          Icon(Icons.arrow_back, color: Colors.white),
                          SizedBox(width: 6),
                          Text('Back', style: TextStyle(color: Colors.white, fontSize: 16)),
                        ],
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 18),

                const Text(
                  'Settings',
                  style: TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold),
                ),

                const SizedBox(height: 24),

                Card(
                  elevation: 0,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  child: Theme(
                    data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
                    child: ExpansionTile(
                      tilePadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      leading: const Icon(Icons.display_settings, color: green),
                      title: const Text('Display', style: TextStyle(fontWeight: FontWeight.w600)),
                      children: [
                        // Energy 
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Padding(
                                padding: EdgeInsets.only(top: 6.0, right: 12.0),
                                child: Icon(Icons.bolt, color: Colors.black54),
                              ),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text('Energy Unit'),
                                    const SizedBox(height: 6),
                                    DropdownButton<String>(
                                      isExpanded: true,
                                      value: _energyUnit,
                                      items: const [
                                        DropdownMenuItem(value: 'kWh (Kilowatt-hour)', child: Text('kWh (Kilowatt-hour)')),
                                        DropdownMenuItem(value: 'Wh (Watt-hour)', child: Text('Wh (Watt-hour)')),
                                      ],
                                      onChanged: (v) {
                                        if (v == null) return;
                                        setState(() => _energyUnit = v);
                                        Settings.instance.setEnergyUnit(v);
                                      },
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),

                        // Water 
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Padding(
                                padding: EdgeInsets.only(top: 6.0, right: 12.0),
                                child: Icon(Icons.water, color: Colors.black54),
                              ),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text('Water Unit'),
                                    const SizedBox(height: 6),
                                    DropdownButton<String>(
                                      isExpanded: true,
                                      value: _waterUnit,
                                      items: const [
                                        DropdownMenuItem(value: 'Litres (L)', child: Text('Litres (L)')),
                                        DropdownMenuItem(value: 'Cubic Metres (m³)', child: Text('Cubic Metres (m³)')),
                                      ],
                                      onChanged: (v) {
                                        if (v == null) return;
                                        setState(() => _waterUnit = v);
                                        Settings.instance.setWaterUnit(v);
                                      },
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),

                        // Temperature 
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Padding(
                                padding: EdgeInsets.only(top: 6.0, right: 12.0),
                                child: Icon(Icons.thermostat, color: Colors.black54),
                              ),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text('Temperature Unit'),
                                    const SizedBox(height: 6),
                                    DropdownButton<String>(
                                      isExpanded: true,
                                      value: _temperatureUnit,
                                      items: const [
                                        DropdownMenuItem(value: '°C (Celsius)', child: Text('°C (Celsius)')),
                                        DropdownMenuItem(value: '°F (Fahrenheit)', child: Text('°F (Fahrenheit)')),
                                      ],
                                      onChanged: (v) {
                                        if (v == null) return;
                                        setState(() => _temperatureUnit = v);
                                        Settings.instance.setTemperatureUnit(v);
                                      },
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 12),

                // Notifications 
                Card(
                  elevation: 0,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  child: Theme(
                    data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
                    child: ExpansionTile(
                      tilePadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      leading: const Icon(Icons.notifications, color: green),
                      title: const Text('Notifications', style: TextStyle(fontWeight: FontWeight.w600)),
                      children: [
                        // Electricity Usage Alert
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 6.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  const Expanded(child: Text('Electricity Usage Alert')),
                                  Switch(value: _electricityAlert, onChanged: (v) => setState(() => _electricityAlert = v)),
                                ],
                              ),
                              const SizedBox(height: 6),
                              Text('• Notify me when electricity usage exceeds my daily limit.', style: TextStyle(color: Colors.grey.shade600, fontSize: 12)),
                            ],
                          ),
                        ),

                        const Divider(height: 1),

                        // Water Usage Alert
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 6.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  const Expanded(child: Text('Water Usage Alert')),
                                  Switch(value: _waterAlert, onChanged: (v) => setState(() => _waterAlert = v)),
                                ],
                              ),
                              const SizedBox(height: 6),
                              Text('• Notify me when water usage exceeds my daily goal.', style: TextStyle(color: Colors.grey.shade600, fontSize: 12)),
                            ],
                          ),
                        ),

                        const Divider(height: 1),

                        // Temperature Comfort Alert
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 6.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  const Expanded(child: Text('Temperature Comfort Alert')),
                                  Switch(value: _temperatureAlert, onChanged: (v) => setState(() => _temperatureAlert = v)),
                                ],
                              ),
                              const SizedBox(height: 6),
                              Text('• Notify me when temperature goes outside preferred range.', style: TextStyle(color: Colors.grey.shade600, fontSize: 12)),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 12),

                // Comfort 
                Card(
                  elevation: 0,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  child: Theme(
                    data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
                    child: ExpansionTile(
                      tilePadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      leading: const Icon(Icons.favorite, color: green),
                      title: const Text('Comfort', style: TextStyle(fontWeight: FontWeight.w600)),
                      children: [
                        // Electricity target
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Padding(
                                padding: EdgeInsets.only(top: 6.0, right: 12.0),
                                child: Icon(Icons.bolt, color: Colors.black54),
                              ),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text('Electricity target'),
                                    const SizedBox(height: 6),
                                    DropdownButton<String>(
                                      isExpanded: true,
                                      value: _electricityTarget,
                                      items: const [
                                        DropdownMenuItem(value: '5 kWh (Low Usage)', child: Text('5 kWh (Low Usage)')),
                                        DropdownMenuItem(value: '10 kWh (Average Household)', child: Text('10 kWh (Average Household)')),
                                        DropdownMenuItem(value: '15 kWh (High Usage)', child: Text('15 kWh (High Usage)')),
                                        DropdownMenuItem(value: 'Custom', child: Text('Custom')),
                                      ],
                                      onChanged: (v) {
                                        if (v == null) return;
                                        setState(() => _electricityTarget = v);

                                        if (v != 'Custom') {
                                          Settings.instance.setElectricityThresholdFromLabel(v);
                                        }
                                      },
                                    ),
                                    if (_electricityTarget == 'Custom') ...[
                                      const SizedBox(height: 8),
                                      Row(
                                        children: [
                                          Expanded(
                                            child: TextField(
                                              controller: _electricityCustomController,
                                              keyboardType: TextInputType.numberWithOptions(decimal: true),
                                              decoration: const InputDecoration(
                                                hintText: 'Enter custom kWh value',
                                                border: OutlineInputBorder(),
                                                isDense: true,
                                              ),
                                            ),
                                          ),
                                          const SizedBox(width: 8),
                                          ElevatedButton(
                                            onPressed: () {
                                              final v = double.tryParse(_electricityCustomController.text.trim());
                                              if (v != null) {
                                                Settings.instance.setElectricityThresholdFromLabel('Custom', customValue: v);
                                                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Electricity target updated')));
                                              }
                                            },
                                            child: const Text('Apply'),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),

                        // Water usage target
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Padding(
                                padding: EdgeInsets.only(top: 6.0, right: 12.0),
                                child: Icon(Icons.water, color: Colors.black54),
                              ),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text('Water usage target'),
                                    const SizedBox(height: 6),
                                    DropdownButton<String>(
                                      isExpanded: true,
                                      value: _waterUsageTarget,
                                      items: const [
                                        DropdownMenuItem(value: '100 L (Low Usage)', child: Text('100 L (Low Usage)')),
                                        DropdownMenuItem(value: '150 L (Average)', child: Text('150 L (Average)')),
                                        DropdownMenuItem(value: '200 L (High Usage)', child: Text('200 L (High Usage)')),
                                        DropdownMenuItem(value: 'Custom', child: Text('Custom')),
                                      ],
                                      onChanged: (v) {
                                        if (v == null) return;
                                        setState(() => _waterUsageTarget = v);
                                        if (v != 'Custom') {
                                          Settings.instance.setWaterThresholdFromLabel(v);
                                        }
                                      },
                                    ),
                                    if (_waterUsageTarget == 'Custom') ...[
                                      const SizedBox(height: 8),
                                      Row(
                                        children: [
                                          Expanded(
                                            child: TextField(
                                              controller: _waterCustomController,
                                              keyboardType: TextInputType.numberWithOptions(decimal: true),
                                              decoration: const InputDecoration(
                                                hintText: 'Enter custom litres value',
                                                border: OutlineInputBorder(),
                                                isDense: true,
                                              ),
                                            ),
                                          ),
                                          const SizedBox(width: 8),
                                          ElevatedButton(
                                            onPressed: () {
                                              final v = double.tryParse(_waterCustomController.text.trim());
                                              if (v != null) {
                                                Settings.instance.setWaterThresholdFromLabel('Custom', customValue: v);
                                                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Water target updated')));
                                              }
                                            },
                                            child: const Text('Apply'),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ],
                                ),
                              ),
                            ],
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
    );
  }

  @override
  void dispose() {
    _electricityCustomController.dispose();
    _waterCustomController.dispose();
    super.dispose();
  }
}
