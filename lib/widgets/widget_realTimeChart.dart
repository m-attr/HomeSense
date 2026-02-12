import 'package:flutter/material.dart';

/// Responsive, dependency-free weekly electricity usage chart.
///
/// This implementation measures available space and lays out three
/// fixed-height regions (title, chart area, labels) so it cannot
/// overflow its parent. It uses CustomPainter for drawing.
class RealTimeChart extends StatelessWidget {
  const RealTimeChart({super.key});

  // Sample data: electricity usage per week (kWh)
  List<double> get _weeklyData => [32, 28, 35, 30, 40, 38, 34];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return LayoutBuilder(builder: (context, constraints) {
      // Use the provided max height when available; otherwise fall back to 300.
      final double totalH = (constraints.maxHeight.isFinite && constraints.maxHeight > 0) ? constraints.maxHeight : 300.0;

      // Outer paddings and internal spacings
      const double outerPadding = 12.0;
      const double innerVPad = 12.0;
      const double headerH = 28.0;
      const double labelH = 20.0;
      const double spacing = 8.0;

      // Compute chart height as the remaining space; ensure non-negative.
      final double chartH = (totalH - (outerPadding * 2) - innerVPad * 2 - headerH - labelH - spacing * 2).clamp(40.0, 1000.0);

      return Padding(
        padding: const EdgeInsets.all(outerPadding),
        child: Container(
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
          padding: const EdgeInsets.symmetric(vertical: innerVPad, horizontal: 12),
          child: SizedBox(
            height: totalH - outerPadding * 2,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SizedBox(
                  height: headerH,
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text('Electricity used (kWh) — last 7 days',
                        style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600)),
                  ),
                ),
                const SizedBox(height: spacing),
                SizedBox(
                  height: chartH,
                  child: CustomPaint(
                    painter: _CubicLineChartPainter(data: _weeklyData),
                    size: Size(constraints.maxWidth, chartH),
                  ),
                ),
                const SizedBox(height: spacing),
                SizedBox(
                  height: labelH,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: const [
                      Text('Mon', style: TextStyle(fontSize: 12)),
                      Text('Tue', style: TextStyle(fontSize: 12)),
                      Text('Wed', style: TextStyle(fontSize: 12)),
                      Text('Thu', style: TextStyle(fontSize: 12)),
                      Text('Fri', style: TextStyle(fontSize: 12)),
                      Text('Sat', style: TextStyle(fontSize: 12)),
                      Text('Sun', style: TextStyle(fontSize: 12)),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    });
  }
}

/// Painter that draws a cubic-smoothed curve, fills the area beneath it,
/// and marks the latest point with a dot. Uses a darker green for the line
/// and a translucent lighter fill.
class _CubicLineChartPainter extends CustomPainter {
  final List<double> data;

  _CubicLineChartPainter({required this.data});

  @override
  void paint(Canvas canvas, Size size) {
    if (data.isEmpty) return;

    final double left = 8.0, right = 8.0, top = 6.0, bottom = 6.0;
    final chartW = size.width - left - right;
    final chartH = size.height - top - bottom;
    if (chartW <= 0 || chartH <= 0) return;

    final double minVal = data.reduce((a, b) => a < b ? a : b);
    final double maxVal = data.reduce((a, b) => a > b ? a : b);
    final double range = (maxVal - minVal) == 0 ? 1.0 : (maxVal - minVal);

    // Map data to points
    final points = <Offset>[];
    for (int i = 0; i < data.length; i++) {
      final dx = left + (chartW) * (i / (data.length - 1));
      final dy = top + chartH - ((data[i] - minVal) / range) * chartH;
      points.add(Offset(dx, dy));
    }

    // Colors: dark green line, lighter transparent fill
    const Color lineColor = Color(0xFF0B7A4A); // darker green
    final Color fillColor = lineColor.withOpacity(0.12);

    final Paint fillPaint = Paint()..color = fillColor..style = PaintingStyle.fill;
    final Paint linePaint = Paint()
      ..color = lineColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.0
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
    final Paint dotPaint = Paint()..color = lineColor;

    // Build cubic path using Catmull-Rom to Bezier conversion
    final Path path = _catmullRomToPath(points);

    // Fill path: copy path and close to bottom
    final Path fillPath = Path.from(path);
    fillPath.lineTo(left + chartW, top + chartH);
    fillPath.lineTo(left, top + chartH);
    fillPath.close();

    canvas.drawPath(fillPath, fillPaint);
    canvas.drawPath(path, linePaint);

    // Draw latest point emphasized
    final last = points.last;
    canvas.drawCircle(last, 5.0, dotPaint);
  }

  Path _catmullRomToPath(List<Offset> pts) {
    final Path path = Path();
    if (pts.isEmpty) return path;
    if (pts.length == 1) {
      path.moveTo(pts[0].dx, pts[0].dy);
      return path;
    }

    path.moveTo(pts[0].dx, pts[0].dy);

    for (int i = 0; i < pts.length - 1; i++) {
      final p0 = i - 1 >= 0 ? pts[i - 1] : pts[i];
      final p1 = pts[i];
      final p2 = pts[i + 1];
      final p3 = i + 2 < pts.length ? pts[i + 2] : p2;

      final control1 = Offset(
        p1.dx + (p2.dx - p0.dx) / 6.0,
        p1.dy + (p2.dy - p0.dy) / 6.0,
      );
      final control2 = Offset(
        p2.dx - (p3.dx - p1.dx) / 6.0,
        p2.dy - (p3.dy - p1.dy) / 6.0,
      );

      path.cubicTo(control1.dx, control1.dy, control2.dx, control2.dy, p2.dx, p2.dy);
    }

    return path;
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}


