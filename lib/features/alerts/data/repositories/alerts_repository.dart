import 'package:flutter/material.dart';
import 'package:glucpred/features/alerts/data/services/alerts_service.dart';

class AlertsRepository {
  Future<Map<String, dynamic>> getAlerts(
          {String type = 'todas', int limit = 50}) =>
      AlertsService.getAlerts(type: type, limit: limit);

  Future<Map<String, dynamic>> markAsRead(int alertId) =>
      AlertsService.markAsRead(alertId);

  Future<Map<String, dynamic>> markAllAsRead() =>
      AlertsService.markAllAsRead();

  Future<Map<String, dynamic>> dismissAlert(int alertId) =>
      AlertsService.dismissAlert(alertId);

  Future<Map<String, dynamic>> createReminder(
          {required String title, required String message}) =>
      AlertsService.createReminder(title: title, message: message);

  Color getColorBySeverity(String severity) =>
      AlertsService.getColorBySeverity(severity);

  IconData getIconByType(String type) => AlertsService.getIconByType(type);

  String getTimeAgo(String createdAt) => AlertsService.getTimeAgo(createdAt);
}
