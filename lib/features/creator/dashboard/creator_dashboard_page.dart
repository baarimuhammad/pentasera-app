import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:pentasera_app/main.dart';
import 'package:pentasera_app/services/auth_service.dart';
import 'package:pentasera_app/services/event_service.dart';

class CreatorDashboardPage extends StatefulWidget {
  const CreatorDashboardPage({super.key});

  @override
  State<CreatorDashboardPage> createState() => _CreatorDashboardPageState();
}

class _CreatorDashboardPageState extends State<CreatorDashboardPage> {
  bool _isLoading = true;
  String _userName = '';
  int _totalEvents = 0;
  int _totalTransaksi = 0;
  int _totalTiketTerjual = 0;
  int _totalPenjualan = 0;
  int _totalPengunjung = 0;

  @override
  void initState() {
    super.initState();
    _loadDashboard();
  }

  /// Safely parse a number from the API (handles int, double, String)
  int _parseNum(dynamic value) {
    if (value == null) return 0;
    if (value is int) return value;
    if (value is double) return value.toInt();
    final str = value.toString().replaceAll(RegExp(r'[^0-9.]'), '');
    return int.tryParse(str) ?? double.tryParse(str)?.toInt() ?? 0;
  }

  Future<void> _loadDashboard() async {
    setState(() {
      _isLoading = true;
      _totalEvents = 0;
      _totalTransaksi = 0;
      _totalTiketTerjual = 0;
      _totalPenjualan = 0;
      _totalPengunjung = 0;
    });

    // Verify role
    final role = await AuthService.getUserRole();
    if (role != 'creator') {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Anda tidak memiliki akses ke halaman ini'),
            backgroundColor: Colors.red,
          ),
        );
        setState(() => _isLoading = false);
      }
      return;
    }

    _userName = await AuthService.getUserNama() ?? 'Creator';

    // Load stats from the dedicated dashboard endpoint
    // This endpoint correctly filters by the logged-in creator's organizer_id
    try {
      final headers = await AuthService.authHeaders();

      // 1. Fetch dashboard stats (filtered by organizer)
      final statsResponse = await http.get(
        Uri.parse('${AuthService.baseUrl}/dashboard/stats'),
        headers: headers,
      );
      debugPrint('[Dashboard] GET /dashboard/stats statusCode=${statsResponse.statusCode}');

      if (statsResponse.statusCode == 200) {
        final statsBody = jsonDecode(statsResponse.body);
        final statsData = statsBody['data'] ?? statsBody;
        debugPrint('[Dashboard] statsData: $statsData');

        _totalEvents = _parseNum(statsData['total_events_active'] ?? statsData['total_events']);
        _totalTiketTerjual = _parseNum(statsData['total_tickets_sold']);
        _totalPenjualan = _parseNum(statsData['total_revenue']);
        _totalTransaksi = _parseNum(statsData['total_transactions']);
        _totalPengunjung = _totalTiketTerjual;

        debugPrint('[Dashboard] totalEvents (from stats): $_totalEvents');
        debugPrint('[Dashboard] totalTiketTerjual (from stats): $_totalTiketTerjual');
        debugPrint('[Dashboard] totalPenjualan (from stats): $_totalPenjualan');
      } else {
        debugPrint('[Dashboard] /dashboard/stats failed, falling back to /my-events');
        // Fallback: count from my-events if /dashboard/stats fails
        final eventsResult = await EventService.getMyEvents();
        if (eventsResult['success'] == true) {
          final events = (eventsResult['data'] as List?)
                  ?.whereType<Map>()
                  .map((item) => Map<String, dynamic>.from(item))
                  .toList() ??
              [];
          _totalEvents = events.where((e) {
            final status = (e['event_status'] ?? e['status'] ?? '').toString().toLowerCase();
            return status == 'published';
          }).length;

          // Sum up tiket_terjual and total_pendapatan from my-events response
          for (var event in events) {
            _totalTiketTerjual += _parseNum(event['tiket_terjual']);
            _totalPenjualan += _parseNum(event['total_pendapatan']);
          }
          _totalPengunjung = _totalTiketTerjual;
        }
      }

      debugPrint('[Dashboard] Final stats - events: $_totalEvents, transaksi: $_totalTransaksi, tiket: $_totalTiketTerjual, penjualan: $_totalPenjualan');
    } catch (e) {
      debugPrint('[Dashboard] ERROR: $e');
    }

    if (mounted) setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? AppColors.textDark : AppColors.textLight;
    final mutedColor = isDark ? AppColors.mutedDark : AppColors.mutedLight;
    final surfaceColor =
        isDark ? AppColors.surfaceDark : AppColors.surfaceLight;
    final borderColor = isDark ? AppColors.borderDark : AppColors.borderLight;
    final formatter =
        NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);

    return Scaffold(
      backgroundColor:
          isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text('Dashboard Creator',
            style: TextStyle(
                color: textColor, fontWeight: FontWeight.bold, fontSize: 18)),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(Icons.refresh, color: mutedColor),
            onPressed: _loadDashboard,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: AppColors.primary))
          : RefreshIndicator(
              color: AppColors.primary,
              onRefresh: _loadDashboard,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Welcome Card
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFFf27f0d), Color(0xFFe06b00)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Selamat Datang,',
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.8),
                              fontSize: 14,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            _userName,
                            style: GoogleFonts.playfairDisplay(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Kelola event dan pantau performa di sini.',
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.7),
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Stats Title
                    Text(
                      'Statistik Overview',
                      style: TextStyle(
                        color: textColor,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Stats Grid
                    GridView.count(
                      crossAxisCount: 2,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      mainAxisSpacing: 12,
                      crossAxisSpacing: 12,
                      childAspectRatio: 1.5,
                      children: [
                        _statCard(
                          Icons.event,
                          'Event Aktif',
                          '$_totalEvents',
                          surfaceColor,
                          borderColor,
                          textColor,
                          mutedColor,
                          Colors.blue,
                        ),
                        _statCard(
                          Icons.receipt_long,
                          'Total Transaksi',
                          '$_totalTransaksi',
                          surfaceColor,
                          borderColor,
                          textColor,
                          mutedColor,
                          Colors.green,
                        ),
                        _statCard(
                          Icons.confirmation_number,
                          'Tiket Terjual',
                          '$_totalTiketTerjual',
                          surfaceColor,
                          borderColor,
                          textColor,
                          mutedColor,
                          AppColors.primary,
                        ),
                        _statCard(
                          Icons.people,
                          'Pengunjung',
                          '$_totalPengunjung',
                          surfaceColor,
                          borderColor,
                          textColor,
                          mutedColor,
                          Colors.purple,
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Revenue card (full width)
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: surfaceColor,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: borderColor),
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.green.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(Icons.account_balance_wallet,
                                color: Colors.green, size: 28),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Total Penjualan',
                                    style: TextStyle(
                                        color: mutedColor, fontSize: 12)),
                                const SizedBox(height: 4),
                                Text(
                                  formatter.format(_totalPenjualan),
                                  style: TextStyle(
                                    color: textColor,
                                    fontSize: 22,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _statCard(
      IconData icon,
      String label,
      String value,
      Color surfaceColor,
      Color borderColor,
      Color textColor,
      Color mutedColor,
      Color accentColor) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: surfaceColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: accentColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: accentColor, size: 20),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(value,
                  style: TextStyle(
                      color: textColor,
                      fontSize: 20,
                      fontWeight: FontWeight.bold)),
              Text(label, style: TextStyle(color: mutedColor, fontSize: 11)),
            ],
          ),
        ],
      ),
    );
  }
}
