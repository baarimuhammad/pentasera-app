import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:pentasera_app/services/auth_service.dart';

class EventService {
  static String get baseUrl {
    if (kIsWeb) return 'http://localhost:8000/api';
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return 'http://10.0.2.2:8000/api';
      default:
        return 'http://localhost:8000/api';
    }
  }

  // GET ALL EVENTS (public)
  static Future<Map<String, dynamic>> getEvents() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/events'),
        headers: {'Accept': 'application/json'},
      );
      final data = jsonDecode(response.body);
      if (response.statusCode == 200) {
        List<dynamic> events = [];
        if (data is List)
          events = data;
        else if (data['data'] is List)
          events = data['data'];
        else if (data['events'] is List) events = data['events'];
        return {'success': true, 'data': events};
      }
      return {
        'success': false,
        'message': data['message'] ?? 'Gagal memuat event'
      };
    } catch (e) {
      return {'success': false, 'message': 'Tidak dapat terhubung ke server.'};
    }
  }

  // GET ORGANIZERS (protected)
  static Future<Map<String, dynamic>> getOrganizers() async {
    try {
      final headers = await AuthService.authHeaders();
      final response = await http.get(
        Uri.parse('$baseUrl/organizers'),
        headers: headers,
      );
      final data = jsonDecode(response.body);
      if (response.statusCode == 200) {
        final rawList = data is List
            ? data
            : data is Map<String, dynamic>
                ? (data['data'] as List?) ?? <dynamic>[]
                : <dynamic>[];
        final organizers = rawList
            .whereType<Map>()
            .map((item) => Map<String, dynamic>.from(item))
            .toList();
        return {'success': true, 'data': organizers};
      }
      return {
        'success': false,
        'message': data is Map<String, dynamic>
            ? data['message'] ?? 'Gagal memuat organizer'
            : 'Gagal memuat organizer'
      };
    } catch (e) {
      return {'success': false, 'message': 'Tidak dapat terhubung ke server.'};
    }
  }

  // GET EVENT BY ID (public)
  static Future<Map<String, dynamic>> getEventById(int id) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/events/$id'),
        headers: {'Accept': 'application/json'},
      );
      final data = jsonDecode(response.body);
      if (response.statusCode == 200) {
        return {'success': true, 'data': data['data'] ?? data};
      }
      return {
        'success': false,
        'message': data['message'] ?? 'Event tidak ditemukan'
      };
    } catch (e) {
      return {'success': false, 'message': 'Tidak dapat terhubung ke server.'};
    }
  }

  // GET TICKETS BY EVENT (public)
  static Future<Map<String, dynamic>> getTicketsByEvent(int eventId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/tickets?event_id=$eventId'),
        headers: {'Accept': 'application/json'},
      );
      final data = jsonDecode(response.body);
      if (response.statusCode == 200) {
        List<dynamic> tickets = [];
        if (data is List)
          tickets = data;
        else if (data['data'] is List) tickets = data['data'];
        return {'success': true, 'data': tickets};
      }
      return {
        'success': false,
        'message': data['message'] ?? 'Gagal memuat tiket'
      };
    } catch (e) {
      return {'success': false, 'message': 'Tidak dapat terhubung ke server.'};
    }
  }

  // GET ALL TICKETS (public)
  static Future<Map<String, dynamic>> getTickets() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/tickets'),
        headers: {'Accept': 'application/json'},
      );
      final data = jsonDecode(response.body);
      if (response.statusCode == 200) {
        List<dynamic> tickets = [];
        if (data is List)
          tickets = data;
        else if (data['data'] is List) tickets = data['data'];
        return {'success': true, 'data': tickets};
      }
      return {
        'success': false,
        'message': data['message'] ?? 'Gagal memuat tiket'
      };
    } catch (e) {
      return {'success': false, 'message': 'Tidak dapat terhubung ke server.'};
    }
  }

  // CREATE EVENT (protected — creator only)
  static Future<Map<String, dynamic>> createEvent({
    required int organizerId,
    required String namaEvent,
    required String lokasi,
    required String eventDatetime,
    String? deskripsi,
  }) async {
    try {
      final headers = await AuthService.authHeaders();
      final response = await http.post(
        Uri.parse('$baseUrl/events'),
        headers: headers,
        body: jsonEncode({
          'organizer_id': organizerId,
          'nama_event': namaEvent,
          'lokasi': lokasi,
          'event_datetime': eventDatetime,
          if (deskripsi != null && deskripsi.isNotEmpty) 'deskripsi': deskripsi,
        }),
      );
      final data = jsonDecode(response.body);
      if (response.statusCode == 201 || response.statusCode == 200) {
        return {'success': true, 'data': data['data'] ?? data};
      } else if (response.statusCode == 422) {
        String errorMsg = 'Validasi gagal';
        if (data['errors'] != null) {
          final errors = data['errors'] as Map<String, dynamic>;
          final first = errors.values.first;
          if (first is List && first.isNotEmpty) errorMsg = first[0];
        } else if (data['message'] != null) {
          errorMsg = data['message'];
        }
        return {'success': false, 'message': errorMsg};
      }
      return {
        'success': false,
        'message': data['message'] ?? 'Gagal membuat event'
      };
    } catch (e) {
      return {'success': false, 'message': 'Tidak dapat terhubung ke server.'};
    }
  }

  // CREATE TICKET (protected — creator only)
  static Future<Map<String, dynamic>> createTicket({
    required int eventId,
    required String kategori,
    required int harga,
    required int kuota,
  }) async {
    try {
      final headers = await AuthService.authHeaders();
      final response = await http.post(
        Uri.parse('$baseUrl/tickets'),
        headers: headers,
        body: jsonEncode({
          'event_id': eventId,
          'kategori': kategori,
          'harga': harga,
          'kuota': kuota,
          'sisa_kuota': kuota,
        }),
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
