import 'package:flutter/foundation.dart';

class AppLogger {
  static void debug(String message) {
    if (kDebugMode) {
      print('[DEBUG] $message');
    }
  }

  static void error(String message, [Object? error]) {
    if (kDebugMode) {
      print('[ERROR] $message${error != null ? ': $error' : ''}');
    }
  }

  static void info(String message) {
    if (kDebugMode) {
      print('[INFO] $message');
    }
  }
}
