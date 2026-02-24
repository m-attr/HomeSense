import 'package:flutter/material.dart';
import 'dart:math' as math;

/// Arc slider for setting temperature.
/// Gradient arc from blue (cold) → red (hot) with a draggable thumb.
/// Displays the current temperature value inside the arc.
class TempArcSlider extends StatefulWidget {
  final double initialTemp;
  final double minTemp;
  final double maxTemp;
  final ValueChanged<double>? onChanged;

  const TempArcSlider({
    super.key,
    this.initialTemp = 22.0,
    this.minTemp = 10.0,
    this.maxTemp = 35.0,
    this.onChanged,
  });

  @override
  State<TempArcSlider> createState() => _TempArcSliderState();
}

class _TempArcSliderState extends State<TempArcSlider> {
  late double _currentTemp;

  // Arc geometry — same 3/5 circle (216°) as HomeStatusChart
  static const double _sweepArc = (3.0 / 5.0) * 2.0 * math.pi;
  static const double _startAngle = -math.pi / 2 - (_sweepArc / 2);
  static const double _strokeWidth = 26.0;
  static const double _thumbRadius = 16.0;

  @override
  void initState() {
    super.initState();
    _currentTemp = widget.initialTemp.clamp(widget.minTemp, widget.maxTemp);
  }

  double get _fraction =>
      ((_currentTemp - widget.minTemp) / (widget.maxTemp - widget.minTemp))
          .clamp(0.0, 1.0);

  // Given a pointer position, compute the closest temperature on the arc
  void _updateFromPosition(Offset localPosition, Size size) {
    final double totalW = size.width;
    final double radius = (totalW - _strokeWidth) / 2.0;
    final center = Offset(totalW / 2, radius + 10);

    final dx = localPosition.dx - center.dx;
    final dy = localPosition.dy - center.dy;
    double angle = math.atan2(dy, dx); // -π..π

    // Normalize angle relative to start
    double rel = angle - _startAngle;
    // Wrap into [0, 2π)
    while (rel < 0) {
      rel += 2 * math.pi;
    }
    while (rel > 2 * math.pi) {
      rel -= 2 * math.pi;
    }

    // Clamp to arc sweep
    if (rel > _sweepArc) {
      // Outside the arc — snap to nearest end
      final distToStart = rel;
      final distToEnd = 2 * math.pi - rel + _sweepArc;
      rel = distToStart < distToEnd ? 0.0 : _sweepArc;
    }

    final frac = (rel / _sweepArc).clamp(0.0, 1.0);
    final temp = widget.minTemp + frac * (widget.maxTemp - widget.minTemp);

    // Round to 0.5 steps
    final rounded = (temp * 2).round() / 2.0;
    setState(() {
      _currentTemp = rounded.clamp(widget.minTemp, widget.maxTemp);
    });
    widget.onChanged?.call(_currentTemp);
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final double w = constraints.maxWidth.clamp(0.0, 280.0);
        final double radius = (w - _strokeWidth) / 2.0;
        final double h =
            radius +
            10 +
            radius * math.sin(_sweepArc / 2) +
            _strokeWidth / 2 +
            20;

        return GestureDetector(
          onPanStart: (d) => _updateFromPosition(d.localPosition, Size(w, h)),
          onPanUpdate: (d) => _updateFromPosition(d.localPosition, Size(w, h)),
          onTapDown: (d) => _updateFromPosition(d.localPosition, Size(w, h)),
          child: SizedBox(
            width: w,
            height: h,
            child: CustomPaint(
              painter: _ArcSliderPainter(
                fraction: _fraction,
                strokeWidth: _strokeWidth,
                thumbRadius: _thumbRadius,
              ),
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.only(top: 20),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        _currentTemp.toStringAsFixed(1),
                        style: const TextStyle(
                          fontSize: 40,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF2D3142),
                        ),
                      ),
                      Text(
                        '°C',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

// ---------------------------------------------------------------------------
// Arc slider painter — gradient blue→red with draggable thumb
// ---------------------------------------------------------------------------
class _ArcSliderPainter extends CustomPainter {
  final double fraction; // 0..1
  final double strokeWidth;
  final double thumbRadius;

  static const double _sweepArc = (3.0 / 5.0) * 2.0 * math.pi;
  static const double _startAngle = -math.pi / 2 - (_sweepArc / 2);

  _ArcSliderPainter({
    required this.fraction,
    this.strokeWidth = 26.0,
    this.thumbRadius = 16.0,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final double totalW = size.width;
    final double radius = (totalW - strokeWidth) / 2.0;
    if (radius <= 0) return;
    final center = Offset(totalW / 2, radius + 10);
    final rect = Rect.fromCircle(center: center, radius: radius);

    // Background track
    final bgPaint = Paint()
      ..color = const Color(0xFFEFEFEF)
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;
    canvas.drawArc(rect, _startAngle, _sweepArc, false, bgPaint);

    // Gradient fill — only up to current fraction
    final fillSweep = (_sweepArc * fraction).clamp(0.0, _sweepArc);
    if (fillSweep > 0) {
      // Build gradient colors/stops only up to the current fraction
      // so the arc visually transitions from blue → current color
      const allColors = [
        Color(0xFF2196F3), // blue   @ 0.0
        Color(0xFF00BCD4), // cyan   @ 0.2
        Color(0xFF1EAA83), // green  @ 0.4
        Color(0xFFFFEB3B), // yellow @ 0.6
        Color(0xFFFF9800), // orange @ 0.8
        Color(0xFFF44336), // red    @ 1.0
      ];
      const allStops = [0.0, 0.2, 0.4, 0.6, 0.8, 1.0];

      // Collect colors/stops that fall within [0, fraction]
      final List<Color> fillColors = [];
      final List<double> fillStops = [];

      for (int i = 0; i < allStops.length; i++) {
        if (allStops[i] <= fraction) {
          fillColors.add(allColors[i]);
          // Remap stop from [0, fraction] → [0, 1]
          fillStops.add(fraction > 0 ? allStops[i] / fraction : 0.0);
        } else {
          break;
        }
      }
      // Always add the exact endpoint color
      final endColor = _colorAtFraction(fraction);
      fillColors.add(endColor);
      fillStops.add(1.0);

      // Need at least 2 colors
      if (fillColors.length < 2) {
        fillColors.insert(0, allColors.first);
        fillStops.insert(0, 0.0);
      }

      final gradient = SweepGradient(
        startAngle: _startAngle,
        endAngle: _startAngle + fillSweep,
        colors: fillColors,
        stops: fillStops,
      );

      final gradPaint = Paint()
        ..shader = gradient.createShader(rect)
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth
        ..strokeCap = StrokeCap.round;

      canvas.drawArc(rect, _startAngle, fillSweep, false, gradPaint);
    }

    // Thumb circle
    final thumbAngle = _startAngle + fillSweep;
    final thumbCenter = Offset(
      center.dx + radius * math.cos(thumbAngle),
      center.dy + radius * math.sin(thumbAngle),
    );

    // White border
    final thumbBorderPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;
    canvas.drawCircle(thumbCenter, thumbRadius, thumbBorderPaint);

    // Shadow
    final shadowPaint = Paint()
      ..color = Colors.black.withOpacity(0.15)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4);
    canvas.drawCircle(thumbCenter, thumbRadius, shadowPaint);

    // Thumb fill — match gradient color at current position
    final thumbColor = _colorAtFraction(fraction);
    final thumbFillPaint = Paint()
      ..color = thumbColor
      ..style = PaintingStyle.fill;
    canvas.drawCircle(thumbCenter, thumbRadius - 3, thumbFillPaint);
  }

  Color _colorAtFraction(double f) {
    const colors = [
      Color(0xFF2196F3),
      Color(0xFF00BCD4),
      Color(0xFF1EAA83),
      Color(0xFFFFEB3B),
      Color(0xFFFF9800),
      Color(0xFFF44336),
    ];
    const stops = [0.0, 0.2, 0.4, 0.6, 0.8, 1.0];

    if (f <= 0) return colors.first;
    if (f >= 1) return colors.last;

    for (int i = 0; i < stops.length - 1; i++) {
      if (f >= stops[i] && f <= stops[i + 1]) {
        final t = (f - stops[i]) / (stops[i + 1] - stops[i]);
        return Color.lerp(colors[i], colors[i + 1], t)!;
      }
    }
    return colors.last;
  }

  @override
  bool shouldRepaint(covariant _ArcSliderPainter old) =>
      old.fraction != fraction;
}
