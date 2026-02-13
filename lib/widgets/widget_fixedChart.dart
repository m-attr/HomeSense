import 'package:flutter/material.dart';

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
  List<String> get _yearLabels => ['Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec'];

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

      return Padding(
        padding: const EdgeInsets.all(outerPadding),
        child: Container(
          decoration: const BoxDecoration(color: Color(0xFF1EAA83)),
          padding: const EdgeInsets.symmetric(vertical: innerVPad, horizontal: 12),
          child: SizedBox(
            height: totalH - outerPadding * 2,
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

                // Rounded white chart container (the white border requested)
                Container(
                  height: chartH,
                  decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
                  padding: const EdgeInsets.all(10),
                  child: CustomPaint(
                    painter: _CubicLineChartPainter(data: data),
                    size: Size(constraints.maxWidth, chartH),
                  ),
                ),
                const SizedBox(height: spacing),

                // Labels row (adapt to number of labels)
                SizedBox(
                  height: labelH,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: labels.map((t) => Text(t, style: const TextStyle(fontSize: 12, color: Colors.white))).toList(),
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

  _CubicLineChartPainter({required this.data});

  @override
  void paint(Canvas canvas, Size size) {
    if (data.isEmpty) return;

    final double left = 8.0, right = 8.0, top = 6.0, bottom = 6.0; // margins
    final chartW = size.width - left - right;
    final chartH = size.height - top - bottom;
    if (chartW <= 0 || chartH <= 0) return;

    final double minVal = data.reduce((a, b) => a < b ? a : b);
    final double maxVal = data.reduce((a, b) => a > b ? a : b);
    final double range = (maxVal - minVal) == 0 ? 1.0 : (maxVal - minVal);

    final points = <Offset>[];
    for (int i = 0; i < data.length; i++) {
      final dx = left + (chartW) * (i / (data.length - 1));
      final dy = top + chartH - ((data[i] - minVal) / range) * chartH;
      points.add(Offset(dx, dy));
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

    final Path path = _catmullRomToPath(points); // generate smooth path using funciton 

    // fill area under curve after closing the bottom
    final Path fillPath = Path.from(path);
    fillPath.lineTo(left + chartW, top + chartH);
    fillPath.lineTo(left, top + chartH);
    fillPath.close();

    canvas.drawPath(fillPath, fillPaint);
    canvas.drawPath(path, linePaint);

    final last = points.last;
    canvas.drawCircle(last, 5.0, dotPaint);
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

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false; // no data, no repa
}


