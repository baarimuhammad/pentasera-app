import 'dart:convert';
import 'package:http/http.dart' as http;
import 'auth_service.dart';

class UserService {
  static String get baseUrl => AuthService.baseUrl;

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
        return {'success': true, 'data': data['data'] ?? data};
      }
      return {'success': false, 'message': 'Gagal memuat pengguna'};
    } catch (e) {
      return {'success': false, 'message': 'Tidak dapat terhubung ke server.'};
    }
  }

  // ─────────────────────────────────────────
  // UPDATE USER (admin only)
  // ─────────────────────────────────────────
  static Future<Map<String, dynamic>> updateUser(
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
        'message': data['message'] ?? 'Gagal memperbarui pengguna'
      };
    } catch (e) {
      return {'success': false, 'message': 'Tidak dapat terhubung ke server.'};
    }
  }
}
