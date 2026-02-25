import 'package:flutter/material.dart';
import '../../models/settings.dart';
import '../../helpers/quality_helpers.dart';

/// Electricity section widget for QualityDetailPage.
/// Displays a large lightning-bolt power meter that fills and pulses
/// based on how close consumption is to the daily threshold.
class ElectricitySection extends StatefulWidget {
  final double currentUsage; // today's reading in kWh (base unit)
  final double maxUsage; // gauge max (visual only)

  const ElectricitySection({
    super.key,
    this.currentUsage = 8.6,
    this.maxUsage = 20.0,
  });

  @override
  State<ElectricitySection> createState() => _ElectricitySectionState();
}

class _ElectricitySectionState extends State<ElectricitySection>
    with TickerProviderStateMixin {
  late final AnimationController _fillCtrl;
  late Animation<double> _fillAnim;
  late final AnimationController _pulseCtrl;
  late Animation<double> _pulseAnim;

  @override
  void initState() {
    super.initState();

    // Fill animation (rises once)
    _fillCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    _fillAnim = CurvedAnimation(parent: _fillCtrl, curve: Curves.easeOutCubic);
    _fillCtrl.addListener(() {
      if (mounted) setState(() {});
    });

    // Continuous subtle pulse (glow)
    _pulseCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1600),
    );
    _pulseAnim = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _pulseCtrl, curve: Curves.easeInOut));
    _pulseCtrl.addListener(() {
      if (mounted) setState(() {});
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fillCtrl.forward();
      _pulseCtrl.repeat(reverse: true);
    });
  }

  @override
  void didUpdateWidget(covariant ElectricitySection old) {
    super.didUpdateWidget(old);
    if (old.currentUsage != widget.currentUsage) {
      _fillCtrl
        ..reset()
        ..forward();
    }
  }

  @override
  void dispose() {
    _fillCtrl.dispose();
    _pulseCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final double threshold = Settings.instance.electricityThreshold;
    final double fraction = electricityFraction(widget.currentUsage);
    final double animFraction = fraction.clamp(0.0, 1.5) * _fillAnim.value;
    final int percentage = (animFraction * 100).round().clamp(0, 999);
    final Color statusCol = electricityStatusColor(widget.currentUsage);
    final String label = electricityStatusLabel(widget.currentUsage);
    final IconData icon = electricityStatusIcon(widget.currentUsage);
    final String desc = electricityStatusDescription(widget.currentUsage);
    final bool overLimit = fraction >= 1.0;

    // Dynamic accent colour based on fill level
    Color boltColor;
    Color glowColor;
    if (fraction < 0.60) {
      boltColor = const Color(0xFFF5A623); // warm amber
      glowColor = const Color(0xFFF5A623);
    } else if (fraction < 0.80) {
      boltColor = const Color(0xFFFF9800); // orange
      glowColor = const Color(0xFFFF9800);
    } else if (fraction < 1.0) {
      boltColor = const Color(0xFFFF5722); // deep orange
      glowColor = const Color(0xFFFF5722);
    } else {
      boltColor = const Color(0xFFF44336); // red
      glowColor = const Color(0xFFF44336);
    }

    final double pulseGlow = 0.15 + (_pulseAnim.value * 0.15);

    return Column(
      children: [
        const SizedBox(height: 20),

        // Lightning bolt + stats side-by-side (like temperature section)
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Bolt icon
              SizedBox(
                width: 100,
                height: 200,
                child: CustomPaint(
                  painter: _LightningBoltPainter(
                    fillFraction: animFraction.clamp(0.0, 1.0),
                    boltColor: boltColor,
                    glowOpacity: pulseGlow,
                    glowColor: glowColor,
                  ),
                ),
              ),
              const SizedBox(width: 24),
              // Stats text beside the bolt
              Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Percentage of target
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '$percentage',
                        style: TextStyle(
                          fontSize: 52,
                          fontWeight: FontWeight.bold,
                          color: boltColor,
                          height: 1.0,
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: Text(
                          '%',
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w600,
                            color: boltColor,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  // Consumed today
                  Text(
                    '${formatElectricity(widget.currentUsage)} ${electricityUnitLabel()}',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey.shade700,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'consumed today',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w400,
                      color: Colors.grey.shade500,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),

        // Daily target
        Column(
          children: [
            Text(
              '${formatElectricity(threshold)} ${electricityUnitLabel()}',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: boltColor,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              'Daily Target',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: Colors.grey.shade500,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),

        // Status indicator — unified colours
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
                  child: Icon(icon, color: statusCol, size: 20),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        overLimit ? 'Target Exceeded' : label,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: statusCol,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        desc,
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
//  Lightning-bolt painter — hexagonal bolt shape with gradient fill + glow
// ---------------------------------------------------------------------------
class _LightningBoltPainter extends CustomPainter {
  final double fillFraction;
  final Color boltColor;
  final double glowOpacity;
  final Color glowColor;

  _LightningBoltPainter({
    required this.fillFraction,
    required this.boltColor,
    this.glowOpacity = 0.15,
    this.glowColor = const Color(0xFFF5A623),
  });

  @override
  void paint(Canvas canvas, Size size) {
    final double w = size.width;
    final double h = size.height;

    final Path bolt = _buildBoltPath(w, h);

    // Outer glow
    final glowPaint = Paint()
      ..color = glowColor.withValues(alpha: glowOpacity)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 18);
    canvas.drawPath(bolt, glowPaint);

    // Drop shadow
    canvas.drawShadow(bolt, Colors.black26, 6, false);

    // Clip to bolt shape
    canvas.save();
    canvas.clipPath(bolt);

    // Background
    final bgPaint = Paint()..color = boltColor.withValues(alpha: 0.15);
    canvas.drawRect(Rect.fromLTWH(0, 0, w, h), bgPaint);

    // Gradient fill rising from bottom
    if (fillFraction > 0) {
      final double fillTop = h * (1.0 - fillFraction * 0.92);

      final fillPaint = Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            boltColor.withValues(alpha: 0.6),
            boltColor.withValues(alpha: 0.85),
            boltColor,
          ],
          stops: const [0.0, 0.5, 1.0],
        ).createShader(Rect.fromLTWH(0, fillTop, w, h - fillTop));

      canvas.drawRect(Rect.fromLTWH(0, fillTop, w, h - fillTop), fillPaint);
    }

    canvas.restore();

    // Border
    final borderPaint = Paint()
      ..color = boltColor.withValues(alpha: 0.5)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5
      ..strokeJoin = StrokeJoin.round;
    canvas.drawPath(bolt, borderPaint);

    // Highlight on upper-left
    final highlightPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.25)
      ..style = PaintingStyle.fill;
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(w * 0.36, h * 0.28),
        width: 14,
        height: 20,
      ),
      highlightPaint,
    );
  }

  /// Builds a classic high-voltage / ⚡ lightning bolt icon.
  ///
  /// This is the universally recognised voltage symbol — a bold,
  /// angular Z-shaped zigzag with a horizontal shelf in the middle.
  /// The upper half slants down-right, the shelf cuts back left,
  /// and the lower half slants down-right to a sharp point.
  ///
  ///    A ___________
  ///    |            \ B
  ///    |             \
  ///    |              \
  ///   G \       D ____/ C   ← horizontal shelf
  ///      \     /
  ///       \   /
  ///        \ /
  ///         E   ← bottom point
  ///
  Path _buildBoltPath(double w, double h) {
    final path = Path();

    // A — Top-left corner
    path.moveTo(w * 0.28, h * 0.02);

    // B — Top-right corner
    path.lineTo(w * 0.72, h * 0.02);

    // C — Slant down to right side of shelf
    path.lineTo(w * 0.58, h * 0.46);

    // D — Shelf jumps right (the horizontal bar of the Z)
    path.lineTo(w * 0.78, h * 0.46);

    // E — Sharp bottom point
    path.lineTo(w * 0.38, h * 0.98);

    // F — Slant back up to left side of shelf
    path.lineTo(w * 0.42, h * 0.54);

    // G — Shelf jumps left
    path.lineTo(w * 0.22, h * 0.54);

    path.close(); // closes back to A

    return path;
  }

  @override
  bool shouldRepaint(covariant _LightningBoltPainter old) =>
      old.fillFraction != fillFraction ||
      old.boltColor != boltColor ||
      old.glowOpacity != glowOpacity;
}
