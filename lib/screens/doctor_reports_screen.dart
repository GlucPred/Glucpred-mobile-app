import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:intl/intl.dart';
import '../services/auth_service.dart';
import '../services/records_service.dart';

class DoctorReportsScreen extends StatefulWidget {
  const DoctorReportsScreen({super.key});

  @override
  State<DoctorReportsScreen> createState() => _DoctorReportsScreenState();
}

class _DoctorReportsScreenState extends State<DoctorReportsScreen> with AutomaticKeepAliveClientMixin {
  String _selectedPeriod = 'Hoy';
  bool _isLoading = false;
  List<Map<String, dynamic>> _allRecords = [];
  Map<int, String> _patientNames = {};
  Map<int, Color> _patientColors = {};

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _loadRecords();
  }

  Future<void> _loadRecords() async {
    print('🔵 DoctorReportsScreen: Llamando a getMyPatientsRecords...');
    setState(() => _isLoading = true);
    
    final result = await RecordsService.getMyPatientsRecords();
    print('🔵 DoctorReportsScreen: Respuesta recibida: ${result['success']}');
    print('🔵 DoctorReportsScreen: Records count: ${(result['records'] as List?)?.length ?? 0}');
    
    if (result['success']) {
      final records = result['records'] as List;
      
      // Crear mapa de nombres de pacientes y asignar colores
      final patientIds = records.map((r) => r['patient_id'] as int).toSet().toList();
      final colors = [
        const Color(0xFF0073E6), // Azul
        const Color(0xFFFF6B35), // Naranja
        const Color(0xFF9B59B6), // Púrpura
        const Color(0xFF2ECC71), // Verde
        const Color(0xFFE74C3C), // Rojo
      ];
      
      for (int i = 0; i < patientIds.length; i++) {
        _patientColors[patientIds[i]] = colors[i % colors.length];
        // El nombre real viene del backend, pero lo usaremos como ID si no está
        _patientNames[patientIds[i]] = 'Paciente ${patientIds[i]}';
      }
      
      setState(() {
        _allRecords = records.cast<Map<String, dynamic>>();
        _isLoading = false;
      });
    } else {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(result['message'] ?? 'Error al cargar registros')),
        );
      }
    }
  }

  List<Map<String, dynamic>> get _filteredRecords {
    final now = DateTime.now();
    DateTime startDate;

    switch (_selectedPeriod) {
      case 'Hoy':
        startDate = DateTime(now.year, now.month, now.day);
        break;
      case 'Semana':
        startDate = now.subtract(const Duration(days: 7));
        break;
      case 'Mes':
        startDate = now.subtract(const Duration(days: 30));
        break;
      default:
        startDate = DateTime(now.year, now.month, now.day);
    }

    return _allRecords.where((record) {
      final measurementTime = DateTime.parse(record['measurement_time']);
      return measurementTime.isAfter(startDate);
    }).toList()
      ..sort((a, b) => DateTime.parse(a['measurement_time'])
          .compareTo(DateTime.parse(b['measurement_time'])));
  }

  Map<String, dynamic> get _statistics {
    final filtered = _filteredRecords;
    
    if (filtered.isEmpty) {
      return {
        'average': 0.0,
        'inRange': 0.0,
        'activePatients': _patientColors.length,
        'criticalAlerts': 0,
      };
    }

    final sum = filtered.fold<double>(0, (prev, record) => prev + record['glucose_value']);
    final average = sum / filtered.length;
    
    final inRange = filtered.where((r) {
      final value = r['glucose_value'];
      return value >= 70 && value <= 140;
    }).length;
    
    final percentage = (inRange / filtered.length) * 100;
    
    final critical = filtered.where((r) {
      final value = r['glucose_value'];
      return value > 140 || value < 70;
    }).length;

    return {
      'average': average,
      'inRange': percentage,
      'activePatients': _patientColors.length,
      'criticalAlerts': critical,
    };
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
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
            onPressed: () => _generateDoctorPdfReport(),
            tooltip: 'Descargar reporte PDF',
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
            _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _filteredRecords.isEmpty
                    ? Card(
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                          side: BorderSide(
                            color: isDark ? const Color(0xFF2C3E50) : const Color(0xFFE0E6EB),
                          ),
                        ),
                        child: const Padding(
                          padding: EdgeInsets.all(40),
                          child: Center(
                            child: Text('No hay registros en este período'),
                          ),
                        ),
                      )
                    : Card(
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
                                  painter: _GlucoseChartPainter(
                                    records: _filteredRecords,
                                    patientColors: _patientColors,
                                  ),
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
                    value: _statistics['average'].toStringAsFixed(0),
                    unit: 'mg/dL',
                    color: const Color(0xFFFBC318),
                    isDark: isDark,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildStatCard(
                    title: '% en rango',
                    value: _statistics['inRange'].toStringAsFixed(0),
                    unit: '%',
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
                    title: 'Pacientes activos',
                    value: _statistics['activePatients'].toString(),
                    unit: 'cantidad',
                    color: const Color(0xFF0073E6),
                    isDark: isDark,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildStatCard(
                    title: 'Alertas críticas',
                    value: _statistics['criticalAlerts'].toString(),
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

  Future<void> _generateDoctorPdfReport() async {
    final pdf = pw.Document();
    
    // Obtener datos del médico
    final profileResult = await AuthService.getProfile();
    String doctorName = 'Médico';
    
    if (profileResult['success']) {
      final user = profileResult['user'];
      doctorName = user['nombre_completo'] ?? 'Médico';
    }
    
    // Obtener fecha actual
    final now = DateTime.now();
    final dateStr = '${now.day.toString().padLeft(2, '0')}/${now.month.toString().padLeft(2, '0')}/${now.year}';
    final timeStr = '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}';
    
    // Datos de ejemplo de pacientes (en producción estos vendrían del servicio)
    final patientsSummary = [
      {'name': 'Juan Pérez', 'age': '45', 'avg': '118', 'status': 'Precaución'},
      {'name': 'María García', 'age': '52', 'avg': '142', 'status': 'Crítico'},
      {'name': 'Carlos López', 'age': '38', 'avg': '95', 'status': 'Normal'},
    ];

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(40),
        build: (pw.Context context) {
          return [
            // Encabezado
            pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Text(
                          'GlucPred',
                          style: pw.TextStyle(
                            fontSize: 28,
                            fontWeight: pw.FontWeight.bold,
                            color: PdfColor.fromHex('#0073E6'),
                          ),
                        ),
                        pw.SizedBox(height: 4),
                        pw.Text(
                          'Reporte General de Pacientes',
                          style: pw.TextStyle(
                            fontSize: 16,
                            color: PdfColor.fromHex('#6C7C93'),
                          ),
                        ),
                      ],
                    ),
                    pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.end,
                      children: [
                        pw.Text(
                          'Fecha: $dateStr',
                          style: const pw.TextStyle(fontSize: 12),
                        ),
                        pw.SizedBox(height: 2),
                        pw.Text(
                          'Hora: $timeStr',
                          style: const pw.TextStyle(fontSize: 12),
                        ),
                      ],
                    ),
                  ],
                ),
                pw.SizedBox(height: 8),
                pw.Divider(thickness: 2, color: PdfColor.fromHex('#0073E6')),
                pw.SizedBox(height: 20),

                // Información del Médico
                pw.Container(
                  padding: const pw.EdgeInsets.all(16),
                  decoration: pw.BoxDecoration(
                    color: PdfColor.fromHex('#F9FAFB'),
                    borderRadius: pw.BorderRadius.circular(8),
                    border: pw.Border.all(
                      color: PdfColor.fromHex('#E0E6EB'),
                      width: 1,
                    ),
                  ),
                  child: pw.Row(
                    children: [
                      pw.Icon(
                        pw.IconData(0xe7fd), // medical services icon
                        size: 20,
                        color: PdfColor.fromHex('#0073E6'),
                      ),
                      pw.SizedBox(width: 12),
                      pw.Text(
                        'Dr. $doctorName',
                        style: pw.TextStyle(
                          fontSize: 14,
                          fontWeight: pw.FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                pw.SizedBox(height: 16),

                // Información del período
                pw.Container(
                  padding: const pw.EdgeInsets.all(16),
                  decoration: pw.BoxDecoration(
                    color: PdfColor.fromHex('#F0F7FF'),
                    borderRadius: pw.BorderRadius.circular(8),
                  ),
                  child: pw.Row(
                    children: [
                      pw.Icon(
                        pw.IconData(0xe190), // calendar_today
                        size: 24,
                        color: PdfColor.fromHex('#0073E6'),
                      ),
                      pw.SizedBox(width: 12),
                      pw.Text(
                        'Período: $_selectedPeriod',
                        style: pw.TextStyle(
                          fontSize: 16,
                          fontWeight: pw.FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                pw.SizedBox(height: 24),

                // Estadísticas Generales
                pw.Text(
                  'Estadísticas Generales',
                  style: pw.TextStyle(
                    fontSize: 20,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
                pw.SizedBox(height: 16),

                // Grid de estadísticas
                pw.Row(
                  children: [
                    pw.Expanded(
                      child: _buildPdfStatCard(
                        'Promedio general',
                        '118',
                        'mg/dL',
                        PdfColor.fromHex('#FBC318'),
                      ),
                    ),
                    pw.SizedBox(width: 12),
                    pw.Expanded(
                      child: _buildPdfStatCard(
                        '% en rango',
                        '72%',
                        'objetivo',
                        PdfColor.fromHex('#337536'),
                      ),
                    ),
                  ],
                ),
                pw.SizedBox(height: 12),
                pw.Row(
                  children: [
                    pw.Expanded(
                      child: _buildPdfStatCard(
                        'Pacientes activos',
                        '3',
                        'pacientes',
                        PdfColor.fromHex('#0073E6'),
                      ),
                    ),
                    pw.SizedBox(width: 12),
                    pw.Expanded(
                      child: _buildPdfStatCard(
                        'Alertas críticas',
                        '2',
                        'alertas',
                        PdfColor.fromHex('#C72331'),
                      ),
                    ),
                  ],
                ),
                pw.SizedBox(height: 24),

                // Resumen de Pacientes
                pw.Text(
                  'Resumen de Pacientes',
                  style: pw.TextStyle(
                    fontSize: 20,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
                pw.SizedBox(height: 16),

                // Tabla de pacientes
                pw.Table(
                  border: pw.TableBorder.all(
                    color: PdfColor.fromHex('#E0E6EB'),
                    width: 1,
                  ),
                  children: [
                    // Encabezado
                    pw.TableRow(
                      decoration: pw.BoxDecoration(
                        color: PdfColor.fromHex('#0073E6'),
                      ),
                      children: [
                        _buildPdfTableCell('Paciente', isHeader: true),
                        _buildPdfTableCell('Edad', isHeader: true),
                        _buildPdfTableCell('Promedio', isHeader: true),
                        _buildPdfTableCell('Estado', isHeader: true),
                      ],
                    ),
                    // Datos de pacientes
                    ...patientsSummary.asMap().entries.map((entry) {
                      final index = entry.key;
                      final patient = entry.value;
                      return pw.TableRow(
                        decoration: index.isEven
                            ? pw.BoxDecoration(color: PdfColor.fromHex('#F9FAFB'))
                            : null,
                        children: [
                          _buildPdfTableCell(patient['name']!),
                          _buildPdfTableCell('${patient['age']!} años'),
                          _buildPdfTableCell('${patient['avg']!} mg/dL', isBold: true),
                          _buildPdfTableCell(
                            patient['status']!,
                            textColor: _getStatusColor(patient['status']!),
                            isBold: true,
                          ),
                        ],
                      );
                    }).toList(),
                  ],
                ),
                pw.SizedBox(height: 24),

                // Rangos de Referencia
                pw.Text(
                  'Rangos de Referencia',
                  style: pw.TextStyle(
                    fontSize: 20,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
                pw.SizedBox(height: 16),

                pw.Table(
                  border: pw.TableBorder.all(
                    color: PdfColor.fromHex('#E0E6EB'),
                    width: 1,
                  ),
                  children: [
                    pw.TableRow(
                      decoration: pw.BoxDecoration(color: PdfColor.fromHex('#337536')),
                      children: [
                        _buildPdfTableCell('Normal', isHeader: true),
                        _buildPdfTableCell('70 - 100 mg/dl', isHeader: true),
                      ],
                    ),
                    pw.TableRow(
                      decoration: pw.BoxDecoration(color: PdfColor.fromHex('#FBC318')),
                      children: [
                        _buildPdfTableCell('Precaución', isHeader: true),
                        _buildPdfTableCell('100 - 140 mg/dl', isHeader: true),
                      ],
                    ),
                    pw.TableRow(
                      decoration: pw.BoxDecoration(color: PdfColor.fromHex('#C72331')),
                      children: [
                        _buildPdfTableCell('Crítico Alto', isHeader: true),
                        _buildPdfTableCell('> 140 mg/dl', isHeader: true),
                      ],
                    ),
                    pw.TableRow(
                      decoration: pw.BoxDecoration(color: PdfColor.fromHex('#C72331')),
                      children: [
                        _buildPdfTableCell('Hipoglucemia', isHeader: true),
                        _buildPdfTableCell('< 70 mg/dl', isHeader: true),
                      ],
                    ),
                  ],
                ),
                pw.SizedBox(height: 24),

                // Observaciones y Recomendaciones
                pw.Text(
                  'Observaciones Generales',
                  style: pw.TextStyle(
                    fontSize: 20,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
                pw.SizedBox(height: 12),

                _buildPdfObservationBox(
                  'Tendencia General',
                  'Los niveles promedio de glucosa se mantienen dentro del rango recomendado en la mayoría de los pacientes.',
                ),
                pw.SizedBox(height: 8),

                _buildPdfObservationBox(
                  'Alertas Críticas',
                  '2 pacientes presentan valores críticos recurrentes. Se recomienda ajuste de tratamiento y seguimiento cercano.',
                ),
                pw.SizedBox(height: 8),

                _buildPdfObservationBox(
                  'Monitoreo',
                  'Se detecta una tendencia ascendente leve en los últimos días. Continuar con el monitoreo frecuente.',
                ),
                pw.SizedBox(height: 24),

                // Nota al pie
                pw.Divider(),
                pw.SizedBox(height: 8),
                pw.Text(
                  'Este reporte es generado automáticamente por GlucPred. Los datos mostrados son un resumen de las mediciones registradas por todos los pacientes en el período seleccionado. Para evaluaciones individuales detalladas, consulte el perfil de cada paciente.',
                  style: pw.TextStyle(
                    fontSize: 10,
                    color: PdfColor.fromHex('#6C7C93'),
                    fontStyle: pw.FontStyle.italic,
                  ),
                  textAlign: pw.TextAlign.center,
                ),
              ],
            ),
          ];
        },
      ),
    );

    // Mostrar el PDF
    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => pdf.save(),
      name: 'Reporte_Pacientes_$_selectedPeriod\_$dateStr.pdf',
    );
  }

  pw.Widget _buildPdfStatCard(String title, String value, String unit, PdfColor color) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(16),
      decoration: pw.BoxDecoration(
        border: pw.Border.all(color: PdfColor.fromHex('#E0E6EB')),
        borderRadius: pw.BorderRadius.circular(8),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            title,
            style: pw.TextStyle(
              fontSize: 11,
              color: PdfColor.fromHex('#6C7C93'),
            ),
          ),
          pw.SizedBox(height: 8),
          pw.Text(
            value,
            style: pw.TextStyle(
              fontSize: 28,
              fontWeight: pw.FontWeight.bold,
              color: color,
            ),
          ),
          pw.Text(
            unit,
            style: pw.TextStyle(
              fontSize: 10,
              color: PdfColor.fromHex('#6C7C93'),
            ),
          ),
        ],
      ),
    );
  }

  pw.Widget _buildPdfTableCell(String text, {bool isHeader = false, bool isBold = false, PdfColor? textColor}) {
    return pw.Padding(
      padding: const pw.EdgeInsets.all(8),
      child: pw.Text(
        text,
        style: pw.TextStyle(
          fontSize: isHeader ? 12 : 11,
          fontWeight: (isHeader || isBold) ? pw.FontWeight.bold : pw.FontWeight.normal,
          color: textColor ?? (isHeader ? PdfColors.white : PdfColors.black),
        ),
        textAlign: pw.TextAlign.center,
      ),
    );
  }

  PdfColor _getStatusColor(String status) {
    switch (status) {
      case 'Normal':
        return PdfColor.fromHex('#337536');
      case 'Precaución':
        return PdfColor.fromHex('#FBC318');
      case 'Crítico':
        return PdfColor.fromHex('#C72331');
      default:
        return PdfColor.fromHex('#6C7C93');
    }
  }

  pw.Widget _buildPdfObservationBox(String title, String description) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(12),
      decoration: pw.BoxDecoration(
        color: PdfColor.fromHex('#F0F7FF'),
        borderRadius: pw.BorderRadius.circular(8),
        border: pw.Border.all(
          color: PdfColor.fromHex('#0073E6'),
          width: 1,
        ),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            '• $title',
            style: pw.TextStyle(
              fontSize: 12,
              fontWeight: pw.FontWeight.bold,
              color: PdfColor.fromHex('#0073E6'),
            ),
          ),
          pw.SizedBox(height: 4),
          pw.Text(
            description,
            style: pw.TextStyle(
              fontSize: 10,
              color: PdfColor.fromHex('#6C7C93'),
            ),
          ),
        ],
      ),
    );
  }
}

// Painter para la gráfica de niveles de glucosa
class _GlucoseChartPainter extends CustomPainter {
  final List<Map<String, dynamic>> records;
  final Map<int, Color> patientColors;

  _GlucoseChartPainter({
    required this.records,
    required this.patientColors,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (records.isEmpty) return;

    // Definir límites de la gráfica
    final chartLeft = 50.0;
    final chartTop = 10.0;
    final chartRight = 10.0;
    final chartBottom = 30.0;
    final chartWidth = size.width - chartLeft - chartRight;
    final chartHeight = size.height - chartTop - chartBottom;

    final paint = Paint()..style = PaintingStyle.fill;

    // Bandas de color de fondo
    // Hipoglucemia (<70)
    final hypoglycemiaHeight = chartHeight * 0.35;
    final hypoglycemiaRect = Rect.fromLTWH(
      chartLeft, 
      chartTop + chartHeight - hypoglycemiaHeight, 
      chartWidth, 
      hypoglycemiaHeight
    );
    paint.color = const Color(0xFFADD8E6);
    canvas.drawRect(hypoglycemiaRect, paint);

    // Normal (70-100)
    final normalHeight = chartHeight * 0.15;
    final normalRect = Rect.fromLTWH(
      chartLeft, 
      chartTop + chartHeight - hypoglycemiaHeight - normalHeight, 
      chartWidth, 
      normalHeight
    );
    paint.color = const Color(0xFF90EE90);
    canvas.drawRect(normalRect, paint);

    // Precaución (100-140)
    final cautionHeight = chartHeight * 0.20;
    final cautionRect = Rect.fromLTWH(
      chartLeft, 
      chartTop + chartHeight - hypoglycemiaHeight - normalHeight - cautionHeight, 
      chartWidth, 
      cautionHeight
    );
    paint.color = const Color(0xFFFFD966);
    canvas.drawRect(cautionRect, paint);

    // Crítico (>140)
    final criticalHeight = chartHeight * 0.30;
    final criticalRect = Rect.fromLTWH(
      chartLeft, 
      chartTop, 
      chartWidth, 
      criticalHeight
    );
    paint.color = const Color(0xFFFFB6C1);
    canvas.drawRect(criticalRect, paint);

    // Función para convertir mg/dL a posición Y
    double mgdlToY(double mgdl) {
      final clampedValue = mgdl.clamp(0.0, 200.0);
      return chartTop + chartHeight * (1 - (clampedValue / 200));
    }

    // Agrupar registros por paciente
    final Map<int, List<Map<String, dynamic>>> recordsByPatient = {};
    for (final record in records) {
      final patientId = record['patient_id'] as int;
      recordsByPatient.putIfAbsent(patientId, () => []).add(record);
    }

    // Dibujar líneas para cada paciente
    for (final entry in recordsByPatient.entries) {
      final patientId = entry.key;
      final patientRecords = entry.value;
      final color = patientColors[patientId] ?? const Color(0xFF0073E6);

      if (patientRecords.length < 2) continue;

      // Crear puntos para la línea
      final points = <Offset>[];
      final maxIndex = patientRecords.length - 1;
      
      for (int i = 0; i < patientRecords.length; i++) {
        final x = chartLeft + (chartWidth * i / maxIndex);
        final y = mgdlToY(patientRecords[i]['glucose_value']);
        points.add(Offset(x, y));
      }

      // Dibujar línea
      final linePaint = Paint()
        ..color = color
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.5
        ..strokeCap = StrokeCap.round;

      for (int i = 0; i < points.length - 1; i++) {
        canvas.drawLine(points[i], points[i + 1], linePaint);
      }

      // Dibujar puntos
      final pointPaint = Paint()
        ..color = color
        ..style = PaintingStyle.fill;

      final pointBorderPaint = Paint()
        ..color = Colors.white
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.5;

      for (final point in points) {
        canvas.drawCircle(point, 5, pointBorderPaint);
        canvas.drawCircle(point, 5, pointPaint);
      }
    }

    // Dibujar etiquetas del eje Y
    final textPainter = TextPainter(
      textAlign: TextAlign.right,
      textDirection: ui.TextDirection.ltr,
    );

    final yLabels = ['200', '150', '100', '50', '0'];
    for (int i = 0; i < yLabels.length; i++) {
      final y = chartTop + (chartHeight * i / (yLabels.length - 1));
      textPainter.text = TextSpan(
        text: yLabels[i],
        style: const TextStyle(fontSize: 10, color: Color(0xFF6C7C93)),
      );
      textPainter.layout();
      textPainter.paint(canvas, Offset(chartLeft - 25, y - 5));
    }

    // Etiqueta "mg/dl"
    textPainter.text = const TextSpan(
      text: 'mg/dl',
      style: TextStyle(fontSize: 10, color: Color(0xFF6C7C93)),
    );
    textPainter.layout();
    textPainter.paint(canvas, Offset(5, chartTop + chartHeight / 2 - 10));

    // Dibujar etiquetas del eje X (simplificadas)
    final xLabelCount = 6;
    for (int i = 0; i < xLabelCount; i++) {
      final x = chartLeft + (chartWidth * i / (xLabelCount - 1));
      final recordIndex = (records.length - 1) * i ~/ (xLabelCount - 1);
      if (recordIndex < records.length) {
        final time = DateTime.parse(records[recordIndex]['measurement_time']);
        final label = '${time.day}/${time.month}';
        
        textPainter.text = TextSpan(
          text: label,
          style: const TextStyle(fontSize: 10, color: Color(0xFF6C7C93)),
        );
        textPainter.layout();
        textPainter.paint(canvas, Offset(x - 15, chartTop + chartHeight + 5));
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
