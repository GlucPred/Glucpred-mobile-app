import 'dart:convert';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import '../network/api_client.dart';

/// Handles FCM token registration and message routing.
/// Call [init] once after login.
class FcmService {
  FcmService._();
  static final FcmService instance = FcmService._();

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

    // Foreground messages
    FirebaseMessaging.onMessage.listen(_handleForeground);

    // Background → app opened
    FirebaseMessaging.onMessageOpenedApp.listen(_handleMessageOpened);

    // Check if app was launched from a notification
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

  void _handleForeground(RemoteMessage message) {
    debugPrint('FCM foreground: ${message.notification?.title}');
    // Notifications while app is open are handled by SocketService / AlertsViewModel.
    // No local notification needed — the banner/badge is shown via Socket.IO.
  }

  void _handleMessageOpened(RemoteMessage message) {
    debugPrint('FCM tapped: ${message.data}');
    // TODO: navigate to Alerts tab via NavigationService when implemented
  }
}
