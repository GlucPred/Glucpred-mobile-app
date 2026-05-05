import 'package:socket_io_client/socket_io_client.dart' as io;
import 'package:flutter/foundation.dart';
import '../config/env_config.dart';
import '../network/api_client.dart';

typedef AlertCallback = void Function(Map<String, dynamic> alert);

/// Manages the persistent Socket.IO connection to the api-gateway.
/// Call [connect] after login; [disconnect] after logout.
class SocketService {
  SocketService._();
  static final SocketService instance = SocketService._();

  io.Socket? _socket;
  final List<AlertCallback> _alertListeners = [];

  bool get isConnected => _socket?.connected ?? false;

  /// Connects to the api-gateway using the stored JWT for room assignment.
  Future<void> connect() async {
    if (isConnected) return;

    final token = await ApiClient.getStoredToken();
    if (token == null) {
      debugPrint('SocketService: no JWT found, skipping connection');
      return;
    }

    final serverUrl = EnvConfig.apiBaseUrl;

    _socket = io.io(
      serverUrl,
      io.OptionBuilder()
          .setTransports(['websocket'])
          .setQuery({'token': token})
          .enableAutoConnect()
          .enableReconnection()
          .setReconnectionAttempts(10)
          .setReconnectionDelay(3000)
          .build(),
    );

    _socket!.onConnect((_) {
      debugPrint('Socket.IO connected to $serverUrl');
    });

    _socket!.on('alert:new', (data) {
      debugPrint('Socket alert:new received: $data');
      final alert = Map<String, dynamic>.from(data as Map);
      for (final cb in _alertListeners) {
        cb(alert);
      }
    });

    _socket!.onDisconnect((_) {
      debugPrint('Socket.IO disconnected');
    });

    _socket!.onError((error) {
      debugPrint('Socket.IO error: $error');
    });

    _socket!.connect();
  }

  void addAlertListener(AlertCallback callback) {
    _alertListeners.add(callback);
  }

  void removeAlertListener(AlertCallback callback) {
    _alertListeners.remove(callback);
  }

  void disconnect() {
    _socket?.disconnect();
    _socket = null;
  }
}
