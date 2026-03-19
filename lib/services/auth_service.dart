import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  // Emulator Android  → 10.0.2.2
  // Device fisik      → IP WiFi laptop kamu (cek: ipconfig / ifconfig)
  static const String baseUrl = 'http://localhost:8000/api';

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
      return {'success': false, 'message': 'Tidak dapat terhubung ke server. '};
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
          'password_confirmation':
              passwordConfirmation, // wajib ada untuk Laravel 'confirmed'
          'role': role,
        }),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 201) {
        // Simpan token langsung setelah register (auto login)
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('token', data['token']);
        await prefs.setString('user_nama', data['user']['nama'] ?? '');
        await prefs.setString('user_role', data['user']['role'] ?? '');
        return {'success': true, 'data': data};
      } else if (response.statusCode == 422) {
        // Validasi gagal dari Laravel — ambil pesan error pertama yang ada
        String errorMsg = 'Registrasi gagal';
        if (data['errors'] != null) {
          final errors = data['errors'] as Map<String, dynamic>;
          // Ambil pesan error pertama dari field manapun
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
      return {'success': false, 'message': 'Tidak dapat terhubung ke server. '};
    }
  }

  // ─────────────────────────────────────────
  // LOGOUT
  // ─────────────────────────────────────────
  static Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('token');
    await prefs.remove('user_nama');
    await prefs.remove('user_role');
  }

  // ─────────────────────────────────────────
  // HELPER
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
}
