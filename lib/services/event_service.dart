import 'dart:convert';
import 'package:http/http.dart' as http;
import 'auth_service.dart';

class EventService {
  static String get baseUrl => AuthService.baseUrl;

  // ─────────────────────────────────────────
  // GET ALL EVENTS
  // ─────────────────────────────────────────
  static Future<Map<String, dynamic>> getEvents() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/events'),
        headers: {'Accept': 'application/json'},
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return {'success': true, 'data': data['data'] ?? data};
      }
      return {'success': false, 'message': 'Gagal memuat event'};
    } catch (e) {
      return {'success': false, 'message': 'Tidak dapat terhubung ke server.'};
    }
  }

  // ─────────────────────────────────────────
  // GET EVENT BY ID
  // ─────────────────────────────────────────
  static Future<Map<String, dynamic>> getEventById(dynamic id) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/events/$id'),
        headers: {'Accept': 'application/json'},
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return {'success': true, 'data': data['data'] ?? data};
      }
      return {'success': false, 'message': 'Event tidak ditemukan'};
    } catch (e) {
      return {'success': false, 'message': 'Tidak dapat terhubung ke server.'};
    }
  }

  // ─────────────────────────────────────────
  // GET TICKETS FOR EVENT
  // ─────────────────────────────────────────
  static Future<Map<String, dynamic>> getTicketsByEvent(dynamic eventId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/tickets?event_id=$eventId'),
        headers: {'Accept': 'application/json'},
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return {'success': true, 'data': data['data'] ?? data};
      }
      return {'success': false, 'message': 'Gagal memuat tiket'};
    } catch (e) {
      return {'success': false, 'message': 'Tidak dapat terhubung ke server.'};
    }
  }

  // ─────────────────────────────────────────
  // GET ALL TICKETS
  // ─────────────────────────────────────────
  static Future<Map<String, dynamic>> getTickets() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/tickets'),
        headers: {'Accept': 'application/json'},
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return {'success': true, 'data': data['data'] ?? data};
      }
      return {'success': false, 'message': 'Gagal memuat tiket'};
    } catch (e) {
      return {'success': false, 'message': 'Tidak dapat terhubung ke server.'};
    }
  }

  // ─────────────────────────────────────────
  // GET ORGANIZERS
  // ─────────────────────────────────────────
  static Future<Map<String, dynamic>> getOrganizers() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/organizers'),
        headers: {'Accept': 'application/json'},
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return {'success': true, 'data': data['data'] ?? data};
      }
      return {'success': false, 'message': 'Gagal memuat organizer'};
    } catch (e) {
      return {'success': false, 'message': 'Tidak dapat terhubung ke server.'};
    }
  }

  // ─────────────────────────────────────────
  // CREATE EVENT (protected — creator)
  // ─────────────────────────────────────────
  static Future<Map<String, dynamic>> createEvent(
      Map<String, dynamic> eventData) async {
    try {
      final headers = await AuthService.authHeaders();
      final response = await http.post(
        Uri.parse('$baseUrl/events'),
        headers: headers,
        body: jsonEncode(eventData),
      );
      final data = jsonDecode(response.body);
      if (response.statusCode == 201 || response.statusCode == 200) {
        return {'success': true, 'data': data['data'] ?? data};
      }
      return {
        'success': false,
        'message': data['message'] ?? 'Gagal membuat event'
      };
    } catch (e) {
      return {'success': false, 'message': 'Tidak dapat terhubung ke server.'};
    }
  }

  // ─────────────────────────────────────────
  // CREATE TICKET (protected — creator)
  // ─────────────────────────────────────────
  static Future<Map<String, dynamic>> createTicket(
      Map<String, dynamic> ticketData) async {
    try {
      final headers = await AuthService.authHeaders();
      final response = await http.post(
        Uri.parse('$baseUrl/tickets'),
        headers: headers,
        body: jsonEncode(ticketData),
      );
      final data = jsonDecode(response.body);
      if (response.statusCode == 201 || response.statusCode == 200) {
        return {'success': true, 'data': data['data'] ?? data};
      }
      return {
        'success': false,
        'message': data['message'] ?? 'Gagal membuat tiket'
      };
    } catch (e) {
      return {'success': false, 'message': 'Tidak dapat terhubung ke server.'};
    }
  }
}
