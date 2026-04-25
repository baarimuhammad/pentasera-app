import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:pentasera_app/main.dart';
import 'package:pentasera_app/services/auth_service.dart';
import 'package:pentasera_app/services/order_service.dart';
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

    // Load stats
    try {
      final eventsResult = await EventService.getEvents();
      if (eventsResult['success'] == true) {
        final events = (eventsResult['data'] as List?)
                ?.whereType<Map>()
                .map((item) => Map<String, dynamic>.from(item))
                .toList() ??
            [];
        _totalEvents =
            events.where((e) => e['event_status'] == 'published').length;
      }

      final ordersResult = await OrderService.getOrders();
      if (ordersResult['success'] == true) {
        final orders = (ordersResult['data'] as List?)
                ?.whereType<Map>()
                .map((item) => Map<String, dynamic>.from(item))
                .toList() ??
            [];
        _totalTransaksi = orders.length;
        for (var order in orders) {
          final total = order['total_harga'];
          _totalPenjualan += total is num ? total.toInt() : 0;
        }
        _totalPengunjung = _totalTiketTerjual;
      }
    } catch (_) {}

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
