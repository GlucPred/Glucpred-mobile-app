import 'package:glucpred/features/auth/data/services/auth_service.dart';

class AuthRepository {
  Future<Map<String, dynamic>> login(String username, String password) =>
      AuthService.login(username: username, password: password);

  Future<Map<String, dynamic>> registerPatient(Map<String, dynamic> data) =>
      AuthService.register(
        nombreCompleto: data['nombre_completo'] ?? '',
        username: data['username'] ?? '',
        email: data['email'] ?? '',
        numeroCelular: data['numero_celular'] ?? '',
        password: data['password'] ?? '',
        confirmarPassword: data['confirmar_password'] ?? '',
        rol: 'Paciente',
      );

  Future<Map<String, dynamic>> registerDoctor(Map<String, dynamic> data) =>
      AuthService.register(
        nombreCompleto: data['nombre_completo'] ?? '',
        username: data['username'] ?? '',
        email: data['email'] ?? '',
        numeroCelular: data['numero_celular'] ?? '',
        password: data['password'] ?? '',
        confirmarPassword: data['confirmar_password'] ?? '',
        rol: 'Medico',
      );

  Future<void> logout() => AuthService.logout();

  Future<Map<String, dynamic>> getUserInfo() => AuthService.getUserInfo();

  Future<bool> isLoggedIn() => AuthService.isAuthenticated();

  Future<String?> getUserRole() async {
    final info = await AuthService.getUserInfo();
    return info['rol'] as String?;
  }

  Future<Map<String, dynamic>> updateProfile(Map<String, dynamic> data) =>
      AuthService.updateProfile(data);

  Future<Map<String, dynamic>> changePassword(
          String currentPassword, String newPassword) =>
      AuthService.changePassword(newPassword: newPassword);

  Future<Map<String, dynamic>> forgotPassword(String usernameOrEmail,
          {String newPassword = ''}) =>
      AuthService.forgotPassword(
        usernameOrEmail: usernameOrEmail,
        newPassword: newPassword,
      );

  Future<Map<String, dynamic>> completePatientProfile(
          Map<String, dynamic> data) =>
      AuthService.completeProfile(data);

  Future<Map<String, dynamic>> completeDoctorProfile(
          Map<String, dynamic> data) =>
      AuthService.completeProfile(data);
}
