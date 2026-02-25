import 'package:flutter/material.dart';
import 'dart:math' as math;

/// Reusable arc slider that can be themed for any quality.
///
/// Pass [gradientColors] / [gradientStops] (each length ≥ 2) to define
/// the track fill colour progression, plus [minValue], [maxValue] and
/// [stepSize] for the knob snap behaviour.
class GenericArcSlider extends StatefulWidget {
  final double initialValue;
  final double minValue;
  final double maxValue;
  final double stepSize;
  final String unitLabel;
  final List<Color> gradientColors;
  final List<double> gradientStops;
  final ValueChanged<double>? onChanged;

  const GenericArcSlider({
    super.key,
    required this.initialValue,
    required this.minValue,
    required this.maxValue,
    this.stepSize = 1.0,
    this.unitLabel = '',
    required this.gradientColors,
    required this.gradientStops,
    this.onChanged,
  });

  @override
  State<GenericArcSlider> createState() => _GenericArcSliderState();
}

class _GenericArcSliderState extends State<GenericArcSlider> {
  late double _currentValue;

  static const double _sweepArc = (3.0 / 5.0) * 2.0 * math.pi;
  static const double _startAngle = -math.pi / 2 - (_sweepArc / 2);
  static const double _strokeWidth = 26.0;
  static const double _thumbRadius = 16.0;

  @override
  void initState() {
    super.initState();
    _currentValue = widget.initialValue.clamp(widget.minValue, widget.maxValue);
  }

  @override
  void didUpdateWidget(covariant GenericArcSlider old) {
    super.didUpdateWidget(old);
    if (old.initialValue != widget.initialValue) {
      _currentValue = widget.initialValue.clamp(
        widget.minValue,
        widget.maxValue,
      );
    }
  }

  double get _fraction =>
      ((_currentValue - widget.minValue) / (widget.maxValue - widget.minValue))
          .clamp(0.0, 1.0);

  void _updateFromPosition(Offset localPosition, Size size) {
    final double totalW = size.width;
    final double radius = (totalW - _strokeWidth) / 2.0;
    final center = Offset(totalW / 2, radius + 10);

    final dx = localPosition.dx - center.dx;
    final dy = localPosition.dy - center.dy;
    double angle = math.atan2(dy, dx);

    double rel = angle - _startAngle;
    while (rel < 0) rel += 2 * math.pi;
    while (rel > 2 * math.pi) rel -= 2 * math.pi;

    if (rel > _sweepArc) {
      final distToStart = rel;
      final distToEnd = 2 * math.pi - rel + _sweepArc;
      rel = distToStart < distToEnd ? 0.0 : _sweepArc;
    }

    final frac = (rel / _sweepArc).clamp(0.0, 1.0);
    final raw = widget.minValue + frac * (widget.maxValue - widget.minValue);

    // Snap to step
    final step = widget.stepSize;
    final snapped = (raw / step).round() * step;
    setState(() {
      _currentValue = snapped.clamp(widget.minValue, widget.maxValue);
    });
    widget.onChanged?.call(_currentValue);
  }

  String get _displayValue {
    if (widget.stepSize >= 1) {
      return _currentValue.toStringAsFixed(0);
    }
    return _currentValue.toStringAsFixed(1);
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
              painter: _GenericArcPainter(
                fraction: _fraction,
                strokeWidth: _strokeWidth,
                thumbRadius: _thumbRadius,
                gradientColors: widget.gradientColors,
                gradientStops: widget.gradientStops,
              ),
              child: Padding(
                padding: EdgeInsets.only(bottom: h * 0.18),
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        _displayValue,
                        style: const TextStyle(
                          fontSize: 40,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF2D3142),
                          height: 1.0,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        widget.unitLabel,
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
// Generic arc painter — reusable gradient colours
// ---------------------------------------------------------------------------
class _GenericArcPainter extends CustomPainter {
  final double fraction;
  final double strokeWidth;
  final double thumbRadius;
  final List<Color> gradientColors;
  final List<double> gradientStops;

  static const double _sweepArc = (3.0 / 5.0) * 2.0 * math.pi;
  static const double _startAngle = -math.pi / 2 - (_sweepArc / 2);

  _GenericArcPainter({
    required this.fraction,
    this.strokeWidth = 26.0,
    this.thumbRadius = 16.0,
    required this.gradientColors,
    required this.gradientStops,
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

    // Gradient fill up to current fraction
    final fillSweep = (_sweepArc * fraction).clamp(0.0, _sweepArc);
    if (fillSweep > 0) {
      final List<Color> fillColors = [];
      final List<double> fillStopsNorm = [];

      for (int i = 0; i < gradientStops.length; i++) {
        if (gradientStops[i] <= fraction) {
          fillColors.add(gradientColors[i]);
          fillStopsNorm.add(fraction > 0 ? gradientStops[i] / fraction : 0.0);
        } else {
          break;
        }
      }
      final endColor = _colorAtFraction(fraction);
      fillColors.add(endColor);
      fillStopsNorm.add(1.0);

      if (fillColors.length < 2) {
        fillColors.insert(0, gradientColors.first);
        fillStopsNorm.insert(0, 0.0);
      }

      final gradient = SweepGradient(
        startAngle: _startAngle,
        endAngle: _startAngle + fillSweep,
        colors: fillColors,
        stops: fillStopsNorm,
      );

      final gradPaint = Paint()
        ..shader = gradient.createShader(rect)
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth
        ..strokeCap = StrokeCap.round;

      canvas.drawArc(rect, _startAngle, fillSweep, false, gradPaint);
    }

    // Thumb
    final thumbAngle = _startAngle + fillSweep;
    final thumbCenter = Offset(
      center.dx + radius * math.cos(thumbAngle),
      center.dy + radius * math.sin(thumbAngle),
    );

    canvas.drawCircle(thumbCenter, thumbRadius, Paint()..color = Colors.white);
    canvas.drawCircle(
      thumbCenter,
      thumbRadius,
      Paint()
        ..color = Colors.black.withOpacity(0.15)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4),
    );
    final thumbColor = _colorAtFraction(fraction);
    canvas.drawCircle(
      thumbCenter,
      thumbRadius - 3,
      Paint()..color = thumbColor,
    );
  }

  Color _colorAtFraction(double f) {
    if (f <= 0) return gradientColors.first;
    if (f >= 1) return gradientColors.last;
    for (int i = 0; i < gradientStops.length - 1; i++) {
      if (f >= gradientStops[i] && f <= gradientStops[i + 1]) {
        final t =
            (f - gradientStops[i]) / (gradientStops[i + 1] - gradientStops[i]);
        return Color.lerp(gradientColors[i], gradientColors[i + 1], t)!;
      }
    }
    return gradientColors.last;
  }

  @override
  bool shouldRepaint(covariant _GenericArcPainter old) =>
      old.fraction != fraction;
}
