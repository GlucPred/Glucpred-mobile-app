import 'dart:math';
import '../models/glucose_reading.dart';
import '../models/risk_prediction.dart';
import '../models/trend_point.dart';

class GlucoseService {
  static final Random _random = Random();

  // Generar lectura actual de glucosa
  static GlucoseReading getCurrentReading() {
    final value = 80.0 + _random.nextDouble() * 60; // Entre 80 y 140 mg/dl
    String status;
    
    if (value < 90) {
      status = 'low';
    } else if (value > 130) {
      status = 'high';
    } else {
      status = 'normal';
    }

    return GlucoseReading(
      value: value,
      timestamp: DateTime.now(),
      status: status,
    );
  }

  // Generar predicción de riesgo
  static RiskPrediction getRiskPrediction() {
    final risks = [
      RiskPrediction(
        level: 'low',
        timeFrame: 'hace 2 horas',
        description: 'Tu nivel de glucosa se mantiene estable',
      ),
      RiskPrediction(
        level: 'medium',
        timeFrame: 'hace 1 hora',
        description: 'Ligera tendencia al alza detectada',
      ),
      RiskPrediction(
        level: 'high',
        timeFrame: 'hace 30 minutos',
        description: 'Riesgo de hipoglucemia en las próximas 2 horas',
      ),
    ];
    
    return risks[_random.nextInt(risks.length)];
  }

  // Generar datos de tendencia de las últimas 12 horas
  static List<TrendPoint> getTrendData() {
    final now = DateTime.now();
    final points = <TrendPoint>[];
    
    // Valores base que crean una tendencia ascendente suave
    // Los valores corresponden a las horas: 6h, 7h, 8h, 9h, 10h, 11h, 12h
    final baseValues = [85.0, 90.0, 95.0, 98.0, 100.0, 105.0, 115.0];
    final hours = [6, 7, 8, 9, 10, 11, 12];
    
    for (int i = 0; i < baseValues.length; i++) {
      final hoursAgo = 12 - hours[i]; // Convertir a "hace cuántas horas"
      final timestamp = now.subtract(Duration(hours: hoursAgo));
      
      points.add(TrendPoint(
        value: baseValues[i] + (_random.nextDouble() * 6 - 3), // Variación pequeña
        time: '${hours[i]}h',
        timestamp: timestamp,
      ));
    }
    
    return points;
  }

  // Generar datos para HOY (cada 2 horas - 12 puntos)
  static List<TrendPoint> getTrendDataForToday() {
    final now = DateTime.now();
    final points = <TrendPoint>[];
    
    // Valores para el día completo (0h a 24h) - 7 puntos
    final baseValues = [90.0, 110.0, 115.0, 120.0, 130.0, 150.0, 170.0];
    final hours = [0, 4, 8, 12, 16, 20, 24];
    
    for (int i = 0; i < baseValues.length; i++) {
      final hoursAgo = 24 - hours[i];
      final timestamp = now.subtract(Duration(hours: hoursAgo));
      
      points.add(TrendPoint(
        value: baseValues[i] + (_random.nextDouble() * 6 - 3),
        time: '${hours[i]}h',
        timestamp: timestamp,
      ));
    }
    
    return points;
  }

  // Generar datos para SEMANA (7 días)
  static List<TrendPoint> getTrendDataForWeek() {
    final now = DateTime.now();
    final points = <TrendPoint>[];
    final baseValue = 95.0;
    final days = ['Lun', 'Mar', 'Mie', 'Jue', 'Vie', 'Sab', 'Dom'];
    
    for (int i = 0; i < 7; i++) {
      final daysAgo = 6 - i;
      final timestamp = now.subtract(Duration(days: daysAgo));
      final variation = _random.nextDouble() * 50;
      final value = baseValue + variation;
      
      points.add(TrendPoint(
        value: value,
        time: days[i],
        timestamp: timestamp,
      ));
    }
    
    return points;
  }

  // Generar datos para MES (últimos 6 meses)
  static List<TrendPoint> getTrendDataForMonth() {
    final now = DateTime.now();
    final points = <TrendPoint>[];
    final months = ['Ene', 'Feb', 'Mar', 'Abr', 'May', 'Jun', 'Jul', 'Ago', 'Sep', 'Oct', 'Nov', 'Dic'];
    
    // Generar datos para los últimos 6 meses
    final baseValues = [98.0, 105.0, 112.0, 118.0, 128.0, 135.0];
    
    for (int i = 0; i < 6; i++) {
      final monthsAgo = 5 - i;
      final monthIndex = (now.month - monthsAgo - 1) % 12;
      final timestamp = DateTime(now.year, now.month - monthsAgo, 1);
      
      points.add(TrendPoint(
        value: baseValues[i] + (_random.nextDouble() * 8 - 4),
        time: months[monthIndex < 0 ? monthIndex + 12 : monthIndex],
        timestamp: timestamp,
      ));
    }
    
    return points;
  }

  // Obtener lecturas históricas
  static List<GlucoseReading> getHistoricalReadings(int count) {
    final readings = <GlucoseReading>[];
    final now = DateTime.now();
    
    for (int i = 0; i < count; i++) {
      final value = 80.0 + _random.nextDouble() * 60;
      String status;
      
      if (value < 90) {
        status = 'low';
      } else if (value > 130) {
        status = 'high';
      } else {
        status = 'normal';
      }
      
      readings.add(GlucoseReading(
        value: value,
        timestamp: now.subtract(Duration(hours: i * 2)),
        status: status,
      ));
    }
    
    return readings;
  }
}
