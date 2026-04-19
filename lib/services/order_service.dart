import 'dart:convert';
import 'package:http/http.dart' as http;
import 'auth_service.dart';

class OrderService {
  static String get baseUrl => AuthService.baseUrl;

  // ─────────────────────────────────────────
  // CREATE ORDER
  // ─────────────────────────────────────────
  static Future<Map<String, dynamic>> createOrder(
      Map<String, dynamic> orderData) async {
    try {
      final headers = await AuthService.authHeaders();
      final response = await http.post(
        Uri.parse('$baseUrl/orders'),
        headers: headers,
        body: jsonEncode(orderData),
      );
      final data = jsonDecode(response.body);
      if (response.statusCode == 201 || response.statusCode == 200) {
        return {'success': true, 'data': data['data'] ?? data};
      }
      return {
        'success': false,
        'message': data['message'] ?? 'Gagal membuat pesanan'
      };
    } catch (e) {
      return {'success': false, 'message': 'Tidak dapat terhubung ke server.'};
    }
  }

  // ─────────────────────────────────────────
  // GET ORDERS
  // ─────────────────────────────────────────
  static Future<Map<String, dynamic>> getOrders() async {
    try {
      final headers = await AuthService.authHeaders();
      final response = await http.get(
        Uri.parse('$baseUrl/orders'),
        headers: headers,
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return {'success': true, 'data': data['data'] ?? data};
      }
      return {'success': false, 'message': 'Gagal memuat pesanan'};
    } catch (e) {
      return {'success': false, 'message': 'Tidak dapat terhubung ke server.'};
    }
  }

  // ─────────────────────────────────────────
  // GET ORDER BY ID
  // ─────────────────────────────────────────
  static Future<Map<String, dynamic>> getOrderById(dynamic id) async {
    try {
      final headers = await AuthService.authHeaders();
      final response = await http.get(
        Uri.parse('$baseUrl/orders/$id'),
        headers: headers,
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return {'success': true, 'data': data['data'] ?? data};
      }
      return {'success': false, 'message': 'Pesanan tidak ditemukan'};
    } catch (e) {
      return {'success': false, 'message': 'Tidak dapat terhubung ke server.'};
    }
  }

  // ─────────────────────────────────────────
  // CREATE PAYMENT
  // ─────────────────────────────────────────
  static Future<Map<String, dynamic>> createPayment(
      Map<String, dynamic> paymentData) async {
    try {
      final headers = await AuthService.authHeaders();
      final response = await http.post(
        Uri.parse('$baseUrl/payments'),
        headers: headers,
        body: jsonEncode(paymentData),
      );
      final data = jsonDecode(response.body);
      if (response.statusCode == 201 || response.statusCode == 200) {
        return {'success': true, 'data': data['data'] ?? data};
      }
      return {
        'success': false,
        'message': data['message'] ?? 'Pembayaran gagal'
      };
    } catch (e) {
      return {'success': false, 'message': 'Tidak dapat terhubung ke server.'};
    }
  }

  // ─────────────────────────────────────────
  // GET PAYMENTS
  // ─────────────────────────────────────────
  static Future<Map<String, dynamic>> getPayments() async {
    try {
      final headers = await AuthService.authHeaders();
      final response = await http.get(
        Uri.parse('$baseUrl/payments'),
        headers: headers,
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return {'success': true, 'data': data['data'] ?? data};
      }
      return {'success': false, 'message': 'Gagal memuat pembayaran'};
    } catch (e) {
      return {'success': false, 'message': 'Tidak dapat terhubung ke server.'};
    }
  }

  // ─────────────────────────────────────────
  // CREATE E-TICKET
  // ─────────────────────────────────────────
  static Future<Map<String, dynamic>> createETicket(
      Map<String, dynamic> ticketData) async {
    try {
      final headers = await AuthService.authHeaders();
      final response = await http.post(
        Uri.parse('$baseUrl/e-tickets'),
        headers: headers,
        body: jsonEncode(ticketData),
      );
      final data = jsonDecode(response.body);
      if (response.statusCode == 201 || response.statusCode == 200) {
        return {'success': true, 'data': data['data'] ?? data};
      }
      return {
        'success': false,
        'message': data['message'] ?? 'Gagal membuat e-tiket'
      };
    } catch (e) {
      return {'success': false, 'message': 'Tidak dapat terhubung ke server.'};
    }
  }

  // ─────────────────────────────────────────
  // GET E-TICKETS (tiket saya)
  // ─────────────────────────────────────────
  static Future<Map<String, dynamic>> getETickets() async {
    try {
      final headers = await AuthService.authHeaders();
      final response = await http.get(
        Uri.parse('$baseUrl/e-tickets'),
        headers: headers,
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
}
