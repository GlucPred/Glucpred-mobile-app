import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:glucpred/core/config/env_config.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class ApiClient {
  static const _secureStorage = FlutterSecureStorage();
  static const Duration _timeout = Duration(seconds: 30);
  static const int _maxRetries = 2;

  /// Called when the server returns 401 (token expired / invalid).
  /// Register this from main.dart to navigate to the login screen.
  static void Function()? onUnauthorized;

  static String get baseUrl => EnvConfig.apiBaseUrl;

  /// Extracts a human-readable error string from a decoded JSON map.
  /// Backends in this project return either `message` or `error`.
  static String parseMessage(Map<String, dynamic> data, [String fallback = 'Error desconocido']) {
    return (data['message'] ?? data['error'] ?? fallback).toString();
  }

  static Future<Map<String, String>> _getHeaders({bool auth = true}) async {
    final headers = {'Content-Type': 'application/json'};
    if (auth) {
      final token = await _secureStorage.read(key: 'access_token');
      if (token != null) {
        headers['Authorization'] = 'Bearer $token';
      }
    }
    return headers;
  }

  static Future<http.Response> _retryRequest(
    Future<http.Response> Function() request,
  ) async {
    int attempts = 0;
    while (true) {
      try {
        attempts++;
        final response = await request().timeout(_timeout);
        if (response.statusCode == 401) {
          await _secureStorage.delete(key: 'access_token');
          onUnauthorized?.call();
          return response;
        }
        return response;
      } on TimeoutException {
        if (attempts > _maxRetries) rethrow;
      } on Exception {
        if (attempts > _maxRetries) rethrow;
      }
      await Future.delayed(Duration(seconds: attempts));
    }
  }

  static Future<http.Response> get(
    String path, {
    bool auth = true,
    Map<String, String>? queryParams,
  }) async {
    final headers = await _getHeaders(auth: auth);
    var uri = Uri.parse('$baseUrl$path');
    if (queryParams != null) {
      uri = uri.replace(queryParameters: queryParams);
    }
    return _retryRequest(() => http.get(uri, headers: headers));
  }

  static Future<http.Response> post(
    String path, {
    bool auth = true,
    Map<String, dynamic>? body,
  }) async {
    final headers = await _getHeaders(auth: auth);
    final uri = Uri.parse('$baseUrl$path');
    return _retryRequest(
      () => http.post(uri, headers: headers, body: body != null ? jsonEncode(body) : null),
    );
  }

  static Future<http.Response> put(
    String path, {
    bool auth = true,
    Map<String, dynamic>? body,
  }) async {
    final headers = await _getHeaders(auth: auth);
    final uri = Uri.parse('$baseUrl$path');
    return _retryRequest(
      () => http.put(uri, headers: headers, body: body != null ? jsonEncode(body) : null),
    );
  }

  static Future<http.Response> delete(
    String path, {
    bool auth = true,
  }) async {
    final headers = await _getHeaders(auth: auth);
    final uri = Uri.parse('$baseUrl$path');
    return _retryRequest(() => http.delete(uri, headers: headers));
  }
}
