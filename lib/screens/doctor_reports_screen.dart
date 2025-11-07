import 'package:flutter/material.dart';

class DoctorReportsScreen extends StatefulWidget {
  const DoctorReportsScreen({super.key});

  @override
  State<DoctorReportsScreen> createState() => _DoctorReportsScreenState();
}

class _DoctorReportsScreenState extends State<DoctorReportsScreen> {
  String _selectedPeriod = 'Hoy';

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Gráfica y reportes'),
        centerTitle: true,
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFF0073E6),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.download,
                color: Colors.white,
                size: 20,
              ),
            ),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Descargando reporte...'),
                  backgroundColor: Color(0xFF337536),
                ),
              );
            },
          ),
          const SizedBox(width: 16),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Título
            Text(
              'Reporte y Monitoreo',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: isDark ? Colors.white : Colors.black87,
              ),
            ),
            const SizedBox(height: 24),

            // Selector de período
            Row(
              children: [
                _buildPeriodButton('Hoy', isDark),
                const SizedBox(width: 12),
                _buildPeriodButton('Semana', isDark),
                const SizedBox(width: 12),
                _buildPeriodButton('Mes', isDark),
              ],
            ),
            const SizedBox(height: 24),

            // Niveles de glucosa
            Row(
              children: [
                Icon(
                  Icons.show_chart,
                  color: isDark ? const Color(0xFF0073E6) : const Color(0xFF0073E6),
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  'Niveles de glucosa',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: isDark ? Colors.white : Colors.black87,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Gráfica
            Card(
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: BorderSide(
                  color: isDark ? const Color(0xFF2C3E50) : const Color(0xFFE0E6EB),
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(8, 16, 16, 12),
                child: Column(
                  children: [
                    SizedBox(
                      height: 250,
                      child: CustomPaint(
                        painter: _GlucoseChartPainter(_selectedPeriod),
                        child: Container(),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Leyenda
            Row(
              children: [
                Expanded(
                  child: _buildLegendItem(
                    'Normal (70 - 100)',
                    const Color(0xFF337536),
                    isDark,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _buildLegendItem(
                    'Precaución (100 - 140)',
                    const Color(0xFFFBC318),
                    isDark,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: _buildLegendItem(
                    'Crítica (>140)',
                    const Color(0xFFC72331),
                    isDark,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _buildLegendItem(
                    'Hipoglucemia (<70)',
                    const Color(0xFFC72331),
                    isDark,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Estadísticas
            Row(
              children: [
                Expanded(
                  child: _buildStatCard(
                    title: 'Promedio general',
                    value: '118',
                    unit: 'mg/dL',
                    color: const Color(0xFFFBC318),
                    isDark: isDark,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildStatCard(
                    title: '% en rango',
                    value: '72',
                    unit: 'mg/dL',
                    color: const Color(0xFFC72331),
                    isDark: isDark,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _buildStatCard(
                    title: 'Paciente activos',
                    value: '3',
                    unit: 'cantidad',
                    color: const Color(0xFF0073E6),
                    isDark: isDark,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildStatCard(
                    title: 'Alertas críticas',
                    value: '2',
                    unit: 'cantidad',
                    color: const Color(0xFFC72331),
                    isDark: isDark,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Resumen
            Text(
              'Resumen',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: isDark ? Colors.white : Colors.black87,
              ),
            ),
            const SizedBox(height: 16),

            // Card de resumen
            Card(
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: BorderSide(
                  color: isDark ? const Color(0xFF2C3E50) : const Color(0xFFE0E6EB),
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildSummaryPoint(
                      'Los niveles promedio se mantienen dentro del rango recomendado.',
                      isDark,
                    ),
                    const SizedBox(height: 8),
                    _buildSummaryPoint(
                      'Se detecta una tendencia ascendente leve día de la última semana.',
                      isDark,
                    ),
                    const SizedBox(height: 8),
                    _buildSummaryPoint(
                      '2 pacientes presentan valores críticos recurrentes.',
                      isDark,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildPeriodButton(String label, bool isDark) {
    final isSelected = _selectedPeriod == label;
    return Expanded(
      child: ElevatedButton(
        onPressed: () {
          setState(() {
            _selectedPeriod = label;
          });
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: isSelected ? const Color(0xFF0073E6) : Colors.transparent,
          foregroundColor: isSelected ? Colors.white : (isDark ? const Color(0xFFB3C3D3) : const Color(0xFF6C7C93)),
          elevation: 0,
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
            side: BorderSide(
              color: isSelected ? const Color(0xFF0073E6) : (isDark ? const Color(0xFF2C3E50) : const Color(0xFFE0E6EB)),
            ),
          ),
        ),
        child: Text(
          label,
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
        ),
      ),
    );
  }

  Widget _buildLegendItem(String label, Color color, bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        border: Border.all(
          color: isDark ? const Color(0xFF2C3E50) : const Color(0xFFE0E6EB),
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 16,
            height: 16,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                fontSize: 11,
                color: isDark ? const Color(0xFFB3C3D3) : const Color(0xFF6C7C93),
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard({
    required String title,
    required String value,
    required String unit,
    required Color color,
    required bool isDark,
  }) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: isDark ? const Color(0xFF2C3E50) : const Color(0xFFE0E6EB),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: TextStyle(
                fontSize: 12,
                color: isDark ? const Color(0xFFB3C3D3) : const Color(0xFF6C7C93),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              value,
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.w700,
                color: color,
              ),
            ),
            Text(
              unit,
              style: TextStyle(
                fontSize: 11,
                color: isDark ? const Color(0xFFB3C3D3) : const Color(0xFF6C7C93),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryPoint(String text, bool isDark) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 6,
          height: 6,
          margin: const EdgeInsets.only(top: 6),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFFB3C3D3) : const Color(0xFF6C7C93),
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              fontSize: 13,
              color: isDark ? const Color(0xFFB3C3D3) : const Color(0xFF6C7C93),
            ),
          ),
        ),
      ],
    );
  }
}

// Painter para la gráfica de niveles de glucosa
class _GlucoseChartPainter extends CustomPainter {
  final String period;

  _GlucoseChartPainter(this.period);

  @override
  void paint(Canvas canvas, Size size) {
    // Definir límites de la gráfica (dejar espacio para etiquetas)
    final chartLeft = 50.0; // Espacio para etiquetas del eje Y y "mg/dl"
    final chartTop = 10.0;
    final chartRight = 10.0;
    final chartBottom = 30.0;
    final chartWidth = size.width - chartLeft - chartRight;
    final chartHeight = size.height - chartTop - chartBottom;

    final paint = Paint()..style = PaintingStyle.fill;

    // Bandas de color de fondo (de abajo hacia arriba, similar a la Imagen 1)
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

    // Datos de los puntos según el período
    List<Offset> blueLinePoints = [];
    List<Offset> orangeLinePoints = [];
    List<String> labels = [];
    
    // Configurar etiquetas según el período
    if (period == 'Hoy') {
      labels = ['0h', '4h', '8h', '12h', '16h', '20h', '24h'];
    } else if (period == 'Semana') {
      labels = ['Lun', 'Mar', 'Mie', 'Jue', 'Vie', 'Sab', 'Dom'];
    } else { // Mes
      labels = ['Sem 1', 'Sem 2', 'Sem 3', 'Sem 4'];
    }
    
    final pointSpacing = chartWidth / (labels.length - 1);
    
    // Función para convertir mg/dL a posición Y (escala 0-200)
    double mgdlToY(double mgdl) {
      return chartTop + chartHeight * (1 - (mgdl / 200));
    }
    
    // Definir puntos según el período
    if (period == 'Hoy') {
      // Vista por horas (0h a 24h)
      final blueValues = [80.0, 95.0, 105.0, 115.0, 130.0, 150.0, 170.0];
      final orangeValues = [75.0, 88.0, 98.0, 110.0, 125.0, 145.0, 165.0];
      
      for (int i = 0; i < labels.length; i++) {
        blueLinePoints.add(Offset(chartLeft + pointSpacing * i, mgdlToY(blueValues[i])));
        orangeLinePoints.add(Offset(chartLeft + pointSpacing * i, mgdlToY(orangeValues[i])));
      }
    } else if (period == 'Semana') {
      // Vista por días (Lun a Dom)
      final blueValues = [95.0, 110.0, 118.0, 125.0, 135.0, 155.0, 168.0];
      final orangeValues = [92.0, 105.0, 115.0, 122.0, 132.0, 152.0, 165.0];
      
      for (int i = 0; i < labels.length; i++) {
        blueLinePoints.add(Offset(chartLeft + pointSpacing * i, mgdlToY(blueValues[i])));
        orangeLinePoints.add(Offset(chartLeft + pointSpacing * i, mgdlToY(orangeValues[i])));
      }
    } else { // Mes
      // Vista por semanas (4 semanas)
      final blueValues = [100.0, 115.0, 128.0, 142.0];
      final orangeValues = [98.0, 112.0, 125.0, 138.0];
      
      for (int i = 0; i < labels.length; i++) {
        blueLinePoints.add(Offset(chartLeft + pointSpacing * i, mgdlToY(blueValues[i])));
        orangeLinePoints.add(Offset(chartLeft + pointSpacing * i, mgdlToY(orangeValues[i])));
      }
    }

    // Dibujar línea azul con puntos
    final blueLinePaint = Paint()
      ..color = const Color(0xFF0073E6)
      ..strokeWidth = 3.0
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final bluePath = Path();
    bluePath.moveTo(blueLinePoints[0].dx, blueLinePoints[0].dy);
    for (int i = 1; i < blueLinePoints.length; i++) {
      bluePath.lineTo(blueLinePoints[i].dx, blueLinePoints[i].dy);
    }
    canvas.drawPath(bluePath, blueLinePaint);

    // Dibujar puntos azules
    final bluePointPaint = Paint()
      ..color = const Color(0xFF0073E6)
      ..style = PaintingStyle.fill;

    final whiteBorderPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5;

    for (var point in blueLinePoints) {
      // Borde blanco primero
      canvas.drawCircle(point, 6, whiteBorderPaint);
      // Punto azul encima
      canvas.drawCircle(point, 4.5, bluePointPaint);
    }

    // Dibujar línea naranja con puntos
    final orangeLinePaint = Paint()
      ..color = const Color(0xFFFF8C42)
      ..strokeWidth = 3.0
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final orangePath = Path();
    orangePath.moveTo(orangeLinePoints[0].dx, orangeLinePoints[0].dy);
    for (int i = 1; i < orangeLinePoints.length; i++) {
      orangePath.lineTo(orangeLinePoints[i].dx, orangeLinePoints[i].dy);
    }
    canvas.drawPath(orangePath, orangeLinePaint);

    // Dibujar puntos naranjas
    final orangePointPaint = Paint()
      ..color = const Color(0xFFFF8C42)
      ..style = PaintingStyle.fill;

    for (var point in orangeLinePoints) {
      // Borde blanco primero
      canvas.drawCircle(point, 6, whiteBorderPaint);
      // Punto naranja encima
      canvas.drawCircle(point, 4.5, orangePointPaint);
    }

    // Etiquetas del eje X
    final textPainter = TextPainter(
      textDirection: TextDirection.ltr,
      textAlign: TextAlign.center,
    );

    for (int i = 0; i < labels.length; i++) {
      textPainter.text = TextSpan(
        text: labels[i],
        style: const TextStyle(
          color: Color(0xFF6C7C93), 
          fontSize: 10, 
          fontWeight: FontWeight.w500,
        ),
      );
      textPainter.layout();
      final xPos = chartLeft + (pointSpacing * i) - (textPainter.width / 2);
      final yPos = chartTop + chartHeight + 8;
      textPainter.paint(
        canvas,
        Offset(xPos, yPos),
      );
    }

    // Etiquetas del eje Y (mg/dL)
    final yLabels = ['200', '150', '100', '50', '0'];
    final yValues = [0.0, 0.25, 0.5, 0.75, 1.0]; // Posiciones relativas
    
    for (int i = 0; i < yLabels.length; i++) {
      textPainter.text = TextSpan(
        text: yLabels[i],
        style: const TextStyle(
          color: Color(0xFF6C7C93), 
          fontSize: 10,
          fontWeight: FontWeight.w500,
        ),
      );
      textPainter.layout();
      final yPos = chartTop + (chartHeight * yValues[i]) - (textPainter.height / 2);
      // Posicionar números más a la derecha para dejar espacio al texto rotado
      textPainter.paint(
        canvas,
        Offset(22, yPos),
      );
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
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
