import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:pentasera_app/services/auth_service.dart';

class AdminService {
  static String get baseUrl => AuthService.baseUrl;

  // ─────────────────────────────────────────
  // GET ADMIN STATS
  // GET /api/admin/stats
  // ─────────────────────────────────────────
  static Future<Map<String, dynamic>> getStats() async {
    try {
      final headers = await AuthService.authHeaders();
      final response = await http.get(
        Uri.parse('$baseUrl/admin/stats'),
        headers: headers,
      );
      debugPrint('[AdminService.getStats] statusCode: ${response.statusCode}');
      final data = jsonDecode(response.body);
      if (response.statusCode == 200) {
        return {'success': true, 'data': data['data'] ?? data};
      }
      return {
        'success': false,
        'message': data['message'] ?? 'Gagal memuat statistik'
      };
    } catch (e) {
      debugPrint('[AdminService.getStats] ERROR: $e');
      return {'success': false, 'message': 'Tidak dapat terhubung ke server.'};
    }
  }

  // ─────────────────────────────────────────
  // GET PENDING EVENTS
  // GET /api/admin/pending-events
  // ─────────────────────────────────────────
  static Future<Map<String, dynamic>> getPendingEvents() async {
    try {
      final headers = await AuthService.authHeaders();
      final response = await http.get(
        Uri.parse('$baseUrl/admin/pending-events'),
        headers: headers,
      );
      debugPrint(
          '[AdminService.getPendingEvents] statusCode: ${response.statusCode}');
      final data = jsonDecode(response.body);
      if (response.statusCode == 200) {
        List<dynamic> events = [];
        if (data['data'] is List) {
          events = data['data'];
        } else if (data is List) {
          events = data;
        }
        return {'success': true, 'data': events};
      }
      return {
        'success': false,
        'message': data['message'] ?? 'Gagal memuat event pending'
      };
    } catch (e) {
      debugPrint('[AdminService.getPendingEvents] ERROR: $e');
      return {'success': false, 'message': 'Tidak dapat terhubung ke server.'};
    }
  }

  // ─────────────────────────────────────────
  // APPROVE EVENT
  // POST /api/admin/events/{id}/approve
  // ─────────────────────────────────────────
  static Future<Map<String, dynamic>> approveEvent(int eventId) async {
    try {
      final headers = await AuthService.authHeaders();
      final response = await http.post(
        Uri.parse('$baseUrl/admin/events/$eventId/approve'),
        headers: headers,
      );
      debugPrint(
          '[AdminService.approveEvent] statusCode: ${response.statusCode}');
      final data = jsonDecode(response.body);
      if (response.statusCode == 200) {
        return {'success': true, 'data': data['data'] ?? data};
      }
      return {
        'success': false,
        'message': data['message'] ?? 'Gagal menyetujui event'
      };
    } catch (e) {
      debugPrint('[AdminService.approveEvent] ERROR: $e');
      return {'success': false, 'message': 'Tidak dapat terhubung ke server.'};
    }
  }

  // ─────────────────────────────────────────
  // REJECT EVENT
  // POST /api/admin/events/{id}/reject
  // ─────────────────────────────────────────
  static Future<Map<String, dynamic>> rejectEvent(
      int eventId, String? alasan) async {
    try {
      final headers = await AuthService.authHeaders();
      final response = await http.post(
        Uri.parse('$baseUrl/admin/events/$eventId/reject'),
        headers: headers,
        body: jsonEncode({'alasan': alasan ?? ''}),
      );
      debugPrint(
          '[AdminService.rejectEvent] statusCode: ${response.statusCode}');
      final data = jsonDecode(response.body);
      if (response.statusCode == 200) {
        return {'success': true, 'data': data['data'] ?? data};
      }
      return {
        'success': false,
        'message': data['message'] ?? 'Gagal menolak event'
      };
    } catch (e) {
      debugPrint('[AdminService.rejectEvent] ERROR: $e');
      return {'success': false, 'message': 'Tidak dapat terhubung ke server.'};
    }
  }

  // ─────────────────────────────────────────
  // GET ANALYTICS
  // GET /api/admin/analytics
  // ─────────────────────────────────────────
  static Future<Map<String, dynamic>> getAnalytics() async {
    try {
      final headers = await AuthService.authHeaders();
      final response = await http.get(
        Uri.parse('$baseUrl/admin/analytics'),
        headers: headers,
      );
      debugPrint(
          '[AdminService.getAnalytics] statusCode: ${response.statusCode}');
      final data = jsonDecode(response.body);
      if (response.statusCode == 200) {
        return {'success': true, 'data': data['data'] ?? data};
      }
      return {
        'success': false,
        'message': data['message'] ?? 'Gagal memuat analitik'
      };
    } catch (e) {
      debugPrint('[AdminService.getAnalytics] ERROR: $e');
      return {'success': false, 'message': 'Tidak dapat terhubung ke server.'};
    }
  }
}
