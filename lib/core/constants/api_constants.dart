import 'package:flutter/foundation.dart';

/// Centralized API configuration constants.
class ApiConstants {
  ApiConstants._();

  // ─────────────────────────────────────────
  // Base URL — Railway Production
  // https://pentasera.up.railway.app
  // ─────────────────────────────────────────

  static const String _railwayUrl = 'https://pentasera.up.railway.app';

  static String get baseUrl {
    return '$_railwayUrl/api';
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
