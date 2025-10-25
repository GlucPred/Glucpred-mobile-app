import 'package:flutter/material.dart';
import '../widgets/glucose_chart_widget.dart';
import '../services/glucose_service.dart';
import '../models/trend_point.dart';

class ChartsScreen extends StatefulWidget {
  const ChartsScreen({super.key});

  @override
  State<ChartsScreen> createState() => _ChartsScreenState();
}

class _ChartsScreenState extends State<ChartsScreen> {
  int _selectedTab = 0;
  late List<TrendPoint> _chartData;
  
  @override
  void initState() {
    super.initState();
    _loadChartData();
  }

  void _loadChartData() {
    setState(() {
      switch (_selectedTab) {
        case 0: // Hoy
          _chartData = GlucoseService.getTrendDataForToday();
          break;
        case 1: // Semana
          _chartData = GlucoseService.getTrendDataForWeek();
          break;
        case 2: // Mes
          _chartData = GlucoseService.getTrendDataForMonth();
          break;
        default:
          _chartData = GlucoseService.getTrendDataForToday();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final stats = _calculateStats();
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Gráfica y reportes'),
        actions: [
          IconButton(
            icon: const Icon(Icons.download, color: Color(0xFF0073E6)),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Descargar reporte')),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
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
                      GlucoseChartWidget(data: _chartData, period: _selectedTab),
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
                      const Color(0xFFFBC318),
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
                      const Color(0xFFFBC318),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTabButton(String label, int index) {
    final isSelected = _selectedTab == index;
    return Expanded(
      child: ElevatedButton(
        onPressed: () {
          setState(() {
            _selectedTab = index;
            _loadChartData();
          });
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: isSelected ? const Color(0xFF0073E6) : Colors.white,
          foregroundColor: isSelected ? Colors.white : Colors.grey,
          elevation: isSelected ? 2 : 0,
          padding: const EdgeInsets.symmetric(vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
            side: BorderSide(
              color: isSelected ? const Color(0xFF0073E6) : const Color(0xFFE0E6EB),
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
    return Column(
      children: [
        Row(
          children: [
            Expanded(child: _buildLegendItem('Normal (70 - 100)', const Color(0xFF337536))),
            const SizedBox(width: 8),
            Expanded(child: _buildLegendItem('Precaución (100 - 140)', const Color(0xFFFBC318))),
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
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        border: Border.all(color: color, width: 2),
        borderRadius: BorderRadius.circular(8),
        color: Colors.white,
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
                color: const Color(0xFF6C7C93),
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
    if (_chartData.isEmpty) {
      return {'average': 110, 'inRange': 78, 'min': 85, 'max': 140};
    }
    
    final values = _chartData.map((p) => p.value).toList();
    final average = (values.reduce((a, b) => a + b) / values.length).round();
    final min = values.reduce((a, b) => a < b ? a : b).round();
    final max = values.reduce((a, b) => a > b ? a : b).round();
    final inRange = ((values.where((v) => v >= 70 && v <= 140).length / values.length) * 100).round();
    
    return {
      'average': average,
      'inRange': inRange,
      'min': min,
      'max': max,
    };
  }
}
