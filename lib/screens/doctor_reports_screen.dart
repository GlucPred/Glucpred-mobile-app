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
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    SizedBox(
                      height: 220,
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
    final chartLeft = 35.0;
    final chartTop = 10.0;
    final chartWidth = size.width - chartLeft - 10;
    final chartHeight = size.height - 25;

    final paint = Paint()..style = PaintingStyle.fill;

    // Áreas de color con gradiente más suave (de abajo hacia arriba: azul, verde, amarillo, morado/rojo)
    // Hipoglucemia crítica (<50) - Azul claro
    final blueRect = Rect.fromLTWH(chartLeft, chartTop + chartHeight * 0.75, chartWidth, chartHeight * 0.25);
    paint.color = const Color(0xFF87CEEB).withOpacity(0.3);
    canvas.drawRect(blueRect, paint);

    // Normal bajo (50-70) - Cyan/Turquesa
    final cyanRect = Rect.fromLTWH(chartLeft, chartTop + chartHeight * 0.65, chartWidth, chartHeight * 0.10);
    paint.color = const Color(0xFF40E0D0).withOpacity(0.3);
    canvas.drawRect(cyanRect, paint);

    // Normal óptimo (70-100) - Verde
    final greenRect = Rect.fromLTWH(chartLeft, chartTop + chartHeight * 0.50, chartWidth, chartHeight * 0.15);
    paint.color = const Color(0xFF90EE90).withOpacity(0.4);
    canvas.drawRect(greenRect, paint);

    // Precaución (100-140) - Amarillo
    final yellowRect = Rect.fromLTWH(chartLeft, chartTop + chartHeight * 0.30, chartWidth, chartHeight * 0.20);
    paint.color = const Color(0xFFFBC318).withOpacity(0.3);
    canvas.drawRect(yellowRect, paint);

    // Crítico (>140) - Morado/Rojo
    final redRect = Rect.fromLTWH(chartLeft, chartTop, chartWidth, chartHeight * 0.30);
    paint.color = const Color(0xFFB19CD9).withOpacity(0.3);
    canvas.drawRect(redRect, paint);

    // Datos de los puntos según el período
    List<Offset> blueLinePoints = [];
    List<Offset> orangeLinePoints = [];
    
    final labels = ['Lun', 'Mar', 'Mie', 'Jue', 'Vie', 'Sab', 'Dom'];
    final pointSpacing = chartWidth / (labels.length - 1);
    
    // Definir puntos para la línea azul y naranja (valores de ejemplo basados en la imagen)
    if (period == 'Hoy') {
      // Línea azul (valores más altos)
      blueLinePoints = [
        Offset(chartLeft, chartTop + chartHeight * 0.50), // 100 mg/dL
        Offset(chartLeft + pointSpacing * 1, chartTop + chartHeight * 0.43), // 115 mg/dL
        Offset(chartLeft + pointSpacing * 2, chartTop + chartHeight * 0.38), // 122 mg/dL
        Offset(chartLeft + pointSpacing * 3, chartTop + chartHeight * 0.36), // 128 mg/dL
        Offset(chartLeft + pointSpacing * 4, chartTop + chartHeight * 0.30), // 145 mg/dL
        Offset(chartLeft + pointSpacing * 5, chartTop + chartHeight * 0.20), // 170 mg/dL
        Offset(chartLeft + pointSpacing * 6, chartTop + chartHeight * 0.05), // 195 mg/dL
      ];
      
      // Línea naranja (valores medios)
      orangeLinePoints = [
        Offset(chartLeft, chartTop + chartHeight * 0.52), // 98 mg/dL
        Offset(chartLeft + pointSpacing * 1, chartTop + chartHeight * 0.45), // 110 mg/dL
        Offset(chartLeft + pointSpacing * 2, chartTop + chartHeight * 0.40), // 118 mg/dL
        Offset(chartLeft + pointSpacing * 3, chartTop + chartHeight * 0.38), // 125 mg/dL
        Offset(chartLeft + pointSpacing * 4, chartTop + chartHeight * 0.32), // 140 mg/dL
        Offset(chartLeft + pointSpacing * 5, chartTop + chartHeight * 0.22), // 165 mg/dL
        Offset(chartLeft + pointSpacing * 6, chartTop + chartHeight * 0.08), // 190 mg/dL
      ];
    } else {
      // Usar los mismos puntos para Semana y Mes (puedes ajustar si necesitas)
      blueLinePoints = [
        Offset(chartLeft, chartTop + chartHeight * 0.50),
        Offset(chartLeft + pointSpacing * 1, chartTop + chartHeight * 0.43),
        Offset(chartLeft + pointSpacing * 2, chartTop + chartHeight * 0.38),
        Offset(chartLeft + pointSpacing * 3, chartTop + chartHeight * 0.36),
        Offset(chartLeft + pointSpacing * 4, chartTop + chartHeight * 0.30),
        Offset(chartLeft + pointSpacing * 5, chartTop + chartHeight * 0.20),
        Offset(chartLeft + pointSpacing * 6, chartTop + chartHeight * 0.05),
      ];
      
      orangeLinePoints = [
        Offset(chartLeft, chartTop + chartHeight * 0.52),
        Offset(chartLeft + pointSpacing * 1, chartTop + chartHeight * 0.45),
        Offset(chartLeft + pointSpacing * 2, chartTop + chartHeight * 0.40),
        Offset(chartLeft + pointSpacing * 3, chartTop + chartHeight * 0.38),
        Offset(chartLeft + pointSpacing * 4, chartTop + chartHeight * 0.32),
        Offset(chartLeft + pointSpacing * 5, chartTop + chartHeight * 0.22),
        Offset(chartLeft + pointSpacing * 6, chartTop + chartHeight * 0.08),
      ];
    }

    // Dibujar línea azul con puntos
    final blueLinePaint = Paint()
      ..color = const Color(0xFF0073E6)
      ..strokeWidth = 2.5
      ..style = PaintingStyle.stroke;

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

    for (var point in blueLinePoints) {
      canvas.drawCircle(point, 5, bluePointPaint);
      // Borde blanco del punto
      final whiteBorderPaint = Paint()
        ..color = Colors.white
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2;
      canvas.drawCircle(point, 5, whiteBorderPaint);
    }

    // Dibujar línea naranja con puntos
    final orangeLinePaint = Paint()
      ..color = const Color(0xFFFF8C42)
      ..strokeWidth = 2.5
      ..style = PaintingStyle.stroke;

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
      canvas.drawCircle(point, 5, orangePointPaint);
      // Borde blanco del punto
      final whiteBorderPaint = Paint()
        ..color = Colors.white
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2;
      canvas.drawCircle(point, 5, whiteBorderPaint);
    }

    // Etiquetas del eje X
    final textPainter = TextPainter(textDirection: TextDirection.ltr);

    for (int i = 0; i < labels.length; i++) {
      textPainter.text = TextSpan(
        text: labels[i],
        style: const TextStyle(color: Color(0xFF6C7C93), fontSize: 11, fontWeight: FontWeight.w500),
      );
      textPainter.layout();
      final xPos = chartLeft + (pointSpacing * i) - (textPainter.width / 2);
      textPainter.paint(
        canvas,
        Offset(xPos, chartTop + chartHeight + 5),
      );
    }

    // Etiquetas del eje Y (mg/dL)
    final yLabels = ['200', '150', '100', '50'];
    final yValues = [0.0, 0.25, 0.5, 0.75]; // Posiciones relativas
    
    for (int i = 0; i < yLabels.length; i++) {
      textPainter.text = TextSpan(
        text: yLabels[i],
        style: const TextStyle(color: Color(0xFF6C7C93), fontSize: 10),
      );
      textPainter.layout();
      textPainter.paint(
        canvas,
        Offset(2, chartTop + (chartHeight * yValues[i]) - 5),
      );
    }
    
    // Etiqueta "mg/dL" en el eje Y
    textPainter.text = const TextSpan(
      text: 'mg/dL',
      style: TextStyle(color: Color(0xFF6C7C93), fontSize: 9, fontWeight: FontWeight.w500),
    );
    textPainter.layout();
    
    // Rotar el texto 90 grados
    canvas.save();
    canvas.translate(8, size.height / 2);
    canvas.rotate(-1.5708); // -90 grados en radianes
    textPainter.paint(canvas, Offset(-textPainter.width / 2, 0));
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
