import 'package:flutter/material.dart';
import 'package:glucpred/core/services/notification_service.dart';
import 'package:glucpred/core/services/socket_service.dart';
import 'package:glucpred/features/alerts/data/repositories/alerts_repository.dart';

enum AlertsFilter { all, critical, reminders }

class AlertsViewModel extends ChangeNotifier {
  final AlertsRepository _repo;

  AlertsViewModel(this._repo) {
    _subscribeToSocket();
  }

  bool _isLoading = false;
  List<Map<String, dynamic>> _alerts = [];
  AlertsFilter _filter = AlertsFilter.all;
  String? _errorMessage;
  int _unreadCount = 0;

  bool get isLoading => _isLoading;
  List<Map<String, dynamic>> get alerts => _alerts;
  AlertsFilter get filter => _filter;
  String? get errorMessage => _errorMessage;
  int get unreadCount => _unreadCount;

  /// Subscribe to real-time alerts from Socket.IO.
  void _subscribeToSocket() {
    SocketService.instance.addAlertListener(_onSocketAlert);
  }

  void _onSocketAlert(Map<String, dynamic> alert) {
    // Prepend the incoming alert to the top of the list (optimistic UI).
    _alerts = [alert, ..._alerts];
    _unreadCount++;
    notifyListeners();

    // Also trigger a local notification if app is in foreground.
    _notifySingleCritical(alert);
  }

  Future<void> _notifySingleCritical(Map<String, dynamic> alert) async {
    if (alert['alert_type'] != 'critica') return;
    final toggles = await NotificationService.readToggles();
    await NotificationService.instance.showCriticalAlert(
      title: alert['title']?.toString() ?? 'Alerta crítica de glucosa',
      body: alert['message']?.toString() ?? 'Se detectó un nivel crítico.',
      soundEnabled: toggles.sound,
      vibrationEnabled: toggles.vibration,
    );
  }

  void clearUnreadCount() {
    _unreadCount = 0;
    notifyListeners();
  }

  @override
  void dispose() {
    SocketService.instance.removeAlertListener(_onSocketAlert);
    super.dispose();
  }

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
      final newAlerts =
          List<Map<String, dynamic>>.from(response['alerts'] ?? []);

      _alerts = newAlerts;
      _unreadCount = newAlerts.where((a) => a['is_read'] == false).length;

      // Disparar notificación local si hay alertas críticas no leídas.
      await _notifyUnreadCritical(newAlerts);
    } catch (e) {
      _errorMessage = 'Error al cargar alertas: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> _notifyUnreadCritical(
      List<Map<String, dynamic>> alerts) async {
    final unreadCritical = alerts.where((a) =>
        a['alert_type'] == 'critica' && a['is_read'] == false).toList();

    if (unreadCritical.isEmpty) return;

    final toggles = await NotificationService.readToggles();

    final latest = unreadCritical.first;
    await NotificationService.instance.showCriticalAlert(
      title: latest['title']?.toString() ?? 'Alerta de glucosa',
      body: latest['message']?.toString() ??
          'Tienes ${unreadCritical.length} alerta(s) crítica(s) sin leer.',
      soundEnabled: toggles.sound,
      vibrationEnabled: toggles.vibration,
    );
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
