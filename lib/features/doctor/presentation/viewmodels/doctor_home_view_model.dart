import 'package:flutter/material.dart';
import 'package:glucpred/features/auth/data/repositories/auth_repository.dart';
import 'package:glucpred/features/doctor/data/repositories/doctor_patient_repository.dart';

class DoctorHomeViewModel extends ChangeNotifier {
  final AuthRepository _authRepo;
  final DoctorPatientRepository _doctorRepo;

  DoctorHomeViewModel(this._authRepo, this._doctorRepo);

  bool _isLoading = false;
  String _doctorName = 'Doctor';
  List<Map<String, dynamic>> _patients = [];
  int _totalPatients = 0;
  int _activePatients = 0;
  int _criticalAlerts = 0;
  double _avgGlucose = 0.0;
  String? _errorMessage;

  bool get isLoading => _isLoading;
  String get doctorName => _doctorName;
  List<Map<String, dynamic>> get patients => _patients;
  int get totalPatients => _totalPatients;
  int get activePatients => _activePatients;
  int get criticalAlerts => _criticalAlerts;
  double get avgGlucose => _avgGlucose;
  String? get errorMessage => _errorMessage;

  Future<void> loadDoctorData() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    final userInfo = await _authRepo.getUserInfo();
    _doctorName = userInfo['nombre_completo'] ?? 'Doctor';

    final result = await _doctorRepo.getPatientsSummary();
    if (result['success'] == true) {
      final patients =
          List<Map<String, dynamic>>.from(result['patients'] ?? []);
      int alertsCount = 0;
      double totalGlucose = 0.0;

      for (final p in patients) {
        alertsCount += (p['alertas_count'] as int? ?? 0);
        totalGlucose += (p['ultima_glucosa'] as num? ?? 0).toDouble();
      }

      _patients = patients;
      _totalPatients = result['total'] ?? 0;
      _activePatients = patients.length;
      _criticalAlerts = alertsCount;
      _avgGlucose =
          patients.isEmpty ? 0.0 : totalGlucose / patients.length;
    } else {
      _errorMessage = result['message'] ?? 'Error al cargar pacientes';
    }

    _isLoading = false;
    notifyListeners();
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
