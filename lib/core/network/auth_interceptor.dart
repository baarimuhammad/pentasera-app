import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:pentasera_app/core/storage/secure_storage.dart';

/// Dio interceptor that automatically attaches auth token to every request
/// and handles 401 unauthorized responses.
class AuthInterceptor extends Interceptor {
  final SecureStorageService _storage;

  /// Callback invoked when a 401 is received — used to trigger logout.
  final VoidCallback? onUnauthorized;

  AuthInterceptor({
    required SecureStorageService storage,
    this.onUnauthorized,
  }) : _storage = storage;

  @override
  void onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    // Read token from secure storage
    final token = await _storage.getToken();
    if (token != null && token.isNotEmpty) {
      options.headers['Authorization'] = 'Bearer $token';
    }

    // Always set Accept header
    options.headers['Accept'] = 'application/json';

    handler.next(options);
  }

  @override
  void onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    if (err.response?.statusCode == 401) {
      // Token expired or invalid — clear storage and notify
      await _storage.clearAll();
      onUnauthorized?.call();
    }

    handler.next(err);
  }
}
