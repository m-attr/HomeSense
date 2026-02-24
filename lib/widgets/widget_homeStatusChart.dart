import 'package:flutter/material.dart';

// Toggle for temporary visual debugging of chart bounds
const bool _kHSVisualDebug = true;

// animate from 0 to respective score
class HomeStatusChart extends StatefulWidget {
  final int score; // 0..100
  final double width;
  final double height;

  // Reduce default height so the widget occupies only the semicircle area
  const HomeStatusChart({super.key, required this.score, this.width = 240, this.height = 220});
// Toggle for temporary visual debugging of chart bounds

  @override
  State<HomeStatusChart> createState() => _HomeStatusChartState();
}

class _HomeStatusChartState extends State<HomeStatusChart> with TickerProviderStateMixin {
  late final AnimationController _bgController; // white semicircle forming
  Animation<double> _bgAnimation = const AlwaysStoppedAnimation(0.0);

  late final AnimationController _yellowController; // yellow fill
  Animation<double> _yellowAnimation = const AlwaysStoppedAnimation(0.0);

  @override
  void initState() {
    super.initState();
    _bgController = AnimationController(vsync: this, duration: const Duration(milliseconds: 700));
    _bgAnimation = Tween<double>(begin: 0.0, end: 3.14).animate(CurvedAnimation(parent: _bgController, curve: Curves.easeOutCubic))
      ..addListener(() {
        if (mounted) setState(() {});
      });

    _yellowController = AnimationController(vsync: this, duration: const Duration(milliseconds: 900));
    _yellowAnimation = Tween<double>(begin: 0.0, end: 0.0).animate(CurvedAnimation(parent: _yellowController, curve: Curves.easeOutCubic))
      ..addListener(() {
        if (mounted) setState(() {});
      });

    // when bg completes, wait 500ms then start yellow
    _bgController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        Future.delayed(const Duration(milliseconds: 500), () {
          final double targetSweep = (widget.score.clamp(0, 100) / 100.0) * 3.14;
          _yellowAnimation = Tween<double>(begin: 0.0, end: targetSweep)
              .animate(CurvedAnimation(parent: _yellowController, curve: Curves.easeOutCubic))
            ..addListener(() {
              if (mounted) setState(() {});
            });
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

    // Compute semicircle size based on available widget width so the
    // container exactly encloses the semicircle (no empty bottom area).
    final double diameter = width * 0.92; // diameter used for the circle
    const double stroke = 18.0;
    const double pad = 4.0; // small padding below stroke
    final double circleRadius = diameter / 2.0;
    // innerH is the required canvas height so the top half of the circle
    // fits into the box: center at y = circleRadius, so top of circle is y=0.
    final double innerH = circleRadius + stroke / 2 + pad;

    return LayoutBuilder(builder: (context, constraints) {
      if (_kHSVisualDebug) {
        debugPrint('HomeStatusChart.build: score=${widget.score} width=$width heightParam=${widget.height} innerH=$innerH constraints=${constraints.maxWidth}x${constraints.maxHeight}');
      }

      Widget content = SizedBox(
        width: width,
        // allow the Column to size itself to the painted semicircle + score text
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // center the painted semicircle horizontally
            SizedBox(
              width: diameter,
              height: innerH,
              child: CustomPaint(
                painter: _HomeStatusPainter(bgSweep: bgSweep, yellowSweep: yellowSweep),
              ),
            ),
            // small spacer so status text sits directly below the semicircle
            const SizedBox(height: 2),
            // score text centered below the semicircle (visually inside top area earlier)
            Text(
              '${widget.score}',
              style: const TextStyle(fontSize: 36, fontWeight: FontWeight.bold, color: Colors.white),
            ),
          ],
        ),
      );

      if (_kHSVisualDebug) {
        content = Container(
          decoration: BoxDecoration(border: Border.all(color: Colors.redAccent, width: 2), borderRadius: BorderRadius.circular(4)),
          child: content,
        );
      }

      return content;
    });
  }
}


// paints the item
class _HomeStatusPainter extends CustomPainter {
  final double bgSweep; // radians of white arc (empty)
  final double yellowSweep; // radians of yellow arc (filled)
  _HomeStatusPainter({required this.bgSweep, required this.yellowSweep});

  @override
  void paint(Canvas canvas, Size size) {
    // Draw a circle whose center sits below the canvas so the top half
    // (the semicircle) appears inside the provided size. The diameter
    // is taken from the painter's width (size.width).
    final double diameter = size.width;
    final double radius = diameter / 2.0;
    final center = Offset(size.width / 2, radius);
    final Rect rect = Rect.fromCircle(center: center, radius: radius);

    final Paint background = Paint()
      ..color = Colors.grey.withAlpha(31)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 18.0
      ..strokeCap = StrokeCap.round;

    final Paint whitePaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 18.0
      ..strokeCap = StrokeCap.round;

    final Paint arcPaint = Paint()
      ..color = const Color(0xFFFFC107)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 18.0
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(rect, -3.14, 3.14, false, background);

    final double start = -3.14; // left

    final double bg = bgSweep.clamp(0.0, 3.14);
    if (bg > 0) {
      canvas.drawArc(rect, start, bg, false, whitePaint);
    }

    final double yellow = yellowSweep.clamp(0.0, 3.14);
    if (yellow > 0) {
      canvas.drawArc(rect, start, yellow, false, arcPaint);
    }
  }

  @override
  bool shouldRepaint(covariant _HomeStatusPainter oldDelegate) =>
      oldDelegate.bgSweep != bgSweep || oldDelegate.yellowSweep != yellowSweep;
}
