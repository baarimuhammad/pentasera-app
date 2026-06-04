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
      debugPrint('[getEvents] statusCode: ${response.statusCode}');
      final data = jsonDecode(response.body);
      if (response.statusCode == 200) {
        List<dynamic> events = [];
        if (data is List) {
          events = data;
        } else if (data is Map) {
          final inner = data['data'];
          if (inner is List) {
            // Non-paginated: { data: [...] }
            events = inner;
          } else if (inner is Map && inner['data'] is List) {
            // Laravel paginated: { data: { current_page, data: [...], total } }
            events = inner['data'] as List;
          } else if (data['events'] is List) {
            events = data['events'] as List;
          }
        }
        debugPrint('[getEvents] parsed events count: ${events.length}');
        return {'success': true, 'data': events};
      }
      return {
        'success': false,
        'message': data is Map ? (data['message'] ?? 'Gagal memuat event') : 'Gagal memuat event'
      };
    } catch (e) {
      debugPrint('[getEvents] ERROR: $e');
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
      debugPrint('[getEventById] statusCode: ${response.statusCode}');
      debugPrint('[getEventById] body: ${response.body}');
      final data = jsonDecode(response.body);
      if (response.statusCode == 200) {
        final eventData = data['data'] ?? data;
        // Log ticket data specifically
        if (eventData is Map) {
          final tickets = eventData['tickets'];
          debugPrint('[getEventById] has tickets? ${tickets != null} | tickets type: ${tickets.runtimeType}');
          if (tickets is List) {
            for (var t in tickets) {
              debugPrint('[getEventById] ticket: ${t}');
            }
          }
        }
        return {'success': true, 'data': eventData};
      }
      return {
        'success': false,
        'message': data['message'] ?? 'Event tidak ditemukan'
      };
    } catch (e) {
      debugPrint('[getEventById] ERROR: $e');
      return {'success': false, 'message': 'Tidak dapat terhubung ke server.'};
    }
  }

  // GET TICKETS BY EVENT (public)
  static Future<Map<String, dynamic>> getTicketsByEvent(int eventId) async {
    try {
      // Primary: query param approach
      final response = await http.get(
        Uri.parse('$baseUrl/tickets?event_id=$eventId'),
        headers: {'Accept': 'application/json'},
      );
      debugPrint('[getTicketsByEvent] URL: $baseUrl/tickets?event_id=$eventId');
      debugPrint('[getTicketsByEvent] statusCode: ${response.statusCode}');
      debugPrint('[getTicketsByEvent] body: ${response.body}');
      final data = jsonDecode(response.body);
      if (response.statusCode == 200) {
        List<dynamic> tickets = [];
        if (data is List)
          tickets = data;
        else if (data['data'] is List) tickets = data['data'];
        // Filter by event_id in case backend ignores query param
        if (tickets.isNotEmpty) {
          tickets = tickets.where((t) {
            if (t is Map) {
              final tEventId = t['event_id'];
              return tEventId != null &&
                  tEventId.toString() == eventId.toString();
            }
            return true;
          }).toList();
        }
        debugPrint('[getTicketsByEvent] parsed tickets: ${tickets.length}');
        for (var t in tickets) {
          debugPrint('[getTicketsByEvent] ticket: id=${t['id']} harga=${t['harga']} kategori=${t['kategori']}');
        }
        if (tickets.isNotEmpty) {
          return {'success': true, 'data': tickets};
        }
      }

      // Fallback: nested route approach
      debugPrint('[getTicketsByEvent] Trying fallback: $baseUrl/events/$eventId/tickets');
      final fallbackResponse = await http.get(
        Uri.parse('$baseUrl/events/$eventId/tickets'),
        headers: {'Accept': 'application/json'},
      );
      debugPrint('[getTicketsByEvent] fallback statusCode: ${fallbackResponse.statusCode}');
      if (fallbackResponse.statusCode == 200) {
        final fallbackData = jsonDecode(fallbackResponse.body);
        List<dynamic> tickets = [];
        if (fallbackData is List)
          tickets = fallbackData;
        else if (fallbackData is Map && fallbackData['data'] is List)
          tickets = fallbackData['data'];
        debugPrint('[getTicketsByEvent] fallback tickets: ${tickets.length}');
        return {'success': true, 'data': tickets};
      }

      return {
        'success': true,
        'data': <dynamic>[],
      };
    } catch (e) {
      debugPrint('[getTicketsByEvent] ERROR: $e');
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

  // GET MY EVENTS (protected — creator's own events)
  static Future<Map<String, dynamic>> getMyEvents() async {
    try {
      final headers = await AuthService.authHeaders();
      final response = await http.get(
        Uri.parse('$baseUrl/my-events'),
        headers: headers,
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
        'message': data is Map ? (data['message'] ?? 'Gagal memuat event saya') : 'Gagal memuat event saya'
      };
    } catch (e) {
      return {'success': false, 'message': 'Tidak dapat terhubung ke server.'};
    }
  }

  // GET OR CREATE ORGANIZER ID for the current logged-in user
  // Fetches the organizer list, finds the one owned by this user.
  // If none exists, auto-creates a default organizer.
  static Future<int?> getOrCreateOrganizerId() async {
    try {
      final userId = await AuthService.getUserId();
      final userName = await AuthService.getUserNama() ?? 'Organizer';
      final headers = await AuthService.authHeaders();

      // Try to fetch existing organizers owned by this user
      final listRes = await http.get(
        Uri.parse('$baseUrl/organizers'),
        headers: headers,
      );
      if (listRes.statusCode == 200) {
        final listData = jsonDecode(listRes.body);
        final rawList = listData is List
            ? listData
            : listData is Map
                ? (listData['data'] as List?) ?? <dynamic>[]
                : <dynamic>[];
        // Find organizer belonging to current user
        for (final item in rawList) {
          if (item is Map) {
            final ownerId = item['user_id'] ?? item['owner_id'];
            if (ownerId != null && ownerId.toString() == userId.toString()) {
              final id = item['id'];
              if (id != null) return int.tryParse(id.toString());
            }
          }
        }
        // No existing organizer → auto-create one
        final createRes = await http.post(
          Uri.parse('$baseUrl/organizers'),
          headers: headers,
          body: jsonEncode({
            'nama_organizer': userName,
            'deskripsi': '',
          }),
        );
        if (createRes.statusCode == 200 || createRes.statusCode == 201) {
          final created = jsonDecode(createRes.body);
          final createdData = created['data'] ?? created;
          final newId = createdData['id'];
          if (newId != null) return int.tryParse(newId.toString());
        }
      }
      return null;
    } catch (_) {
      return null;
    }
  }

  // CREATE EVENT (protected — creator only)
  static Future<Map<String, dynamic>> createEvent({
    required String namaEvent,
    required String lokasi,
    required String eventDatetime,
    String? deskripsi,
    String status = 'draft',
    int? organizerId,
  }) async {
    try {
      // Resolve organizer_id — required by backend
      final resolvedOrganizerId = organizerId ?? await getOrCreateOrganizerId();
      if (resolvedOrganizerId == null) {
        return {
          'success': false,
          'message':
              'Gagal mendapatkan data organizer. Pastikan akun Anda sudah terdaftar sebagai kreator.'
        };
      }

      final headers = await AuthService.authHeaders();
      final response = await http.post(
        Uri.parse('$baseUrl/events'),
        headers: headers,
        body: jsonEncode({
          'nama_event': namaEvent,
          'lokasi': lokasi,
          'event_datetime': eventDatetime,
          'event_status': status,
          'organizer_id': resolvedOrganizerId,
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

  // UPDATE EVENT (protected — creator only)
  static Future<Map<String, dynamic>> updateEvent({
    required int eventId,
    required String namaEvent,
    required String lokasi,
    required String eventDatetime,
    String? deskripsi,
  }) async {
    try {
      final headers = await AuthService.authHeaders();
      final response = await http.patch(
        Uri.parse('$baseUrl/events/$eventId'),
        headers: headers,
        body: jsonEncode({
          'nama_event': namaEvent,
          'lokasi': lokasi,
          'event_datetime': eventDatetime,
          if (deskripsi != null && deskripsi.isNotEmpty) 'deskripsi': deskripsi,
        }),
      );
      final data = jsonDecode(response.body);
      if (response.statusCode == 200) {
        return {'success': true, 'data': data['data'] ?? data};
      }
      return {
        'success': false,
        'message': data['message'] ?? 'Gagal update event'
      };
    } catch (e) {
      return {'success': false, 'message': 'Tidak dapat terhubung ke server.'};
    }
  }

  // DELETE EVENT (protected — creator only)
  static Future<Map<String, dynamic>> deleteEvent(int eventId) async {
    try {
      final headers = await AuthService.authHeaders();
      final response = await http.delete(
        Uri.parse('$baseUrl/events/$eventId'),
        headers: headers,
      );
      final data = jsonDecode(response.body);
      if (response.statusCode == 200) {
        return {'success': true, 'data': data};
      }
      return {
        'success': false,
        'message': data['message'] ?? 'Gagal hapus event'
      };
    } catch (e) {
      return {'success': false, 'message': 'Tidak dapat terhubung ke server.'};
    }
  }
}
