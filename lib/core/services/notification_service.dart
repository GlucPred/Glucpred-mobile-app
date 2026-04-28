import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

/// Servicio singleton para notificaciones locales.
///
/// Gestiona dos tipos:
/// 1. Alertas críticas de glucosa → notificación inmediata cuando el backend
///    reporta alertas no leídas de tipo "critica".
/// 2. Recordatorio diario de medición → notificación programada a una hora
///    fija (por defecto 9:00 AM) que el OS dispara aunque el app esté cerrado.
class NotificationService {
  NotificationService._();
  static final NotificationService instance = NotificationService._();

  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  static const int _reminderNotifId = 1000;
  static const int _criticalAlertNotifId = 1001;

  // IDs de canal Android
  static const String _channelSoundVibration = 'glucpred_critical_sv';
  static const String _channelSoundOnly = 'glucpred_critical_s';
  static const String _channelVibrationOnly = 'glucpred_critical_v';
  static const String _channelSilent = 'glucpred_critical_silent';
  static const String _channelReminder = 'glucpred_reminder';

  bool _initialized = false;

  Future<void> init() async {
    if (_initialized) return;

    tz.initializeTimeZones();

    const androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const initSettings = InitializationSettings(android: androidSettings);

    await _plugin.initialize(initSettings,
        onDidReceiveNotificationResponse: _onNotificationTap);

    await _createChannels();

    _initialized = true;
  }

  void _onNotificationTap(NotificationResponse response) {
    // Navegación futura si se necesita deep-link al tap de notificación
  }

  Future<void> _createChannels() async {
    final androidPlugin =
        _plugin.resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();
    if (androidPlugin == null) return;

    await androidPlugin.createNotificationChannel(
      const AndroidNotificationChannel(
        _channelSoundVibration,
        'Alertas críticas',
        description: 'Alertas de glucosa con sonido y vibración',
        importance: Importance.max,
        playSound: true,
        enableVibration: true,
      ),
    );
    await androidPlugin.createNotificationChannel(
      const AndroidNotificationChannel(
        _channelSoundOnly,
        'Alertas críticas (solo sonido)',
        description: 'Alertas de glucosa con sonido, sin vibración',
        importance: Importance.high,
        playSound: true,
        enableVibration: false,
      ),
    );
    await androidPlugin.createNotificationChannel(
      const AndroidNotificationChannel(
        _channelVibrationOnly,
        'Alertas críticas (solo vibración)',
        description: 'Alertas de glucosa con vibración, sin sonido',
        importance: Importance.high,
        playSound: false,
        enableVibration: true,
      ),
    );
    await androidPlugin.createNotificationChannel(
      const AndroidNotificationChannel(
        _channelSilent,
        'Alertas críticas (silencioso)',
        description: 'Alertas de glucosa sin sonido ni vibración',
        importance: Importance.low,
        playSound: false,
        enableVibration: false,
      ),
    );
    await androidPlugin.createNotificationChannel(
      const AndroidNotificationChannel(
        _channelReminder,
        'Recordatorios de medición',
        description: 'Recordatorio diario para registrar la glucosa',
        importance: Importance.high,
        playSound: true,
        enableVibration: true,
      ),
    );
  }

  /// Muestra una notificación inmediata de alerta crítica de glucosa.
  ///
  /// Respeta los toggles de [soundEnabled] y [vibrationEnabled].
  Future<void> showCriticalAlert({
    required String title,
    required String body,
    required bool soundEnabled,
    required bool vibrationEnabled,
  }) async {
    if (!_initialized) return;

    final channelId = _resolveAlertChannel(soundEnabled, vibrationEnabled);

    final androidDetails = AndroidNotificationDetails(
      channelId,
      'Alerta de glucosa',
      channelDescription: 'Notificación de nivel crítico de glucosa',
      importance: Importance.max,
      priority: Priority.high,
      playSound: soundEnabled,
      enableVibration: vibrationEnabled,
      icon: '@mipmap/ic_launcher',
    );

    await _plugin.show(
      _criticalAlertNotifId,
      title,
      body,
      NotificationDetails(android: androidDetails),
    );
  }

  /// Programa un recordatorio diario recurrente a la hora indicada.
  ///
  /// Se dispara aunque el app esté cerrado (el OS administra la alarma).
  /// Cancela cualquier recordatorio previo antes de programar el nuevo.
  Future<void> scheduleDailyReminder({int hour = 9, int minute = 0}) async {
    if (!_initialized) return;

    await cancelReminder();

    final now = tz.TZDateTime.now(tz.local);
    var scheduled =
        tz.TZDateTime(tz.local, now.year, now.month, now.day, hour, minute);

    if (scheduled.isBefore(now)) {
      scheduled = scheduled.add(const Duration(days: 1));
    }

    const androidDetails = AndroidNotificationDetails(
      _channelReminder,
      'Recordatorio de medición',
      channelDescription: 'Recordatorio diario para registrar la glucosa',
      importance: Importance.high,
      priority: Priority.high,
      icon: '@mipmap/ic_launcher',
    );

    await _plugin.zonedSchedule(
      _reminderNotifId,
      '¡No olvides registrar tu glucosa!',
      'Mantén tu control al día. Abre GlucPred y registra tu medición.',
      scheduled,
      const NotificationDetails(android: androidDetails),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      matchDateTimeComponents: DateTimeComponents.time,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
    );
  }

  /// Cancela el recordatorio diario programado.
  Future<void> cancelReminder() async {
    if (!_initialized) return;
    await _plugin.cancel(_reminderNotifId);
  }

  /// Solicita permiso de notificaciones en Android 13+.
  Future<bool> requestPermission() async {
    if (defaultTargetPlatform != TargetPlatform.android) return true;

    final androidPlugin =
        _plugin.resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();
    if (androidPlugin == null) return false;

    final granted = await androidPlugin.requestNotificationsPermission();
    return granted ?? false;
  }

  String _resolveAlertChannel(bool sound, bool vibration) {
    if (sound && vibration) return _channelSoundVibration;
    if (sound) return _channelSoundOnly;
    if (vibration) return _channelVibrationOnly;
    return _channelSilent;
  }

  /// Lee los toggles desde SharedPreferences para uso interno.
  static Future<({bool sound, bool vibration})> readToggles() async {
    final prefs = await SharedPreferences.getInstance();
    return (
      sound: prefs.getBool('sound_enabled') ?? true,
      vibration: prefs.getBool('vibration_enabled') ?? true,
    );
  }
}
