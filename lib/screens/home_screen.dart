import 'package:flutter/material.dart';
import '../services/records_service.dart';
import '../widgets/glucose_card.dart';
import '../widgets/risk_card.dart';
import '../widgets/trend_chart.dart';
import '../models/glucose_reading.dart';
import '../models/risk_prediction.dart';
import '../models/trend_point.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool _isLoading = true;
  GlucoseReading? currentReading;
  RiskPrediction? riskPrediction;
  List<TrendPoint> trendData = [];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
    });

    // Cargar última medición
    final latestResult = await RecordsService.getLatestReading();
    
    // Cargar tendencia de las últimas 12 horas
    final trendResult = await RecordsService.getTrend(hours: 12);

    if (latestResult['success']) {
      final record = latestResult['record'];
      
      setState(() {
        currentReading = GlucoseReading(
          value: record['glucose_value'].toDouble(),
          timestamp: DateTime.parse(record['measurement_time']),
          status: _mapClassificationToStatus(record['classification']),
        );
      });
    }

    if (trendResult['success']) {
      final records = trendResult['records'] as List;
      
      setState(() {
        trendData = records.map((r) {
          final dt = DateTime.parse(r['measurement_time']);
          return TrendPoint(
            timestamp: dt,
            value: r['glucose_value'].toDouble(),
            time: '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}',
          );
        }).toList();
      });
    }

    // Generar predicción de riesgo basada en la última medición
    if (currentReading != null) {
      setState(() {
        riskPrediction = _generateRiskPrediction(currentReading!);
      });
    }

    setState(() {
      _isLoading = false;
    });

    if (!latestResult['success']) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(latestResult['message'] ?? 'Error al cargar datos'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  String _mapClassificationToStatus(String classification) {
    switch (classification.toLowerCase()) {
      case 'bajo':
        return 'low';
      case 'normal':
        return 'normal';
      case 'alto':
      case 'critico':
        return 'high';
      default:
        return 'normal';
    }
  }

  RiskPrediction _generateRiskPrediction(GlucoseReading reading) {
    String level;
    String description;
    
    if (reading.value < 70) {
      level = 'high';
      description = 'Riesgo de hipoglucemia - Nivel bajo detectado';
    } else if (reading.value > 180) {
      level = 'high';
      description = 'Riesgo de hiperglucemia - Nivel crítico detectado';
    } else if (reading.value > 140) {
      level = 'medium';
      description = 'Ligera tendencia al alza detectada';
    } else {
      level = 'low';
      description = 'Tu nivel de glucosa se mantiene estable';
    }
    
    return RiskPrediction(
      level: level,
      timeFrame: 'hace ${_getTimeAgo(reading.timestamp)}',
      description: description,
    );
  }

  String _getTimeAgo(DateTime timestamp) {
    final diff = DateTime.now().difference(timestamp);
    if (diff.inMinutes < 60) {
      return '${diff.inMinutes} minutos';
    } else if (diff.inHours < 24) {
      return '${diff.inHours} horas';
    } else {
      return '${diff.inDays} días';
    }
  }

  Future<void> _refreshData() async {
    await _loadData();
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Datos actualizados'),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Monitoreo de la glucosa'),
        ),
        body: const Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    // Si no hay datos, mostrar mensaje
    if (currentReading == null || riskPrediction == null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Monitoreo de la glucosa'),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.info_outline, size: 64, color: Colors.grey),
              const SizedBox(height: 16),
              const Text(
                'No hay datos disponibles',
                style: TextStyle(fontSize: 18, color: Colors.grey),
              ),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: _refreshData,
                icon: const Icon(Icons.refresh),
                label: const Text('Actualizar'),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Monitoreo de la glucosa'),
        actions: [
          IconButton(
            icon: const Icon(Icons.share, color: Color(0xFF0073E6)),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Compartir funcionalidad próximamente'),
                ),
              );
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _refreshData,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              GlucoseCard(reading: currentReading!),
              const SizedBox(height: 16),
              RiskCard(prediction: riskPrediction!),
              const SizedBox(height: 16),
              TrendChart(data: trendData),
              const SizedBox(height: 80), // Espacio para el bottom nav
            ],
          ),
        ),
      ),
    );
  }
}
