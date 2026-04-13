import 'package:flutter/material.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:glucpred/core/config/theme.dart';
import 'package:glucpred/core/widgets/glucose_chart_widget.dart';
import 'package:glucpred/features/records/data/services/records_service.dart';
import 'package:glucpred/features/auth/data/services/auth_service.dart';
import 'package:glucpred/features/records/domain/models/trend_point.dart';

class ChartsScreen extends StatefulWidget {
  const ChartsScreen({super.key});

  @override
  State<ChartsScreen> createState() => _ChartsScreenState();
}

class _ChartsScreenState extends State<ChartsScreen> {
  int _selectedTab = 0;
  bool _isLoading = true;
  List<TrendPoint> _chartData = [];
  Map<String, dynamic>? _statistics;
  
  @override
  void initState() {
    super.initState();
    _loadChartData();
  }

  Future<void> _loadChartData() async {
    setState(() {
      _isLoading = true;
    });

    int hours;
    switch (_selectedTab) {
      case 0: // Hoy
        hours = 24;
        break;
      case 1: // Semana
        hours = 168; // 7 días
        break;
      case 2: // Mes
        hours = 720; // 30 días
        break;
      default:
        hours = 24;
    }

    // Cargar tendencia
    final trendResult = await RecordsService.getTrend(hours: hours);
    
    // Cargar estadísticas
    final statsResult = await RecordsService.getStatistics(hours: hours);

    if (trendResult['success']) {
      final records = trendResult['records'] as List;
      
      setState(() {
        _chartData = records.map((r) {
          final dt = DateTime.parse(r['measurement_time']);
          return TrendPoint(
            timestamp: dt,
            value: r['glucose_value'].toDouble(),
            time: '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}',
          );
        }).toList();
      });
    } else {
      setState(() {
        _chartData = [];
      });
    }

    if (statsResult['success']) {
      setState(() {
        _statistics = statsResult['statistics'];
      });
    } else {
      setState(() {
        _statistics = null;
      });
    }

    setState(() {
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final stats = _calculateStats();
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Gráfica y reportes'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadChartData,
            tooltip: 'Actualizar',
          ),
          IconButton(
            icon: const Icon(Icons.download, color: Color(0xFF0073E6)),
            onPressed: _chartData.isEmpty ? null : () => _generatePdfReport(),
            tooltip: 'Descargar reporte PDF',
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadChartData,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Tabs de periodo
                      Row(
                        children: [
                          _buildTabButton('Hoy', 0),
                          const SizedBox(width: 8),
                          _buildTabButton('Semana', 1),
                          const SizedBox(width: 8),
                          _buildTabButton('Mes', 2),
                        ],
                      ),
                      const SizedBox(height: 24),
                      
                      // Mostrar mensaje si no hay datos
                      if (_chartData.isEmpty)
                        Card(
                          child: Padding(
                            padding: const EdgeInsets.all(32.0),
                            child: Center(
                              child: Column(
                                children: [
                                  Icon(
                                    Icons.info_outline,
                                    size: 64,
                                    color: Colors.grey[400],
                                  ),
                                  const SizedBox(height: 16),
                                  Text(
                                    'No hay datos para este período',
                                    style: TextStyle(
                                      fontSize: 16,
                                      color: Colors.grey[600],
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    _getEmptyMessage(),
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Colors.grey[500],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        )
                      else ...[
                        // Gráfico
                        Card(
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Icon(Icons.show_chart, color: Colors.blue[700], size: 24),
                                    const SizedBox(width: 8),
                                    const Text(
                                      'Niveles de glucosa',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 16),
                                Padding(
                                  padding: const EdgeInsets.fromLTRB(0, 0, 0, 0),
                                  child: GlucoseChartWidget(data: _chartData, period: _selectedTab),
                                ),
                                const SizedBox(height: 20),
                                _buildLegend(),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        
                        // Estadísticas
                        Row(
                          children: [
                            Expanded(
                              child: _buildStatCard(
                                'Promedio',
                      '${stats['average']}',
                      'mg/dl',
                      isDark ? AppTheme.warningColorBright : AppTheme.warningColor,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildStatCard(
                      '% en rango',
                      '${stats['inRange']}%',
                      'objetivo',
                      const Color(0xFF337536),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _buildStatCard(
                      'Mínimo',
                      '${stats['min']}',
                      'mg/dl',
                      const Color(0xFF0073E6),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildStatCard(
                      'Máximo',
                      '${stats['max']}',
                      'mg/dl',
                      isDark ? AppTheme.warningColorBright : AppTheme.warningColor,
                    ),
                  ),
                ],
              ),
                      ],
                    ],
                  ),
                ),
              ),
            ),
    );
  }

  String _getEmptyMessage() {
    switch (_selectedTab) {
      case 0:
        return 'No se han registrado mediciones en las últimas 24 horas';
      case 1:
        return 'No se han registrado mediciones en los últimos 7 días';
      case 2:
        return 'No se han registrado mediciones en los últimos 30 días';
      default:
        return 'No se han registrado mediciones';
    }
  }

  Widget _buildTabButton(String label, int index) {
    final isSelected = _selectedTab == index;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Expanded(
      child: ElevatedButton(
        onPressed: () {
          setState(() {
            _selectedTab = index;
            _loadChartData();
          });
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: isSelected 
              ? const Color(0xFF0073E6) 
              : (isDark ? const Color(0xFF1A1F3A) : Colors.white),
          foregroundColor: isSelected 
              ? Colors.white 
              : (isDark ? const Color(0xFFB3C3D3) : Colors.grey),
          elevation: isSelected ? 2 : 0,
          padding: const EdgeInsets.symmetric(vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
            side: BorderSide(
              color: isSelected 
                  ? const Color(0xFF0073E6) 
                  : (isDark ? const Color(0xFF2C3E50) : const Color(0xFFE0E6EB)),
              width: 1,
            ),
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
          ),
        ),
      ),
    );
  }

  Widget _buildLegend() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Column(
      children: [
        Row(
          children: [
            Expanded(child: _buildLegendItem('Normal (70 - 100)', const Color(0xFF337536))),
            const SizedBox(width: 8),
            Expanded(child: _buildLegendItem('Precaución (100 - 140)', isDark ? AppTheme.warningColorBright : AppTheme.warningColor)),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(child: _buildLegendItem('Crítico (>140)', const Color(0xFFC72331))),
            const SizedBox(width: 8),
            Expanded(child: _buildLegendItem('Hipoglucemia (<70)', const Color(0xFFC72331))),
          ],
        ),
      ],
    );
  }

  Widget _buildLegendItem(String label, Color color) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        border: Border.all(color: color, width: 2),
        borderRadius: BorderRadius.circular(8),
        color: isDark ? const Color(0xFF1A1F3A) : Colors.white,
      ),
      child: Row(
        children: [
          Container(
            width: 20,
            height: 20,
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
                fontSize: 12,
                color: isDark ? const Color(0xFFB3C3D3) : const Color(0xFF6C7C93),
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(String label, String value, String unit, Color color) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              value,
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            Text(
              unit,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Map<String, int> _calculateStats() {
    if (_chartData.isEmpty || _statistics == null) {
      return {'average': 0, 'inRange': 0, 'min': 0, 'max': 0};
    }

    final totalReadings = _statistics!['total_readings'] ?? 0;
    final average = (_statistics!['average'] ?? 0.0).round();
    final min = (_statistics!['min'] ?? 0.0).round();
    final max = (_statistics!['max'] ?? 0.0).round();
    final classifications = _statistics!['classifications'] ?? {};
    
    final inRange = totalReadings > 0
        ? RecordsService.calculateNormalPercentage(classifications, totalReadings).round()
        : 0;

    return {
      'average': average,
      'inRange': inRange,
      'min': min,
      'max': max,
    };
  }

  String _getPeriodName() {
    switch (_selectedTab) {
      case 0:
        return 'Hoy';
      case 1:
        return 'Semana';
      case 2:
        return 'Mes';
      default:
        return 'Hoy';
    }
  }

  Future<void> _generatePdfReport() async {
    final stats = _calculateStats();
    final pdf = pw.Document();
    
    // Obtener datos del paciente
    final profileResult = await AuthService.getProfile();
    String patientName = 'Paciente';
    String patientAge = 'N/A';
    String patientWeight = 'N/A';
    String patientHeight = 'N/A';
    String patientIMC = 'N/A';
    
    if (profileResult['success']) {
      final user = profileResult['user'];
      final profile = profileResult['profile'];
      
      patientName = user['nombre_completo'] ?? 'Paciente';
      patientAge = profile['edad']?.toString() ?? 'N/A';
      patientWeight = profile['peso']?.toString() ?? 'N/A';
      patientHeight = profile['altura']?.toString() ?? 'N/A';
      
      // Calcular IMC si hay datos
      if (profile['peso'] != null && profile['altura'] != null) {
        final peso = profile['peso'].toDouble();
        final altura = profile['altura'].toDouble();
        if (altura > 0) {
          final imc = peso / (altura * altura);
          patientIMC = imc.toStringAsFixed(1);
        }
      }
    }
    
    // Obtener fecha actual
    final now = DateTime.now();
    final dateStr = '${now.day.toString().padLeft(2, '0')}/${now.month.toString().padLeft(2, '0')}/${now.year}';
    final timeStr = '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}';

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
                          'Reporte de Glucosa',
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

                // Información del Paciente
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
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Row(
                        children: [
                          pw.Icon(
                            pw.IconData(0xe491), // person icon
                            size: 20,
                            color: PdfColor.fromHex('#0073E6'),
                          ),
                          pw.SizedBox(width: 8),
                          pw.Text(
                            'Información del Paciente',
                            style: pw.TextStyle(
                              fontSize: 14,
                              fontWeight: pw.FontWeight.bold,
                              color: PdfColor.fromHex('#0073E6'),
                            ),
                          ),
                        ],
                      ),
                      pw.SizedBox(height: 12),
                      pw.Row(
                        children: [
                          pw.Expanded(
                            child: pw.Column(
                              crossAxisAlignment: pw.CrossAxisAlignment.start,
                              children: [
                                pw.Text(
                                  'Nombre:',
                                  style: pw.TextStyle(
                                    fontSize: 10,
                                    color: PdfColor.fromHex('#6C7C93'),
                                  ),
                                ),
                                pw.SizedBox(height: 4),
                                pw.Text(
                                  patientName,
                                  style: pw.TextStyle(
                                    fontSize: 12,
                                    fontWeight: pw.FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          pw.SizedBox(width: 16),
                          pw.Expanded(
                            child: pw.Column(
                              crossAxisAlignment: pw.CrossAxisAlignment.start,
                              children: [
                                pw.Text(
                                  'Edad:',
                                  style: pw.TextStyle(
                                    fontSize: 10,
                                    color: PdfColor.fromHex('#6C7C93'),
                                  ),
                                ),
                                pw.SizedBox(height: 4),
                                pw.Text(
                                  '$patientAge años',
                                  style: pw.TextStyle(
                                    fontSize: 12,
                                    fontWeight: pw.FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      pw.SizedBox(height: 12),
                      pw.Row(
                        children: [
                          pw.Expanded(
                            child: pw.Column(
                              crossAxisAlignment: pw.CrossAxisAlignment.start,
                              children: [
                                pw.Text(
                                  'Peso:',
                                  style: pw.TextStyle(
                                    fontSize: 10,
                                    color: PdfColor.fromHex('#6C7C93'),
                                  ),
                                ),
                                pw.SizedBox(height: 4),
                                pw.Text(
                                  '$patientWeight kg',
                                  style: pw.TextStyle(
                                    fontSize: 12,
                                    fontWeight: pw.FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          pw.SizedBox(width: 16),
                          pw.Expanded(
                            child: pw.Column(
                              crossAxisAlignment: pw.CrossAxisAlignment.start,
                              children: [
                                pw.Text(
                                  'Altura:',
                                  style: pw.TextStyle(
                                    fontSize: 10,
                                    color: PdfColor.fromHex('#6C7C93'),
                                  ),
                                ),
                                pw.SizedBox(height: 4),
                                pw.Text(
                                  '$patientHeight m',
                                  style: pw.TextStyle(
                                    fontSize: 12,
                                    fontWeight: pw.FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          pw.SizedBox(width: 16),
                          pw.Expanded(
                            child: pw.Column(
                              crossAxisAlignment: pw.CrossAxisAlignment.start,
                              children: [
                                pw.Text(
                                  'IMC:',
                                  style: pw.TextStyle(
                                    fontSize: 10,
                                    color: PdfColor.fromHex('#6C7C93'),
                                  ),
                                ),
                                pw.SizedBox(height: 4),
                                pw.Text(
                                  patientIMC,
                                  style: pw.TextStyle(
                                    fontSize: 12,
                                    fontWeight: pw.FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
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
                        'Período: ${_getPeriodName()}',
                        style: pw.TextStyle(
                          fontSize: 16,
                          fontWeight: pw.FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                pw.SizedBox(height: 24),

                // Título de estadísticas
                pw.Text(
                  'Estadísticas de Glucosa',
                  style: pw.TextStyle(
                    fontSize: 20,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
                pw.SizedBox(height: 16),

                // Tabla de estadísticas
                pw.Table(
                  border: pw.TableBorder.all(
                    color: PdfColor.fromHex('#E0E6EB'),
                    width: 1,
                  ),
                  children: [
                    // Encabezado de tabla
                    pw.TableRow(
                      decoration: pw.BoxDecoration(
                        color: PdfColor.fromHex('#0073E6'),
                      ),
                      children: [
                        _buildTableCell('Métrica', isHeader: true),
                        _buildTableCell('Valor', isHeader: true),
                        _buildTableCell('Unidad', isHeader: true),
                        _buildTableCell('Estado', isHeader: true),
                      ],
                    ),
                    // Promedio
                    pw.TableRow(
                      children: [
                        _buildTableCell('Promedio de glucosa'),
                        _buildTableCell('${stats['average']}', isBold: true),
                        _buildTableCell('mg/dl'),
                        _buildTableCell(_getStatusForValue(stats['average']!)),
                      ],
                    ),
                    // Porcentaje en rango
                    pw.TableRow(
                      decoration: pw.BoxDecoration(
                        color: PdfColor.fromHex('#F9FAFB'),
                      ),
                      children: [
                        _buildTableCell('Porcentaje en rango'),
                        _buildTableCell('${stats['inRange']}%', isBold: true),
                        _buildTableCell('del tiempo'),
                        _buildTableCell(
                          stats['inRange']! >= 70 ? 'Excelente' : stats['inRange']! >= 50 ? 'Bueno' : 'Necesita mejora',
                        ),
                      ],
                    ),
                    // Mínimo
                    pw.TableRow(
                      children: [
                        _buildTableCell('Valor mínimo'),
                        _buildTableCell('${stats['min']}', isBold: true),
                        _buildTableCell('mg/dl'),
                        _buildTableCell(_getStatusForValue(stats['min']!)),
                      ],
                    ),
                    // Máximo
                    pw.TableRow(
                      decoration: pw.BoxDecoration(
                        color: PdfColor.fromHex('#F9FAFB'),
                      ),
                      children: [
                        _buildTableCell('Valor máximo'),
                        _buildTableCell('${stats['max']}', isBold: true),
                        _buildTableCell('mg/dl'),
                        _buildTableCell(_getStatusForValue(stats['max']!)),
                      ],
                    ),
                  ],
                ),
                pw.SizedBox(height: 24),

                // Rangos de referencia
                pw.Text(
                  'Rangos de Referencia',
                  style: pw.TextStyle(
                    fontSize: 20,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
                pw.SizedBox(height: 16),

                // Tabla de rangos
                pw.Table(
                  border: pw.TableBorder.all(
                    color: PdfColor.fromHex('#E0E6EB'),
                    width: 1,
                  ),
                  children: [
                    pw.TableRow(
                      decoration: pw.BoxDecoration(
                        color: PdfColor.fromHex('#337536'),
                      ),
                      children: [
                        _buildTableCell('Normal', isHeader: true),
                        _buildTableCell('70 - 100 mg/dl', isHeader: true),
                      ],
                    ),
                    pw.TableRow(
                      decoration: pw.BoxDecoration(
                        color: PdfColor.fromHex('#B8860B'),
                      ),
                      children: [
                        _buildTableCell('Precaución', isHeader: true),
                        _buildTableCell('100 - 140 mg/dl', isHeader: true),
                      ],
                    ),
                    pw.TableRow(
                      decoration: pw.BoxDecoration(
                        color: PdfColor.fromHex('#C72331'),
                      ),
                      children: [
                        _buildTableCell('Crítico Alto', isHeader: true),
                        _buildTableCell('> 140 mg/dl', isHeader: true),
                      ],
                    ),
                    pw.TableRow(
                      decoration: pw.BoxDecoration(
                        color: PdfColor.fromHex('#C72331'),
                      ),
                      children: [
                        _buildTableCell('Hipoglucemia', isHeader: true),
                        _buildTableCell('< 70 mg/dl', isHeader: true),
                      ],
                    ),
                  ],
                ),
                pw.SizedBox(height: 24),

                // Recomendaciones
                pw.Text(
                  'Recomendaciones',
                  style: pw.TextStyle(
                    fontSize: 20,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
                pw.SizedBox(height: 12),
                
                _buildRecommendationBox(
                  'Monitoreo Regular',
                  'Continúa registrando tus niveles de glucosa diariamente para un mejor control.',
                ),
                pw.SizedBox(height: 8),
                
                _buildRecommendationBox(
                  'Alimentación Saludable',
                  'Mantén una dieta balanceada, baja en azúcares procesados y rica en fibra.',
                ),
                pw.SizedBox(height: 8),
                
                _buildRecommendationBox(
                  'Actividad Física',
                  'Realiza ejercicio moderado al menos 30 minutos al día, 5 días a la semana.',
                ),
                pw.SizedBox(height: 8),
                
                _buildRecommendationBox(
                  'Consulta Médica',
                  'Mantén un seguimiento regular con tu médico y reporta cualquier anomalía.',
                ),
                pw.SizedBox(height: 24),

                // Nota al pie
                pw.Divider(),
                pw.SizedBox(height: 8),
                pw.Text(
                  'Este reporte es generado automáticamente por GlucPred. Los datos mostrados son un resumen de las mediciones registradas en el período seleccionado. Para un diagnóstico preciso, consulta con tu médico.',
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

    // Mostrar el PDF para previsualizar o descargar
    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => pdf.save(),
      name: 'Reporte_Glucosa_${_getPeriodName()}_$dateStr.pdf',
    );
  }

  pw.Widget _buildTableCell(String text, {bool isHeader = false, bool isBold = false}) {
    return pw.Padding(
      padding: const pw.EdgeInsets.all(8),
      child: pw.Text(
        text,
        style: pw.TextStyle(
          fontSize: isHeader ? 12 : 11,
          fontWeight: (isHeader || isBold) ? pw.FontWeight.bold : pw.FontWeight.normal,
          color: isHeader ? PdfColors.white : PdfColors.black,
        ),
        textAlign: pw.TextAlign.center,
      ),
    );
  }

  String _getStatusForValue(int value) {
    if (value < 70) {
      return 'Hipoglucemia';
    } else if (value >= 70 && value <= 100) {
      return 'Normal';
    } else if (value > 100 && value <= 140) {
      return 'Precaución';
    } else {
      return 'Crítico Alto';
    }
  }

  pw.Widget _buildRecommendationBox(String title, String description) {
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
