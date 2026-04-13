import 'package:flutter/material.dart';
import 'package:glucpred/features/doctor/data/repositories/doctor_patient_repository.dart';

class DoctorPatientViewModel extends ChangeNotifier {
  final DoctorPatientRepository _repo;

  DoctorPatientViewModel(this._repo);

  bool _isLoading = false;
  List<Map<String, dynamic>> _alerts = [];
  List<dynamic> _records = [];
  List<Map<String, dynamic>> _observations = [];
  String? _errorMessage;
  bool _isActing = false;

  bool get isLoading => _isLoading;
  List<Map<String, dynamic>> get alerts => _alerts;
  List<dynamic> get records => _records;
  List<Map<String, dynamic>> get observations => _observations;
  String? get errorMessage => _errorMessage;
  bool get isActing => _isActing;

  Future<void> loadPatientAlerts(
      {int? patientId, bool unreadOnly = false}) async {
    _isLoading = true;
    notifyListeners();

    final result = await _repo.getPatientAlerts(
        patientId: patientId, unreadOnly: unreadOnly);
    if (result['success'] == true) {
      _alerts = List<Map<String, dynamic>>.from(result['alerts'] ?? []);
    } else {
      _errorMessage = result['message'];
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> loadPatientRecords(int patientId,
      {int limit = 20, int offset = 0}) async {
    _isLoading = true;
    notifyListeners();

    final result = await _repo.getPatientRecords(patientId,
        limit: limit, offset: offset);
    if (result['success'] == true) {
      _records = result['records'] as List? ?? [];
    } else {
      _errorMessage = result['message'];
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> loadObservations(int patientId) async {
    _isLoading = true;
    notifyListeners();

    final result = await _repo.getObservations(patientId);
    if (result['success'] == true) {
      _observations =
          List<Map<String, dynamic>>.from(result['observations'] ?? []);
    } else {
      _errorMessage = result['message'];
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<bool> addObservation(int patientId, String observation) async {
    _isActing = true;
    notifyListeners();

    final result = await _repo.addObservation(patientId, observation);
    _isActing = false;

    if (result['success'] == true) {
      await loadObservations(patientId);
      return true;
    } else {
      _errorMessage = result['message'];
      notifyListeners();
      return false;
    }
  }

  Future<bool> addPatient(int patientUserId) async {
    _isActing = true;
    notifyListeners();

    final result = await _repo.addPatient(patientUserId);
    _isActing = false;
    if (result['success'] != true) {
      _errorMessage = result['message'];
      notifyListeners();
      return false;
    }
    notifyListeners();
    return true;
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
