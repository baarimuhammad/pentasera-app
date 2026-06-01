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

      final data = _decodeJsonObject(response.body);

      if (response.statusCode == 200) {
        final prefs = await SharedPreferences.getInstance();
        final token = data['token'];
        final user = _extractUser(data);

        if (token is String && token.isNotEmpty) {
          await prefs.setString('token', token);
        }
        if (user != null) {
          await cacheUserData(user, fallbackEmail: email);
        }
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

      final data = _decodeJsonObject(response.body);

      if (response.statusCode >= 200 && response.statusCode < 300) {
        final token = data['token'];
        final user = _extractUser(data);

        if (token is String && token.isNotEmpty && user != null) {
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString('token', token);
          await cacheUserData(
            user,
            fallbackEmail: email,
            fallbackRole: role,
          );
          return {'success': true, 'data': data};
        }

        return {
          'success': true,
          'requiresLogin': true,
          'message': data['message']?.toString() ??
              'Registrasi berhasil. Silakan login.',
          'data': data,
        };
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
      if (kDebugMode) {
        debugPrint('[AuthService.register] $e');
      }

      final errorText = e.toString();
      final isNetworkError = e is http.ClientException ||
          errorText.contains('SocketException') ||
          errorText.contains('Connection refused') ||
          errorText.contains('Failed host lookup');

      return {
        'success': false,
        'message': isNetworkError
            ? 'Tidak dapat terhubung ke server.'
            : 'Registrasi berhasil dikirim, tetapi respons server tidak sesuai format aplikasi.',
      };
    }
  }

  static Map<String, dynamic> _decodeJsonObject(String body) {
    if (body.trim().isEmpty) return <String, dynamic>{};

    final decoded = jsonDecode(body);
    if (decoded is Map<String, dynamic>) return decoded;
    if (decoded is Map) return Map<String, dynamic>.from(decoded);

    return <String, dynamic>{'message': decoded.toString()};
  }

  static Map<String, dynamic>? _extractUser(Map<String, dynamic> data) {
    final user = data['user'];
    if (user is Map<String, dynamic>) return user;
    if (user is Map) return Map<String, dynamic>.from(user);

    final nestedData = data['data'];
    if (nestedData is Map) {
      final nestedUser = nestedData['user'];
      if (nestedUser is Map<String, dynamic>) return nestedUser;
      if (nestedUser is Map) return Map<String, dynamic>.from(nestedUser);
    }

    return null;
  }

  static int _asInt(dynamic value) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    return int.tryParse(value?.toString() ?? '') ?? 0;
  }

  static Future<void> cacheUserData(
    Map<String, dynamic> user, {
    String? fallbackNama,
    String? fallbackEmail,
    String? fallbackRole,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final userId = _asInt(user['id'] ?? user['user_id']);
    final nama = (user['nama'] ?? user['name'] ?? fallbackNama)?.toString();
    final email =
        (user['email'] ?? user['user_email'] ?? fallbackEmail)?.toString();
    final role = (user['role'] ?? fallbackRole)?.toString();
    final createdAt = (user['created_at'] ??
            user['createdAt'] ??
            user['joined_at'] ??
            user['joinedAt'] ??
            user['tanggal_daftar'])
        ?.toString();

    if (userId > 0) await prefs.setInt('user_id', userId);
    if (nama != null && nama.trim().isNotEmpty) {
      await prefs.setString('user_nama', nama);
    }
    if (email != null && email.trim().isNotEmpty) {
      await prefs.setString('user_email', email);
    }
    if (role != null && role.trim().isNotEmpty) {
      await prefs.setString('user_role', role);
    }
    if (createdAt != null && createdAt.trim().isNotEmpty) {
      await prefs.setString('user_created_at', createdAt);
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
    await prefs.remove('user_id');
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
        final data = _decodeJsonObject(response.body);
        // Backend returns {"user": {...}} per claude.md
        final rawUserData = data['user'] ?? data['data'] ?? data;
        final userData = rawUserData is Map<String, dynamic>
            ? rawUserData
            : rawUserData is Map
                ? Map<String, dynamic>.from(rawUserData)
                : <String, dynamic>{};
        await cacheUserData(userData);
        return {'success': true, 'data': userData};
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

  static Future<int?> getUserId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt('user_id');
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
