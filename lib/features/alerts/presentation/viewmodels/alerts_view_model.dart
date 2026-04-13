import 'package:flutter/material.dart';
import 'package:glucpred/features/alerts/data/repositories/alerts_repository.dart';

enum AlertsFilter { all, critical, reminders }

class AlertsViewModel extends ChangeNotifier {
  final AlertsRepository _repo;

  AlertsViewModel(this._repo);

  bool _isLoading = false;
  List<Map<String, dynamic>> _alerts = [];
  AlertsFilter _filter = AlertsFilter.all;
  String? _errorMessage;

  bool get isLoading => _isLoading;
  List<Map<String, dynamic>> get alerts => _alerts;
  AlertsFilter get filter => _filter;
  String? get errorMessage => _errorMessage;

  void setFilter(AlertsFilter f) {
    _filter = f;
    loadAlerts();
  }

  Future<void> loadAlerts() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      String typeFilter = 'todas';
      if (_filter == AlertsFilter.critical) typeFilter = 'critica';
      if (_filter == AlertsFilter.reminders) typeFilter = 'recordatorio';

      final response = await _repo.getAlerts(type: typeFilter, limit: 50);
      _alerts = List<Map<String, dynamic>>.from(response['alerts'] ?? []);
    } catch (e) {
      _errorMessage = 'Error al cargar alertas: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> markAsRead(int alertId) async {
    try {
      await _repo.markAsRead(alertId);
      await loadAlerts();
      return true;
    } catch (e) {
      _errorMessage = 'Error: $e';
      notifyListeners();
      return false;
    }
  }

  Future<bool> markAllAsRead() async {
    try {
      await _repo.markAllAsRead();
      await loadAlerts();
      return true;
    } catch (e) {
      _errorMessage = 'Error: $e';
      notifyListeners();
      return false;
    }
  }

  Future<bool> dismissAlert(int alertId) async {
    try {
      await _repo.dismissAlert(alertId);
      await loadAlerts();
      return true;
    } catch (e) {
      _errorMessage = 'Error: $e';
      notifyListeners();
      return false;
    }
  }

  Future<bool> createReminder(
      {required String title, required String message}) async {
    try {
      await _repo.createReminder(title: title, message: message);
      await loadAlerts();
      return true;
    } catch (e) {
      _errorMessage = 'Error: $e';
      notifyListeners();
      return false;
    }
  }

  Color getColorBySeverity(String severity) =>
      _repo.getColorBySeverity(severity);

  IconData getIconByType(String type) => _repo.getIconByType(type);

  String getTimeAgo(String createdAt) => _repo.getTimeAgo(createdAt);

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
