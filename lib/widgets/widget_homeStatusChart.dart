import 'package:flutter/material.dart';
import 'dart:math' as math;

// arc geometry constants (3/5 of a circle = 216 degrees)
const double _kSweepArc = (3.0 / 5.0) * 2.0 * math.pi; // 216deg = 1.2 * pi
// Start angle chosen so the arc is centered upright (top):
// start = -pi/2 - sweep/2
const double _kStartAngle = -math.pi / 2 - (_kSweepArc / 2);

// Toggle for temporary visual debugging of chart bounds
const bool _kHSVisualDebug = false;

// animate from 0 to respective score
class HomeStatusChart extends StatefulWidget {
  final int score; // 0..100
  final double width;
  final double height;

  // Reduce default height so the widget occupies only the semicircle area
  const HomeStatusChart({
    super.key,
    required this.score,
    this.width = 240,
    this.height = 220,
  });
  // Toggle for temporary visual debugging of chart bounds

  @override
  State<HomeStatusChart> createState() => _HomeStatusChartState();
}

class _HomeStatusChartState extends State<HomeStatusChart>
    with TickerProviderStateMixin {
  late final AnimationController _bgController; // white semicircle forming
  Animation<double> _bgAnimation = const AlwaysStoppedAnimation(0.0);

  late final AnimationController _yellowController; // yellow fill
  Animation<double> _yellowAnimation = const AlwaysStoppedAnimation(0.0);

  @override
  void initState() {
    super.initState();
    _bgController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 450),
    );
    _bgAnimation = Tween<double>(begin: 0.0, end: _kSweepArc).animate(
      CurvedAnimation(parent: _bgController, curve: Curves.easeOutCubic),
    );

    _yellowController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _yellowAnimation = Tween<double>(begin: 0.0, end: 0.0).animate(
      CurvedAnimation(parent: _yellowController, curve: Curves.easeOutCubic),
    );

    // Attach a single listener to each controller to trigger rebuilds.
    _bgController.addListener(() {
      if (mounted) setState(() {});
    });
    _yellowController.addListener(() {
      if (mounted) setState(() {});
    });

    // when bg completes, wait 500ms then start yellow
    _bgController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        Future.delayed(const Duration(milliseconds: 200), () {
          final double targetSweep =
              (widget.score.clamp(0, 100) / 100.0) * _kSweepArc;
          _yellowAnimation = Tween<double>(
            begin: 0.0,
            end: targetSweep,
          ).animate(_yellowController);
          _yellowController
            ..reset()
            ..forward();
        });
      }
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _bgController.forward();
    });
  }

  @override
  void didUpdateWidget(covariant HomeStatusChart oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.score != widget.score) {
      _bgController
        ..reset()
        ..forward();
      _yellowController.reset();
    }
  }

  @override
  void dispose() {
    _bgController.dispose();
    _yellowController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final double width = widget.width;
    // final double height = widget.height;
    final double bgSweep = _bgAnimation.value;
    final double yellowSweep = _yellowAnimation.value;

    Color _colorForScore(int s) {
      if (s < 50) return Colors.red;
      if (s < 75) return const Color(0xFFFFC107); // amber/yellow
      return const Color(0xFF1EAA83); // green
    }

    // Compute semicircle size so the arc fits within available width
    // and accounts for stroke thickness.
    final double totalWidth = width;
    const double pad = 4.0; // small padding below stroke
    const double stroke = 30.0; // thicker arc per user request
    // arc geometry: using top-level constants for 3/4 circle
    // diameter available for the circle (leave room for stroke on both sides)
    final double diameter = (totalWidth - stroke).clamp(0.0, totalWidth);
    final double circleRadius = diameter / 2.0;
    // innerH is the required canvas height so the 3/4 arc fits into the box.
    // For a 3/4 arc from -135deg..+135deg the lowest point has y = center.y + r*sin(135deg)
    // center.y is at 'radius' (we place center near top), so innerH must accommodate that
    final double halfSweep = _kSweepArc / 2.0;
    final double innerH =
        (1.0 + math.sin(halfSweep)) * circleRadius + stroke / 2 + pad;

    return LayoutBuilder(
      builder: (context, constraints) {
        if (_kHSVisualDebug) {
          debugPrint(
            'HomeStatusChart.build: score=${widget.score} width=$width heightParam=${widget.height} innerH=$innerH constraints=${constraints.maxWidth}x${constraints.maxHeight}',
          );
        }

        final double verticalShift = 25.0;

        Widget content = SizedBox(
          width: width,
          // Use a Stack so the score text sits centered inside the painted arc
          child: SizedBox(
            width: totalWidth,
            height: innerH,
            child: Stack(
              alignment: Alignment.center,
              children: [
                // small vertical offset moves the painted arc and text down
                // without changing the parent container size (debug border stays fixed)
                Transform.translate(
                  offset: Offset(0, verticalShift),
                  child: CustomPaint(
                    size: Size(totalWidth, innerH),
                    painter: _HomeStatusPainter(
                      bgSweep: bgSweep,
                      yellowSweep: yellowSweep,
                      strokeWidth: stroke,
                      arcColor: _colorForScore(widget.score),
                    ),
                  ),
                ),
                // Score display: big number top-left, /100 bottom-right
                Transform.translate(
                  offset: Offset(0, verticalShift),
                  child: SizedBox(
                    width: totalWidth * 0.42,
                    height: totalWidth * 0.38,
                    child: Stack(
                      children: [
                        // Big score number — top left
                        Positioned(
                          top: 0,
                          left: 0,
                          child: Text(
                            '${widget.score}',
                            style: const TextStyle(
                              fontSize: 52,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF2D3142),
                              height: 1.0,
                            ),
                          ),
                        ),
                        // / 100 — bottom right
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: Text(
                            '/ 100',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                              color: Colors.grey.shade500,
                              height: 1.0,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );

        if (_kHSVisualDebug) {
          content = Container(
            decoration: BoxDecoration(
              border: Border.all(color: Colors.redAccent, width: 2),
              borderRadius: BorderRadius.circular(4),
            ),
            child: content,
          );
        }

        return content;
      },
    );
  }
}

// paints the item
class _HomeStatusPainter extends CustomPainter {
  final double bgSweep; // radians of white arc (empty)
  final double yellowSweep; // radians of yellow arc (filled)
  final double strokeWidth;
  final Color arcColor;
  _HomeStatusPainter({
    required this.bgSweep,
    required this.yellowSweep,
    this.strokeWidth = 18.0,
    this.arcColor = const Color(0xFFFFC107),
  });

  @override
  void paint(Canvas canvas, Size size) {
    // Draw a circle whose center sits below the canvas so the top half
    // (the semicircle) appears inside the provided size. The diameter
    // is taken from the painter's width (size.width).
    // size.width may be larger than the actual circle diameter because
    // we ask the CustomPaint to be full `totalWidth` to accommodate stroke.
    // Compute center x as the horizontal center and radius from size.width and strokeWidth.
    final double totalW = size.width;
    final double radius = (totalW - strokeWidth) / 2.0;
    if (radius <= 0 || radius.isNaN) return; // defensive: nothing to draw
    final center = Offset(totalW / 2, radius);
    final Rect rect = Rect.fromCircle(center: center, radius: radius);

    // Color used for the unfilled portion of the arc
    const Color unfilledColor = Color(0xFFEFEFEF);
    final Paint background = Paint()
      ..color = unfilledColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    final Paint arcPaint = Paint()
      ..color = arcColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    // draw full background arc for the sweep range (unfilled)
    canvas.drawArc(rect, _kStartAngle, _kSweepArc, false, background);

    // draw filled (yellow) arc proportional to the score
    final double start = _kStartAngle;
    final double yellow = yellowSweep.clamp(0.0, _kSweepArc);
    if (yellow > 0) {
      canvas.drawArc(rect, start, yellow, false, arcPaint);
    }
  }

  @override
  bool shouldRepaint(covariant _HomeStatusPainter oldDelegate) =>
      oldDelegate.bgSweep != bgSweep ||
      oldDelegate.yellowSweep != yellowSweep ||
      oldDelegate.strokeWidth != strokeWidth ||
      oldDelegate.arcColor != arcColor;
}
