import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:glucpred/core/config/env_config.dart';

class AuthService {
  static const _secureStorage = FlutterSecureStorage();
  static final String _baseUrl = EnvConfig.apiBaseUrl;

  // Registro de usuario (Paciente o Médico)
  static Future<Map<String, dynamic>> register({
    required String nombreCompleto,
    required String username,
    required String email,
    required String numeroCelular,
    required String password,
    required String confirmarPassword,
    required String rol, // "Paciente" o "Medico"
  }) async {
    try {
      final url = Uri.parse('$_baseUrl/api/auth/register');
      
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'nombre_completo': nombreCompleto,
          'username': username,
          'email': email,
          'numero_celular': numeroCelular,
          'password': password,
          'confirmar_password': confirmarPassword,
          'rol': rol,
        }),
      ).timeout(const Duration(seconds: 30));

      final data = jsonDecode(response.body);

      if (response.statusCode == 201 || response.statusCode == 200) {
        // Guardar el token de acceso
        if (data['access_token'] != null) {
          await _saveToken(data['access_token']);
        }
        
        // Guardar información del usuario
        if (data['user'] != null) {
          await _saveUserInfo(data['user']);
        }

        return {
          'success': true,
          'message': data['message'] ?? 'Usuario registrado exitosamente',
          'user': data['user'],
          'access_token': data['access_token'],
        };
      } else {
        return {
          'success': false,
          'message': data['message'] ?? 'Error al registrar usuario',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Error de conexión: ${e.toString()}',
      };
    }
  }

  // Guardar token en secure storage
  static Future<void> _saveToken(String token) async {
    await _secureStorage.write(key: 'access_token', value: token);
  }

  // Guardar información del usuario
  static Future<void> _saveUserInfo(Map<String, dynamic> user) async {
    // Store user_id in secure storage (used for auth)
    await _secureStorage.write(key: 'user_id', value: user['id'].toString());
    // Non-sensitive user info stays in SharedPreferences
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('username', user['username'] ?? '');
    await prefs.setString('email', user['email'] ?? '');
    await prefs.setString('nombre_completo', user['nombre_completo'] ?? '');
    await prefs.setString('rol', user['rol'] ?? '');
    
    // Manejar tanto 'es_primer_inicio' como 'primer_inicio_sesion' del backend
    final bool primerInicio = user['es_primer_inicio'] ?? user['primer_inicio_sesion'] ?? true;
    await prefs.setBool('es_primer_inicio', primerInicio);
  }

  // Login de usuario
  static Future<Map<String, dynamic>> login({
    required String username,
    required String password,
  }) async {
    try {
      final url = Uri.parse('$_baseUrl/api/auth/login');
      
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'username': username,
          'password': password,
        }),
      ).timeout(const Duration(seconds: 30));

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        // Guardar el token de acceso
        if (data['access_token'] != null) {
          await _saveToken(data['access_token']);
        }
        
        // Guardar información del usuario
        if (data['user'] != null) {
          await _saveUserInfo(data['user']);
        }

        return {
          'success': true,
          'message': data['message'] ?? 'Inicio de sesión exitoso',
          'user': data['user'],
          'access_token': data['access_token'],
        };
      } else {
        return {
          'success': false,
          'message': data['message'] ?? 'Usuario o contraseña incorrectos',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Error de conexión: ${e.toString()}',
      };
    }
  }

  // Obtener token guardado
  static Future<String?> getToken() async {
    return await _secureStorage.read(key: 'access_token');
  }

  // Obtener información del usuario
  static Future<Map<String, dynamic>> getUserInfo() async {
    final userId = await _secureStorage.read(key: 'user_id');
    final prefs = await SharedPreferences.getInstance();
    return {
      'user_id': userId,
      'username': prefs.getString('username'),
      'email': prefs.getString('email'),
      'nombre_completo': prefs.getString('nombre_completo'),
      'rol': prefs.getString('rol'),
      'es_primer_inicio': prefs.getBool('es_primer_inicio'),
    };
  }

  // Verificar si es el primer inicio de sesión
  static Future<bool> esPrimerInicio() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('es_primer_inicio') ?? true;
  }

  // Actualizar estado de primer inicio de sesión
  static Future<void> completarPrimerInicio() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('es_primer_inicio', false);
  }

  // Cerrar sesión
  static Future<void> logout() async {
    // Clear secure storage (tokens and user_id)
    await _secureStorage.deleteAll();
    // Clear only auth-related shared preferences
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('username');
    await prefs.remove('email');
    await prefs.remove('nombre_completo');
    await prefs.remove('rol');
    await prefs.remove('es_primer_inicio');
  }

  // Verificar si el usuario está autenticado
  static Future<bool> isAuthenticated() async {
    final token = await getToken();
    return token != null && token.isNotEmpty;
  }

  // Completar o actualizar el perfil del usuario (paciente o médico)
  // body: mapa con los campos que requiere el backend
  // Para paciente: altura, antecedentes, edad, fecha_diagnostico, medicamentos, peso
  // Para médico: centro_trabajo, especialidad, numero_colegiatura
  static Future<Map<String, dynamic>> completeProfile(Map<String, dynamic> body) async {
    try {
      final token = await getToken();
      final userInfo = await getUserInfo();
      final rol = userInfo['rol']?.toString().toLowerCase() ?? 'paciente';
      
      // Usar endpoint específico según el rol
      final endpoint = rol == 'medico' ? '/api/profile/medico' : '/api/profile/paciente';
      final url = Uri.parse('$_baseUrl$endpoint');

      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        },
        body: jsonEncode(body),
      ).timeout(const Duration(seconds: 30));

      final data = jsonDecode(response.body);

      if (response.statusCode == 200 || response.statusCode == 201) {
        // Si el backend devuelve el usuario actualizado, guardar info local
        if (data['user'] != null) {
          await _saveUserInfo(data['user']);
        } else {
          // De lo contrario, marcar localmente que ya no es primer inicio
          await completarPrimerInicio();
        }

        return {
          'success': true,
          'message': data['message'] ?? 'Perfil actualizado correctamente',
          'data': data,
        };
      } else {
        return {
          'success': false,
          'message': data['message'] ?? 'Error al actualizar perfil',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Error de conexión: ${e.toString()}',
      };
    }
  }

  // Obtener perfil del usuario (GET /api/profile/paciente o /api/profile/medico)
  static Future<Map<String, dynamic>> getProfile() async {
    try {
      final token = await getToken();
      final userInfo = await getUserInfo();
      final rol = userInfo['rol']?.toString().toLowerCase() ?? 'paciente';
      
      // Usar endpoint específico según el rol
      final endpoint = rol == 'medico' ? '/api/profile/medico' : '/api/profile/paciente';
      final url = Uri.parse('$_baseUrl$endpoint');

      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        },
      ).timeout(const Duration(seconds: 30));

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return {
          'success': true,
          'user': data['user'],
          'profile': data['profile'],
        };
      } else {
        return {
          'success': false,
          'message': data['message'] ?? 'Error al obtener perfil',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Error de conexión: ${e.toString()}',
      };
    }
  }

  // Actualizar perfil del usuario (PUT /api/profile/paciente o /api/profile/medico)
  // Solo envía los campos que se modificaron
  static Future<Map<String, dynamic>> updateProfile(Map<String, dynamic> body) async {
    try {
      final token = await getToken();
      final userInfo = await getUserInfo();
      final rol = userInfo['rol']?.toString().toLowerCase() ?? 'paciente';
      
      // Usar endpoint específico según el rol
      final endpoint = rol == 'medico' ? '/api/profile/medico' : '/api/profile/paciente';
      final url = Uri.parse('$_baseUrl$endpoint');

      final response = await http.put(
        url,
        headers: {
          'Content-Type': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        },
        body: jsonEncode(body),
      ).timeout(const Duration(seconds: 30));

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return {
          'success': true,
          'message': data['message'] ?? 'Perfil actualizado correctamente',
          'data': data,
        };
      } else {
        return {
          'success': false,
          'message': data['message'] ?? 'Error al actualizar perfil',
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
