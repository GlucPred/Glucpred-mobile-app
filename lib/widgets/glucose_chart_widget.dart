import 'package:flutter/material.dart';
import '../models/trend_point.dart';

class GlucoseChartWidget extends StatelessWidget {
  final List<TrendPoint> data;
  final int period; // 0: Hoy, 1: Semana, 2: Mes

  const GlucoseChartWidget({
    super.key,
    required this.data,
    required this.period,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          height: 250,
          child: CustomPaint(
            size: Size.infinite,
            painter: _GlucoseChartPainter(data),
          ),
        ),
        const SizedBox(height: 12),
        _buildTimeLabels(),
      ],
    );
  }

  Widget _buildTimeLabels() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: data.map((point) {
          return Text(
            point.time,
            style: TextStyle(
              fontSize: 12,
              color: const Color(0xFF6C7C93),
            ),
          );
        }).toList(),
      ),
    );
  }
}

class _GlucoseChartPainter extends CustomPainter {
  final List<TrendPoint> data;

  _GlucoseChartPainter(this.data);

  @override
  void paint(Canvas canvas, Size size) {
    if (data.isEmpty) return;

    // Definir rangos de glucosa
    const double chartMinValue = 40.0;
    const double chartMaxValue = 200.0;
    const double range = chartMaxValue - chartMinValue;

    // Función para convertir valor de glucosa a coordenada Y
    double valueToY(double value) {
      final normalized = (value - chartMinValue) / range;
      return size.height - (normalized * size.height);
    }

    // Dibujar áreas de fondo con los colores de la paleta
    _drawBackgroundZones(canvas, size, valueToY);

    // Crear puntos del gráfico
    final points = <Offset>[];
    for (int i = 0; i < data.length; i++) {
      final x = (i / (data.length - 1)) * size.width;
      final y = valueToY(data[i].value);
      points.add(Offset(x, y));
    }

    // Dibujar área bajo la línea
    _drawAreaUnderLine(canvas, size, points, valueToY);

    // Dibujar línea principal
    final linePaint = Paint()
      ..color = const Color(0xFF0073E6)
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final path = Path();
    if (points.isNotEmpty) {
      path.moveTo(points.first.dx, points.first.dy);
      for (int i = 1; i < points.length; i++) {
        path.lineTo(points[i].dx, points[i].dy);
      }
    }
    canvas.drawPath(path, linePaint);

    // Dibujar puntos
    final pointPaint = Paint()
      ..color = const Color(0xFF0073E6)
      ..style = PaintingStyle.fill;

    final pointBorderPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill
      ..strokeWidth = 2;

    for (final point in points) {
      canvas.drawCircle(point, 6, pointPaint);
      canvas.drawCircle(point, 3.5, pointBorderPaint);
    }

    // Dibujar líneas de cuadrícula
    _drawGrid(canvas, size, valueToY);
  }

  void _drawGrid(Canvas canvas, Size size, double Function(double) valueToY) {
    final gridPaint = Paint()
      ..color = const Color(0xFFE0E6EB).withOpacity(0.5)
      ..strokeWidth = 1
      ..style = PaintingStyle.stroke;

    // Líneas horizontales cada 50 mg/dl
    for (double value = 50; value <= 200; value += 50) {
      final y = valueToY(value);
      canvas.drawLine(Offset(0, y), Offset(size.width, y), gridPaint);
      
      // Dibujar etiquetas de valor
      if (value % 50 == 0) {
        final textPainter = TextPainter(
          text: TextSpan(
            text: '${value.toInt()}',
            style: const TextStyle(
              color: Color(0xFF6C7C93),
              fontSize: 11,
            ),
          ),
          textDirection: TextDirection.ltr,
        );
        textPainter.layout();
        textPainter.paint(canvas, Offset(-35, y - 8));
      }
    }
  }

  void _drawBackgroundZones(
    Canvas canvas,
    Size size,
    double Function(double) valueToY,
  ) {
    // Zona Crítica (>140) - Rojo #C72331
    final criticalPaint = Paint()
      ..color = const Color(0xFFC72331).withOpacity(0.25)
      ..style = PaintingStyle.fill;
    
    final criticalY = valueToY(140.0);
    canvas.drawRect(
      Rect.fromLTWH(0, 0, size.width, criticalY),
      criticalPaint,
    );

    // Zona Prealerta (100-140) - Amarillo #FBC318
    final prealertPaint = Paint()
      ..color = const Color(0xFFFBC318).withOpacity(0.25)
      ..style = PaintingStyle.fill;
    
    final prealertTopY = valueToY(140.0);
    final prealertBottomY = valueToY(100.0);
    canvas.drawRect(
      Rect.fromLTWH(0, prealertTopY, size.width, prealertBottomY - prealertTopY),
      prealertPaint,
    );

    // Zona Normal (70-100) - Verde #337536
    final normalPaint = Paint()
      ..color = const Color(0xFF337536).withOpacity(0.25)
      ..style = PaintingStyle.fill;
    
    final normalTopY = valueToY(100.0);
    final normalBottomY = valueToY(70.0);
    canvas.drawRect(
      Rect.fromLTWH(0, normalTopY, size.width, normalBottomY - normalTopY),
      normalPaint,
    );

    // Zona Hipoglucemia (<70) - Rojo #C72331
    final hypoPaint = Paint()
      ..color = const Color(0xFFC72331).withOpacity(0.25)
      ..style = PaintingStyle.fill;
    
    final hypoY = valueToY(70.0);
    canvas.drawRect(
      Rect.fromLTWH(0, hypoY, size.width, size.height - hypoY),
      hypoPaint,
    );
  }

  void _drawAreaUnderLine(
    Canvas canvas,
    Size size,
    List<Offset> points,
    double Function(double) valueToY,
  ) {
    if (points.isEmpty) return;

    final areaPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          const Color(0xFF0073E6).withOpacity(0.3),
          const Color(0xFF0073E6).withOpacity(0.05),
        ],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height))
      ..style = PaintingStyle.fill;

    final areaPath = Path();
    areaPath.moveTo(points.first.dx, size.height);
    areaPath.lineTo(points.first.dx, points.first.dy);
    
    for (final point in points) {
      areaPath.lineTo(point.dx, point.dy);
    }
    
    areaPath.lineTo(points.last.dx, size.height);
    areaPath.close();
    
    canvas.drawPath(areaPath, areaPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
