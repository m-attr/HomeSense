import 'package:flutter/material.dart';
import 'dart:math' as math;
import '../../models/settings.dart';
import '../../helpers/quality_helpers.dart';

/// Water section widget for QualityDetailPage.
/// Displays a large water-droplet widget filled to the current usage fraction
/// with today's consumption in mL/L and the percentage of the daily goal.
class WaterSection extends StatefulWidget {
  final double currentUsage; // current reading in litres (today's total)
  final double maxUsage; // scale maximum (for gauge, not the goal)

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
      duration: const Duration(milliseconds: 1200),
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

  String _formatUsage(double litres) {
    final unit = Settings.instance.waterUnit;
    if (unit.contains('m³')) {
      return '${(litres / 1000).toStringAsFixed(3)} m³';
    }
    // Always show in litres as that's the base unit when 'Litres' is selected
    if (litres < 1.0) {
      return '${(litres * 1000).toStringAsFixed(0)} mL';
    }
    return '${litres.toStringAsFixed(1)} L';
  }

  String _formatGoal(double litres) {
    final unit = Settings.instance.waterUnit;
    if (unit.contains('m³')) {
      return '${(litres / 1000).toStringAsFixed(2)} m³';
    }
    return '${litres.toStringAsFixed(0)} L';
  }

  @override
  Widget build(BuildContext context) {
    final double goal = Settings.instance.waterThreshold;
    final double fraction = (widget.currentUsage / goal).clamp(0.0, 1.5);
    final double animFraction = fraction * _anim.value;
    final int percentage = (animFraction * 100).round();

    // Use unified status colour from quality_helpers
    final Color statusCol = waterStatusColor(widget.currentUsage);
    final String statusLbl = waterStatusLabel(widget.currentUsage);
    final IconData statusIcn = waterStatusIcon(widget.currentUsage);
    final String statusDesc = waterStatusDescription(widget.currentUsage);

    // Droplet fill colour based on unified thresholds
    Color dropletColor;
    Color accentColor;
    if (statusCol == kStatusGreen) {
      dropletColor = const Color(0xFF42A5F5);
      accentColor = const Color(0xFF1E88E5);
    } else if (statusCol == kStatusAmber) {
      dropletColor = const Color(0xFF29B6F6);
      accentColor = const Color(0xFF039BE5);
    } else if (statusCol == kStatusOrange) {
      dropletColor = const Color(0xFF26A69A);
      accentColor = const Color(0xFF00897B);
    } else {
      dropletColor = const Color(0xFFEF5350);
      accentColor = const Color(0xFFE53935);
    }

    return Column(
      children: [
        const SizedBox(height: 20),

        // Water droplet widget
        SizedBox(
          width: 180,
          height: 220,
          child: CustomPaint(
            painter: _WaterDropletPainter(
              fillFraction: animFraction.clamp(0.0, 1.0),
              fillColor: dropletColor,
              wavePhase: _anim.value * math.pi * 2,
            ),
            child: Center(
              child: Padding(
                padding: const EdgeInsets.only(top: 50),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Today's consumption in mL/L
                    Text(
                      _formatUsage(widget.currentUsage),
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: Colors.white.withValues(alpha: 0.9),
                      ),
                    ),
                    const SizedBox(height: 4),
                    // Percentage of daily goal
                    Text(
                      '$percentage%',
                      style: const TextStyle(
                        fontSize: 38,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        height: 1.1,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 20),

        // Daily goal display
        Column(
          children: [
            Text(
              _formatGoal(goal),
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: accentColor,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              'Daily Goal',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: Colors.grey.shade500,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),

        // Usage status indicator
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              color: statusCol.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: statusCol.withValues(alpha: 0.25),
                width: 1.2,
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: statusCol.withValues(alpha: 0.15),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(statusIcn, color: statusCol, size: 20),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        statusLbl,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: statusCol,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        statusDesc,
                        style: TextStyle(
                          fontSize: 11,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 8),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Water droplet painter — teardrop shape with animated fill & wave
// ---------------------------------------------------------------------------
class _WaterDropletPainter extends CustomPainter {
  final double fillFraction; // 0..1
  final Color fillColor;
  final double wavePhase;

  _WaterDropletPainter({
    required this.fillFraction,
    required this.fillColor,
    this.wavePhase = 0.0,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final double w = size.width;
    final double h = size.height;

    // Build droplet path — pointed top, rounded bottom
    final Path droplet = _buildDropletPath(w, h);

    // Outline shadow
    canvas.drawShadow(droplet, Colors.black26, 6, false);

    // Clip to droplet shape
    canvas.save();
    canvas.clipPath(droplet);

    // Light background
    final bgPaint = Paint()..color = fillColor.withValues(alpha: 0.12);
    canvas.drawRect(Rect.fromLTWH(0, 0, w, h), bgPaint);

    // Water fill — rises from bottom
    if (fillFraction > 0) {
      final double fillTop =
          h * (1.0 - fillFraction * 0.82); // 82% of height max

      // Subtle wave at the water surface
      final wavePath = Path();
      wavePath.moveTo(0, fillTop);
      for (double x = 0; x <= w; x += 1) {
        final waveY = fillTop + math.sin((x / w) * math.pi * 3 + wavePhase) * 3;
        wavePath.lineTo(x, waveY);
      }
      wavePath.lineTo(w, h);
      wavePath.lineTo(0, h);
      wavePath.close();

      // Gradient fill — darker at bottom
      final fillPaint = Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [fillColor.withValues(alpha: 0.7), fillColor],
        ).createShader(Rect.fromLTWH(0, fillTop, w, h - fillTop));

      canvas.drawPath(wavePath, fillPaint);
    }

    canvas.restore();

    // Droplet border
    final borderPaint = Paint()
      ..color = fillColor.withValues(alpha: 0.4)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5;
    canvas.drawPath(droplet, borderPaint);

    // Small highlight reflection on upper left
    final highlightPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.35)
      ..style = PaintingStyle.fill;
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(w * 0.32, h * 0.42),
        width: 14,
        height: 22,
      ),
      highlightPaint,
    );
  }

  Path _buildDropletPath(double w, double h) {
    final path = Path();
    // Tip at top center
    final double tipX = w / 2;
    final double tipY = h * 0.05;
    // Body center
    final double bodyY = h * 0.58;
    final double bodyR = w * 0.46;

    path.moveTo(tipX, tipY);
    // Right curve from tip down to body
    path.cubicTo(
      tipX + w * 0.04,
      h * 0.22,
      tipX + bodyR,
      h * 0.36,
      tipX + bodyR,
      bodyY,
    );
    // Bottom arc
    path.arcToPoint(
      Offset(tipX - bodyR, bodyY),
      radius: Radius.circular(bodyR),
      clockwise: true,
    );
    // Left curve from body back up to tip
    path.cubicTo(tipX - bodyR, h * 0.36, tipX - w * 0.04, h * 0.22, tipX, tipY);
    path.close();
    return path;
  }

  @override
  bool shouldRepaint(covariant _WaterDropletPainter old) =>
      old.fillFraction != fillFraction ||
      old.fillColor != fillColor ||
      old.wavePhase != wavePhase;
}
