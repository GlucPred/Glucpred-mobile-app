import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:glucpred/config/env_config.dart';
import 'auth_service.dart';

/// Servicio para comunicarse con el analysis-service
/// Endpoint: POST /api/analysis/predict
class AnalysisService {
  static final String _baseUrl = EnvConfig.apiBaseUrl;
  /// Enviar predicción de episodio de glucosa
  /// 
  /// Combina datos del usuario (glucosa, insulina, carbohidratos)
  /// con datos de Health Connect (heart rate, steps, calories)
  /// 
  /// Request body:
  /// - glucose: Nivel actual de glucosa en mg/dL (obligatorio)
  /// - insulin_30min: Insulina administrada en últimos 30 min en unidades (obligatorio)
  /// - carbs_30min: Carbohidratos consumidos en últimos 30 min en gramos (obligatorio)
  /// - heart_rate: Frecuencia cardíaca actual en bpm (opcional, default: 70)
  /// - steps_15min: Pasos en últimos 15 min (opcional, default: 50)
  /// - calories_15min: Calorías quemadas en últimos 15 min en kcal (opcional, default: 5)
  /// - hour: Hora del día 0-23 (opcional, default: hora actual)
  /// 
  /// Response:
  /// - prediction: "Hipoglucemia", "Normal", o "Hiperglucemia"
  /// - probabilities: Map con probabilidades para cada clase
  /// - alert_level: "Bajo", "Medio", o "Alto"
  /// - recommendation: Texto con recomendación
  /// - input_summary: Resumen de los datos enviados
  static Future<Map<String, dynamic>> predictEpisode({
    required double glucose,
    required double insulin30min,
    required double carbs30min,
    double? heartRate,
    int? steps15min,
    double? calories15min,
    int? hour,
  }) async {
    try {
      final token = await AuthService.getToken();
      
      if (token == null) {
        return {
          'success': false,
          'message': 'No se encontró token de autenticación',
        };
      }

      // Preparar el body
      final body = {
        'glucose': glucose,
        'insulin_30min': insulin30min,
        'carbs_30min': carbs30min,
        'heart_rate': heartRate ?? 70.0,
        'steps_15min': steps15min ?? 50,
        'calories_15min': calories15min ?? 5.0,
        'hour': hour ?? DateTime.now().hour,
      };

      final response = await http.post(
        Uri.parse('$_baseUrl/api/analysis/predict'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: json.encode(body),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return {
          'success': true,
          'prediction': data['prediction'],
          'probabilities': data['probabilities'],
          'alert_level': data['alert_level'],
          'recommendation': data['recommendation'],
          'input_summary': data['input_summary'],
        };
      } else {
        final error = json.decode(response.body);
        return {
          'success': false,
          'message': error['error'] ?? 'Error al realizar predicción',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Error de conexión: $e',
      };
    }
  }

  /// Verificar el estado de salud del servicio de análisis
  static Future<Map<String, dynamic>> checkHealth() async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/api/analysis/health'),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return {
          'success': true,
          'status': data['status'],
          'model_loaded': data['model_loaded'],
        };
      } else {
        return {
          'success': false,
          'message': 'Servicio no disponible',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Error de conexión: $e',
      };
    }
  }
}
