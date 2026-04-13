import 'package:flutter/material.dart';
import 'package:glucpred/features/auth/data/repositories/auth_repository.dart';

enum AuthStatus { initial, loading, authenticated, unauthenticated, error }

class AuthViewModel extends ChangeNotifier {
  final AuthRepository _repo;

  AuthViewModel(this._repo);

  AuthStatus _status = AuthStatus.initial;
  String? _errorMessage;
  String? _userRole;
  Map<String, dynamic>? _userInfo;

  AuthStatus get status => _status;
  String? get errorMessage => _errorMessage;
  String? get userRole => _userRole;
  Map<String, dynamic>? get userInfo => _userInfo;
  bool get isLoading => _status == AuthStatus.loading;

  Future<bool> checkAuth() async {
    final loggedIn = await _repo.isLoggedIn();
    if (loggedIn) {
      _userRole = await _repo.getUserRole();
      _userInfo = await _repo.getUserInfo();
      _status = AuthStatus.authenticated;
    } else {
      _status = AuthStatus.unauthenticated;
    }
    notifyListeners();
    return loggedIn;
  }

  Future<bool> login(String username, String password) async {
    _status = AuthStatus.loading;
    _errorMessage = null;
    notifyListeners();

    final result = await _repo.login(username, password);
    if (result['success'] == true) {
      _userRole = await _repo.getUserRole();
      _userInfo = await _repo.getUserInfo();
      _status = AuthStatus.authenticated;
      notifyListeners();
      return true;
    } else {
      _errorMessage = result['message'] ?? 'Error al iniciar sesión';
      _status = AuthStatus.error;
      notifyListeners();
      return false;
    }
  }

  Future<bool> registerPatient(Map<String, dynamic> data) async {
    _status = AuthStatus.loading;
    _errorMessage = null;
    notifyListeners();

    final result = await _repo.registerPatient(data);
    if (result['success'] == true) {
      _userRole = await _repo.getUserRole();
      _userInfo = await _repo.getUserInfo();
      _status = AuthStatus.authenticated;
      notifyListeners();
      return true;
    } else {
      _errorMessage = result['message'] ?? 'Error al registrar';
      _status = AuthStatus.error;
      notifyListeners();
      return false;
    }
  }

  Future<bool> registerDoctor(Map<String, dynamic> data) async {
    _status = AuthStatus.loading;
    _errorMessage = null;
    notifyListeners();

    final result = await _repo.registerDoctor(data);
    if (result['success'] == true) {
      _userRole = await _repo.getUserRole();
      _userInfo = await _repo.getUserInfo();
      _status = AuthStatus.authenticated;
      notifyListeners();
      return true;
    } else {
      _errorMessage = result['message'] ?? 'Error al registrar';
      _status = AuthStatus.error;
      notifyListeners();
      return false;
    }
  }

  Future<void> logout() async {
    await _repo.logout();
    _status = AuthStatus.unauthenticated;
    _userRole = null;
    _userInfo = null;
    notifyListeners();
  }

  Future<bool> updateProfile(Map<String, dynamic> data) async {
    _status = AuthStatus.loading;
    notifyListeners();

    final result = await _repo.updateProfile(data);
    if (result['success'] == true) {
      _userInfo = await _repo.getUserInfo();
      _status = AuthStatus.authenticated;
      notifyListeners();
      return true;
    } else {
      _errorMessage = result['message'] ?? 'Error al actualizar';
      _status = AuthStatus.error;
      notifyListeners();
      return false;
    }
  }

  Future<bool> changePassword(
      String currentPassword, String newPassword) async {
    _status = AuthStatus.loading;
    notifyListeners();

    final result = await _repo.changePassword(currentPassword, newPassword);
    if (result['success'] == true) {
      _status = AuthStatus.authenticated;
      notifyListeners();
      return true;
    } else {
      _errorMessage = result['message'] ?? 'Error al cambiar contraseña';
      _status = AuthStatus.error;
      notifyListeners();
      return false;
    }
  }

  Future<bool> forgotPassword(String email) async {
    _status = AuthStatus.loading;
    notifyListeners();

    final result = await _repo.forgotPassword(email);
    if (result['success'] == true) {
      _status = AuthStatus.unauthenticated;
      notifyListeners();
      return true;
    } else {
      _errorMessage = result['message'] ?? 'Error';
      _status = AuthStatus.error;
      notifyListeners();
      return false;
    }
  }

  Future<bool> completePatientProfile(Map<String, dynamic> data) async {
    _status = AuthStatus.loading;
    notifyListeners();

    final result = await _repo.completePatientProfile(data);
    if (result['success'] == true) {
      _status = AuthStatus.authenticated;
      notifyListeners();
      return true;
    } else {
      _errorMessage = result['message'] ?? 'Error';
      _status = AuthStatus.error;
      notifyListeners();
      return false;
    }
  }

  Future<bool> completeDoctorProfile(Map<String, dynamic> data) async {
    _status = AuthStatus.loading;
    notifyListeners();

    final result = await _repo.completeDoctorProfile(data);
    if (result['success'] == true) {
      _status = AuthStatus.authenticated;
      notifyListeners();
      return true;
    } else {
      _errorMessage = result['message'] ?? 'Error';
      _status = AuthStatus.error;
      notifyListeners();
      return false;
    }
  }

  void clearError() {
    _errorMessage = null;
    if (_status == AuthStatus.error) _status = AuthStatus.unauthenticated;
    notifyListeners();
  }
}
