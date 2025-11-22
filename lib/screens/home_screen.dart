import 'dart:async';
import 'package:flutter/material.dart';
import '../services/records_service.dart';
import '../services/analysis_service.dart';
import '../services/health_connect_service.dart';
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
  Timer? _updateTimer;
  Map<String, dynamic>? _lastAnalysisResult; // Última respuesta del análisis

  // Controllers para el modal de ingreso
  final TextEditingController _glucoseController = TextEditingController();
  final TextEditingController _insulinController = TextEditingController();
  final TextEditingController _carbsController = TextEditingController();
  bool _showInputModal = false;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _loadData(isInitial: true);
    _startAutoUpdate();
  }

  @override
  void dispose() {
    _updateTimer?.cancel();
    _glucoseController.dispose();
    _insulinController.dispose();
    _carbsController.dispose();
    super.dispose();
  }

  /// Inicia actualización automática cada 5 segundos (para pruebas)
  /// TODO: Cambiar a Duration(minutes: 5) en producción
  void _startAutoUpdate() {
    _updateTimer = Timer.periodic(const Duration(seconds: 5), (timer) {
      if (mounted) {
        // Actualización automática en silencio (sin mostrar errores)
        _loadData(isInitial: false, silentError: true);
      }
    });
  }

  Future<void> _loadData({bool isInitial = false, bool silentError = false}) async {
    // Solo mostrar loading en la carga inicial
    if (isInitial) {
      setState(() {
        _isLoading = true;
      });
    }

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

    // Solo cambiar el estado de loading en la carga inicial
    if (isInitial) {
      setState(() {
        _isLoading = false;
      });
    }

    // Solo mostrar error si no es silencioso Y el mensaje no es "No hay mediciones"
    if (!latestResult['success'] && !silentError) {
      final message = latestResult['message'] ?? 'Error al cargar datos';
      // No mostrar SnackBar si es el error de "no hay mediciones" (usuario nuevo)
      if (message != 'No hay mediciones registradas' && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(message),
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
    
    // Si tenemos datos del último análisis, usarlos
    if (_lastAnalysisResult != null) {
      final alertLevel = _lastAnalysisResult!['alert_level']?.toString().toLowerCase() ?? 'bajo';
      
      // Mapear alert_level del backend a nivel local
      if (alertLevel.contains('alto') || alertLevel.contains('crítico')) {
        level = 'high';
      } else if (alertLevel.contains('medio')) {
        level = 'medium';
      } else {
        level = 'low';
      }
      
      description = _lastAnalysisResult!['recommendation'] ?? 'Continuar con monitoreo regular';
      
      return RiskPrediction(
        level: level,
        timeFrame: 'hace ${_getTimeAgo(reading.timestamp)}',
        description: description,
        prediction: _lastAnalysisResult!['prediction'],
        probabilities: Map<String, double>.from(
          (_lastAnalysisResult!['probabilities'] as Map).map(
            (key, value) => MapEntry(key.toString(), (value as num).toDouble()),
          ),
        ),
        alertLevel: _lastAnalysisResult!['alert_level'],
      );
    }
    
    // Fallback a lógica local si no hay análisis previo
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
    await _loadData(isInitial: false);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Datos actualizados'),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  void _openInputModal() {
    setState(() {
      _showInputModal = true;
    });
  }

  void _closeInputModal() {
    setState(() {
      _showInputModal = false;
    });
  }

  Future<void> _submitInitialData() async {
    // Validar campos
    final glucose = double.tryParse(_glucoseController.text);
    final insulin = double.tryParse(_insulinController.text);
    final carbs = double.tryParse(_carbsController.text);

    if (glucose == null || insulin == null || carbs == null) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Por favor, ingresa valores válidos'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (!mounted) return;

    setState(() {
      _isSubmitting = true;
    });

    try {
      // 1. Leer datos de Health Connect
      final healthData = await HealthConnectService.readHealthData();
      
      // Log de datos de Health Connect
      print('═══════════════════════════════════════════════════════');
      print('📊 DATOS DE HEALTH CONNECT:');
      print('  ${healthData['is_real_data'] == true ? "✅ DATOS REALES" : "⚠️  DATOS DEFAULT (sin permisos o sin datos)"}');
      print('  ❤️  Frecuencia cardíaca: ${healthData['heart_rate']} bpm');
      print('  👟 Pasos (15 min): ${healthData['steps_15min']}');
      print('  🔥 Calorías (15 min): ${healthData['calories_15min']} kcal');
      print('═══════════════════════════════════════════════════════');
      print('📝 DATOS DEL USUARIO:');
      print('  💉 Glucosa: $glucose mg/dL');
      print('  💊 Insulina (30 min): $insulin unidades');
      print('  🍞 Carbohidratos (30 min): $carbs gramos');
      print('  🕐 Hora del día: ${DateTime.now().hour}');
      print('═══════════════════════════════════════════════════════');
      print('🚀 ENVIANDO AL BACKEND /api/analysis/predict...');
      print('═══════════════════════════════════════════════════════');

      // 2. Enviar predicción al backend
      final result = await AnalysisService.predictEpisode(
        glucose: glucose,
        insulin30min: insulin,
        carbs30min: carbs,
        heartRate: healthData['heart_rate'],
        steps15min: healthData['steps_15min'],
        calories15min: healthData['calories_15min'],
      );
      
      // Log de respuesta del backend
      print('📥 RESPUESTA DEL BACKEND:');
      print('  ✅ Éxito: ${result['success']}');
      if (result['success']) {
        print('  🎯 Predicción: ${result['prediction']}');
        print('  ⚠️  Nivel de alerta: ${result['alert_level']}');
        print('  💡 Recomendación: ${result['recommendation']}');
        print('  📊 Probabilidades:');
        final probs = result['probabilities'] as Map<String, dynamic>;
        probs.forEach((key, value) {
          final percentage = (value * 100).toStringAsFixed(1);
          print('     - $key: $percentage%');
        });
      } else {
        print('  ❌ Error: ${result['message']}');
      }
      print('═══════════════════════════════════════════════════════');

      setState(() {
        _isSubmitting = false;
      });

      if (result['success']) {
        // Guardar resultado del análisis para usarlo en la UI
        setState(() {
          _lastAnalysisResult = result;
        });
        
        _closeInputModal();
        
        // Limpiar campos
        _glucoseController.clear();
        _insulinController.clear();
        _carbsController.clear();

        // Mostrar resultado de la predicción
        _showPredictionResult(
          prediction: result['prediction'],
          alertLevel: result['alert_level'],
          recommendation: result['recommendation'],
          probabilities: result['probabilities'],
        );

        // Recargar datos para actualizar la UI
        _loadData(isInitial: false);
      } else {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result['message'] ?? 'Error al realizar predicción'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      setState(() {
        _isSubmitting = false;
      });
      
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _showPredictionResult({
    required String prediction,
    required String alertLevel,
    required String recommendation,
    required Map<String, dynamic> probabilities,
  }) {
    Color alertColor;
    IconData alertIcon;

    switch (alertLevel) {
      case 'Alto':
        alertColor = const Color(0xFFC72331);
        alertIcon = Icons.warning_amber_rounded;
        break;
      case 'Medio':
        alertColor = const Color(0xFFFBC318);
        alertIcon = Icons.info_outline;
        break;
      default:
        alertColor = const Color(0xFF337536);
        alertIcon = Icons.check_circle_outline;
    }

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(alertIcon, color: alertColor, size: 28),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                'Predicción: $prediction',
                style: TextStyle(color: alertColor),
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Nivel de alerta: $alertLevel',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Text(recommendation),
            const SizedBox(height: 16),
            const Text(
              'Probabilidades:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            ...probabilities.entries.map((entry) {
              final percentage = (entry.value * 100).toStringAsFixed(1);
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(entry.key),
                    Text(
                      '$percentage%',
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
              );
            }),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cerrar'),
          ),
        ],
      ),
    );
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
        floatingActionButton: FloatingActionButton.extended(
          onPressed: _openInputModal,
          icon: const Icon(Icons.analytics),
          label: const Text('Analizar'),
          backgroundColor: const Color(0xFF0073E6),
        ),
        bottomSheet: _showInputModal ? _buildInputModal(context) : null,
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
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _openInputModal,
        icon: const Icon(Icons.analytics),
        label: const Text('Analizar'),
        backgroundColor: const Color(0xFF0073E6),
      ),
      bottomSheet: _showInputModal ? _buildInputModal(context) : null,
    );
  }

  Widget _buildInputModal(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      height: MediaQuery.of(context).size.height * 0.7,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF232946) : Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.2),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Analizar datos de glucosa',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              IconButton(
                icon: const Icon(Icons.close),
                onPressed: _closeInputModal,
              ),
            ],
          ),
          const SizedBox(height: 8),
          const Text(
            'Ingresa tus datos actuales para obtener una predicción',
            style: TextStyle(fontSize: 14, color: Colors.grey),
          ),
          const SizedBox(height: 24),
          TextField(
            controller: _glucoseController,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              labelText: 'Glucosa actual (mg/dL)',
              hintText: 'Ej: 120',
              prefixIcon: const Icon(Icons.bloodtype, color: Color(0xFF0073E6)),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              filled: true,
              fillColor: isDark ? const Color(0xFF1A1F3A) : Colors.grey.shade50,
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _insulinController,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              labelText: 'Insulina últimos 30 min (unidades)',
              hintText: 'Ej: 5',
              prefixIcon: const Icon(Icons.medical_services, color: Color(0xFF0073E6)),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              filled: true,
              fillColor: isDark ? const Color(0xFF1A1F3A) : Colors.grey.shade50,
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _carbsController,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              labelText: 'Carbohidratos últimos 30 min (gramos)',
              hintText: 'Ej: 45',
              prefixIcon: const Icon(Icons.restaurant, color: Color(0xFF0073E6)),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              filled: true,
              fillColor: isDark ? const Color(0xFF1A1F3A) : Colors.grey.shade50,
            ),
          ),
          const SizedBox(height: 24),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFF0073E6).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Row(
              children: [
                Icon(Icons.info_outline, color: Color(0xFF0073E6), size: 20),
                SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Los datos de Health Connect (frecuencia cardíaca, pasos, calorías) se leerán automáticamente',
                    style: TextStyle(fontSize: 12, color: Color(0xFF0073E6)),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              onPressed: _isSubmitting ? null : _submitInitialData,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF0073E6),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: _isSubmitting
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : const Text(
                      'Analizar',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
            ),
          ),
        ],
      ),
    );
  }
}
