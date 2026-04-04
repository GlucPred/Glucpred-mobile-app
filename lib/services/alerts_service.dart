import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:glucpred/config/theme.dart';
import 'package:glucpred/utils/logger.dart';
import 'api_client.dart';

/// Servicio para gestionar alertas de glucosa desde el backend
/// Endpoints base: /api/alerts
class AlertsService {

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

      final response = await ApiClient.get(
        '/api/alerts/',
        queryParams: queryParams,
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
          'message': data['message'] ?? data['error'] ?? 'Error al obtener alertas',
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
      final response = await ApiClient.get('/api/alerts/unread-count');

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
      final response = await ApiClient.get(
        '/api/alerts/critical-count',
        queryParams: {'hours': hours.toString()},
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
      final response = await ApiClient.put('/api/alerts/$alertId/read');

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return {
          'success': true,
          'alert': data['alert'],
          'message': data['message'] ?? data['error'] ?? 'Alerta marcada como leída',
        };
      } else {
        return {
          'success': false,
          'message': data['message'] ?? data['error'] ?? 'Error al marcar alerta como leída',
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
      final response = await ApiClient.put('/api/alerts/read-all');

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return {
          'success': true,
          'count': data['count'] ?? 0,
          'message': data['message'] ?? data['error'] ?? 'Alertas marcadas como leídas',
        };
      } else {
        return {
          'success': false,
          'message': data['message'] ?? data['error'] ?? 'Error al marcar alertas como leídas',
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
      final response = await ApiClient.delete('/api/alerts/$alertId');

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return {
          'success': true,
          'message': data['message'] ?? data['error'] ?? 'Alerta descartada exitosamente',
        };
      } else {
        return {
          'success': false,
          'message': data['message'] ?? data['error'] ?? 'Error al descartar alerta',
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
      final response = await ApiClient.post(
        '/api/alerts/reminder',
        body: {'title': title, 'message': message},
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 201) {
        return {
          'success': true,
          'alert': data['alert'],
          'message': data['message'] ?? data['error'] ?? 'Recordatorio creado exitosamente',
        };
      } else {
        return {
          'success': false,
          'message': data['message'] ?? data['error'] ?? 'Error al crear recordatorio',
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
        return AppTheme.warningColor; // Amarillo accesible
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

  /// Obtiene las alertas de todos los pacientes asignados al doctor
  /// GET /api/alerts/my-patients
  /// 
  /// Retorna:
  /// - success: bool
  /// - alerts: List de alertas con estructura:
  ///   {
  ///     "id": int,
  ///     "user_id": int,
  ///     "patient_id": int,
  ///     "patient_name": String,
  ///     "glucose_record_id": int?,
  ///     "glucose_value": double?,
  ///     "alert_type": "critica" | "recordatorio",
  ///     "severity": "critico" | "advertencia" | "info",
  ///     "title": String,
  ///     "message": String,
  ///     "is_read": bool,
  ///     "is_dismissed": bool,
  ///     "created_at": String (ISO 8601),
  ///     "read_at": String?,
  ///     "dismissed_at": String?
  ///   }
  /// - message: String (en caso de error)
  static Future<Map<String, dynamic>> getMyPatientsAlerts() async {
    try {
      AppLogger.debug('AlertsService: GET /api/alerts/my-patients');

      final response = await ApiClient.get('/api/alerts/my-patients');

      AppLogger.debug('AlertsService: Status code: ${response.statusCode}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final alerts = data is Map && data.containsKey('alerts') 
            ? data['alerts'] as List 
            : (data is List ? data : []);
        AppLogger.debug('AlertsService: Alertas extraídas: ${alerts.length}');
        return {
          'success': true,
          'alerts': alerts,
        };
      } else {
        final data = jsonDecode(response.body);
        return {
          'success': false,
          'message': data['message'] ?? data['error'] ?? 'Error al obtener alertas de pacientes',
          'alerts': [],
        };
      }
    } catch (e) {
      AppLogger.error('AlertsService: Error', e);
      return {
        'success': false,
        'message': 'Error de conexión: ${e.toString()}',
        'alerts': [],
      };
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
