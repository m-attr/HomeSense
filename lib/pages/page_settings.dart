import 'package:flutter/material.dart';
import '../helpers/nav_helper.dart';
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

  static const List<String> _energyOptions = [
    'kWh (Kilowatt-hour)',
    'Wh (Watt-hour)',
  ];
  static const List<String> _waterOptions = ['Litres (L)', 'Cubic Metres (m³)'];
  static const List<String> _temperatureOptions = [
    '°C (Celsius)',
    '°F (Fahrenheit)',
  ];

  @override
  void initState() {
    super.initState();
    final s = Settings.instance;
    _energyUnit = _energyOptions.contains(s.energyUnit)
        ? s.energyUnit
        : _energyOptions[0];
    _waterUnit = _waterOptions.contains(s.waterUnit)
        ? s.waterUnit
        : _waterOptions[0];
    _temperatureUnit = _temperatureOptions.contains(s.temperatureUnit)
        ? s.temperatureUnit
        : _temperatureOptions[0];
  }

  // Comfort targets (selections)
  String _electricityTarget = '10 kWh (Average Household)';
  String _waterUsageTarget = '150 L (Average)';

  // Custom target inputs
  final TextEditingController _electricityCustomController =
      TextEditingController();
  final TextEditingController _waterCustomController = TextEditingController();

  // Notification toggles
  bool _electricityAlert = false;
  bool _waterAlert = false;
  bool _temperatureAlert = false;

  @override
  Widget build(BuildContext context) {
    const Color green = Color(0xFF1EAA83);
    const Color dark = Color(0xFF2D3142);
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      body: Column(
        children: [
          // Green app bar with rounded bottom corners
          ClipRRect(
            borderRadius: const BorderRadius.only(
              bottomLeft: Radius.circular(18),
              bottomRight: Radius.circular(18),
            ),
            child: Container(
              width: double.infinity,
              color: green,
              padding: EdgeInsets.only(
                top: MediaQuery.of(context).padding.top,
                left: 4,
                right: 8,
                bottom: 12,
              ),
              child: SizedBox(
                height: 56,
                child: Stack(
                  children: [
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(
                              Icons.arrow_back,
                              color: Colors.white,
                            ),
                            onPressed: () => navigateNamedWithLoading(
                              context,
                              routeName: '/dashboard',
                              replace: true,
                            ),
                          ),
                          const Padding(
                            padding: EdgeInsets.only(left: 6.0),
                            child: Text(
                              'Back',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Center(
                      child: Text(
                        'Settings',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 16),

                  // ── Display section ──
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: const [
                          BoxShadow(
                            color: Colors.black12,
                            blurRadius: 6,
                            offset: Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Theme(
                        data: Theme.of(
                          context,
                        ).copyWith(dividerColor: Colors.transparent),
                        child: ExpansionTile(
                          tilePadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 4,
                          ),
                          leading: const Icon(
                            Icons.display_settings,
                            color: green,
                          ),
                          title: const Text(
                            'Display',
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              color: dark,
                            ),
                          ),
                          children: [
                            Divider(color: Colors.grey.shade200, height: 1),
                            // Energy
                            _unitRow(
                              Icons.bolt,
                              'Energy Unit',
                              _energyUnit,
                              const [
                                DropdownMenuItem(
                                  value: 'kWh (Kilowatt-hour)',
                                  child: Text('kWh (Kilowatt-hour)'),
                                ),
                                DropdownMenuItem(
                                  value: 'Wh (Watt-hour)',
                                  child: Text('Wh (Watt-hour)'),
                                ),
                              ],
                              (v) {
                                setState(() => _energyUnit = v);
                                Settings.instance.setEnergyUnit(v);
                              },
                            ),
                            // Water
                            _unitRow(
                              Icons.water,
                              'Water Unit',
                              _waterUnit,
                              const [
                                DropdownMenuItem(
                                  value: 'Litres (L)',
                                  child: Text('Litres (L)'),
                                ),
                                DropdownMenuItem(
                                  value: 'Cubic Metres (m³)',
                                  child: Text('Cubic Metres (m³)'),
                                ),
                              ],
                              (v) {
                                setState(() => _waterUnit = v);
                                Settings.instance.setWaterUnit(v);
                              },
                            ),
                            // Temperature
                            _unitRow(
                              Icons.thermostat,
                              'Temperature Unit',
                              _temperatureUnit,
                              const [
                                DropdownMenuItem(
                                  value: '°C (Celsius)',
                                  child: Text('°C (Celsius)'),
                                ),
                                DropdownMenuItem(
                                  value: '°F (Fahrenheit)',
                                  child: Text('°F (Fahrenheit)'),
                                ),
                              ],
                              (v) {
                                setState(() => _temperatureUnit = v);
                                Settings.instance.setTemperatureUnit(v);
                              },
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // ── Notifications section ──
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: const [
                          BoxShadow(
                            color: Colors.black12,
                            blurRadius: 6,
                            offset: Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Theme(
                        data: Theme.of(
                          context,
                        ).copyWith(dividerColor: Colors.transparent),
                        child: ExpansionTile(
                          tilePadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 4,
                          ),
                          leading: const Icon(
                            Icons.notifications,
                            color: green,
                          ),
                          title: const Text(
                            'Notifications',
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              color: dark,
                            ),
                          ),
                          children: [
                            Divider(color: Colors.grey.shade200, height: 1),
                            _alertRow(
                              'Electricity Usage Alert',
                              '• Notify me when electricity usage exceeds my daily limit.',
                              _electricityAlert,
                              (v) => setState(() => _electricityAlert = v),
                            ),
                            const Divider(height: 1),
                            _alertRow(
                              'Water Usage Alert',
                              '• Notify me when water usage exceeds my daily goal.',
                              _waterAlert,
                              (v) => setState(() => _waterAlert = v),
                            ),
                            const Divider(height: 1),
                            _alertRow(
                              'Temperature Comfort Alert',
                              '• Notify me when temperature goes outside preferred range.',
                              _temperatureAlert,
                              (v) => setState(() => _temperatureAlert = v),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // ── Comfort section ──
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: const [
                          BoxShadow(
                            color: Colors.black12,
                            blurRadius: 6,
                            offset: Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Theme(
                        data: Theme.of(
                          context,
                        ).copyWith(dividerColor: Colors.transparent),
                        child: ExpansionTile(
                          tilePadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 4,
                          ),
                          leading: const Icon(Icons.favorite, color: green),
                          title: const Text(
                            'Comfort',
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              color: dark,
                            ),
                          ),
                          children: [
                            Divider(color: Colors.grey.shade200, height: 1),
                            // Electricity target
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12.0,
                                vertical: 8.0,
                              ),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Padding(
                                    padding: EdgeInsets.only(
                                      top: 6.0,
                                      right: 12.0,
                                    ),
                                    child: Icon(
                                      Icons.bolt,
                                      color: Colors.black54,
                                    ),
                                  ),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        const Text('Electricity target'),
                                        const SizedBox(height: 6),
                                        DropdownButton<String>(
                                          isExpanded: true,
                                          value: _electricityTarget,
                                          items: const [
                                            DropdownMenuItem(
                                              value: '5 kWh (Low Usage)',
                                              child: Text('5 kWh (Low Usage)'),
                                            ),
                                            DropdownMenuItem(
                                              value:
                                                  '10 kWh (Average Household)',
                                              child: Text(
                                                '10 kWh (Average Household)',
                                              ),
                                            ),
                                            DropdownMenuItem(
                                              value: '15 kWh (High Usage)',
                                              child: Text(
                                                '15 kWh (High Usage)',
                                              ),
                                            ),
                                            DropdownMenuItem(
                                              value: 'Custom',
                                              child: Text('Custom'),
                                            ),
                                          ],
                                          onChanged: (v) {
                                            if (v == null) return;
                                            setState(
                                              () => _electricityTarget = v,
                                            );
                                            if (v != 'Custom') {
                                              Settings.instance
                                                  .setElectricityThresholdFromLabel(
                                                    v,
                                                  );
                                            }
                                          },
                                        ),
                                        if (_electricityTarget == 'Custom') ...[
                                          const SizedBox(height: 8),
                                          Row(
                                            children: [
                                              Expanded(
                                                child: TextField(
                                                  controller:
                                                      _electricityCustomController,
                                                  keyboardType:
                                                      TextInputType.numberWithOptions(
                                                        decimal: true,
                                                      ),
                                                  decoration: const InputDecoration(
                                                    hintText:
                                                        'Enter custom kWh value',
                                                    border:
                                                        OutlineInputBorder(),
                                                    isDense: true,
                                                  ),
                                                ),
                                              ),
                                              const SizedBox(width: 8),
                                              ElevatedButton(
                                                onPressed: () {
                                                  final v = double.tryParse(
                                                    _electricityCustomController
                                                        .text
                                                        .trim(),
                                                  );
                                                  if (v != null) {
                                                    Settings.instance
                                                        .setElectricityThresholdFromLabel(
                                                          'Custom',
                                                          customValue: v,
                                                        );
                                                    ScaffoldMessenger.of(
                                                      context,
                                                    ).showSnackBar(
                                                      const SnackBar(
                                                        content: Text(
                                                          'Electricity target updated',
                                                        ),
                                                      ),
                                                    );
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
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12.0,
                                vertical: 8.0,
                              ),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Padding(
                                    padding: EdgeInsets.only(
                                      top: 6.0,
                                      right: 12.0,
                                    ),
                                    child: Icon(
                                      Icons.water,
                                      color: Colors.black54,
                                    ),
                                  ),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        const Text('Water usage target'),
                                        const SizedBox(height: 6),
                                        DropdownButton<String>(
                                          isExpanded: true,
                                          value: _waterUsageTarget,
                                          items: const [
                                            DropdownMenuItem(
                                              value: '100 L (Low Usage)',
                                              child: Text('100 L (Low Usage)'),
                                            ),
                                            DropdownMenuItem(
                                              value: '150 L (Average)',
                                              child: Text('150 L (Average)'),
                                            ),
                                            DropdownMenuItem(
                                              value: '200 L (High Usage)',
                                              child: Text('200 L (High Usage)'),
                                            ),
                                            DropdownMenuItem(
                                              value: 'Custom',
                                              child: Text('Custom'),
                                            ),
                                          ],
                                          onChanged: (v) {
                                            if (v == null) return;
                                            setState(
                                              () => _waterUsageTarget = v,
                                            );
                                            if (v != 'Custom') {
                                              Settings.instance
                                                  .setWaterThresholdFromLabel(
                                                    v,
                                                  );
                                            }
                                          },
                                        ),
                                        if (_waterUsageTarget == 'Custom') ...[
                                          const SizedBox(height: 8),
                                          Row(
                                            children: [
                                              Expanded(
                                                child: TextField(
                                                  controller:
                                                      _waterCustomController,
                                                  keyboardType:
                                                      TextInputType.numberWithOptions(
                                                        decimal: true,
                                                      ),
                                                  decoration: const InputDecoration(
                                                    hintText:
                                                        'Enter custom litres value',
                                                    border:
                                                        OutlineInputBorder(),
                                                    isDense: true,
                                                  ),
                                                ),
                                              ),
                                              const SizedBox(width: 8),
                                              ElevatedButton(
                                                onPressed: () {
                                                  final v = double.tryParse(
                                                    _waterCustomController.text
                                                        .trim(),
                                                  );
                                                  if (v != null) {
                                                    Settings.instance
                                                        .setWaterThresholdFromLabel(
                                                          'Custom',
                                                          customValue: v,
                                                        );
                                                    ScaffoldMessenger.of(
                                                      context,
                                                    ).showSnackBar(
                                                      const SnackBar(
                                                        content: Text(
                                                          'Water target updated',
                                                        ),
                                                      ),
                                                    );
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
                  ),

                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Helper: unit dropdown row for Display section
  Widget _unitRow(
    IconData icon,
    String label,
    String value,
    List<DropdownMenuItem<String>> items,
    ValueChanged<String> onChanged,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 6.0, right: 12.0),
            child: Icon(icon, color: Colors.black54),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label),
                const SizedBox(height: 6),
                DropdownButton<String>(
                  isExpanded: true,
                  value: value,
                  items: items,
                  onChanged: (v) {
                    if (v == null) return;
                    onChanged(v);
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Helper: alert toggle row for Notifications section
  Widget _alertRow(
    String title,
    String subtitle,
    bool value,
    ValueChanged<bool> onChanged,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 6.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(child: Text(title)),
              Switch(value: value, onChanged: onChanged),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            subtitle,
            style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
          ),
        ],
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
