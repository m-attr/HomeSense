import 'package:flutter/material.dart';
import 'dart:math' as math;
import '../../models/settings.dart';

/// Temperature section widget for QualityDetailPage.
/// Displays a gradient donut chart (blue→red = cold→hot)
/// with current temperature and related stats.
class TemperatureSection extends StatefulWidget {
  final double currentTemp; // current reading
  final double minTemp; // scale minimum
  final double maxTemp; // scale maximum

  const TemperatureSection({
    super.key,
    this.currentTemp = 24.0,
    this.minTemp = 0.0,
    this.maxTemp = 50.0,
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

  @override
  Widget build(BuildContext context) {
    final unit = Settings.instance.temperatureUnit.split(' ').first;
    final fraction = ((widget.currentTemp - widget.minTemp) /
            (widget.maxTemp - widget.minTemp))
        .clamp(0.0, 1.0);

    return Column(
      children: [
        const SizedBox(height: 12),
        // Gradient donut chart
        SizedBox(
          width: 220,
          height: 200,
          child: CustomPaint(
            painter: _TempGradientDonutPainter(
              fraction: fraction * _anim.value,
            ),
            child: Center(
              child: Padding(
                padding: const EdgeInsets.only(top: 20),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '${widget.currentTemp.toStringAsFixed(1)}',
                      style: const TextStyle(
                        fontSize: 36,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      unit,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 16),
        // Stats row
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _statColumn(
                  Icons.thermostat, 'Avg', '23.5 $unit', Colors.orange),
              _statColumn(
                  Icons.arrow_downward, 'Low', '18.0 $unit', Colors.blue),
              _statColumn(
                  Icons.arrow_upward, 'High', '29.2 $unit', Colors.red),
            ],
          ),
        ),
        const SizedBox(height: 12),
        // Comfort indicator
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: _comfortColor(widget.currentTemp).withAlpha(25),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: _comfortColor(widget.currentTemp).withAlpha(80),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  _comfortIcon(widget.currentTemp),
                  color: _comfortColor(widget.currentTemp),
                  size: 28,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _comfortLabel(widget.currentTemp),
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          color: _comfortColor(widget.currentTemp),
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        _comfortDescription(widget.currentTemp),
                        style: TextStyle(
                            fontSize: 12, color: Colors.grey.shade700),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _statColumn(
      IconData icon, String label, String value, Color color) {
    return Column(
      children: [
        Icon(icon, color: color, size: 22),
        const SizedBox(height: 4),
        Text(label,
            style: TextStyle(fontSize: 11, color: Colors.grey.shade600)),
        const SizedBox(height: 2),
        Text(value,
            style:
                const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
      ],
    );
  }

  // Comfort helpers
  Color _comfortColor(double t) {
    if (t < 16) return Colors.blue;
    if (t < 20) return Colors.lightBlue;
    if (t <= 26) return const Color(0xFF1EAA83);
    if (t <= 30) return Colors.orange;
    return Colors.red;
  }

  IconData _comfortIcon(double t) {
    if (t < 16) return Icons.ac_unit;
    if (t <= 26) return Icons.check_circle_outline;
    return Icons.warning_amber_rounded;
  }

  String _comfortLabel(double t) {
    if (t < 16) return 'Too Cold';
    if (t < 20) return 'Cool';
    if (t <= 26) return 'Comfortable';
    if (t <= 30) return 'Warm';
    return 'Too Hot';
  }

  String _comfortDescription(double t) {
    if (t < 16) return 'Temperature is below comfortable range.';
    if (t < 20) return 'Slightly cool — consider warming up.';
    if (t <= 26) return 'Temperature is within the ideal range.';
    if (t <= 30) return 'Getting warm — consider cooling.';
    return 'Temperature is above comfortable range.';
  }
}

// ---------------------------------------------------------------------------
// Gradient donut painter — 3/5 arc, blue→red gradient (cold→hot)
// Same geometry as HomeStatusChart
// ---------------------------------------------------------------------------
const double _kTempSweep = (3.0 / 5.0) * 2.0 * math.pi; // 216°
const double _kTempStart = -math.pi / 2 - (_kTempSweep / 2);

class _TempGradientDonutPainter extends CustomPainter {
  final double fraction; // 0..1

  _TempGradientDonutPainter({required this.fraction});

  @override
  void paint(Canvas canvas, Size size) {
    const double strokeWidth = 26.0;
    final double totalW = size.width;
    final double radius = (totalW - strokeWidth) / 2.0;
    if (radius <= 0) return;
    final center = Offset(totalW / 2, radius + 10);
    final rect = Rect.fromCircle(center: center, radius: radius);

    // Unfilled track
    final bgPaint = Paint()
      ..color = const Color(0xFFEFEFEF)
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;
    canvas.drawArc(rect, _kTempStart, _kTempSweep, false, bgPaint);

    // Gradient fill
    final fillSweep = (_kTempSweep * fraction).clamp(0.0, _kTempSweep);
    if (fillSweep <= 0) return;

    final gradient = SweepGradient(
      startAngle: _kTempStart,
      endAngle: _kTempStart + _kTempSweep,
      colors: const [
        Color(0xFF2196F3), // blue — cold
        Color(0xFF00BCD4), // cyan
        Color(0xFF4CAF50), // green — comfortable
        Color(0xFFFFEB3B), // yellow
        Color(0xFFFF9800), // orange
        Color(0xFFF44336), // red — hot
      ],
      stops: const [0.0, 0.2, 0.4, 0.6, 0.8, 1.0],
    );

    final gradPaint = Paint()
      ..shader = gradient.createShader(rect)
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(rect, _kTempStart, fillSweep, false, gradPaint);
  }

  @override
  bool shouldRepaint(covariant _TempGradientDonutPainter old) =>
      old.fraction != fraction;
}
