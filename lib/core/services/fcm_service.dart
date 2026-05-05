import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import '../network/api_client.dart';
import '../services/notification_service.dart';

/// Handles FCM token registration and message routing.
/// Call [init] once after login.
class FcmService {
  FcmService._();
  static final FcmService instance = FcmService._();

  /// Called when user taps a notification from background/terminated state.
  /// Set this in the navigation widget to switch to the alerts tab.
  static void Function()? onAlertTapped;

  /// Must be called BEFORE [init] — top-level handler for background/terminated messages.
  static Future<void> backgroundHandler(RemoteMessage message) async {
    await Firebase.initializeApp();
    debugPrint('FCM background message: ${message.messageId}');
  }

  Future<void> init() async {
    // Request permission (iOS / Android 13+)
    final settings = await FirebaseMessaging.instance.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );
    debugPrint('FCM permission: ${settings.authorizationStatus}');

    // Get and register token
    await _registerToken();

    // Token refresh
    FirebaseMessaging.instance.onTokenRefresh.listen(_sendTokenToServer);

    // Foreground messages — show local notification since Android suppresses them
    FirebaseMessaging.onMessage.listen(_handleForeground);

    // Background → app opened via notification tap
    FirebaseMessaging.onMessageOpenedApp.listen(_handleMessageOpened);

    // Check if app was launched from a notification (terminated state)
    final initial = await FirebaseMessaging.instance.getInitialMessage();
    if (initial != null) _handleMessageOpened(initial);
  }

  Future<void> _registerToken() async {
    try {
      final token = await FirebaseMessaging.instance.getToken();
      if (token != null) {
        await _sendTokenToServer(token);
      }
    } catch (e) {
      debugPrint('FCM token error: $e');
    }
  }

  Future<void> _sendTokenToServer(String token) async {
    try {
      await ApiClient.post('/api/alerts/fcm-token', body: {
        'token': token,
        'platform': defaultTargetPlatform.name.toLowerCase(),
      });
      debugPrint('FCM token registered on server');
    } catch (e) {
      debugPrint('Failed to register FCM token: $e');
    }
  }

  /// Foreground: Android does NOT show FCM notification messages automatically.
  /// We show a local notification manually so the user sees it even while in the app.
  Future<void> _handleForeground(RemoteMessage message) async {
    debugPrint('FCM foreground: ${message.notification?.title}');
    final notification = message.notification;
    if (notification == null) return;
    final toggles = await NotificationService.readToggles();
    await NotificationService.instance.showCriticalAlert(
      title: notification.title ?? 'Alerta GlucPred',
      body: notification.body ?? '',
      soundEnabled: toggles.sound,
      vibrationEnabled: toggles.vibration,
    );
  }

  /// Background/terminated: user tapped the notification → navigate to alerts.
  void _handleMessageOpened(RemoteMessage message) {
    debugPrint('FCM tapped: ${message.data}');
    onAlertTapped?.call();
  }
}
