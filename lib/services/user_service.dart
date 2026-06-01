import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'auth_service.dart';

class UserService {
  static String get baseUrl => AuthService.baseUrl;

  static Map<String, dynamic> _decodeJsonObject(String body) {
    if (body.trim().isEmpty) return <String, dynamic>{};

    final decoded = jsonDecode(body);
    if (decoded is Map<String, dynamic>) return decoded;
    if (decoded is Map) return Map<String, dynamic>.from(decoded);

    return <String, dynamic>{'message': decoded.toString()};
  }

  static Map<String, dynamic> _extractData(Map<String, dynamic> data) {
    final rawData = data['user'] ?? data['data'];
    if (rawData is Map<String, dynamic>) return rawData;
    if (rawData is Map) return Map<String, dynamic>.from(rawData);
    return data;
  }

  static String _extractErrorMessage(
      Map<String, dynamic> data, String fallback) {
    final errors = data['errors'];
    if (errors is Map && errors.values.isNotEmpty) {
      final firstField = errors.values.first;
      if (firstField is List && firstField.isNotEmpty) {
        return firstField.first.toString();
      }
    }

    return data['message']?.toString() ?? fallback;
  }

  // ─────────────────────────────────────────
  // GET USERS (admin only)
  // ─────────────────────────────────────────
  static Future<Map<String, dynamic>> getUsers() async {
    try {
      final headers = await AuthService.authHeaders();
      final response = await http.get(
        Uri.parse('$baseUrl/users'),
        headers: headers,
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        List<dynamic> users = [];
        if (data is List) {
          users = data;
        } else if (data is Map<String, dynamic>) {
          users = (data['data'] as List?) ?? <dynamic>[];
        }
        return {'success': true, 'data': users};
      }
      return {'success': false, 'message': 'Gagal memuat pengguna'};
    } catch (e) {
      return {'success': false, 'message': 'Tidak dapat terhubung ke server.'};
    }
  }

  // ─────────────────────────────────────────
  // UPDATE USER ROLE (admin only)
  // Backend: PATCH /api/users/{id}
  // ─────────────────────────────────────────
  static Future<Map<String, dynamic>> updateUserRole(
      int userId, String newRole) async {
    try {
      final headers = await AuthService.authHeaders();
      final response = await http.patch(
        Uri.parse('$baseUrl/users/$userId'),
        headers: headers,
        body: jsonEncode({'role': newRole}),
      );
      final data = jsonDecode(response.body);
      if (response.statusCode == 200 || response.statusCode == 201) {
        return {'success': true, 'data': data['data'] ?? data};
      }
      return {
        'success': false,
        'message': data['message'] ?? 'Gagal memperbarui pengguna'
      };
    } catch (e) {
      return {'success': false, 'message': 'Tidak dapat terhubung ke server.'};
    }
  }

  // ─────────────────────────────────────────
  // UPDATE PROFILE
  // Backend: PATCH /api/users/{id}
  // ─────────────────────────────────────────
  static Future<Map<String, dynamic>> updateProfile({
    required int userId,
    required String nama,
    required String email,
  }) async {
    try {
      final headers = await AuthService.authHeaders();
      final savedRole = await AuthService.getUserRole();
      final role = savedRole != null && savedRole.trim().isNotEmpty
          ? savedRole
          : 'buyer';
      final response = await http.patch(
        Uri.parse('$baseUrl/users/$userId'),
        headers: headers,
        body: jsonEncode({
          'nama': nama,
          'name': nama,
          'email': email,
          'role': role,
        }),
      );
      final data = _decodeJsonObject(response.body);

      if (kDebugMode) {
        debugPrint(
          '[UserService.updateProfile] ${response.statusCode}: ${response.body}',
        );
      }

      if (response.statusCode >= 200 && response.statusCode < 300) {
        final userData = _extractData(data);
        await AuthService.cacheUserData({
          ...userData,
          'id': userData['id'] ?? userId,
          'nama': userData['nama'] ?? nama,
          'email': userData['email'] ?? email,
          'role': userData['role'] ?? role,
        });
        return {'success': true, 'data': userData};
      }

      return {
        'success': false,
        'message': _extractErrorMessage(data, 'Gagal memperbarui profil'),
      };
    } catch (e) {
      return {'success': false, 'message': 'Tidak dapat terhubung ke server.'};
    }
  }

  // â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
  // CREATE USER (admin only)
  // Backend: POST /api/users
  // â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€

  static Future<Map<String, dynamic>> createUser(
      Map<String, dynamic> userData) async {
    try {
      final headers = await AuthService.authHeaders();
      final response = await http.post(
        Uri.parse('$baseUrl/users'),
        headers: headers,
        body: jsonEncode(userData),
      );
      final data = jsonDecode(response.body);
      if (response.statusCode == 200 || response.statusCode == 201) {
        return {'success': true, 'data': data['data'] ?? data};
      }
      return {
        'success': false,
        'message': data['message'] ?? 'Gagal membuat pengguna'
      };
    } catch (e) {
      return {'success': false, 'message': 'Tidak dapat terhubung ke server.'};
    }
  }
}
