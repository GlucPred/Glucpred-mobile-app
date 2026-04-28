import 'package:flutter/material.dart';
import 'package:glucpred/features/records/domain/models/trend_point.dart';

class GlucoseChartWidget extends StatelessWidget {
  final List<TrendPoint> data;
  final int period;

  /// User-configured range thresholds. If not provided, clinical defaults are used.
  final double rangeMin;
  final double rangeMax;
  final double lowCritical;
  final double highCritical;

  const GlucoseChartWidget({
    super.key,
    required this.data,
    required this.period,
    this.rangeMin = 70.0,
    this.rangeMax = 140.0,
    this.lowCritical = 60.0,
    this.highCritical = 180.0,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 250,
      child: CustomPaint(
        painter: _GlucoseChartPainter(
          data,
          period,
          rangeMin: rangeMin,
          rangeMax: rangeMax,
          lowCritical: lowCritical,
          highCritical: highCritical,
        ),
        child: Container(),
      ),
    );
  }
}

class _GlucoseChartPainter extends CustomPainter {
  final List<TrendPoint> data;
  final int period;
  final double rangeMin;
  final double rangeMax;
  final double lowCritical;
  final double highCritical;

  _GlucoseChartPainter(
    this.data,
    this.period, {
    required this.rangeMin,
    required this.rangeMax,
    required this.lowCritical,
    required this.highCritical,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (data.isEmpty) return;

    const chartLeft = 50.0;
    const chartTop = 10.0;
    const chartRight = 10.0;
    const chartBottom = 30.0;
    final chartWidth = size.width - chartLeft - chartRight;
    final chartHeight = size.height - chartTop - chartBottom;

    // Calculate scale first so zone rects align with the data line
    final maxDataValue =
        data.map((p) => p.value).reduce((a, b) => a > b ? a : b);
    final rawMax = maxDataValue > 200 ? maxDataValue * 1.15 : 200.0;
    final scaleMax = (rawMax / 50).ceil() * 50.0;

    double mgdlToY(double mgdl) =>
        chartTop + chartHeight * (1.0 - (mgdl.clamp(0, scaleMax) / scaleMax));

    final bottomY = chartTop + chartHeight;
    final paint = Paint()..style = PaintingStyle.fill;

    // Zone: 0 → lowCritical (critical low, red)
    if (lowCritical > 0) {
      paint.color = const Color(0xFFFFB6C1).withValues(alpha: 0.75);
      canvas.drawRect(
        Rect.fromLTRB(
            chartLeft, mgdlToY(lowCritical), chartLeft + chartWidth, bottomY),
        paint,
      );
    }

    // Zone: lowCritical → rangeMin (caution low, orange/yellow)
    if (rangeMin > lowCritical) {
      paint.color = const Color(0xFFFFD966).withValues(alpha: 0.60);
      canvas.drawRect(
        Rect.fromLTRB(chartLeft, mgdlToY(rangeMin),
            chartLeft + chartWidth, mgdlToY(lowCritical)),
        paint,
      );
    }

    // Zone: rangeMin → rangeMax (normal, green)
    paint.color = const Color(0xFF90EE90).withValues(alpha: 0.55);
    canvas.drawRect(
      Rect.fromLTRB(chartLeft, mgdlToY(rangeMax),
          chartLeft + chartWidth, mgdlToY(rangeMin)),
      paint,
    );

    // Zone: rangeMax → highCritical (caution high, yellow)
    if (highCritical > rangeMax) {
      paint.color = const Color(0xFFFFD966).withValues(alpha: 0.60);
      canvas.drawRect(
        Rect.fromLTRB(chartLeft, mgdlToY(highCritical),
            chartLeft + chartWidth, mgdlToY(rangeMax)),
        paint,
      );
    }

    // Zone: highCritical → scaleMax (critical high, red)
    if (scaleMax > highCritical) {
      paint.color = const Color(0xFFFFB6C1).withValues(alpha: 0.75);
      canvas.drawRect(
        Rect.fromLTRB(chartLeft, mgdlToY(scaleMax),
            chartLeft + chartWidth, mgdlToY(highCritical)),
        paint,
      );
    }

    // Grid lines
    final gridPaint = Paint()
      ..color = const Color(0xFF6C7C93).withValues(alpha: 0.25)
      ..strokeWidth = 0.8
      ..style = PaintingStyle.stroke;

    final gridStep = scaleMax / 4;
    for (int g = 1; g <= 3; g++) {
      final gy = mgdlToY(gridStep * g);
      canvas.drawLine(
          Offset(chartLeft, gy), Offset(chartLeft + chartWidth, gy), gridPaint);
    }

    // Build data points
    final points = <Offset>[];
    if (data.length == 1) {
      points.add(Offset(chartLeft + chartWidth / 2, mgdlToY(data[0].value)));
    } else {
      final spacing = chartWidth / (data.length - 1);
      for (int i = 0; i < data.length; i++) {
        points.add(Offset(chartLeft + spacing * i, mgdlToY(data[i].value)));
      }
    }

    // Data line
    if (points.length >= 2) {
      final linePaint = Paint()
        ..color = const Color(0xFF0073E6)
        ..strokeWidth = 3.0
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round;

      final path = Path()..moveTo(points.first.dx, points.first.dy);
      for (int i = 1; i < points.length; i++) {
        path.lineTo(points[i].dx, points[i].dy);
      }
      canvas.drawPath(path, linePaint);
    }

    // Data point circles
    final dotPaint = Paint()
      ..color = const Color(0xFF0073E6)
      ..style = PaintingStyle.fill;
    final borderPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5;

    for (final pt in points) {
      canvas.drawCircle(pt, 6, borderPaint);
      canvas.drawCircle(pt, 4.5, dotPaint);
    }

    // Value labels for sparse datasets
    if (data.length <= 3) {
      final valuePainter =
          TextPainter(textDirection: TextDirection.ltr, textAlign: TextAlign.center);
      for (int i = 0; i < points.length; i++) {
        valuePainter.text = TextSpan(
          text: '${data[i].value.round()} mg/dl',
          style: const TextStyle(
            color: Color(0xFF0073E6),
            fontSize: 11,
            fontWeight: FontWeight.w700,
          ),
        );
        valuePainter.layout();
        valuePainter.paint(
            canvas, Offset(points[i].dx - valuePainter.width / 2, points[i].dy - 20));
      }
    }

    // Y-axis labels
    final textPainter =
        TextPainter(textDirection: TextDirection.ltr, textAlign: TextAlign.center);
    for (int i = 0; i < 5; i++) {
      final val = scaleMax * (1 - i / 4);
      final yPos = chartTop + chartHeight * (i / 4) - 5;
      textPainter.text = TextSpan(
        text: val.round().toString(),
        style: const TextStyle(
          color: Color(0xFF6C7C93),
          fontSize: 10,
          fontWeight: FontWeight.w500,
        ),
      );
      textPainter.layout();
      textPainter.paint(canvas, Offset(22, yPos));
    }

    // Rotated "mg/dl" label on Y axis
    canvas.save();
    canvas.translate(8, chartTop + chartHeight / 2);
    canvas.rotate(-1.5708);
    textPainter.text = const TextSpan(
      text: 'mg/dl',
      style: TextStyle(color: Color(0xFF6C7C93), fontSize: 10, fontWeight: FontWeight.w600),
    );
    textPainter.layout();
    textPainter.paint(canvas, Offset(-textPainter.width / 2, 0));
    canvas.restore();

    // X-axis time labels
    final xIndices = data.length <= 12
        ? List.generate(data.length, (i) => i)
        : [0, data.length ~/ 2, data.length - 1];

    for (final i in xIndices) {
      textPainter.text = TextSpan(
        text: data[i].time,
        style: const TextStyle(
          color: Color(0xFF6C7C93),
          fontSize: 9,
          fontWeight: FontWeight.w500,
        ),
      );
      textPainter.layout();
      textPainter.paint(
          canvas,
          Offset(points[i].dx - textPainter.width / 2,
              chartTop + chartHeight + 6));
    }
  }

  @override
  bool shouldRepaint(covariant _GlucoseChartPainter old) =>
      old.rangeMin != rangeMin ||
      old.rangeMax != rangeMax ||
      old.lowCritical != lowCritical ||
      old.highCritical != highCritical ||
      old.data != data;
}
