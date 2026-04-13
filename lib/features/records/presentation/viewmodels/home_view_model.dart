import 'dart:async';
import 'package:flutter/material.dart';
import 'package:glucpred/features/records/data/repositories/records_repository.dart';
import 'package:glucpred/features/analysis/data/repositories/analysis_repository.dart';
import 'package:glucpred/features/records/domain/models/glucose_reading.dart';
import 'package:glucpred/features/analysis/domain/models/risk_prediction.dart';
import 'package:glucpred/features/records/domain/models/trend_point.dart';
import 'package:glucpred/core/utils/logger.dart';

class HomeViewModel extends ChangeNotifier {
  final RecordsRepository _recordsRepo;
  final AnalysisRepository _analysisRepo;

  HomeViewModel(this._recordsRepo, this._analysisRepo);

  bool _isLoading = true;
  bool _isSubmitting = false;
  GlucoseReading? _currentReading;
  RiskPrediction? _riskPrediction;
  List<TrendPoint> _trendData = [];
  Map<String, dynamic>? _lastAnalysisResult;
  String? _errorMessage;
  Timer? _updateTimer;

  bool get isLoading => _isLoading;
  bool get isSubmitting => _isSubmitting;
  GlucoseReading? get currentReading => _currentReading;
  RiskPrediction? get riskPrediction => _riskPrediction;
  List<TrendPoint> get trendData => _trendData;
  Map<String, dynamic>? get lastAnalysisResult => _lastAnalysisResult;
  String? get errorMessage => _errorMessage;

  void startAutoUpdate() {
    _updateTimer?.cancel();
    _updateTimer = Timer.periodic(const Duration(minutes: 5), (_) {
      loadData(isInitial: false, silentError: true);
    });
  }

  void stopAutoUpdate() {
    _updateTimer?.cancel();
    _updateTimer = null;
  }

  Future<void> loadData(
      {bool isInitial = false, bool silentError = false}) async {
    if (isInitial) {
      _isLoading = true;
      notifyListeners();
    }

    final latestResult = await _recordsRepo.getLatestReading();
    final trendResult = await _recordsRepo.getTrend(hours: 12);

    if (latestResult['success'] == true) {
      final record = latestResult['record'];
      _currentReading = GlucoseReading(
        value: (record['glucose_value'] as num).toDouble(),
        timestamp: _parseUtcTimestamp(record['measurement_time']),
        status: _mapClassificationToStatus(record['classification']),
      );
    }

    if (trendResult['success'] == true) {
      final records = trendResult['records'] as List;
      _trendData = records.map((r) {
        final dt = _parseUtcTimestamp(r['measurement_time']);
        return TrendPoint(
          timestamp: dt,
          value: (r['glucose_value'] as num).toDouble(),
          time:
              '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}',
        );
      }).toList();
    }

    if (_currentReading != null) {
      _riskPrediction = _generateRiskPrediction(_currentReading!);
    }

    if (!silentError && latestResult['success'] != true) {
      final msg = latestResult['message'] ?? 'Error al cargar datos';
      if (msg != 'No hay mediciones registradas') {
        _errorMessage = msg;
      }
    }

    if (isInitial) {
      _isLoading = false;
    }
    notifyListeners();
  }

  Future<Map<String, dynamic>?> submitAnalysis({
    required double glucose,
    required double insulin,
    required double carbs,
  }) async {
    _isSubmitting = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final healthData = await _analysisRepo.readHealthData();
      AppLogger.debug(
          'Health Connect: ${healthData['is_real_data'] == true ? "DATOS REALES" : "DATOS DEFAULT"}');

      final result = await _analysisRepo.predictEpisode(
        glucose: glucose,
        insulin30min: insulin,
        carbs30min: carbs,
        heartRate: healthData['heart_rate'] as double?,
        steps15min: (healthData['steps_15min'] as num?)?.toInt(),
        calories15min: healthData['calories_15min'] as double?,
      );

      _isSubmitting = false;

      if (result['success'] == true) {
        _lastAnalysisResult = result;
        await loadData(isInitial: false);
        notifyListeners();
        return result;
      } else {
        _errorMessage = result['message'] ?? 'Error al realizar predicción';
        notifyListeners();
        return null;
      }
    } catch (e) {
      _isSubmitting = false;
      _errorMessage = 'Error: $e';
      notifyListeners();
      return null;
    }
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
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
    if (_lastAnalysisResult != null) {
      final alertLevel =
          _lastAnalysisResult!['alert_level']?.toString().toLowerCase() ??
              'bajo';
      final String level;
      if (alertLevel.contains('alto') || alertLevel.contains('crítico')) {
        level = 'high';
      } else if (alertLevel.contains('medio')) {
        level = 'medium';
      } else {
        level = 'low';
      }

      return RiskPrediction(
        level: level,
        timeFrame: 'hace ${_getTimeAgo(reading.timestamp)}',
        description: _lastAnalysisResult!['recommendation'] ??
            'Continuar con monitoreo regular',
        prediction: _lastAnalysisResult!['prediction'],
        probabilities: Map<String, double>.from(
          (_lastAnalysisResult!['probabilities'] as Map).map(
            (key, value) =>
                MapEntry(key.toString(), (value as num).toDouble()),
          ),
        ),
        alertLevel: _lastAnalysisResult!['alert_level'],
      );
    }

    final String level;
    final String description;
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

  static DateTime _parseUtcTimestamp(String isoString) {
    final parsed = DateTime.parse(isoString);
    if (!isoString.endsWith('Z') && !isoString.contains('+')) {
      return DateTime.utc(parsed.year, parsed.month, parsed.day, parsed.hour,
              parsed.minute, parsed.second)
          .toLocal();
    }
    return parsed.toLocal();
  }

  String _getTimeAgo(DateTime timestamp) {
    final diff = DateTime.now().difference(timestamp);
    if (diff.isNegative) return 'ahora';
    if (diff.inSeconds < 60) return '${diff.inSeconds} segundos';
    if (diff.inMinutes < 60) return '${diff.inMinutes} minutos';
    if (diff.inHours < 24) return '${diff.inHours} horas';
    return '${diff.inDays} días';
  }

  @override
  void dispose() {
    stopAutoUpdate();
    super.dispose();
  }
}
