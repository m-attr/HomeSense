import 'package:flutter/material.dart';

// Reusable home status doughnut chart widget with animation.
// Usage: `HomeStatusChart(score: 71)` — animates from 0 to score.
class HomeStatusChart extends StatefulWidget {
  final int score; // 0..100
  final double width;
  final double height;

  const HomeStatusChart({super.key, required this.score, this.width = 240, this.height = 170});

  @override
  State<HomeStatusChart> createState() => _HomeStatusChartState();
}

class _HomeStatusChartState extends State<HomeStatusChart> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    // animate over 900ms
    _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 900));
    final curved = CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic);

    // target sweep is proportional to score (0..100) across the semicircle (pi radians)
    final double targetSweep = (widget.score.clamp(0, 100) / 100.0) * 3.14;
    _animation = Tween<double>(begin: 0.0, end: targetSweep).animate(curved)
      ..addListener(() {
        if (mounted) setState(() {});
      });

    // start animation after build
    WidgetsBinding.instance.addPostFrameCallback((_) => _controller.forward());
  }

  @override
  void didUpdateWidget(covariant HomeStatusChart oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.score != widget.score) {
      final double newTarget = (widget.score.clamp(0, 100) / 100.0) * 3.14;
      _animation = Tween<double>(begin: 0.0, end: newTarget).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic));
      _controller
        ..reset()
        ..forward();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final double width = widget.width;
    final double height = widget.height;
    final double currentSweep = _animation.value;

    return SizedBox(
      width: width,
      height: height,
      child: Stack(
        alignment: Alignment.center,
        children: [
          SizedBox(
            width: width * 0.92,
            height: height * 0.88,
            child: CustomPaint(
              painter: _HomeStatusPainter(sweep: currentSweep),
            ),
          ),
          // score text
          Text(
            '${widget.score}',
            style: const TextStyle(fontSize: 48, fontWeight: FontWeight.bold, color: Colors.white),
          ),
        ],
      ),
    );
  }
}

class _HomeStatusPainter extends CustomPainter {
  final double sweep; // radians of yellow arc
  _HomeStatusPainter({required this.sweep});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.height * 0.9) / 2;

    final Rect rect = Rect.fromCircle(center: center, radius: radius);

    final Paint background = Paint()
      ..color = Colors.grey.withOpacity(0.12)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 18.0
      ..strokeCap = StrokeCap.round;

    final Paint arcPaint = Paint()
      ..color = const Color(0xFFFFC107)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 18.0
      ..strokeCap = StrokeCap.round;

    // Draw a light background (partial semicircle)
    canvas.drawArc(rect, -3.14, 3.14, false, background);

    // Draw the animated amber arc from the left up to current sweep
    final double start = -3.14; // left
    final double current = sweep.clamp(0.0, 3.14);
    if (current > 0) {
      canvas.drawArc(rect, start, current, false, arcPaint);
    }

    // Cover the remaining gap with a white stroke so the header doesn't show through
    final double gapStart = start + current;
    final double gapSweep = 3.14 - current; // remaining arc of the semicircle
    if (gapSweep > 0.001) {
      final Paint gapCover = Paint()
        ..color = Colors.white
        ..style = PaintingStyle.stroke
        ..strokeWidth = 20.0
        ..strokeCap = StrokeCap.round;
      canvas.drawArc(rect, gapStart, gapSweep, false, gapCover);

      // Draw a subtle border around the white gap to make the edge visible
      final Paint gapBorder = Paint()
        ..color = Colors.grey.withOpacity(0.5)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.0
        ..strokeCap = StrokeCap.round;
      canvas.drawArc(rect, gapStart, gapSweep, false, gapBorder);
    }
  }

  @override
  bool shouldRepaint(covariant _HomeStatusPainter oldDelegate) => oldDelegate.sweep != sweep;
}
