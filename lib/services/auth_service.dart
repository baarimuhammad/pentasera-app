import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  // ─────────────────────────────────────────
  // BASE URL — auto-detect platform
  // ─────────────────────────────────────────
  static String get baseUrl {
    if (kIsWeb) {
      return 'http://localhost:8000/api';
    }
    // Android emulator → 10.0.2.2, iOS simulator → localhost
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
  // AUTH HEADERS
  // ─────────────────────────────────────────
  static Future<Map<String, String>> authHeaders() async {
    final token = await getToken();
    return {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }

  // ─────────────────────────────────────────
  // LOGIN
  // ─────────────────────────────────────────
  static Future<Map<String, dynamic>> login(
      String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/login'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode({'email': email, 'password': password}),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('token', data['token']);
        await prefs.setString('user_nama', data['user']['nama'] ?? '');
        await prefs.setString('user_role', data['user']['role'] ?? '');
        await prefs.setString('user_email', data['user']['email'] ?? '');
        await prefs.setString(
            'user_created_at', data['user']['created_at'] ?? '');
        return {'success': true, 'data': data};
      } else if (response.statusCode == 422) {
        String errorMsg = 'Email atau password salah';
        if (data['errors'] != null && data['errors']['email'] != null) {
          errorMsg = data['errors']['email'][0];
        } else if (data['message'] != null) {
          errorMsg = data['message'];
        }
        return {'success': false, 'message': errorMsg};
      } else if (response.statusCode == 403) {
        return {
          'success': false,
          'message': data['message'] ?? 'Akun dinonaktifkan'
        };
      } else {
        return {'success': false, 'message': data['message'] ?? 'Login gagal'};
      }
    } catch (e) {
      return {'success': false, 'message': 'Tidak dapat terhubung ke server.'};
    }
  }

  // ─────────────────────────────────────────
  // REGISTER
  // ─────────────────────────────────────────
  static Future<Map<String, dynamic>> register({
    required String nama,
    required String email,
    required String password,
    required String passwordConfirmation,
    String role = 'buyer',
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/register'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode({
          'nama': nama,
          'email': email,
          'password': password,
          'password_confirmation': passwordConfirmation,
          'role': role,
        }),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 201) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('token', data['token']);
        await prefs.setString('user_nama', data['user']['nama'] ?? '');
        await prefs.setString('user_role', data['user']['role'] ?? '');
        await prefs.setString('user_email', data['user']['email'] ?? '');
        await prefs.setString(
            'user_created_at', data['user']['created_at'] ?? '');
        return {'success': true, 'data': data};
      } else if (response.statusCode == 422) {
        String errorMsg = 'Registrasi gagal';
        if (data['errors'] != null) {
          final errors = data['errors'] as Map<String, dynamic>;
          final firstField = errors.values.first;
          if (firstField is List && firstField.isNotEmpty) {
            errorMsg = firstField[0];
          }
        } else if (data['message'] != null) {
          errorMsg = data['message'];
        }
        return {'success': false, 'message': errorMsg};
      } else {
        return {
          'success': false,
          'message': data['message'] ?? 'Registrasi gagal'
        };
      }
    } catch (e) {
      return {'success': false, 'message': 'Tidak dapat terhubung ke server.'};
    }
  }

  // ─────────────────────────────────────────
  // LOGOUT
  // ─────────────────────────────────────────
  static Future<void> logout() async {
    try {
      final headers = await authHeaders();
      await http.post(Uri.parse('$baseUrl/logout'), headers: headers);
    } catch (_) {}
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('token');
    await prefs.remove('user_nama');
    await prefs.remove('user_role');
    await prefs.remove('user_email');
    await prefs.remove('user_created_at');
  }

  // ─────────────────────────────────────────
  // GET ME (profil user dari server)
  // ─────────────────────────────────────────
  static Future<Map<String, dynamic>> getMe() async {
    try {
      final headers = await authHeaders();
      final response = await http.get(
        Uri.parse('$baseUrl/me'),
        headers: headers,
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return {'success': true, 'data': data['data'] ?? data};
      }
      return {'success': false, 'message': 'Gagal memuat profil'};
    } catch (e) {
      return {'success': false, 'message': 'Tidak dapat terhubung ke server.'};
    }
  }

  // ─────────────────────────────────────────
  // HELPERS
  // ─────────────────────────────────────────
  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }

  static Future<bool> isLoggedIn() async {
    final token = await getToken();
    return token != null && token.isNotEmpty;
  }

  static Future<String?> getUserNama() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('user_nama');
  }

  static Future<String?> getUserRole() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('user_role');
  }

  static Future<String?> getUserEmail() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('user_email');
  }

  static Future<String?> getUserCreatedAt() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('user_created_at');
  }
}
