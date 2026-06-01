import 'package:flutter/foundation.dart';

/// Centralized API configuration constants.
class ApiConstants {
  ApiConstants._();

  // ─────────────────────────────────────────
  // Base URL — auto-detect platform
  // ─────────────────────────────────────────
  static String get baseUrl {
    if (kIsWeb) return 'http://localhost:8000/api';
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return 'http://10.0.2.2:8000/api';
      case TargetPlatform.iOS:
        return 'http://localhost:8000/api';
      default:
        return 'http://localhost:8000/api';
    }
  }

  // ─────────────────────────────────────────
  // Timeouts
  // ─────────────────────────────────────────
  static const Duration connectTimeout = Duration(seconds: 15);
  static const Duration receiveTimeout = Duration(seconds: 15);

  // ─────────────────────────────────────────
  // Endpoint paths
  // ─────────────────────────────────────────
  static const String login = '/login';
  static const String register = '/register';
  static const String logout = '/logout';
  static const String me = '/me';
  static const String resendVerification = '/email/resend-verification';
}
