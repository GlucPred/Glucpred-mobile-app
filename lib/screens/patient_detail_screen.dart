import 'package:flutter/material.dart';
import '../config/theme.dart';
import 'medical_observations_screen.dart';
import '../services/doctor_patient_service.dart';
import '../services/records_service.dart';
import '../models/trend_point.dart';

class PatientDetailScreen extends StatefulWidget {
  final int patientUserId;
  final String patientName;
  final String patientAge;
  final String currentStatus;

  const PatientDetailScreen({
    super.key,
    required this.patientUserId,
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
  List<TrendPoint> _trendData = [];
  List<Map<String, dynamic>> _allRecords = [];
  bool _isLoading = true;
  bool _isSavingObservation = false;
  
  // Estadísticas calculadas desde el historial
  double _currentGlucose = 0.0;
  double _averageGlucose = 0.0;
  double _normalPercentage = 0.0;
  Map<String, dynamic>? _latestObservation;

  @override
  void initState() {
    super.initState();
    _loadPatientData();
  }

  Future<void> _loadPatientData() async {
    setState(() => _isLoading = true);

    try {
      // Cargar historial completo del paciente
      final historyResult = await RecordsService.getPatientHistory(
        widget.patientUserId,
        limit: 500,
      );

      if (historyResult['success']) {
        final records = List<Map<String, dynamic>>.from(historyResult['records'] ?? []);
        
        setState(() {
          _allRecords = records;
          _calculateStatistics();
          _filterDataByPeriod();
          _isLoading = false;
        });

        // Cargar observación médica más reciente
        _loadLatestObservation();
      } else {
        setState(() => _isLoading = false);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(historyResult['message'] ?? 'Error al cargar datos del paciente'),
              backgroundColor: const Color(0xFFC72331),
            ),
          );
        }
      }
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: const Color(0xFFC72331),
          ),
        );
      }
    }
  }

  Future<void> _loadLatestObservation() async {
    try {
      final period = _selectedPeriod == 'Hoy' ? 'day' : (_selectedPeriod == 'Semana' ? 'week' : 'month');
      final result = await DoctorPatientService.getPatientDetail(
        widget.patientUserId,
        period: period,
      );

      if (result['success'] && result['latest_observation'] != null) {
        setState(() {
          _latestObservation = result['latest_observation'];
          _observationController.text = _latestObservation!['observation'] ?? '';
        });
      }
    } catch (e) {
      // Error silencioso, la observación no es crítica
    }
  }

  void _calculateStatistics() {
    if (_allRecords.isEmpty) {
      _currentGlucose = 0.0;
      _averageGlucose = 0.0;
      _normalPercentage = 0.0;
      return;
    }

    // Última glucosa
    _currentGlucose = (_allRecords.first['glucose_value'] as num).toDouble();

    // Promedio
    double sum = 0.0;
    int normalCount = 0;

    for (var record in _allRecords) {
      final value = (record['glucose_value'] as num).toDouble();
      sum += value;
      
      final classification = (record['classification'] ?? '').toLowerCase();
      if (classification == 'normal') {
        normalCount++;
      }
    }

    _averageGlucose = sum / _allRecords.length;
    _normalPercentage = (normalCount / _allRecords.length) * 100;
  }

  void _filterDataByPeriod() {
    final now = DateTime.now();
    DateTime cutoffDate;

    switch (_selectedPeriod) {
      case 'Hoy':
        cutoffDate = DateTime(now.year, now.month, now.day);
        break;
      case 'Semana':
        cutoffDate = now.subtract(const Duration(days: 7));
        break;
      case 'Mes':
        cutoffDate = now.subtract(const Duration(days: 30));
        break;
      default:
        cutoffDate = DateTime(now.year, now.month, now.day);
    }

    final filteredRecords = _allRecords.where((record) {
      final timestamp = DateTime.parse(record['measurement_time']);
      return timestamp.isAfter(cutoffDate);
    }).toList();

    // Ordenar de pasado a presente (orden cronológico)
    filteredRecords.sort((a, b) {
      final timeA = DateTime.parse(a['measurement_time']);
      final timeB = DateTime.parse(b['measurement_time']);
      return timeA.compareTo(timeB); // Pasado → Presente
    });

    setState(() {
      _trendData = filteredRecords.map((record) {
        final timestamp = DateTime.parse(record['measurement_time']);
        return TrendPoint(
          timestamp: timestamp,
          value: (record['glucose_value'] as num).toDouble(),
          time: '${timestamp.day}/${timestamp.month}', // Solo día/mes
        );
      }).toList();
    });
  }

  Future<void> _saveObservation() async {
    final observationText = _observationController.text.trim();
    
    if (observationText.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Escribe una observación antes de guardar')),
      );
      return;
    }

    setState(() => _isSavingObservation = true);

    try {
      final result = await DoctorPatientService.createObservation(
        widget.patientUserId,
        observationText,
      );

      setState(() => _isSavingObservation = false);

      if (result['success']) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(result['message'] ?? 'Observación guardada')),
          );
          // Recargar la última observación
          _loadLatestObservation();
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(result['message'] ?? 'Error al guardar observación'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      setState(() => _isSavingObservation = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  @override
  void dispose() {
    _observationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    if (_isLoading) {
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
        body: const Center(child: CircularProgressIndicator()),
      );
    }

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
                    value: _currentGlucose.toStringAsFixed(0),
                    unit: 'mg/dl',
                    color: const Color(0xFFC72331),
                    isDark: isDark,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildMeasurementCard(
                    title: 'Promedio diario',
                    value: _averageGlucose.toStringAsFixed(0),
                    unit: 'mg/dl',
                    color: const Color(0xFFC72331),
                    isDark: isDark,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildMeasurementCard(
                    title: '% en rango',
                    value: '${_normalPercentage.toStringAsFixed(0)}%',
                    unit: 'objetivo',
                    color: isDark ? AppTheme.warningColorBright : AppTheme.warningColor,
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
                    // Gráfica con datos dinámicos
                    SizedBox(
                      height: 200,
                      child: _trendData.isEmpty
                          ? const Center(child: CircularProgressIndicator())
                          : CustomPaint(
                              painter: _TrendChartPainter(_trendData),
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
                onPressed: _isSavingObservation ? null : _saveObservation,
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
                      patientUserId: widget.patientUserId,
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
          _filterDataByPeriod(); // Filtrar datos con nuevo periodo
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

// Painter para la gráfica de tendencia con datos dinámicos
class _TrendChartPainter extends CustomPainter {
  final List<TrendPoint> data;

  _TrendChartPainter(this.data);

  @override
  void paint(Canvas canvas, Size size) {
    if (data.isEmpty) return;

    // Márgenes para que todo quepa dentro del contenedor
    const double chartLeft = 50.0;
    const double chartTop = 10.0;
    const double chartRight = 10.0;
    const double chartBottom = 30.0;

    final chartWidth = size.width - chartLeft - chartRight;
    final chartHeight = size.height - chartTop - chartBottom;

    // Rangos de glucosa
    const double minGlucose = 0.0;
    const double maxGlucose = 300.0;
    
    // Niveles de zona
    const double normalLowLevel = 70.0;
    const double normalHighLevel = 180.0;
    const double hyperglycemiaLevel = 250.0;

    // Convertir niveles a coordenadas Y
    double glucoseToY(double glucose) {
      final ratio = (glucose - minGlucose) / (maxGlucose - minGlucose);
      return chartTop + chartHeight - (ratio * chartHeight);
    }

    // Dibujar bandas de color (COLORES VIVOS Y SÓLIDOS)
    final paint = Paint()..style = PaintingStyle.fill;

    // Banda rosa crítica superior (250-300)
    paint.color = const Color(0xFFFFB6C1); // Rosa vivo
    canvas.drawRect(
      Rect.fromLTRB(
        chartLeft,
        chartTop,
        chartLeft + chartWidth,
        glucoseToY(hyperglycemiaLevel),
      ),
      paint,
    );

    // Banda amarilla precaución (180-250)
    paint.color = const Color(0xFFFFD966); // Amarillo vivo
    canvas.drawRect(
      Rect.fromLTRB(
        chartLeft,
        glucoseToY(hyperglycemiaLevel),
        chartLeft + chartWidth,
        glucoseToY(normalHighLevel),
      ),
      paint,
    );

    // Banda verde normal (70-180)
    paint.color = const Color(0xFF90EE90); // Verde vivo
    canvas.drawRect(
      Rect.fromLTRB(
        chartLeft,
        glucoseToY(normalHighLevel),
        chartLeft + chartWidth,
        glucoseToY(normalLowLevel),
      ),
      paint,
    );

    // Banda cyan hipoglucemia (0-70)
    paint.color = const Color(0xFFADD8E6); // Cyan vivo
    canvas.drawRect(
      Rect.fromLTRB(
        chartLeft,
        glucoseToY(normalLowLevel),
        chartLeft + chartWidth,
        chartTop + chartHeight,
      ),
      paint,
    );

    // Dibujar líneas de referencia de glucosa
    final linePaint = Paint()
      ..color = Colors.white.withOpacity(0.3)
      ..strokeWidth = 1;

    final levels = [0, 50, 100, 150, 200, 250, 300];
    for (final level in levels) {
      final y = glucoseToY(level.toDouble());
      canvas.drawLine(
        Offset(chartLeft, y),
        Offset(chartLeft + chartWidth, y),
        linePaint,
      );
    }

    // Dibujar etiquetas del eje Y (mg/dl)
    final textPainter = TextPainter(textDirection: TextDirection.ltr);
    
    // Etiqueta "mg/dl" en la parte superior
    textPainter.text = const TextSpan(
      text: 'mg/dl',
      style: TextStyle(color: Color(0xFF6C7C93), fontSize: 10, fontWeight: FontWeight.w600),
    );
    textPainter.layout();
    textPainter.paint(canvas, Offset(8, chartTop));

    // Números del eje Y
    for (final level in levels) {
      final y = glucoseToY(level.toDouble());
      textPainter.text = TextSpan(
        text: level.toString(),
        style: const TextStyle(color: Color(0xFF6C7C93), fontSize: 10),
      );
      textPainter.layout();
      textPainter.paint(canvas, Offset(22, y - 6));
    }

    // Dibujar la línea de tendencia
    if (data.length > 1) {
      final path = Path();
      final linePaint = Paint()
        ..color = const Color(0xFF0073E6)
        ..strokeWidth = 3
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round;

      // Calcular posiciones de los puntos
      for (int i = 0; i < data.length; i++) {
        final x = chartLeft + (chartWidth / (data.length - 1)) * i;
        final y = glucoseToY(data[i].value);

        if (i == 0) {
          path.moveTo(x, y);
        } else {
          path.lineTo(x, y);
        }
      }

      canvas.drawPath(path, linePaint);

      // Dibujar puntos de datos (círculos)
      final pointPaint = Paint()
        ..color = const Color(0xFF0073E6)
        ..style = PaintingStyle.fill;

      final pointBorderPaint = Paint()
        ..color = Colors.white
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2;

      for (int i = 0; i < data.length; i++) {
        final x = chartLeft + (chartWidth / (data.length - 1)) * i;
        final y = glucoseToY(data[i].value);

        // Círculo blanco de borde
        canvas.drawCircle(Offset(x, y), 5, pointBorderPaint);
        // Círculo azul interior
        canvas.drawCircle(Offset(x, y), 4, pointPaint);
      }
    }

    // Dibujar etiquetas del eje X
    for (int i = 0; i < data.length; i++) {
      textPainter.text = TextSpan(
        text: data[i].time,
        style: const TextStyle(color: Color(0xFF6C7C93), fontSize: 10),
      );
      textPainter.layout();
      final x = chartLeft + (chartWidth / (data.length - 1)) * i;
      textPainter.paint(
        canvas,
        Offset(x - textPainter.width / 2, chartTop + chartHeight + 5),
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
