import 'package:flutter/material.dart';
import '../helpers/nav_helper.dart';
import '../models/settings.dart';
import '../helpers/quality_helpers.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  String _energyUnit = 'kWh (Kilowatt-hour)';
  String _waterUnit = 'Litres (L)';
  String _temperatureUnit = '°C (Celsius)';

  static const List<String> _energyOptions = [
    'kWh (Kilowatt-hour)',
    'Wh (Watt-hour)',
  ];
  static const List<String> _waterOptions = ['Litres (L)', 'Millilitres (mL)'];
  static const List<String> _temperatureOptions = [
    '°C (Celsius)',
    '°F (Fahrenheit)',
  ];

  String _electricityTarget = '300 kWh (Average Household)';
  String _waterUsageTarget = '4500 L (Average)';

  final TextEditingController _electricityCustomController =
      TextEditingController();
  final TextEditingController _waterCustomController = TextEditingController();

  bool _electricityAlert = false;
  bool _waterAlert = false;
  bool _temperatureAlert = false;

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

  @override
  Widget build(BuildContext context) {
    const Color green = Color(0xFF1EAA83);
    final s = Settings.instance;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      body: Column(
        children: [
          // Green app bar
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
                  _sectionCard(
                    context,
                    icon: Icons.display_settings,
                    title: 'Display',
                    children: [
                      _unitRow(
                        Icons.bolt,
                        'Energy Unit',
                        _energyUnit,
                        _energyOptions
                            .map(
                              (e) => DropdownMenuItem(value: e, child: Text(e)),
                            )
                            .toList(),
                        (v) {
                          setState(() => _energyUnit = v);
                          Settings.instance.setEnergyUnit(v);
                        },
                      ),
                      _unitRow(
                        Icons.water,
                        'Water Unit',
                        _waterUnit,
                        _waterOptions
                            .map(
                              (e) => DropdownMenuItem(value: e, child: Text(e)),
                            )
                            .toList(),
                        (v) {
                          setState(() => _waterUnit = v);
                          Settings.instance.setWaterUnit(v);
                        },
                      ),
                      _unitRow(
                        Icons.thermostat,
                        'Temperature Unit',
                        _temperatureUnit,
                        _temperatureOptions
                            .map(
                              (e) => DropdownMenuItem(value: e, child: Text(e)),
                            )
                            .toList(),
                        (v) {
                          setState(() => _temperatureUnit = v);
                          Settings.instance.setTemperatureUnit(v);
                        },
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  // ── Notifications section ──
                  _sectionCard(
                    context,
                    icon: Icons.notifications,
                    title: 'Notifications',
                    children: [
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

                  const SizedBox(height: 16),

                  // ── Targets section ──
                  _sectionCard(
                    context,
                    icon: Icons.track_changes,
                    title: 'Monthly Targets',
                    children: [
                      // — Electricity monthly target —
                      _targetSection(
                        icon: Icons.bolt,
                        iconColor: const Color(0xFFF5A623),
                        label: 'Electricity',
                        monthlyValue:
                            '${formatElectricity(s.electricityMonthlyTarget)} ${electricityUnitLabel()}',
                        dailyValue:
                            '${formatElectricity(s.electricityThreshold)} ${electricityUnitLabel()}',
                        daysInMonth: s.daysInCurrentMonth,
                        selectedPreset: _electricityTarget,
                        presets: const [
                          '150 kWh (Low Usage)',
                          '300 kWh (Average Household)',
                          '500 kWh (High Usage)',
                          'Custom',
                        ],
                        onPresetChanged: (v) {
                          setState(() => _electricityTarget = v);
                          if (v != 'Custom') {
                            s.setElectricityMonthlyTarget(v);
                          }
                        },
                        isCustom: _electricityTarget == 'Custom',
                        customController: _electricityCustomController,
                        customHint: 'Enter monthly kWh',
                        onCustomApply: () {
                          final v = double.tryParse(
                            _electricityCustomController.text.trim(),
                          );
                          if (v != null) {
                            setState(() {
                              s.setElectricityMonthlyTarget(
                                'Custom',
                                customValue: v,
                              );
                            });
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Electricity target updated'),
                              ),
                            );
                          }
                        },
                      ),
                      Divider(color: Colors.grey.shade200, height: 1),
                      // — Water monthly target —
                      _targetSection(
                        icon: Icons.water_drop,
                        iconColor: const Color(0xFF42A5F5),
                        label: 'Water',
                        monthlyValue:
                            '${formatWater(s.waterMonthlyTarget)} ${waterUnitLabel()}',
                        dailyValue:
                            '${formatWater(s.waterThreshold)} ${waterUnitLabel()}',
                        daysInMonth: s.daysInCurrentMonth,
                        selectedPreset: _waterUsageTarget,
                        presets: const [
                          '3000 L (Low Usage)',
                          '4500 L (Average)',
                          '6000 L (High Usage)',
                          'Custom',
                        ],
                        onPresetChanged: (v) {
                          setState(() => _waterUsageTarget = v);
                          if (v != 'Custom') {
                            s.setWaterMonthlyTarget(v);
                          }
                        },
                        isCustom: _waterUsageTarget == 'Custom',
                        customController: _waterCustomController,
                        customHint: 'Enter monthly litres',
                        onCustomApply: () {
                          final v = double.tryParse(
                            _waterCustomController.text.trim(),
                          );
                          if (v != null) {
                            setState(() {
                              s.setWaterMonthlyTarget('Custom', customValue: v);
                            });
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Water target updated'),
                              ),
                            );
                          }
                        },
                      ),
                    ],
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

  // ── Section card wrapper ──
  Widget _sectionCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required List<Widget> children,
  }) {
    const Color green = Color(0xFF1EAA83);
    const Color dark = Color(0xFF2D3142);
    return Padding(
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
          data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
          child: ExpansionTile(
            tilePadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 4,
            ),
            leading: Icon(icon, color: green),
            title: Text(
              title,
              style: const TextStyle(fontWeight: FontWeight.w600, color: dark),
            ),
            children: [
              Divider(color: Colors.grey.shade200, height: 1),
              ...children,
            ],
          ),
        ),
      ),
    );
  }

  // ── Target section with monthly + daily display ──
  Widget _targetSection({
    required IconData icon,
    required Color iconColor,
    required String label,
    required String monthlyValue,
    required String dailyValue,
    required int daysInMonth,
    required String selectedPreset,
    required List<String> presets,
    required ValueChanged<String> onPresetChanged,
    required bool isCustom,
    required TextEditingController customController,
    required String customHint,
    required VoidCallback onCustomApply,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header row
          Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: iconColor.withOpacity(0.12),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: iconColor, size: 20),
              ),
              const SizedBox(width: 12),
              Text(
                '$label Monthly Target',
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF2D3142),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Monthly + Daily target display cards
          Row(
            children: [
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    color: iconColor.withOpacity(0.06),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: iconColor.withOpacity(0.2),
                      width: 1,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.calendar_month,
                            size: 14,
                            color: iconColor,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'Monthly',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w500,
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        monthlyValue,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: iconColor,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 10),
              // Arrow
              Icon(Icons.arrow_forward, size: 16, color: Colors.grey.shade400),
              const SizedBox(width: 10),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1EAA83).withOpacity(0.06),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: const Color(0xFF1EAA83).withOpacity(0.2),
                      width: 1,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(
                            Icons.today,
                            size: 14,
                            color: Color(0xFF1EAA83),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'Daily (÷$daysInMonth)',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w500,
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        dailyValue,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1EAA83),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Preset dropdown
          DropdownButton<String>(
            isExpanded: true,
            value: selectedPreset,
            items: presets
                .map((p) => DropdownMenuItem(value: p, child: Text(p)))
                .toList(),
            onChanged: (v) {
              if (v == null) return;
              onPresetChanged(v);
            },
          ),

          // Custom input
          if (isCustom) ...[
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: customController,
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    decoration: InputDecoration(
                      hintText: customHint,
                      border: const OutlineInputBorder(),
                      isDense: true,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: onCustomApply,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1EAA83),
                  ),
                  child: const Text(
                    'Apply',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

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
