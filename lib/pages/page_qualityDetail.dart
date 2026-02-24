import 'package:flutter/material.dart';
import '../helpers/nav_helper.dart';
import '../widgets/widget_fixedChart.dart';
import '../widgets/widget_qualityDeviceCard.dart';
import '../widgets/widget_tempArcSlider.dart';
import '../models/settings.dart';
import '../widgets/qualities/widget_temperatureSection.dart';
import '../widgets/qualities/widget_waterSection.dart';

class QualityDetailPage extends StatefulWidget {
  final String room;
  final String quality;
  final bool hasDevices;
  final List<String> availableQualities;

  const QualityDetailPage({
    super.key,
    required this.room,
    required this.quality,
    this.hasDevices = true,
    this.availableQualities = const ['Electricity', 'Water', 'Temperature'],
  });

  @override
  State<QualityDetailPage> createState() => _QualityDetailPageState();
}

class _QualityDetailPageState extends State<QualityDetailPage> {
  late String _activeQuality;

  /// Track direction: 1 = slide in from right, -1 = slide in from left
  int _slideDirection = 1;

  @override
  void initState() {
    super.initState();
    _activeQuality = widget.quality;
  }

  void _switchQuality(String next) {
    if (next == _activeQuality) return;
    final qualities = widget.availableQualities;
    final oldIdx = qualities.indexWhere(
      (q) => _activeQuality.toLowerCase().contains(q.toLowerCase()),
    );
    final newIdx = qualities.indexWhere(
      (q) => next.toLowerCase().contains(q.toLowerCase()),
    );
    setState(() {
      _slideDirection = newIdx > oldIdx ? 1 : -1;
      _activeQuality = next;
    });
  }

  bool _isActive(String q) =>
      _activeQuality.toLowerCase().contains(q.toLowerCase());

  IconData _iconForQuality(String q) {
    switch (q.toLowerCase()) {
      case 'electricity':
        return Icons.bolt;
      case 'water':
        return Icons.water_drop;
      case 'temperature':
        return Icons.thermostat;
      default:
        return Icons.device_hub;
    }
  }

  Color _colorForQuality(String quality) {
    switch (quality.toLowerCase()) {
      case 'electricity':
        return const Color(0xFFF5A623);
      case 'water':
        return const Color(0xFF42A5F5);
      case 'temperature':
        return const Color(0xFFEF6C57);
      default:
        return const Color(0xFF1EAA83);
    }
  }

  List<Widget> _buildQualityNavButtons() {
    final qualities = widget.availableQualities;
    final List<Widget> buttons = [];
    for (int i = 0; i < qualities.length; i++) {
      if (i > 0) buttons.add(const SizedBox(width: 10));
      final q = qualities[i];
      buttons.add(
        _qualityNavButton(
          icon: _iconForQuality(q),
          label: q,
          isActive: _isActive(q),
          onTap: () => _switchQuality(q),
          qualityColor: _colorForQuality(q),
        ),
      );
    }
    return buttons;
  }

  @override
  Widget build(BuildContext context) {
    const Color green = Color(0xFF1EAA83);
    final String room = widget.room;
    final String quality = _activeQuality;

    // prebuild device cards list
    final bool isTemp = quality.toLowerCase().contains('temperature');
    final List<Widget> deviceWidgets = List<Widget>.generate(3, (i) {
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

      if (isTemp) {
        return _TempDeviceCard(
          deviceName: '$quality device ${i + 1}',
          deviceCountText: '${(i % 3) + 1} devices',
          currentTemp: (20.0 + i),
          unit: unit,
        );
      }

      return QualityDeviceCard(
        leftIcon: leftIcon,
        rightIcon: Icons.settings,
        deviceName: '$quality device ${i + 1}',
        deviceCountText: '${(i % 3) + 1} devices',
        valueText: (20 + i).toString(),
        unitText: unit,
        onTap: () {},
      );
    });

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // App bar: green with rounded bottom corners
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
                              onPressed: () {
                                if (Navigator.canPop(context)) {
                                  popWithLoading(context);
                                } else {
                                  navigateNamedWithLoading(
                                    context,
                                    routeName: '/dashboard',
                                    replace: true,
                                  );
                                }
                              },
                            ),
                            Padding(
                              padding: const EdgeInsets.only(left: 6.0),
                              child: const Text(
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
                      Center(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 64.0),
                          child: Text(
                            room,
                            textAlign: TextAlign.center,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Section 1: Chart area
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Container(
                width: double.infinity,
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
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: SizedBox(
                    height: 260,
                    child: RealTimeChart(label: quality),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Section 2: Quality nav + indicator
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Container(
                width: double.infinity,
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
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      // Quality navigation buttons
                      Row(children: _buildQualityNavButtons()),
                    ],
                  ),
                ),
              ),
            ),

            const SizedBox(height: 16),

            // --- Sliding content area ---
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 350),
              switchInCurve: Curves.easeInOut,
              switchOutCurve: Curves.easeInOut,
              transitionBuilder: (child, animation) {
                final isIncoming = child.key == ValueKey(_activeQuality);
                final begin = isIncoming
                    ? Offset(_slideDirection.toDouble(), 0.0)
                    : Offset(-_slideDirection.toDouble(), 0.0);
                return SlideTransition(
                  position: Tween<Offset>(
                    begin: begin,
                    end: Offset.zero,
                  ).animate(animation),
                  child: child,
                );
              },
              child: _buildContentForQuality(
                key: ValueKey(_activeQuality),
                quality: quality,
                deviceWidgets: deviceWidgets,
              ),
            ),

            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  /// Builds the quality-specific section + device cards, keyed for AnimatedSwitcher.
  Widget _buildContentForQuality({
    required Key key,
    required String quality,
    required List<Widget> deviceWidgets,
  }) {
    return Column(
      key: key,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Quality-specific section widget in styled container
        if (quality.toLowerCase().contains('water') ||
            quality.toLowerCase().contains('temperature'))
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Container(
              width: double.infinity,
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
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 4.0),
                child: quality.toLowerCase().contains('water')
                    ? const WaterSection()
                    : const TemperatureSection(),
              ),
            ),
          ),

        const SizedBox(height: 16),

        // Section 3: Devices
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Container(
            width: double.infinity,
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
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    children: const [
                      Icon(
                        Icons.devices_other,
                        color: Color(0xFF1EAA83),
                        size: 22,
                      ),
                      SizedBox(width: 8),
                      Text(
                        'Devices',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF2D3142),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  if (!widget.hasDevices)
                    Column(
                      children: [
                        const SizedBox(height: 8),
                        Icon(
                          Icons.bluetooth_disabled,
                          size: 44,
                          color: Colors.grey.shade300,
                        ),
                        const SizedBox(height: 10),
                        Text(
                          'No devices connected',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: Colors.grey.shade500,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Add a device to start monitoring.',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade400,
                          ),
                        ),
                        const SizedBox(height: 16),
                        GridView.count(
                          crossAxisCount: 2,
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          mainAxisSpacing: 12,
                          crossAxisSpacing: 12,
                          childAspectRatio: 1.05,
                          children: [_addDeviceCard(context)],
                        ),
                      ],
                    )
                  else
                    GridView.count(
                      crossAxisCount: 2,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      mainAxisSpacing: 12,
                      crossAxisSpacing: 12,
                      childAspectRatio: 1.05,
                      children: [...deviceWidgets, _addDeviceCard(context)],
                    ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  /// "+ Add Device" card matching the dashboard Add Location style.
  Widget _addDeviceCard(BuildContext context) {
    return GestureDetector(
      onTap: () => _showAddDevicePopup(context),
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFFE8F5F0),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: const Color(0xFF1EAA83).withOpacity(0.4),
            width: 1.5,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: const Color(0xFF1EAA83).withOpacity(0.12),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.add_rounded,
                color: Color(0xFF1EAA83),
                size: 28,
              ),
            ),
            const SizedBox(height: 10),
            const Text(
              'Add Device',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Color(0xFF1EAA83),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Bluetooth scanning popup for adding a device.
  void _showAddDevicePopup(BuildContext context) {
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'Add Device',
      barrierColor: Colors.black.withOpacity(0.5),
      transitionDuration: const Duration(milliseconds: 300),
      pageBuilder: (ctx, anim1, anim2) {
        return Center(
          child: Material(
            color: Colors.transparent,
            child: Container(
              width: 320,
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
                  // Close button row
                  Align(
                    alignment: Alignment.topRight,
                    child: GestureDetector(
                      onTap: () => Navigator.pop(ctx),
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
                  const SizedBox(height: 8),
                  // Bluetooth icon with animated pulse ring
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: const Color(0xFF1EAA83).withOpacity(0.08),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.bluetooth_searching,
                      size: 42,
                      color: Color(0xFF1EAA83),
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'Searching for Devices',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF2D3142),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Make sure your device is powered on\nand within Bluetooth range.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.grey.shade600,
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 24),
                  // Scanning indicator
                  SizedBox(
                    width: 200,
                    child: LinearProgressIndicator(
                      backgroundColor: const Color(
                        0xFF1EAA83,
                      ).withOpacity(0.12),
                      valueColor: const AlwaysStoppedAnimation<Color>(
                        Color(0xFF1EAA83),
                      ),
                      minHeight: 4,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Waiting for connectable devices…',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade500,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                  const SizedBox(height: 8),
                ],
              ),
            ),
          ),
        );
      },
      transitionBuilder: (ctx, anim1, anim2, child) {
        return FadeTransition(
          opacity: anim1,
          child: ScaleTransition(
            scale: CurvedAnimation(parent: anim1, curve: Curves.easeOutBack),
            child: child,
          ),
        );
      },
    );
  }

  Widget _qualityNavButton({
    required IconData icon,
    required String label,
    required bool isActive,
    required VoidCallback onTap,
    required Color qualityColor,
  }) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isActive ? qualityColor : Colors.grey.shade100,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isActive ? qualityColor : Colors.grey.shade300,
              width: 1.5,
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                size: 24,
                color: isActive ? Colors.white : qualityColor,
              ),
              const SizedBox(height: 4),
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: isActive ? Colors.white : qualityColor,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Temperature device card with 3-dot vertical menu that opens arc slider popup
// ---------------------------------------------------------------------------
class _TempDeviceCard extends StatefulWidget {
  final String deviceName;
  final String deviceCountText;
  final double currentTemp;
  final String unit;

  const _TempDeviceCard({
    required this.deviceName,
    required this.deviceCountText,
    required this.currentTemp,
    required this.unit,
  });

  @override
  State<_TempDeviceCard> createState() => _TempDeviceCardState();
}

class _TempDeviceCardState extends State<_TempDeviceCard> {
  late double _setTemp;

  @override
  void initState() {
    super.initState();
    _setTemp = widget.currentTemp;
  }

  void _showTempSliderPopup() {
    double tempValue = _setTemp;
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'Dismiss',
      barrierColor: Colors.black54,
      transitionDuration: const Duration(milliseconds: 300),
      pageBuilder: (ctx, anim1, anim2) {
        return Center(
          child: Material(
            color: Colors.transparent,
            child: StatefulBuilder(
              builder: (ctx, setPopupState) {
                return Container(
                  width: 320,
                  padding: const EdgeInsets.fromLTRB(24, 28, 24, 20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        blurRadius: 20,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        widget.deviceName,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF2D3142),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Set Temperature',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey.shade600,
                        ),
                      ),
                      const SizedBox(height: 20),
                      TempArcSlider(
                        initialTemp: tempValue,
                        minTemp: 10.0,
                        maxTemp: 35.0,
                        onChanged: (v) {
                          setPopupState(() => tempValue = v);
                        },
                      ),
                      const SizedBox(height: 20),
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton(
                              onPressed: () => Navigator.pop(ctx),
                              style: OutlinedButton.styleFrom(
                                side: const BorderSide(
                                  color: Color(0xFF1EAA83),
                                ),
                                padding: const EdgeInsets.symmetric(
                                  vertical: 14,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              child: const Text(
                                'Cancel',
                                style: TextStyle(
                                  color: Color(0xFF1EAA83),
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: ElevatedButton(
                              onPressed: () {
                                setState(() => _setTemp = tempValue);
                                Navigator.pop(ctx);
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF1EAA83),
                                padding: const EdgeInsets.symmetric(
                                  vertical: 14,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              child: const Text(
                                'Set',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        );
      },
      transitionBuilder: (ctx, anim1, anim2, child) {
        return FadeTransition(
          opacity: anim1,
          child: ScaleTransition(
            scale: CurvedAnimation(parent: anim1, curve: Curves.easeOutBack),
            child: child,
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    const Color accent = Color(0xFF1EAA83);
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Icon(Icons.thermostat, size: 28, color: accent),
                // 3-dot vertical menu button
                GestureDetector(
                  onTap: _showTempSliderPopup,
                  child: Icon(
                    Icons.more_vert,
                    size: 24,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: Text(
                    widget.deviceName,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const Spacer(),
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Expanded(
                  child: Text(
                    _setTemp.toStringAsFixed(1),
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: accent,
                    ),
                  ),
                ),
                const SizedBox(width: 4),
                Text(
                  widget.unit,
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
