import 'package:flutter/material.dart';
import '../../models/settings.dart';

/// Temperature section widget for QualityDetailPage.
/// Displays a large thermometer with dynamic fill (blue→red)
/// and the current temperature beside it.
class TemperatureSection extends StatefulWidget {
  final double currentTemp; // current reading
  final double minTemp; // scale minimum
  final double maxTemp; // scale maximum

  const TemperatureSection({
    super.key,
    this.currentTemp = 35.0,
    this.minTemp = 0.0,
    this.maxTemp = 39.0,
  });

  @override
  State<TemperatureSection> createState() => _TemperatureSectionState();
}

class _TemperatureSectionState extends State<TemperatureSection>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late Animation<double> _anim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
    _anim = CurvedAnimation(parent: _ctrl, curve: Curves.easeOutCubic);
    _ctrl.addListener(() {
      if (mounted) setState(() {});
    });
    WidgetsBinding.instance.addPostFrameCallback((_) => _ctrl.forward());
  }

  @override
  void didUpdateWidget(covariant TemperatureSection old) {
    super.didUpdateWidget(old);
    if (old.currentTemp != widget.currentTemp) {
      _ctrl
        ..reset()
        ..forward();
    }
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  /// Returns gradient color from blue (cold) → red (hot) based on fraction 0..1
  Color _tempColor(double fraction) {
    if (fraction <= 0.25) {
      return Color.lerp(
        const Color(0xFF2196F3),
        const Color(0xFF00BCD4),
        fraction / 0.25,
      )!;
    } else if (fraction <= 0.5) {
      return Color.lerp(
        const Color(0xFF00BCD4),
        const Color(0xFF1EAA83),
        (fraction - 0.25) / 0.25,
      )!;
    } else if (fraction <= 0.75) {
      return Color.lerp(
        const Color(0xFF1EAA83),
        const Color(0xFFFF9800),
        (fraction - 0.5) / 0.25,
      )!;
    } else {
      return Color.lerp(
        const Color(0xFFFF9800),
        const Color(0xFFF44336),
        (fraction - 0.75) / 0.25,
      )!;
    }
  }

  @override
  Widget build(BuildContext context) {
    final unit = Settings.instance.temperatureUnit.split(' ').first;
    final fraction =
        ((widget.currentTemp - widget.minTemp) /
                (widget.maxTemp - widget.minTemp))
            .clamp(0.0, 1.0);
    final animatedFraction = fraction * _anim.value;
    final fillColor = _tempColor(animatedFraction);

    return Column(
      children: [
        const SizedBox(height: 20),
        // Thermometer + temperature display
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Big thermometer
              SizedBox(
                width: 60,
                height: 200,
                child: CustomPaint(
                  painter: _ThermometerPainter(
                    fraction: animatedFraction,
                    fillColor: fillColor,
                  ),
                ),
              ),
              const SizedBox(width: 28),
              // Temperature value + unit
              Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.currentTemp.toStringAsFixed(1),
                        style: TextStyle(
                          fontSize: 52,
                          fontWeight: FontWeight.bold,
                          color: fillColor,
                          height: 1.0,
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: Text(
                          unit,
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w600,
                            color: fillColor,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        // Comfort indicator container
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: _comfortColor(widget.currentTemp).withOpacity(0.08),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: _comfortColor(widget.currentTemp).withOpacity(0.3),
                width: 1.2,
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    color: _comfortColor(widget.currentTemp).withOpacity(0.15),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    _comfortIcon(widget.currentTemp),
                    color: _comfortColor(widget.currentTemp),
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _comfortLabel(widget.currentTemp),
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: _comfortColor(widget.currentTemp),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      _comfortDescription(widget.currentTemp),
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),
      ],
    );
  }

  Color _comfortColor(double t) {
    if (t < 16) return const Color(0xFF2196F3);
    if (t < 20) return const Color(0xFF00BCD4);
    if (t <= 26) return const Color(0xFF1EAA83);
    if (t <= 30) return const Color(0xFFFF9800);
    return const Color(0xFFF44336);
  }

  IconData _comfortIcon(double t) {
    if (t < 16) return Icons.ac_unit;
    if (t < 20) return Icons.air;
    if (t <= 26) return Icons.check_circle_outline;
    if (t <= 30) return Icons.wb_sunny_outlined;
    return Icons.local_fire_department;
  }

  String _comfortLabel(double t) {
    if (t < 16) return 'Too Cold';
    if (t < 20) return 'Cool';
    if (t <= 26) return 'Comfortable';
    if (t <= 30) return 'Warm';
    return 'Too Hot';
  }

  String _comfortDescription(double t) {
    if (t < 16) return 'Below comfortable range';
    if (t < 20) return 'Slightly cool';
    if (t <= 26) return 'Ideal temperature';
    if (t <= 30) return 'Getting warm';
    return 'Above comfortable range';
  }
}

// ---------------------------------------------------------------------------
// Thermometer painter — vertical bulb thermometer with gradient fill
// ---------------------------------------------------------------------------
class _ThermometerPainter extends CustomPainter {
  final double fraction; // 0..1 fill level
  final Color fillColor;

  _ThermometerPainter({required this.fraction, required this.fillColor});

  @override
  void paint(Canvas canvas, Size size) {
    final double w = size.width;
    final double h = size.height;

    // Dimensions
    final double tubeWidth = w * 0.36;
    final double bulbRadius = w * 0.38;
    final double tubeLeft = (w - tubeWidth) / 2;
    final double tubeRight = tubeLeft + tubeWidth;
    final double bulbCenterY = h - bulbRadius - 2;
    final double tubeTop = 8.0;
    final double tubeBottom = bulbCenterY - bulbRadius * 0.3;
    final double tubeRadius = tubeWidth / 2;

    // Outer shell — grey background
    final shellPaint = Paint()
      ..color = const Color(0xFFE0E0E0)
      ..style = PaintingStyle.fill;

    // Draw tube background
    final tubeBgRect = RRect.fromRectAndRadius(
      Rect.fromLTRB(
        tubeLeft - 3,
        tubeTop,
        tubeRight + 3,
        tubeBottom + tubeRadius,
      ),
      Radius.circular(tubeRadius + 3),
    );
    canvas.drawRRect(tubeBgRect, shellPaint);

    // Draw bulb background
    canvas.drawCircle(Offset(w / 2, bulbCenterY), bulbRadius + 3, shellPaint);

    // White inner tube
    final innerPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;
    final tubeInnerRect = RRect.fromRectAndRadius(
      Rect.fromLTRB(tubeLeft, tubeTop + 3, tubeRight, tubeBottom + tubeRadius),
      Radius.circular(tubeRadius),
    );
    canvas.drawRRect(tubeInnerRect, innerPaint);
    canvas.drawCircle(Offset(w / 2, bulbCenterY), bulbRadius, innerPaint);

    // Fill — bulb always filled, tube fills up based on fraction
    final fillPaint = Paint()
      ..color = fillColor
      ..style = PaintingStyle.fill;

    // Bulb fill
    canvas.drawCircle(Offset(w / 2, bulbCenterY), bulbRadius - 4, fillPaint);

    // Tube fill — from bottom up
    final tubeInnerTop = tubeTop + 6;
    final tubeInnerBottom = tubeBottom + tubeRadius - 2;
    final totalTubeHeight = tubeInnerBottom - tubeInnerTop;
    final fillHeight = totalTubeHeight * fraction;
    final fillTop = tubeInnerBottom - fillHeight;

    if (fillHeight > 0) {
      final fillRect = RRect.fromRectAndCorners(
        Rect.fromLTRB(tubeLeft + 3, fillTop, tubeRight - 3, tubeInnerBottom),
        topLeft: Radius.circular(tubeRadius - 3),
        topRight: Radius.circular(tubeRadius - 3),
      );
      canvas.drawRRect(fillRect, fillPaint);
    }

    // Tick marks on the right side
    final tickPaint = Paint()
      ..color = const Color(0xFFBDBDBD)
      ..strokeWidth = 1.5;
    const int tickCount = 5;
    for (int i = 0; i <= tickCount; i++) {
      final y = tubeInnerTop + (totalTubeHeight * (1.0 - i / tickCount));
      final xStart = tubeRight + 5;
      final xEnd = xStart + (i % tickCount == 0 ? 10.0 : 6.0);
      canvas.drawLine(Offset(xStart, y), Offset(xEnd, y), tickPaint);
    }
  }

  @override
  bool shouldRepaint(covariant _ThermometerPainter old) =>
      old.fraction != fraction || old.fillColor != fillColor;
}
