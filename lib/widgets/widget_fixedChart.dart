import 'package:flutter/material.dart';
import '../models/settings.dart';

// Toggle this to true for a temporary visual test (remove or set false when done)
const bool _kVisualDebug = false;

class RealTimeChart extends StatefulWidget {
  final String label;
  const RealTimeChart({super.key, required this.label});

  @override
  State<RealTimeChart> createState() => _RealTimeChartState();
}

enum ChartPeriod { week, month, year }

class _RealTimeChartState extends State<RealTimeChart> {
  ChartPeriod _period = ChartPeriod.week;

  // dataset to use for 3 periods
  List<double> get _weekData => [32, 28, 35, 30, 40, 38, 34];
  List<double> get _monthData => [120, 98, 110, 130];
  List<double> get _yearData => [320, 300, 330, 310, 340, 360, 350, 370, 380, 390, 400, 420];

  List<String> get _weekLabels => ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
  List<String> get _monthLabels => ['Wk1', 'Wk2', 'Wk3', 'Wk4'];
  List<String> get _yearLabels => ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];

  String _unitForLabel(String label) {
    final l = label.toLowerCase();
    if (l.contains('electric')) return Settings.instance.energyUnit.split(' ').first;
    if (l.contains('water')) return Settings.instance.waterUnit.split(' ').first;
    return Settings.instance.temperatureUnit.split(' ').first;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return LayoutBuilder(builder: (context, constraints) {
      final double totalH = (constraints.maxHeight.isFinite && constraints.maxHeight > 0) ? constraints.maxHeight : 300.0;

      const double outerPadding = 12.0;
      const double innerVPad = 12.0;
      const double headerH = 36.0;
      const double labelH = 20.0;
      const double spacing = 8.0;
      final double chartH = (totalH - (outerPadding * 2) - innerVPad * 2 - headerH - labelH - spacing * 2).clamp(40.0, 1000.0);

      // choose data/labels by period and select the appropriate lists on _period
      final List<double> data = (_period == ChartPeriod.week) ? _weekData : (_period == ChartPeriod.month ? _monthData : _yearData);
      final List<String> labels = (_period == ChartPeriod.week) ? _weekLabels : (_period == ChartPeriod.month ? _monthLabels : _yearLabels);

      final unitLabel = _unitForLabel(widget.label);

      // debug: log layout and data so we can see why painter might be empty
      debugPrint('RealTimeChart.build: label=${widget.label} period=$_period totalH=$totalH chartH=$chartH width=${constraints.maxWidth} data=${data.toString()} labels=${labels.length} unit=$unitLabel');

      return Padding(
        padding: const EdgeInsets.all(outerPadding),
        child: Container(
          decoration: const BoxDecoration(color: Color(0xFF1EAA83)),
          padding: const EdgeInsets.symmetric(vertical: innerVPad, horizontal: 12),
          child: SizedBox(
            height: totalH - outerPadding * 3,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch, // stretch children to full width
              children: [
                SizedBox(
                  height: headerH,
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(widget.label,
                            style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600, color: Colors.white)),
                      ),
                      DropdownButton<ChartPeriod>(
                        value: _period,
                        underline: const SizedBox.shrink(),
                        dropdownColor: Colors.white,
                        style: const TextStyle(color: Colors.black),
                        iconEnabledColor: Colors.white,
                        items: const [
                          DropdownMenuItem(value: ChartPeriod.week, child: Text('Week')),
                          DropdownMenuItem(value: ChartPeriod.month, child: Text('Month')),
                          DropdownMenuItem(value: ChartPeriod.year, child: Text('Year')),
                        ],
                        onChanged: (v) {
                          if (v == null) return;
                          setState(() => _period = v);
                        },
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: spacing),
                Container(
                  height: chartH,
                  decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
                  padding: const EdgeInsets.all(10),
                  child: Column(
                    children: [
                      Expanded(
                        child: Stack(
                          children: [
                            // Highly visible debug background for quick visual confirmation
                            if (_kVisualDebug)
                              Positioned.fill(
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: Colors.yellowAccent.withOpacity(0.35),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                ),
                              ),
                            // When visual debug is enabled, show a solid red test block
                            if (_kVisualDebug)
                              Positioned.fill(
                                child: Container(
                                  alignment: Alignment.center,
                                  decoration: BoxDecoration(
                                    color: Colors.red.withOpacity(0.85),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: const Text('VISUAL TEST', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
                                ),
                              ),

                            // Always include the painter on top so we can see its output and logs
                            Positioned.fill(
                              child: CustomPaint(
                                painter: _CubicLineChartPainter(data: data, unitLabel: unitLabel),
                              ),
                            ),
                            // on-screen debug overlay so we don't depend only on console
                            Positioned(
                              top: 6,
                              left: 6,
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(color: Colors.white.withOpacity(0.85), borderRadius: BorderRadius.circular(4)),
                                child: Text('pts:${data.length} h:${chartH.toStringAsFixed(0)} w:${constraints.maxWidth.toStringAsFixed(0)}', style: const TextStyle(fontSize: 11, color: Colors.black87)),
                              ),
                            ),
                          ],
                        ),
                      ),

                      // X-axis labels inside the white background
                      SizedBox(
                        height: labelH,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: labels.map((t) => Text(t, style: const TextStyle(fontSize: 12, color: Colors.black87))).toList(),
                        ),
                      ),
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

// draws the cubic line and fills area beneath
class _CubicLineChartPainter extends CustomPainter {
  final List<double> data;
  final String unitLabel;

  _CubicLineChartPainter({required this.data, required this.unitLabel});

  @override
  void paint(Canvas canvas, Size size) {
    if (data.isEmpty) {
      debugPrint('CubicPainter.paint: data empty, returning');
      return;
    }

    final double left = 44.0, right = 8.0, top = 6.0, bottom = 6.0; // left increased for Y labels
    final chartW = size.width - left - right;
    final chartH = size.height - top - bottom;
    if (chartW <= 0 || chartH <= 0) return;

    final double minVal = data.reduce((a, b) => a < b ? a : b);
    final double maxVal = data.reduce((a, b) => a > b ? a : b);
    debugPrint('CubicPainter.paint: size=$size left=$left right=$right top=$top bottom=$bottom chartW=$chartW chartH=$chartH min=$minVal max=$maxVal');
    final double range = (maxVal - minVal) == 0 ? 1.0 : (maxVal - minVal);

    final points = <Offset>[];
    for (int i = 0; i < data.length; i++) {
      final dx = left + (chartW) * (i / (data.length - 1));
      final dy = top + chartH - ((data[i] - minVal) / range) * chartH;
      points.add(Offset(dx, dy));
    }

    // draw Y-axis dotted grid lines and labels
    final gridPaint = Paint()
      ..color = Colors.grey.withOpacity(0.5)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;

    void drawDottedLine(double y) {
      const dashWidth = 6.0;
      const gap = 4.0;
      double startX = left;
      final endX = left + chartW;
      while (startX < endX) {
        final x2 = (startX + dashWidth).clamp(startX, endX);
        canvas.drawLine(Offset(startX, y), Offset(x2, y), gridPaint);
        startX += dashWidth + gap;
      }
    }

    const int gridLines = 4;
    for (int i = 0; i <= gridLines; i++) {
      final double y = top + (chartH) * (i / gridLines);
      drawDottedLine(y);
      final double value = maxVal - (i / gridLines) * range;
      final formatted = (range > 50) ? value.toStringAsFixed(0) : value.toStringAsFixed(1);
      final labelText = '$formatted ${unitLabel}'.trim();
      final tp = TextPainter(
        text: TextSpan(text: labelText, style: const TextStyle(fontSize: 10, color: Colors.black54)),
        textDirection: TextDirection.ltr,
      );
      tp.layout(minWidth: 0, maxWidth: left - 8);
      tp.paint(canvas, Offset(4, y - tp.height / 2));
    }

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

    final Path path = _catmullRomToPath(points); // generate smooth path using function

    // draw a more visible solid border for debugging/visibility
    final borderPaint = Paint()
      ..color = Colors.black.withOpacity(0.7)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;
    canvas.drawRect(Rect.fromLTWH(left, top, chartW, chartH), borderPaint);

    // fill area under smoothed curve
    final Path fillPath = Path.from(path);
    fillPath.lineTo(left + chartW, top + chartH);
    fillPath.lineTo(left, top + chartH);
    fillPath.close();

    canvas.drawPath(fillPath, fillPaint);
    canvas.drawPath(path, linePaint);

    // fallback: draw raw polyline on top to ensure visibility if smoothing misbehaves
    if (points.length >= 2) {
      final Paint rawPaint = Paint()
        ..color = Colors.red.withOpacity(1.0)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3.0;
      final Path raw = Path();
      raw.moveTo(points[0].dx, points[0].dy);
      for (var i = 1; i < points.length; i++) raw.lineTo(points[i].dx, points[i].dy);
      canvas.drawPath(raw, rawPaint);
      final last = points.last;
      canvas.drawCircle(last, 5.0, dotPaint);
    }
  }

  // helper method to convert points to cubic path
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

  bool _listEquals(List<double> a, List<double> b) {
    if (identical(a, b)) return true;
    if (a.length != b.length) return false;
    for (int i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    if (oldDelegate is! _CubicLineChartPainter) return true;
    return !_listEquals(oldDelegate.data, data) || oldDelegate.unitLabel != unitLabel;
  }
}



