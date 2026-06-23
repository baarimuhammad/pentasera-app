import 'package:flutter/foundation.dart';

/// Centralized API configuration constants.
class ApiConstants {
  ApiConstants._();

  // ─────────────────────────────────────────
  // Base URL — auto-detect platform
  //
  // ⚠️  Untuk HP fisik: ganti IP di bawah dengan IP WiFi laptop Anda.
  //    Cek dengan: ipconfig (Windows) → cari IPv4 di adapter WiFi.
  //    Contoh: 192.168.213.26
  //
  // Untuk emulator Android: gunakan 10.0.2.2
  // ─────────────────────────────────────────

  static const String _ngrokUrl = 'https://bounding-shrine-exemption.ngrok-free.dev';

  static String get baseUrl {
    return '$_ngrokUrl/api';
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
