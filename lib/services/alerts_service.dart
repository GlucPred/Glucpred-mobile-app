import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'auth_service.dart';

/// Servicio para gestionar alertas de glucosa desde el backend
/// Endpoints base: /api/alerts
class AlertsService {
  static final String _baseUrl = dotenv.env['API_BASE_URL'] ?? 'http://localhost:5000';

  /// Obtiene alertas del usuario con filtros
  /// GET /api/alerts/?type={tipo}&severity={severidad}&is_read={leido}
  /// 
  /// Parámetros:
  /// - type: 'todas', 'critica', 'recordatorio'
  /// - severity: 'critico', 'advertencia', 'info'
  /// - isRead: true/false
  /// - limit: int (default: 100, max: 500)
  /// - offset: int (default: 0)
  /// 
  /// Retorna:
  /// - success: bool
  /// - alerts: List de alertas con estructura:
  ///   {
  ///     "id": int,
  ///     "user_id": int,
  ///     "glucose_record_id": int?,
  ///     "glucose_value": double?,
  ///     "alert_type": "critica" | "recordatorio",
  ///     "severity": "critico" | "advertencia" | "info",
  ///     "title": String,
  ///     "message": String,
  ///     "is_read": bool,
  ///     "created_at": String (ISO 8601)
  ///   }
  /// - total: int
  /// - limit: int
  /// - offset: int
  /// - has_more: bool
  static Future<Map<String, dynamic>> getAlerts({
    String type = 'todas',
    String? severity,
    bool? isRead,
    int limit = 100,
    int offset = 0,
  }) async {
    try {
      final token = await AuthService.getToken();
      
      final queryParams = <String, String>{
        'type': type,
        'limit': limit.toString(),
        'offset': offset.toString(),
      };
      
      if (severity != null) {
        queryParams['severity'] = severity;
      }
      
      if (isRead != null) {
        queryParams['is_read'] = isRead.toString();
      }

      final uri = Uri.parse('$_baseUrl/api/alerts/').replace(
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
          'alerts': data['alerts'] ?? [],
          'total': data['total'] ?? 0,
          'limit': data['limit'] ?? limit,
          'offset': data['offset'] ?? offset,
          'has_more': data['has_more'] ?? false,
        };
      } else {
        final data = jsonDecode(response.body);
        return {
          'success': false,
          'message': data['message'] ?? 'Error al obtener alertas',
          'alerts': [],
          'total': 0,
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Error de conexión: ${e.toString()}',
        'alerts': [],
        'total': 0,
      };
    }
  }

  /// Obtiene el contador de alertas no leídas
  /// GET /api/alerts/unread-count
  /// 
  /// Retorna:
  /// - success: bool
  /// - unread_count: int
  static Future<Map<String, dynamic>> getUnreadCount() async {
    try {
      final token = await AuthService.getToken();
      final url = Uri.parse('$_baseUrl/api/alerts/unread-count');

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
          'unread_count': data['unread_count'] ?? 0,
        };
      } else {
        return {
          'success': false,
          'unread_count': 0,
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Error de conexión: ${e.toString()}',
        'unread_count': 0,
      };
    }
  }

  /// Obtiene el contador de alertas críticas en un período
  /// GET /api/alerts/critical-count?hours={horas}
  /// 
  /// Parámetros:
  /// - hours: int (default: 24)
  /// 
  /// Retorna:
  /// - success: bool
  /// - critical_count: int
  /// - period_hours: int
  static Future<Map<String, dynamic>> getCriticalCount({int hours = 24}) async {
    try {
      final token = await AuthService.getToken();
      final url = Uri.parse('$_baseUrl/api/alerts/critical-count?hours=$hours');

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
          'critical_count': data['critical_count'] ?? 0,
          'period_hours': data['period_hours'] ?? hours,
        };
      } else {
        return {
          'success': false,
          'critical_count': 0,
          'period_hours': hours,
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Error de conexión: ${e.toString()}',
        'critical_count': 0,
        'period_hours': hours,
      };
    }
  }

  /// Marca una alerta como leída
  /// PUT /api/alerts/{alert_id}/read
  /// 
  /// Parámetros:
  /// - alertId: int
  /// 
  /// Retorna:
  /// - success: bool
  /// - alert: Map con la alerta actualizada
  /// - message: String
  static Future<Map<String, dynamic>> markAsRead(int alertId) async {
    try {
      final token = await AuthService.getToken();
      final url = Uri.parse('$_baseUrl/api/alerts/$alertId/read');

      final response = await http.put(
        url,
        headers: {
          'Content-Type': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        },
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return {
          'success': true,
          'alert': data['alert'],
          'message': data['message'] ?? 'Alerta marcada como leída',
        };
      } else {
        return {
          'success': false,
          'message': data['message'] ?? 'Error al marcar alerta como leída',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Error de conexión: ${e.toString()}',
      };
    }
  }

  /// Marca todas las alertas como leídas
  /// PUT /api/alerts/read-all
  /// 
  /// Retorna:
  /// - success: bool
  /// - count: int (número de alertas marcadas)
  /// - message: String
  static Future<Map<String, dynamic>> markAllAsRead() async {
    try {
      final token = await AuthService.getToken();
      final url = Uri.parse('$_baseUrl/api/alerts/read-all');

      final response = await http.put(
        url,
        headers: {
          'Content-Type': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        },
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return {
          'success': true,
          'count': data['count'] ?? 0,
          'message': data['message'] ?? 'Alertas marcadas como leídas',
        };
      } else {
        return {
          'success': false,
          'message': data['message'] ?? 'Error al marcar alertas como leídas',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Error de conexión: ${e.toString()}',
      };
    }
  }

  /// Descarta/elimina una alerta
  /// DELETE /api/alerts/{alert_id}
  /// 
  /// Parámetros:
  /// - alertId: int
  /// 
  /// Retorna:
  /// - success: bool
  /// - message: String
  static Future<Map<String, dynamic>> dismissAlert(int alertId) async {
    try {
      final token = await AuthService.getToken();
      final url = Uri.parse('$_baseUrl/api/alerts/$alertId');

      final response = await http.delete(
        url,
        headers: {
          'Content-Type': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        },
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return {
          'success': true,
          'message': data['message'] ?? 'Alerta descartada exitosamente',
        };
      } else {
        return {
          'success': false,
          'message': data['message'] ?? 'Error al descartar alerta',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Error de conexión: ${e.toString()}',
      };
    }
  }

  /// Crea un recordatorio manual
  /// POST /api/alerts/reminder
  /// 
  /// Parámetros:
  /// - title: String
  /// - message: String
  /// 
  /// Retorna:
  /// - success: bool
  /// - alert: Map con el recordatorio creado
  /// - message: String
  static Future<Map<String, dynamic>> createReminder({
    required String title,
    required String message,
  }) async {
    try {
      final token = await AuthService.getToken();
      final url = Uri.parse('$_baseUrl/api/alerts/reminder');

      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'title': title,
          'message': message,
        }),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 201) {
        return {
          'success': true,
          'alert': data['alert'],
          'message': data['message'] ?? 'Recordatorio creado exitosamente',
        };
      } else {
        return {
          'success': false,
          'message': data['message'] ?? 'Error al crear recordatorio',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Error de conexión: ${e.toString()}',
      };
    }
  }

  /// Helper: Obtiene el color según la severidad de la alerta
  static Color getColorBySeverity(String severity) {
    switch (severity.toLowerCase()) {
      case 'critico':
        return const Color(0xFFC72331); // Rojo crítico
      case 'advertencia':
        return const Color(0xFFFBC318); // Amarillo advertencia
      case 'info':
        return const Color(0xFF0073E6); // Azul info
      default:
        return const Color(0xFF6C7C93); // Gris default
    }
  }

  /// Helper: Obtiene el ícono según el tipo de alerta
  static IconData getIconByType(String alertType) {
    switch (alertType.toLowerCase()) {
      case 'critica':
        return Icons.warning; // Alerta de glucosa
      case 'recordatorio':
        return Icons.notifications; // Recordatorio
      default:
        return Icons.info;
    }
  }

  /// Helper: Formatea el tiempo relativo de la alerta
  static String getTimeAgo(String createdAt) {
    final alertTime = DateTime.parse(createdAt);
    final now = DateTime.now();
    final difference = now.difference(alertTime);

    if (difference.inMinutes < 1) {
      return 'Hace un momento';
    } else if (difference.inMinutes < 60) {
      return 'Hace ${difference.inMinutes} minutos';
    } else if (difference.inHours < 24) {
      return 'Hace ${difference.inHours} horas';
    } else if (difference.inDays < 7) {
      return 'Hace ${difference.inDays} días';
    } else {
      return 'Hace ${(difference.inDays / 7).floor()} semanas';
    }
  }
}
