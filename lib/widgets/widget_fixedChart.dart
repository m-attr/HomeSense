import 'package:flutter/material.dart';
import '../models/settings.dart';

// Toggle for visual debug aids
const bool _kVisualDebug = false;

class RealTimeChart extends StatefulWidget {
  final String label;
  final List<double>? weekData;
  final List<double>? monthData;
  final List<double>? yearData;
  final List<String>? weekLabels;
  final List<String>? monthLabels;
  final List<String>? yearLabels;
  final bool showPeriodSelector;

  const RealTimeChart({
    super.key,
    required this.label,
    this.weekData,
    this.monthData,
    this.yearData,
    this.weekLabels,
    this.monthLabels,
    this.yearLabels,
    this.showPeriodSelector = true,
  });

  @override
  State<RealTimeChart> createState() => _RealTimeChartState();
}

enum ChartPeriod { week, month, year }

class _RealTimeChartState extends State<RealTimeChart>
    with TickerProviderStateMixin {
  ChartPeriod _period = ChartPeriod.week;

  // Animation state — initialised to safe defaults; real values set in initState
  AnimationController? _morphCtrl;
  Animation<double>? _morphAnim;
  List<double> _oldData = [];
  List<double> _newData = [];

  // Reveal animation — draws the curve from left to right
  AnimationController? _revealCtrl;
  Animation<double>? _revealAnim;
  bool _firstBuild = true;

  List<double> get _weekData => widget.weekData ?? [30, 36, 36, 36, 36, 36, 38];
  List<double> get _monthData =>
      widget.monthData ?? [115, 124, 124, 124, 124, 126];
  List<double> get _yearData =>
      widget.yearData ??
      [300, 325, 325, 325, 325, 325, 325, 330, 332, 335, 338, 340];

  List<String> get _weekLabels =>
      widget.weekLabels ?? ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
  List<String> get _monthLabels =>
      widget.monthLabels ?? ['Wk1', 'Wk2', 'Wk3', 'Wk4'];
  List<String> get _yearLabels =>
      widget.yearLabels ??
      [
        'Jan',
        'Feb',
        'Mar',
        'Apr',
        'May',
        'Jun',
        'Jul',
        'Aug',
        'Sep',
        'Oct',
        'Nov',
        'Dec',
      ];

  @override
  void initState() {
    super.initState();
    _morphCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _morphAnim = CurvedAnimation(parent: _morphCtrl!, curve: Curves.easeInOut);
    _oldData = _dataForPeriod(_period);
    _newData = _oldData;

    _revealCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    );
    _revealAnim = CurvedAnimation(
      parent: _revealCtrl!,
      curve: Curves.easeInOutCubic,
    );
    _revealCtrl!.forward();
  }

  @override
  void didUpdateWidget(covariant RealTimeChart oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.label != widget.label) {
      // Re-trigger reveal animation when quality changes
      _period = ChartPeriod.week;
      _oldData = _dataForPeriod(_period);
      _newData = _oldData;
      _revealCtrl?.forward(from: 0.0);
    }
  }

  @override
  void dispose() {
    _morphCtrl?.dispose();
    _revealCtrl?.dispose();
    super.dispose();
  }

  List<double> _dataForPeriod(ChartPeriod p) {
    switch (p) {
      case ChartPeriod.week:
        return _weekData;
      case ChartPeriod.month:
        return _monthData;
      case ChartPeriod.year:
        return _yearData;
    }
  }

  void _switchPeriod(ChartPeriod next) {
    if (next == _period) return;
    setState(() {
      _oldData = _newData; // snapshot the current target
      _newData = _dataForPeriod(next);
      _period = next;
      _morphCtrl?.forward(from: 0.0);
      _revealCtrl?.forward(from: 0.0);
    });
  }

  String _unitForLabel(String label) {
    final l = label.toLowerCase();
    if (l.contains('electric')) {
      return Settings.instance.energyUnit.split(' ').first;
    }
    if (l.contains('water')) {
      return Settings.instance.waterUnit.split(' ').first;
    }
    return Settings.instance.temperatureUnit.split(' ').first;
  }

  @override
  Widget build(BuildContext context) {
    // Initialise data on first build (can't call setState in initState safely
    // with LayoutBuilder, so we do it here once).
    if (_firstBuild) {
      _firstBuild = false;
      _oldData = _dataForPeriod(_period);
      _newData = _oldData;
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final double totalH =
            (constraints.maxHeight.isFinite && constraints.maxHeight > 0)
            ? constraints.maxHeight
            : 420.0;

        const double outerPadding = 12.0;
        const double headerH = 36.0;
        const double labelH = 24.0;
        const double spacing = 8.0;
        final double chartH =
            (totalH - (outerPadding * 2) - headerH - labelH - spacing).clamp(
              80.0,
              2000.0,
            );

        final List<String> labels = (_period == ChartPeriod.week)
            ? _weekLabels
            : (_period == ChartPeriod.month ? _monthLabels : _yearLabels);
        final unitLabel = _unitForLabel(widget.label);

        debugPrint(
          'RealTimeChart.build: label=${widget.label} period=$_period '
          'totalH=$totalH chartH=$chartH width=${constraints.maxWidth} '
          'labels=${labels.length} unit=$unitLabel',
        );

        return Padding(
          padding: const EdgeInsets.all(outerPadding),
          child: Container(
            color: Colors.white,
            child: SizedBox(
              height: totalH - outerPadding * 2,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  if (widget.showPeriodSelector)
                    Container(
                      height: headerH,
                      color: Colors.white,
                      child: Row(
                        children: [
                          const Expanded(child: SizedBox.shrink()),
                          Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8.0,
                            ),
                            child: Container(
                              padding: const EdgeInsets.all(3.0),
                              decoration: BoxDecoration(
                                color: Colors.grey.shade100,
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  _periodRadio(ChartPeriod.week, 'Week'),
                                  const SizedBox(width: 2),
                                  _periodRadio(ChartPeriod.month, 'Month'),
                                  const SizedBox(width: 2),
                                  _periodRadio(ChartPeriod.year, 'Year'),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    )
                  else
                    SizedBox(height: headerH),
                  const SizedBox(height: spacing),
                  SizedBox(
                    height: chartH,
                    child: Stack(
                      children: [
                        if (_kVisualDebug)
                          Positioned.fill(
                            child: Container(
                              color: Colors.yellowAccent.withAlpha(
                                (0.35 * 255).round(),
                              ),
                            ),
                          ),
                        Positioned.fill(
                          child: AnimatedBuilder(
                            animation: Listenable.merge([
                              _morphAnim ?? const AlwaysStoppedAnimation(1.0),
                              _revealAnim ?? const AlwaysStoppedAnimation(1.0),
                            ]),
                            builder: (context, _) {
                              // Left offset = Y-axis labels area so they stay visible
                              final chartAreaW =
                                  constraints.maxWidth - 24.0; // outerPadding*2
                              const leftPad = 8.0;
                              final pointPad = (chartAreaW * 0.06).clamp(
                                8.0,
                                24.0,
                              );
                              final leftOffset =
                                  12.0 +
                                  leftPad +
                                  pointPad; // outerPadding + left + pointPad
                              return ClipRect(
                                clipper: _RevealClipper(
                                  _revealAnim?.value ?? 1.0,
                                  leftOffset: leftOffset,
                                ),
                                child: CustomPaint(
                                  painter: _CubicLineChartPainter(
                                    oldData: _oldData,
                                    newData: _newData,
                                    t: _morphAnim?.value ?? 1.0,
                                    unitLabel: unitLabel,
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: labelH),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _periodRadio(ChartPeriod p, String label) {
    final bool isActive = _period == p;
    const Color green = Color(0xFF1EAA83);
    return GestureDetector(
      onTap: () => _switchPeriod(p),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeInOut,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        decoration: BoxDecoration(
          color: isActive ? green : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
            color: isActive ? Colors.white : Colors.grey.shade600,
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Painter – morphs between old and new data using linear interpolation
// ---------------------------------------------------------------------------
class _CubicLineChartPainter extends CustomPainter {
  final List<double> oldData;
  final List<double> newData;
  final double t; // 0 = show oldData, 1 = show newData
  final String unitLabel;

  _CubicLineChartPainter({
    required this.oldData,
    required this.newData,
    required this.t,
    required this.unitLabel,
  });

  /// Resample [src] to [count] points using linear interpolation so that
  /// datasets of different lengths can be morphed smoothly.
  static List<double> _resample(List<double> src, int count) {
    if (src.isEmpty) return List.filled(count, 0);
    if (src.length == count) return List.of(src);
    final out = <double>[];
    for (int i = 0; i < count; i++) {
      final double pos = i / (count - 1) * (src.length - 1);
      final int lo = pos.floor().clamp(0, src.length - 1);
      final int hi = pos.ceil().clamp(0, src.length - 1);
      final frac = pos - lo;
      out.add(src[lo] + (src[hi] - src[lo]) * frac);
    }
    return out;
  }

  @override
  void paint(Canvas canvas, Size size) {
    if (newData.isEmpty && oldData.isEmpty) return;

    // Use the larger count so we have enough points for a smooth morph
    final int morphCount = oldData.length > newData.length
        ? oldData.length
        : newData.length;
    final sampledOld = _resample(oldData, morphCount);
    final sampledNew = _resample(newData, morphCount);

    // Lerp each value
    final List<double> data = List.generate(
      morphCount,
      (i) => sampledOld[i] + (sampledNew[i] - sampledOld[i]) * t,
    );

    const double left = 8.0, right = 8.0, top = 6.0, bottom = 6.0;
    final chartW = size.width - left - right;
    final chartH = size.height - top - bottom;
    if (chartW <= 0 || chartH <= 0) return;

    final double minVal = data.reduce((a, b) => a < b ? a : b);
    final double maxVal = data.reduce((a, b) => a > b ? a : b);
    final double range = (maxVal - minVal) == 0 ? 1.0 : (maxVal - minVal);

    // Y-axis grid labels
    const int gridLines = 4;
    final double pointPad = (chartW * 0.06).clamp(8.0, 24.0);
    final double startX = left + pointPad;
    final double endX = left + chartW - pointPad;

    for (int i = 0; i <= gridLines; i++) {
      final double y = top + chartH * (i / gridLines);
      final double value = maxVal - (i / gridLines) * range;
      final tp = TextPainter(
        text: TextSpan(
          text: value.toStringAsFixed(0),
          style: const TextStyle(
            fontSize: 10,
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
        textDirection: TextDirection.ltr,
      );
      tp.layout(minWidth: 0, maxWidth: 64);
      tp.paint(canvas, Offset(4, y - tp.height / 2));
    }

    // Build points with virtual endpoints, shifted one x-step forward
    final points = <Offset>[];
    final double rawStep = (endX - startX) / (data.length - 1);
    final double startX2 = startX + rawStep;
    final double endX2 = endX - rawStep;
    final double fullRange = (endX2 - startX2) + 2 * rawStep;
    final int slots = data.length + 1;
    final double step = fullRange / slots;
    final double firstX = startX2 - rawStep;

    for (int i = 0; i < data.length + 2; i++) {
      final dx = firstX + step * i;
      final double value;
      if (i == 0) {
        // Left virtual point raised 30 % of the range
        value = (data.first + (maxVal - minVal) * 0.30).clamp(minVal, maxVal);
      } else if (i == data.length + 1) {
        value = data.last;
      } else {
        value = data[i - 1];
      }
      final dy = top + chartH - ((value - minVal) / range) * chartH;
      points.add(Offset(dx, dy));
    }

    // Colours & paints
    const Color lineColor = Color(0xFF0B7A4A);
    final fillColor = lineColor.withAlpha((0.12 * 255).round());

    final fillPaint = Paint()
      ..color = fillColor
      ..style = PaintingStyle.fill;
    final linePaint = Paint()
      ..color = lineColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.0
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final path = _catmullRomToPath(points);

    // Fill under curve
    final fillPath = Path.from(path)
      ..lineTo(endX, top + chartH)
      ..lineTo(startX, top + chartH)
      ..close();
    canvas.drawPath(fillPath, fillPaint);
    canvas.drawPath(path, linePaint);

    // X-axis line
    final axisPaint = Paint()
      ..color = Colors.grey.withAlpha((0.65 * 255).round())
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.4;
    canvas.drawLine(
      Offset(startX2, top + chartH),
      Offset(endX2, top + chartH),
      axisPaint,
    );

    // Optional debug markers
    if (_kVisualDebug && points.length >= 2) {
      canvas.drawCircle(
        points[0],
        6.0,
        Paint()
          ..color = Colors.red
          ..style = PaintingStyle.fill,
      );
      canvas.drawCircle(
        points[1],
        4.0,
        Paint()
          ..color = Colors.blue
          ..style = PaintingStyle.fill,
      );
    }
  }

  // Catmull-Rom → cubic-Bézier conversion
  Path _catmullRomToPath(List<Offset> pts) {
    final path = Path();
    if (pts.isEmpty) return path;
    if (pts.length == 1) {
      path.moveTo(pts[0].dx, pts[0].dy);
      return path;
    }
    path.moveTo(pts[0].dx, pts[0].dy);
    for (int i = 0; i < pts.length - 1; i++) {
      final p0 = i > 0 ? pts[i - 1] : pts[i];
      final p1 = pts[i];
      final p2 = pts[i + 1];
      final p3 = i + 2 < pts.length ? pts[i + 2] : p2;
      final c1 = Offset(
        p1.dx + (p2.dx - p0.dx) / 6.0,
        p1.dy + (p2.dy - p0.dy) / 6.0,
      );
      final c2 = Offset(
        p2.dx - (p3.dx - p1.dx) / 6.0,
        p2.dy - (p3.dy - p1.dy) / 6.0,
      );
      path.cubicTo(c1.dx, c1.dy, c2.dx, c2.dy, p2.dx, p2.dy);
    }
    return path;
  }

  @override
  bool shouldRepaint(covariant _CubicLineChartPainter oldDelegate) {
    return oldDelegate.t != t ||
        oldDelegate.unitLabel != unitLabel ||
        !identical(oldDelegate.oldData, oldData) ||
        !identical(oldDelegate.newData, newData);
  }
}

// ---------------------------------------------------------------------------
// Clipper — progressively reveals the chart from left to right
// ---------------------------------------------------------------------------
class _RevealClipper extends CustomClipper<Rect> {
  final double revealFraction;
  final double leftOffset;
  _RevealClipper(this.revealFraction, {this.leftOffset = 0.0});

  @override
  Rect getClip(Size size) {
    // Y-axis labels (0 → leftOffset) are always visible.
    // The curve area (leftOffset → width) reveals progressively.
    final double revealWidth =
        leftOffset + (size.width - leftOffset) * revealFraction;
    return Rect.fromLTWH(0, 0, revealWidth, size.height);
  }

  @override
  bool shouldReclip(covariant _RevealClipper oldClipper) {
    return oldClipper.revealFraction != revealFraction ||
        oldClipper.leftOffset != leftOffset;
  }
}
