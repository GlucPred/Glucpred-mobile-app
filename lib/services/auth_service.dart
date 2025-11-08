import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class AuthService {
  static final String _baseUrl = dotenv.env['API_BASE_URL'] ?? 'http://localhost:5000';

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
      );

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

  // Guardar token en SharedPreferences
  static Future<void> _saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('access_token', token);
  }

  // Guardar información del usuario
  static Future<void> _saveUserInfo(Map<String, dynamic> user) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('user_id', user['id'].toString());
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
      );

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
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('access_token');
  }

  // Obtener información del usuario
  static Future<Map<String, dynamic>> getUserInfo() async {
    final prefs = await SharedPreferences.getInstance();
    return {
      'user_id': prefs.getString('user_id'),
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
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }

  // Verificar si el usuario está autenticado
  static Future<bool> isAuthenticated() async {
    final token = await getToken();
    return token != null && token.isNotEmpty;
  }

  // Completar o actualizar el perfil del usuario (paciente o médico)
  // body: mapa con los campos que requiere el backend, por ejemplo:
  // {
  //  "altura": 170,
  //  "antecedentes": "...",
  //  "edad": 45,
  //  "fecha_diagnostico": "2020-05-15",
  //  "medicamentos": "...",
  //  "peso": 75.5
  // }
  static Future<Map<String, dynamic>> completeProfile(Map<String, dynamic> body) async {
    try {
      final token = await getToken();
      final url = Uri.parse('$_baseUrl/api/profile');

      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        },
        body: jsonEncode(body),
      );

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
}
