import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:glucpred/config/env_config.dart';
import 'auth_service.dart';

/// Servicio para gestión de relaciones médico-paciente y observaciones médicas
/// 
/// Endpoints disponibles:
/// - GET /api/doctor-patient/patients-summary - Resumen de todos los pacientes
/// - GET /api/doctor-patient/patient/{id}/detail - Detalle completo de un paciente
/// - POST /api/doctor-patient/patient/{id}/observations - Crear observación
/// - GET /api/doctor-patient/patient/{id}/observations - Historial de observaciones
/// - PUT /api/doctor-patient/observations/{id} - Actualizar observación
/// - DELETE /api/doctor-patient/observations/{id} - Eliminar observación
class DoctorPatientService {
  static final String _baseUrl = EnvConfig.apiBaseUrl;

  /// Obtiene resumen de todos los pacientes del médico autenticado
  /// 
  /// Retorna:
  /// - doctor_user_id: ID del médico
  /// - total: Total de pacientes
  /// - patients: Lista con nombre, edad, última glucosa, estado, alertas
  static Future<Map<String, dynamic>> getPatientsSummary() async {
    try {
      final token = await AuthService.getToken();
      
      if (token == null) {
        return {
          'success': false,
          'message': 'No hay sesión activa',
        };
      }

      final url = Uri.parse('$_baseUrl/api/doctor-patient/patients-summary');
      
      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return {
          'success': true,
          'doctor_user_id': data['doctor_user_id'],
          'total': data['total'],
          'patients': data['patients'],
        };
      } else {
        final data = jsonDecode(response.body);
        return {
          'success': false,
          'message': data['message'] ?? 'Error al obtener pacientes',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Error de conexión: ${e.toString()}',
      };
    }
  }

  /// Obtiene detalle completo de un paciente específico
  /// 
  /// Parámetros:
  /// - patientUserId: ID del paciente
  /// - period: 'day', 'week', 'month' (default: 'day')
  /// 
  /// Retorna:
  /// - profile: Información del paciente
  /// - glucose_stats: Estadísticas (promedio, min, max, % en rango)
  /// - glucose_trend: Array de mediciones para la gráfica
  /// - latest_observation: Última observación médica (o null)
  static Future<Map<String, dynamic>> getPatientDetail(
    int patientUserId, {
    String period = 'day',
  }) async {
    try {
      final token = await AuthService.getToken();
      
      if (token == null) {
        return {
          'success': false,
          'message': 'No hay sesión activa',
        };
      }

      final url = Uri.parse(
        '$_baseUrl/api/doctor-patient/patient/$patientUserId/detail?period=$period',
      );
      
      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return {
          'success': true,
          'patient_user_id': data['patient_user_id'],
          'profile': data['profile'],
          'glucose_stats': data['glucose_stats'],
          'glucose_trend': data['glucose_trend'],
          'latest_observation': data['latest_observation'],
        };
      } else {
        final data = jsonDecode(response.body);
        return {
          'success': false,
          'message': data['message'] ?? 'Error al obtener detalle del paciente',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Error de conexión: ${e.toString()}',
      };
    }
  }

  /// Crea una nueva observación médica para el paciente
  /// 
  /// Parámetros:
  /// - patientUserId: ID del paciente
  /// - observationText: Texto de la observación
  static Future<Map<String, dynamic>> createObservation(
    int patientUserId,
    String observationText,
  ) async {
    try {
      final token = await AuthService.getToken();
      
      if (token == null) {
        return {
          'success': false,
          'message': 'No hay sesión activa',
        };
      }

      final url = Uri.parse(
        '$_baseUrl/api/doctor-patient/patient/$patientUserId/observations',
      );
      
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'observation_text': observationText,
        }),
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return {
          'success': true,
          'message': data['message'] ?? 'Observación creada exitosamente',
          'observation': data['observation'],
        };
      } else {
        final data = jsonDecode(response.body);
        return {
          'success': false,
          'message': data['message'] ?? 'Error al crear observación',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Error de conexión: ${e.toString()}',
      };
    }
  }

  /// Obtiene historial de observaciones médicas del paciente
  /// 
  /// Parámetros:
  /// - patientUserId: ID del paciente
  /// - limit: Número de resultados (default: 100)
  /// - offset: Desplazamiento para paginación (default: 0)
  static Future<Map<String, dynamic>> getObservations(
    int patientUserId, {
    int limit = 100,
    int offset = 0,
  }) async {
    try {
      final token = await AuthService.getToken();
      
      if (token == null) {
        return {
          'success': false,
          'message': 'No hay sesión activa',
        };
      }

      final url = Uri.parse(
        '$_baseUrl/api/doctor-patient/patient/$patientUserId/observations?limit=$limit&offset=$offset',
      );
      
      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return {
          'success': true,
          'patient_user_id': data['patient_user_id'],
          'total': data['total'],
          'observations': data['observations'],
        };
      } else {
        final data = jsonDecode(response.body);
        return {
          'success': false,
          'message': data['message'] ?? 'Error al obtener observaciones',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Error de conexión: ${e.toString()}',
      };
    }
  }

  /// Actualiza una observación médica existente
  /// 
  /// Parámetros:
  /// - observationId: ID de la observación
  /// - observationText: Nuevo texto de la observación
  static Future<Map<String, dynamic>> updateObservation(
    int observationId,
    String observationText,
  ) async {
    try {
      final token = await AuthService.getToken();
      
      if (token == null) {
        return {
          'success': false,
          'message': 'No hay sesión activa',
        };
      }

      final url = Uri.parse(
        '$_baseUrl/api/doctor-patient/observations/$observationId',
      );
      
      final response = await http.put(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'observation_text': observationText,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return {
          'success': true,
          'message': data['message'] ?? 'Observación actualizada exitosamente',
          'observation': data['observation'],
        };
      } else {
        final data = jsonDecode(response.body);
        return {
          'success': false,
          'message': data['message'] ?? 'Error al actualizar observación',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Error de conexión: ${e.toString()}',
      };
    }
  }

  /// Elimina una observación médica
  /// 
  /// Parámetros:
  /// - observationId: ID de la observación
  static Future<Map<String, dynamic>> deleteObservation(int observationId) async {
    try {
      final token = await AuthService.getToken();
      
      if (token == null) {
        return {
          'success': false,
          'message': 'No hay sesión activa',
        };
      }

      final url = Uri.parse(
        '$_baseUrl/api/doctor-patient/observations/$observationId',
      );
      
      final response = await http.delete(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return {
          'success': true,
          'message': data['message'] ?? 'Observación eliminada exitosamente',
        };
      } else {
        final data = jsonDecode(response.body);
        return {
          'success': false,
          'message': data['message'] ?? 'Error al eliminar observación',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Error de conexión: ${e.toString()}',
      };
    }
  }

  /// Helpers para mapear estados y clasificaciones
  
  /// Mapea el estado del paciente a un color
  static String getEstadoColor(String estado) {
    switch (estado.toLowerCase()) {
      case 'critica':
        return '#C72331'; // Rojo
      case 'moderada':
        return '#FBC318'; // Amarillo
      case 'estable':
        return '#337536'; // Verde
      default:
        return '#6C7C93'; // Gris
    }
  }

  /// Mapea la clasificación de glucosa a un color
  static String getClassificationColor(String classification) {
    switch (classification.toLowerCase()) {
      case 'critico':
      case 'bajo':
        return '#C72331'; // Rojo
      case 'alto':
        return '#FBC318'; // Amarillo
      case 'normal':
        return '#337536'; // Verde
      default:
        return '#6C7C93'; // Gris
    }
  }

  /// Obtiene lista de pacientes disponibles (no asignados al médico)
  /// 
  /// Retorna lista de pacientes que pueden ser asignados
  static Future<Map<String, dynamic>> getAvailablePatients() async {
    try {
      final token = await AuthService.getToken();
      
      if (token == null) {
        return {
          'success': false,
          'message': 'No hay sesión activa',
        };
      }

      final url = Uri.parse('$_baseUrl/api/doctor-patient/available-patients');
      
      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return {
          'success': true,
          'patients': data['available_patients'] ?? [],
          'total': data['total'] ?? 0,
        };
      } else {
        final data = jsonDecode(response.body);
        return {
          'success': false,
          'message': data['message'] ?? 'Error al obtener pacientes disponibles',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Error de conexión: ${e.toString()}',
      };
    }
  }

  /// Asigna un paciente al médico autenticado
  /// 
  /// Parámetros:
  /// - patientUserId: ID del paciente a asignar
  static Future<Map<String, dynamic>> assignPatient(int patientUserId) async {
    try {
      final token = await AuthService.getToken();
      
      if (token == null) {
        return {
          'success': false,
          'message': 'No hay sesión activa',
        };
      }

      final url = Uri.parse('$_baseUrl/api/doctor-patient/assign');
      
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'patient_user_id': patientUserId,
        }),
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return {
          'success': true,
          'message': data['message'] ?? 'Paciente asignado exitosamente',
          'relation': data['relation'],
        };
      } else {
        final data = jsonDecode(response.body);
        return {
          'success': false,
          'message': data['message'] ?? 'Error al asignar paciente',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Error de conexión: ${e.toString()}',
      };
    }
  }

  /// Desactiva la relación con un paciente
  /// 
  /// Parámetros:
  /// - patientUserId: ID del paciente
  static Future<Map<String, dynamic>> deactivatePatient(int patientUserId) async {
    try {
      final token = await AuthService.getToken();
      
      if (token == null) {
        return {
          'success': false,
          'message': 'No hay sesión activa',
        };
      }

      final url = Uri.parse('$_baseUrl/api/doctor-patient/deactivate');
      
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'patient_user_id': patientUserId,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return {
          'success': true,
          'message': data['message'] ?? 'Relación desactivada exitosamente',
        };
      } else {
        final data = jsonDecode(response.body);
        return {
          'success': false,
          'message': data['message'] ?? 'Error al desactivar relación',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Error de conexión: ${e.toString()}',
      };
    }
  }
}
