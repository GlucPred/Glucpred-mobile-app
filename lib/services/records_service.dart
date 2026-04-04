import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:glucpred/config/env_config.dart';
import 'auth_service.dart';
import 'package:glucpred/utils/logger.dart';

/// Servicio para gestionar registros de glucosa desde el backend
/// Endpoints base: /api/records
class RecordsService {
  static final String _baseUrl = EnvConfig.apiBaseUrl;

  /// Obtiene la última medición de glucosa del usuario
  /// GET /api/records/latest
  /// 
  /// Retorna:
  /// - success: bool
  /// - record: Map con {id, user_id, glucose_value, measurement_time, classification, created_at}
  /// - message: String (en caso de error)
  static Future<Map<String, dynamic>> getLatestReading() async {
    try {
      final token = await AuthService.getToken();
      final url = Uri.parse('$_baseUrl/api/records/latest');

      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return {
          'success': true,
          'record': data,
        };
      } else if (response.statusCode == 404) {
        return {
          'success': false,
          'message': 'No hay mediciones registradas',
        };
      } else {
        final data = jsonDecode(response.body);
        return {
          'success': false,
          'message': data['message'] ?? 'Error al obtener última medición',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Error de conexión: ${e.toString()}',
      };
    }
  }

  /// Crea un nuevo registro de medición de glucosa
  /// POST /api/records/
  /// 
  /// Parámetros:
  /// - glucoseValue: double (valor en mg/dL)
  /// - measurementTime: DateTime (opcional, por defecto: ahora)
  /// 
  /// Retorna:
  /// - success: bool
  /// - record: Map con el registro creado
  /// - message: String
  static Future<Map<String, dynamic>> createReading({
    required double glucoseValue,
    DateTime? measurementTime,
  }) async {
    try {
      final token = await AuthService.getToken();
      final url = Uri.parse('$_baseUrl/api/records/');

      final body = {
        'glucose_value': glucoseValue,
        if (measurementTime != null)
          'measurement_time': measurementTime.toIso8601String(),
      };

      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        },
        body: jsonEncode(body),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 201) {
        return {
          'success': true,
          'record': data['record'],
          'message': data['message'] ?? 'Registro creado exitosamente',
        };
      } else {
        return {
          'success': false,
          'message': data['message'] ?? 'Error al crear registro',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Error de conexión: ${e.toString()}',
      };
    }
  }

  /// Obtiene estadísticas rápidas para un período de tiempo
  /// GET /api/records/statistics?hours={hours}
  /// 
  /// Parámetros:
  /// - hours: int (horas hacia atrás, default: 24, rango: 1-720)
  /// 
  /// Retorna:
  /// - success: bool
  /// - statistics: Map con {period_hours, total_readings, average, min, max, classifications, last_reading}
  /// - message: String (en caso de error)
  static Future<Map<String, dynamic>> getStatistics({int hours = 24}) async {
    try {
      final token = await AuthService.getToken();
      final url = Uri.parse('$_baseUrl/api/records/statistics?hours=$hours');

      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return {
          'success': true,
          'statistics': data,
        };
      } else {
        final data = jsonDecode(response.body);
        return {
          'success': false,
          'message': data['message'] ?? 'Error al obtener estadísticas',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Error de conexión: ${e.toString()}',
      };
    }
  }

  /// Obtiene tendencia de glucosa para gráficos
  /// GET /api/records/trend?hours={hours}
  /// 
  /// Parámetros:
  /// - hours: int (horas hacia atrás, default: 12, rango: 1-720)
  /// 
  /// Ejemplos de uso:
  /// - Hoy (24h): getTrend(hours: 24)
  /// - Semana (7 días): getTrend(hours: 168)
  /// - Mes (30 días): getTrend(hours: 720)
  /// 
  /// Retorna:
  /// - success: bool
  /// - records: List de registros con {id, glucose_value, measurement_time, classification}
  /// - total: int (total de registros)
  /// - period_hours: int
  /// - message: String (en caso de error)
  static Future<Map<String, dynamic>> getTrend({int hours = 12}) async {
    try {
      final token = await AuthService.getToken();
      final url = Uri.parse('$_baseUrl/api/records/trend?hours=$hours');

      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return {
          'success': true,
          'records': data['records'] ?? [],
          'total': data['total'] ?? 0,
          'period_hours': data['period_hours'] ?? hours,
        };
      } else {
        final data = jsonDecode(response.body);
        return {
          'success': false,
          'message': data['message'] ?? 'Error al obtener tendencia',
          'records': [],
          'total': 0,
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Error de conexión: ${e.toString()}',
        'records': [],
        'total': 0,
      };
    }
  }

  /// Obtiene historial paginado de registros
  /// GET /api/records/history?limit={limit}&offset={offset}&start_date={start}&end_date={end}
  /// 
  /// Parámetros:
  /// - limit: int (registros por página, default: 100, max: 500)
  /// - offset: int (desplazamiento, default: 0)
  /// - startDate: DateTime (fecha inicial, opcional)
  /// - endDate: DateTime (fecha final, opcional)
  /// 
  /// Retorna:
  /// - success: bool
  /// - records: List de registros
  /// - total: int (total de registros disponibles)
  /// - limit: int
  /// - offset: int
  /// - has_more: bool (hay más páginas)
  /// - message: String (en caso de error)
  static Future<Map<String, dynamic>> getHistory({
    int limit = 100,
    int offset = 0,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      final token = await AuthService.getToken();
      
      // Construir query parameters
      final queryParams = <String, String>{
        'limit': limit.toString(),
        'offset': offset.toString(),
      };
      
      if (startDate != null) {
        queryParams['start_date'] = startDate.toIso8601String();
      }
      
      if (endDate != null) {
        queryParams['end_date'] = endDate.toIso8601String();
      }

      final uri = Uri.parse('$_baseUrl/api/records/history').replace(
        queryParameters: queryParams,
      );

      final response = await http.get(
        uri,
        headers: {
          'Content-Type': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return {
          'success': true,
          'records': data['records'] ?? [],
          'total': data['total'] ?? 0,
          'limit': data['limit'] ?? limit,
          'offset': data['offset'] ?? offset,
          'has_more': data['has_more'] ?? false,
        };
      } else {
        final data = jsonDecode(response.body);
        return {
          'success': false,
          'message': data['message'] ?? 'Error al obtener historial',
          'records': [],
          'total': 0,
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Error de conexión: ${e.toString()}',
        'records': [],
        'total': 0,
      };
    }
  }

  /// Obtiene historial de un paciente específico (para uso del médico)
  /// GET /api/records/user/{userId}/history?limit={limit}
  /// 
  /// Parámetros:
  /// - userId: int (ID del paciente)
  /// - limit: int (registros a obtener, default: 500)
  /// 
  /// Retorna:
  /// - success: bool
  /// - records: List de registros
  /// - total: int
  /// - message: String (en caso de error)
  static Future<Map<String, dynamic>> getPatientHistory(int userId, {int limit = 500}) async {
    try {
      final token = await AuthService.getToken();
      
      final uri = Uri.parse('$_baseUrl/api/records/user/$userId/history').replace(
        queryParameters: {'limit': limit.toString()},
      );

      final response = await http.get(
        uri,
        headers: {
          'Content-Type': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return {
          'success': true,
          'records': data['records'] ?? [],
          'total': data['total'] ?? 0,
        };
      } else {
        final data = jsonDecode(response.body);
        return {
          'success': false,
          'message': data['message'] ?? 'Error al obtener historial del paciente',
          'records': [],
          'total': 0,
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Error de conexión: ${e.toString()}',
        'records': [],
        'total': 0,
      };
    }
  }

  /// Helper: Calcula porcentaje de lecturas en rango normal
  /// Útil para tarjetas de estadísticas en la UI
  static double calculateNormalPercentage(Map<String, dynamic> classifications, int totalReadings) {
    if (totalReadings == 0) return 0.0;
    final normalCount = classifications['normal'] ?? 0;
    return (normalCount / totalReadings) * 100;
  }

  /// Helper: Determina el color según la clasificación de glucosa
  static String getColorByClassification(String classification) {
    switch (classification.toLowerCase()) {
      case 'bajo':
        return 'red'; // Hipoglucemia
      case 'normal':
        return 'green';
      case 'alto':
        return 'yellow';
      case 'critico':
        return 'red'; // Hiperglucemia crítica
      default:
        return 'gray';
    }
  }

  /// Obtiene los registros de glucosa de todos los pacientes asignados al doctor
  /// GET /api/records/my-patients
  /// 
  /// Retorna:
  /// - success: bool
  /// - records: List de registros con {id, user_id, patient_id, glucose_value, measurement_time, classification, created_at}
  /// - message: String (en caso de error)
  static Future<Map<String, dynamic>> getMyPatientsRecords() async {
    try {
      final token = await AuthService.getToken();
      final url = Uri.parse('$_baseUrl/api/records/my-patients');

      AppLogger.debug('RecordsService: GET $_baseUrl/api/records/my-patients');
      AppLogger.debug('RecordsService: Token presente: ${token != null}');

      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        },
      );

      AppLogger.debug('RecordsService: Status code: ${response.statusCode}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final records = data is Map && data.containsKey('records') 
            ? data['records'] as List 
            : (data is List ? data : []);
        AppLogger.debug('RecordsService: Registros extraídos: ${records.length}');
        return {
          'success': true,
          'records': records,
        };
      } else {
        final data = jsonDecode(response.body);
        return {
          'success': false,
          'message': data['message'] ?? 'Error al obtener registros de pacientes',
          'records': [],
        };
      }
    } catch (e) {
      AppLogger.error('RecordsService: Error', e);
      return {
        'success': false,
        'message': 'Error de conexión: ${e.toString()}',
        'records': [],
      };
    }
  }

  /// Helper: Obtiene mensaje descriptivo según clasificación
  static String getMessageByClassification(String classification) {
    switch (classification.toLowerCase()) {
      case 'bajo':
        return 'Nivel bajo - Hipoglucemia';
      case 'normal':
        return 'Nivel normal';
      case 'alto':
        return 'Nivel alto - Requiere atención';
      case 'critico':
        return 'Nivel crítico - Contactar médico';
      default:
        return 'Sin clasificación';
    }
  }
}
