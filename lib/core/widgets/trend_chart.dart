import 'package:flutter/material.dart';
import 'package:glucpred/features/records/domain/models/trend_point.dart';

class TrendChart extends StatelessWidget {
  final List<TrendPoint> data;

  const TrendChart({
    super.key,
    required this.data,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
          Row(
            children: [
              Icon(
                Icons.show_chart,
                color: const Color(0xFF0073E6), // Azul de la paleta
                size: 28,
              ),
              const SizedBox(width: 12),
              Text(
                'Tendencia (12 horas)',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: isDark ? Colors.white : const Color(0xFF000000),
                ),
              ),
              const Spacer(),
              Icon(
                Icons.access_time,
                color: const Color(0xFF0073E6), // Azul de la paleta
                size: 24,
              ),
            ],
          ),
            const SizedBox(height: 24),
            SizedBox(
              height: 150,
              child: CustomPaint(
                size: Size.infinite,
                painter: _ChartPainter(data),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ChartPainter extends CustomPainter {
  final List<TrendPoint> data;

  _ChartPainter(this.data);

  @override
  void paint(Canvas canvas, Size size) {
    if (data.isEmpty) return;

    final paint = Paint()
      ..color = const Color(0xFF0073E6) // Azul de la paleta
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final fillPaint = Paint()
      ..color = const Color(0xFF0073E6).withOpacity(0.1) // Azul de la paleta
      ..style = PaintingStyle.fill;

    final pointPaint = Paint()
      ..color = const Color(0xFF0073E6) // Azul de la paleta
      ..style = PaintingStyle.fill;

    // Encontrar valores min y max para escalar
    final minValue = data.map((p) => p.value).reduce((a, b) => a < b ? a : b);
    final maxValue = data.map((p) => p.value).reduce((a, b) => a > b ? a : b);
    final range = maxValue - minValue;

    // Crear puntos
    final points = <Offset>[];
    for (int i = 0; i < data.length; i++) {
      final x = (i / (data.length - 1)) * size.width;
      final normalizedValue = (data[i].value - minValue) / (range == 0 ? 1 : range);
      final y = size.height - (normalizedValue * size.height);
      points.add(Offset(x, y));
    }

    // Dibujar área bajo la línea
    final fillPath = Path();
    fillPath.moveTo(points.first.dx, size.height);
    for (final point in points) {
      fillPath.lineTo(point.dx, point.dy);
    }
    fillPath.lineTo(points.last.dx, size.height);
    fillPath.close();
    canvas.drawPath(fillPath, fillPaint);

    // Dibujar línea
    final path = Path();
    path.moveTo(points.first.dx, points.first.dy);
    for (int i = 1; i < points.length; i++) {
      path.lineTo(points[i].dx, points[i].dy);
    }
    canvas.drawPath(path, paint);

    // Dibujar puntos
    for (final point in points) {
      canvas.drawCircle(point, 5, pointPaint);
      canvas.drawCircle(point, 3, Paint()..color = Colors.white);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
