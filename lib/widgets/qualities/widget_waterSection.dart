import 'package:flutter/material.dart';
import 'dart:math' as math;
import '../../models/settings.dart';

/// Water section widget for QualityDetailPage.
/// Displays a gradient donut chart (blue→red = low→high usage)
/// with current water consumption and related stats.
class WaterSection extends StatefulWidget {
  final double currentUsage; // current reading in litres
  final double maxUsage; // scale maximum

  const WaterSection({
    super.key,
    this.currentUsage = 120.0,
    this.maxUsage = 300.0,
  });

  @override
  State<WaterSection> createState() => _WaterSectionState();
}

class _WaterSectionState extends State<WaterSection>
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
  void didUpdateWidget(covariant WaterSection old) {
    super.didUpdateWidget(old);
    if (old.currentUsage != widget.currentUsage) {
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
    final unit = Settings.instance.waterUnit.split(' ').first;
    final fraction =
        (widget.currentUsage / widget.maxUsage).clamp(0.0, 1.0);

    return Column(
      children: [
        const SizedBox(height: 12),
        // Gradient donut chart
        SizedBox(
          width: 220,
          height: 200,
          child: CustomPaint(
            painter: _WaterGradientDonutPainter(
              fraction: fraction * _anim.value,
            ),
            child: Center(
              child: Padding(
                padding: const EdgeInsets.only(top: 20),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '${widget.currentUsage.toStringAsFixed(0)}',
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
                  Icons.water_drop, 'Avg', '105 $unit', Colors.blue),
              _statColumn(
                  Icons.arrow_downward, 'Low', '60 $unit', Colors.lightBlue),
              _statColumn(
                  Icons.arrow_upward, 'High', '180 $unit', Colors.red),
            ],
          ),
        ),
        const SizedBox(height: 12),
        // Usage indicator
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: _usageColor(fraction).withAlpha(25),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: _usageColor(fraction).withAlpha(80),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  _usageIcon(fraction),
                  color: _usageColor(fraction),
                  size: 28,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _usageLabel(fraction),
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          color: _usageColor(fraction),
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        _usageDescription(fraction),
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

  Color _usageColor(double f) {
    if (f < 0.4) return const Color(0xFF1EAA83);
    if (f < 0.7) return Colors.orange;
    return Colors.red;
  }

  IconData _usageIcon(double f) {
    if (f < 0.4) return Icons.check_circle_outline;
    if (f < 0.7) return Icons.info_outline;
    return Icons.warning_amber_rounded;
  }

  String _usageLabel(double f) {
    if (f < 0.4) return 'Low Usage';
    if (f < 0.7) return 'Moderate Usage';
    return 'High Usage';
  }

  String _usageDescription(double f) {
    if (f < 0.4) return 'Water consumption is well within limits.';
    if (f < 0.7) return 'Water usage is moderate — keep monitoring.';
    return 'Water consumption is high — consider reducing.';
  }
}

// ---------------------------------------------------------------------------
// Gradient donut painter — 3/5 arc, blue→red gradient (cold→hot)
// Same geometry as HomeStatusChart
// ---------------------------------------------------------------------------
const double _kWaterSweep = (3.0 / 5.0) * 2.0 * math.pi; // 216°
const double _kWaterStart = -math.pi / 2 - (_kWaterSweep / 2);

class _WaterGradientDonutPainter extends CustomPainter {
  final double fraction; // 0..1

  _WaterGradientDonutPainter({required this.fraction});

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
    canvas.drawArc(rect, _kWaterStart, _kWaterSweep, false, bgPaint);

    // Gradient fill: blue → red
    final fillSweep = (_kWaterSweep * fraction).clamp(0.0, _kWaterSweep);
    if (fillSweep <= 0) return;

    final gradient = SweepGradient(
      startAngle: _kWaterStart,
      endAngle: _kWaterStart + _kWaterSweep,
      colors: const [
        Color(0xFF2196F3), // blue — cold / low
        Color(0xFF00BCD4), // cyan
        Color(0xFF4CAF50), // green
        Color(0xFFFFEB3B), // yellow
        Color(0xFFFF9800), // orange
        Color(0xFFF44336), // red — hot / high
      ],
      stops: const [0.0, 0.2, 0.4, 0.6, 0.8, 1.0],
    );

    final gradPaint = Paint()
      ..shader = gradient.createShader(rect)
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(rect, _kWaterStart, fillSweep, false, gradPaint);
  }

  @override
  bool shouldRepaint(covariant _WaterGradientDonutPainter old) =>
      old.fraction != fraction;
}
