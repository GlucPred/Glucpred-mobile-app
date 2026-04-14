import 'package:flutter/material.dart';
import 'package:glucpred/features/records/domain/models/trend_point.dart';

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
    return SizedBox(
      height: 250,
      child: CustomPaint(
        painter: _GlucoseChartPainter(data, period),
        child: Container(),
      ),
    );
  }
}

class _GlucoseChartPainter extends CustomPainter {
  final List<TrendPoint> data;
  final int period;

  _GlucoseChartPainter(this.data, this.period);

  @override
  void paint(Canvas canvas, Size size) {
    if (data.isEmpty) return;

    // Definir límites de la gráfica (dejar espacio para etiquetas)
    final chartLeft = 50.0; // Espacio para etiquetas del eje Y y "mg/dl"
    final chartTop = 10.0;
    final chartRight = 10.0;
    final chartBottom = 30.0;
    final chartWidth = size.width - chartLeft - chartRight;
    final chartHeight = size.height - chartTop - chartBottom;

    final paint = Paint()..style = PaintingStyle.fill;

    // Bandas de color de fondo (de abajo hacia arriba, similar a la imagen de referencia)
    // Escala: 0-200 mg/dL
    // Hipoglucemia (<70) - Cyan/Azul claro - 0 a 70 (35% inferior del gráfico)
    final hypoglycemiaHeight = chartHeight * 0.35;
    final hypoglycemiaRect = Rect.fromLTWH(
      chartLeft, 
      chartTop + chartHeight - hypoglycemiaHeight, 
      chartWidth, 
      hypoglycemiaHeight
    );
    paint.color = const Color(0xFFADD8E6); // Azul claro brillante
    canvas.drawRect(hypoglycemiaRect, paint);

    // Normal (70-100) - Verde - 70 a 100 (15% del gráfico)
    final normalHeight = chartHeight * 0.15;
    final normalRect = Rect.fromLTWH(
      chartLeft, 
      chartTop + chartHeight - hypoglycemiaHeight - normalHeight, 
      chartWidth, 
      normalHeight
    );
    paint.color = const Color(0xFF90EE90); // Verde claro brillante
    canvas.drawRect(normalRect, paint);

    // Precaución (100-140) - Amarillo - 100 a 140 (20% del gráfico)
    final cautionHeight = chartHeight * 0.20;
    final cautionRect = Rect.fromLTWH(
      chartLeft, 
      chartTop + chartHeight - hypoglycemiaHeight - normalHeight - cautionHeight, 
      chartWidth, 
      cautionHeight
    );
    paint.color = const Color(0xFFFFD966); // Amarillo brillante
    canvas.drawRect(cautionRect, paint);

    // Crítico (>140) - Rosa/Rojo claro - 140 a 200 (30% superior del gráfico)
    final criticalHeight = chartHeight * 0.30;
    final criticalRect = Rect.fromLTWH(
      chartLeft, 
      chartTop, 
      chartWidth, 
      criticalHeight
    );
    paint.color = const Color(0xFFFFB6C1); // Rosa claro
    canvas.drawRect(criticalRect, paint);

    // Escala dinámica: máximo = max(200, maxValor + 20%) redondeado a 50
    final maxDataValue = data.map((p) => p.value).reduce((a, b) => a > b ? a : b);
    final rawMax = maxDataValue > 200 ? maxDataValue * 1.15 : 200.0;
    final scaleMax = (rawMax / 50).ceil() * 50.0;

    // Líneas de referencia horizontales (grid) — dinámicas
    final gridPaint = Paint()
      ..color = const Color(0xFF6C7C93).withValues(alpha: 0.25)
      ..strokeWidth = 0.8
      ..style = PaintingStyle.stroke;

    final gridStep = scaleMax / 4;
    for (int g = 1; g <= 3; g++) {
      final val = gridStep * g;
      final gy = chartTop + chartHeight * (1 - (val / scaleMax));
      canvas.drawLine(Offset(chartLeft, gy), Offset(chartLeft + chartWidth, gy), gridPaint);
    }

    // Escala dinámica: máximo = max(200, maxValor + 20%) redondeado a 50
    final maxDataValue = data.map((p) => p.value).reduce((a, b) => a > b ? a : b);
    final rawMax = maxDataValue > 200 ? maxDataValue * 1.15 : 200.0;
    final scaleMax = (rawMax / 50).ceil() * 50.0;

    // Función para convertir mg/dL a posición Y (escala dinámica)
    double mgdlToY(double mgdl) {
      return chartTop + chartHeight * (1 - (mgdl / scaleMax));
    }

    // Crear puntos del gráfico
    final points = <Offset>[];

    if (data.length == 1) {
      // Un solo punto: centrar horizontalmente
      final x = chartLeft + chartWidth / 2;
      final y = mgdlToY(data[0].value);
      points.add(Offset(x, y));
    } else {
      final pointSpacing = chartWidth / (data.length - 1);
      for (int i = 0; i < data.length; i++) {
        final x = chartLeft + (pointSpacing * i);
        final y = mgdlToY(data[i].value);
        points.add(Offset(x, y));
      }
    }

    // Dibujar línea principal (solo si hay 2+ puntos)
    if (points.length >= 2) {
      final linePaint = Paint()
        ..color = const Color(0xFF0073E6)
        ..strokeWidth = 3.0
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round;

      final path = Path();
      path.moveTo(points.first.dx, points.first.dy);
      for (int i = 1; i < points.length; i++) {
        path.lineTo(points[i].dx, points[i].dy);
      }
      canvas.drawPath(path, linePaint);
    }

    // Dibujar puntos
    final pointPaint = Paint()
      ..color = const Color(0xFF0073E6)
      ..style = PaintingStyle.fill;

    final whiteBorderPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5;

    for (var point in points) {
      canvas.drawCircle(point, 6, whiteBorderPaint);
      canvas.drawCircle(point, 4.5, pointPaint);
    }

    // Etiqueta de valor sobre el punto (para 1-3 puntos)
    if (data.length <= 3) {
      final valuePainter = TextPainter(
        textDirection: TextDirection.ltr,
        textAlign: TextAlign.center,
      );
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
          canvas,
          Offset(points[i].dx - valuePainter.width / 2, points[i].dy - 20),
        );
      }
    }

    // Etiquetas del eje Y dinámicas
    final textPainter = TextPainter(
      textDirection: TextDirection.ltr,
      textAlign: TextAlign.center,
    );
    final yLabelCount = 5;
    for (int i = 0; i < yLabelCount; i++) {
      final val = scaleMax * (1 - i / (yLabelCount - 1));
      final yPos = chartTop + chartHeight * (i / (yLabelCount - 1)) - 5;
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
    
    // Etiqueta "mg/dl" en el eje Y (rotada, a la izquierda de los números)
    canvas.save();
    final labelYPos = chartTop + (chartHeight / 2);
    canvas.translate(8, labelYPos); // Más a la izquierda
    canvas.rotate(-1.5708); // -90 grados en radianes
    
    textPainter.text = const TextSpan(
      text: 'mg/dl',
      style: TextStyle(
        color: Color(0xFF6C7C93), 
        fontSize: 10, 
        fontWeight: FontWeight.w600,
      ),
    );
    textPainter.layout();
    textPainter.paint(canvas, Offset(-textPainter.width / 2, 0));
    canvas.restore();

    // Etiquetas del eje X (hora de cada punto)
    if (data.length <= 12) {
      for (int i = 0; i < points.length; i++) {
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
          Offset(points[i].dx - textPainter.width / 2, chartTop + chartHeight + 6),
        );
      }
    } else {
      // Demasiados puntos: mostrar solo primer, medio y último
      final indices = [0, data.length ~/ 2, data.length - 1];
      for (final i in indices) {
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
          Offset(points[i].dx - textPainter.width / 2, chartTop + chartHeight + 6),
        );
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
