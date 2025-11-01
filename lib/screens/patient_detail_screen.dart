import 'package:flutter/material.dart';
import 'medical_observations_screen.dart';

class PatientDetailScreen extends StatefulWidget {
  final String patientName;
  final String patientAge;
  final String currentStatus;

  const PatientDetailScreen({
    super.key,
    required this.patientName,
    required this.patientAge,
    required this.currentStatus,
  });

  @override
  State<PatientDetailScreen> createState() => _PatientDetailScreenState();
}

class _PatientDetailScreenState extends State<PatientDetailScreen> {
  String _selectedPeriod = 'Hoy';
  final TextEditingController _observationController = TextEditingController();

  @override
  void dispose() {
    _observationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0A0E27) : const Color(0xFFF9FAFB),
      appBar: AppBar(
        title: const Text('Detalle del paciente'),
        centerTitle: true,
        leading: IconButton(
          icon: Container(
            padding: const EdgeInsets.all(8),
            decoration: const BoxDecoration(
              color: Color(0xFF0073E6),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.arrow_back,
              color: Colors.white,
              size: 20,
            ),
          ),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Título
            Center(
              child: Text(
                'Detalle del paciente',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: isDark ? const Color(0xFFB3C3D3) : const Color(0xFF6C7C93),
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Card de información del paciente
            Card(
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: BorderSide(
                  color: isDark ? const Color(0xFF2C3E50) : const Color(0xFFE0E6EB),
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Row(
                  children: [
                    // Avatar
                    Container(
                      width: 60,
                      height: 60,
                      decoration: const BoxDecoration(
                        color: Color(0xFF6C7C93),
                        shape: BoxShape.circle,
                      ),
                      child: const Center(
                        child: Icon(
                          Icons.person,
                          color: Colors.white,
                          size: 32,
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    // Información
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Nombre completo',
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: isDark ? Colors.white : Colors.black87,
                                ),
                              ),
                              Text(
                                widget.patientName,
                                style: TextStyle(
                                  fontSize: 13,
                                  color: isDark ? const Color(0xFFB3C3D3) : const Color(0xFF6C7C93),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Edad',
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: isDark ? Colors.white : Colors.black87,
                                ),
                              ),
                              Text(
                                widget.patientAge,
                                style: TextStyle(
                                  fontSize: 13,
                                  color: isDark ? const Color(0xFFB3C3D3) : const Color(0xFF6C7C93),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Estado actual',
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: isDark ? Colors.white : Colors.black87,
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFC72331),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  widget.currentStatus,
                                  style: const TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Mediciones
            Text(
              'Mediciones',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: isDark ? Colors.white : Colors.black87,
              ),
            ),
            const SizedBox(height: 16),

            // Tarjetas de mediciones
            Row(
              children: [
                Expanded(
                  child: _buildMeasurementCard(
                    title: 'Glucosa actual',
                    value: '245',
                    unit: 'mg/dl',
                    color: const Color(0xFFC72331),
                    isDark: isDark,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildMeasurementCard(
                    title: 'Promedio diario',
                    value: '178',
                    unit: 'mg/dl',
                    color: const Color(0xFFC72331),
                    isDark: isDark,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildMeasurementCard(
                    title: '% en rango',
                    value: '64%',
                    unit: 'objetivo',
                    color: const Color(0xFFFBC318),
                    isDark: isDark,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Tendencia
            Text(
              'Tendencia',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: isDark ? Colors.white : Colors.black87,
              ),
            ),
            const SizedBox(height: 16),

            // Card de gráfica
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
                    // Selector de período
                    Row(
                      children: [
                        _buildPeriodButton('Hoy', isDark),
                        const SizedBox(width: 8),
                        _buildPeriodButton('Semana', isDark),
                        const SizedBox(width: 8),
                        _buildPeriodButton('Mes', isDark),
                      ],
                    ),
                    const SizedBox(height: 16),
                    // Gráfica (simplificada)
                    SizedBox(
                      height: 200,
                      child: CustomPaint(
                        painter: _TrendChartPainter(),
                        child: Container(),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Observación médica
            Text(
              'Observación médica',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: isDark ? Colors.white : Colors.black87,
              ),
            ),
            const SizedBox(height: 16),

            // Campo de texto para observación
            TextField(
              controller: _observationController,
              maxLines: 4,
              style: TextStyle(
                fontSize: 14,
                color: isDark ? Colors.white : Colors.black87,
              ),
              decoration: InputDecoration(
                hintText: 'Escribe una observación...',
                hintStyle: TextStyle(
                  fontSize: 14,
                  color: isDark ? const Color(0xFF6C7C93) : const Color(0xFFB3C3D3),
                ),
                filled: true,
                fillColor: isDark ? const Color(0xFF1A1F3A) : Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(
                    color: isDark ? const Color(0xFF2C3E50) : const Color(0xFFE0E6EB),
                  ),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(
                    color: isDark ? const Color(0xFF2C3E50) : const Color(0xFFE0E6EB),
                  ),
                ),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.edit, color: Color(0xFF0073E6)),
                  onPressed: () {},
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Botón guardar cambios
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Cambios guardados exitosamente'),
                      backgroundColor: Color(0xFF337536),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF0073E6),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                  elevation: 0,
                ),
                child: const Text(
                  'Guardar cambios',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Card de historial
            InkWell(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => MedicalObservationsScreen(
                      patientName: widget.patientName,
                    ),
                  ),
                );
              },
              child: Card(
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: BorderSide(
                    color: isDark ? const Color(0xFF2C3E50) : const Color(0xFFE0E6EB),
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: const Color(0xFF0073E6).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(
                          Icons.history,
                          color: Color(0xFF0073E6),
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Historial',
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                                color: isDark ? Colors.white : Colors.black87,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Ver historial de observaciones.',
                              style: TextStyle(
                                fontSize: 13,
                                color: isDark ? const Color(0xFFB3C3D3) : const Color(0xFF6C7C93),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Icon(
                        Icons.arrow_forward_ios,
                        color: Color(0xFF0073E6),
                        size: 20,
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildMeasurementCard({
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
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: TextStyle(
                fontSize: 11,
                color: isDark ? const Color(0xFFB3C3D3) : const Color(0xFF6C7C93),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              value,
              style: TextStyle(
                fontSize: 28,
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
          padding: const EdgeInsets.symmetric(vertical: 10),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
            side: BorderSide(
              color: isSelected ? const Color(0xFF0073E6) : (isDark ? const Color(0xFF2C3E50) : const Color(0xFFE0E6EB)),
            ),
          ),
        ),
        child: Text(
          label,
          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
        ),
      ),
    );
  }
}

// Painter simple para la gráfica de tendencia
class _TrendChartPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.fill;

    // Áreas de color (rojo, amarillo, verde)
    final redRect = Rect.fromLTWH(0, 0, size.width, size.height * 0.2);
    paint.color = const Color(0xFFC72331).withOpacity(0.3);
    canvas.drawRect(redRect, paint);

    final yellowRect = Rect.fromLTWH(0, size.height * 0.2, size.width, size.height * 0.5);
    paint.color = const Color(0xFFFBC318).withOpacity(0.3);
    canvas.drawRect(yellowRect, paint);

    final greenRect = Rect.fromLTWH(0, size.height * 0.7, size.width, size.height * 0.3);
    paint.color = const Color(0xFF337536).withOpacity(0.3);
    canvas.drawRect(greenRect, paint);

    // Línea de tendencia (simplificada)
    final linePaint = Paint()
      ..color = const Color(0xFF0073E6)
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke;

    final path = Path();
    path.moveTo(0, size.height * 0.6);
    path.lineTo(size.width * 0.2, size.height * 0.5);
    path.lineTo(size.width * 0.4, size.height * 0.45);
    path.lineTo(size.width * 0.6, size.height * 0.35);
    path.lineTo(size.width * 0.8, size.height * 0.3);
    path.lineTo(size.width, size.height * 0.25);

    canvas.drawPath(path, linePaint);

    // Etiquetas del eje X
    final textPainter = TextPainter(
      textDirection: TextDirection.ltr,
    );

    final labels = ['0h', '4h', '8h', '12h', '16h', '20h', '24h'];
    for (int i = 0; i < labels.length; i++) {
      textPainter.text = TextSpan(
        text: labels[i],
        style: const TextStyle(color: Color(0xFF6C7C93), fontSize: 10),
      );
      textPainter.layout();
      textPainter.paint(
        canvas,
        Offset((size.width / (labels.length - 1)) * i - 10, size.height + 5),
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
