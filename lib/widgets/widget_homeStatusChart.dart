import 'package:flutter/material.dart';

// Reusable home status doughnut chart widget.
// Usage: `HomeStatusChart(score: 71)`
class HomeStatusChart extends StatelessWidget {
  final int score;
  final double width;
  final double height;

  const HomeStatusChart({super.key, required this.score, this.width = 240, this.height = 170});

  @override
  Widget build(BuildContext context) {
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
              painter: _HomeStatusPainter(),
            ),
          ),
          // score text
          Text(
            '$score',
            style: const TextStyle(fontSize: 48, fontWeight: FontWeight.bold, color: Colors.white),
          ),
        ],
      ),
    );
  }
}

class _HomeStatusPainter extends CustomPainter {
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

    // Draw the accent arc (omit bottom segment by limiting sweep)
    final double start = -3.14; // start at left
    final double sweep = 2.6; // less than pi to leave bottom gap
    canvas.drawArc(rect, start, sweep, false, arcPaint);

    // Cover the remaining gap with a white stroke so the header doesn't show through
    final double gapStart = start + sweep;
    final double gapSweep = 3.14 - sweep; // remaining arc of the semicircle
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

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
