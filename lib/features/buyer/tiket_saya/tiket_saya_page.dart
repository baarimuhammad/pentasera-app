import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:shimmer/shimmer.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:pentasera_app/main.dart';
import 'package:pentasera_app/services/order_service.dart';
import 'package:pentasera_app/services/auth_service.dart';
import 'package:pentasera_app/features/buyer/tiket_saya/detail_tiket_page.dart';
import 'package:pentasera_app/features/authentication/login/login_page.dart';

class TiketSayaPage extends StatefulWidget {
  const TiketSayaPage({super.key});

  @override
  State<TiketSayaPage> createState() => _TiketSayaPageState();
}

class _TiketSayaPageState extends State<TiketSayaPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  List<Map<String, dynamic>> _tickets = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _checkAuthAndLoad();
  }

  Future<void> _checkAuthAndLoad() async {
    final token = await AuthService.getToken();
    if (token == null || token.isEmpty) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _error = 'login_required'; // flag khusus, bukan redirect langsung
        });
      }
      return;
    }
    _loadTickets();
  }

  Future<void> _loadTickets() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    final result = await OrderService.getMyTickets();
    if (result['success'] == true) {
      final rawTickets = (result['data'] as List?)
              ?.whereType<Map>()
              .map((item) => Map<String, dynamic>.from(item))
              .toList() ??
          [];

      // Enrich tickets with locally saved event info
      final localTicketMap = await _getLocalTicketMap();
      for (var ticket in rawTickets) {
        final kodeQr = (ticket['kode_qr'] ?? '').toString();
        if (localTicketMap.containsKey(kodeQr)) {
          final local = localTicketMap[kodeQr]!;
          ticket['_local_event_name'] = local['eventName'];
          ticket['_local_ticket_name'] = local['ticketName'];
          ticket['_local_event_id'] = local['eventId'];
          ticket['_local_holder_name'] = local['holderName'];
        }
      }

      _tickets = rawTickets;
    } else {
      _error = result['message'];
    }

    if (mounted) setState(() => _isLoading = false);
  }

  /// Read locally saved ticket info (saved during checkout)
  Future<Map<String, Map<String, String>>> _getLocalTicketMap() async {
    final prefs = await SharedPreferences.getInstance();
    final list = prefs.getStringList('local_tickets') ?? [];
    final map = <String, Map<String, String>>{};
    for (final entry in list) {
      final parts = entry.split('|');
      if (parts.length >= 5) {
        map[parts[0]] = {
          'eventName': parts[1],
          'ticketName': parts[2],
          'eventId': parts[3],
          'holderName': parts[4],
        };
      }
    }
    return map;
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? AppColors.textDark : AppColors.textLight;
    final mutedColor = isDark ? AppColors.mutedDark : AppColors.mutedLight;

    return Scaffold(
      backgroundColor:
          isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text('Tiket Saya',
            style: TextStyle(
                color: textColor, fontWeight: FontWeight.bold, fontSize: 18)),
        centerTitle: true,
        iconTheme: IconThemeData(color: textColor),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh, color: mutedColor),
            onPressed: _loadTickets,
          ),
        ],
      ),
      body: Column(
        children: [
          // Tab bar
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            child: Container(
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.05),
                borderRadius: BorderRadius.circular(12),
              ),
              child: TabBar(
                controller: _tabController,
                labelColor: Colors.white,
                unselectedLabelColor: AppColors.primary,
                indicator: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(12),
                ),
                indicatorSize: TabBarIndicatorSize.tab,
                labelStyle:
                    const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                dividerColor: Colors.transparent,
                tabs: const [
                  Tab(text: 'Aktif'),
                  Tab(text: 'Riwayat'),
                ],
              ),
            ),
          ),

          // Content
          Expanded(
            child: _isLoading
                ? _buildShimmer(isDark)
                : _error != null
                    ? _buildErrorState(mutedColor)
                    : TabBarView(
                        controller: _tabController,
                        children: [
                          _buildTicketList(
                              _tickets
                                  .where((t) =>
                                      (t['status_validasi'] ?? 'valid')
                                          .toString()
                                          .toLowerCase() ==
                                      'valid')
                                  .toList(),
                              isDark,
                              textColor,
                              mutedColor,
                              isActive: true),
                          _buildTicketList(
                              _tickets
                                  .where((t) =>
                                      (t['status_validasi'] ?? 'valid')
                                          .toString()
                                          .toLowerCase() !=
                                      'valid')
                                  .toList(),
                              isDark,
                              textColor,
                              mutedColor,
                              isActive: false),
                        ],
                      ),
          ),
        ],
      ),
    );
  }

  Widget _buildTicketList(List<Map<String, dynamic>> tickets, bool isDark,
      Color textColor, Color mutedColor,
      {required bool isActive}) {
    if (tickets.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.confirmation_number_outlined,
                size: 48, color: mutedColor),
            const SizedBox(height: 12),
            Text(
              isActive ? 'Belum ada tiket aktif' : 'Belum ada riwayat tiket',
              style: TextStyle(color: mutedColor, fontSize: 14),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      color: AppColors.primary,
      onRefresh: _loadTickets,
      child: ListView.builder(
        padding: const EdgeInsets.all(20),
        itemCount: tickets.length,
        itemBuilder: (context, index) => _buildTicketCard(
            tickets[index], isDark, textColor, mutedColor, isActive),
      ),
    );
  }

  Widget _buildTicketCard(Map<String, dynamic> ticket, bool isDark,
      Color textColor, Color mutedColor, bool isActive) {
    final surfaceColor =
        isDark ? AppColors.surfaceDark : AppColors.surfaceLight;
    final borderColor = isDark ? AppColors.borderDark : AppColors.borderLight;

    // Try nested data first, then local enriched data, then fallback
    final event = ticket['event'] is Map ? ticket['event'] as Map : null;
    final detailOrder =
        ticket['detail_order'] is Map ? ticket['detail_order'] as Map : null;
    final ticketInfo = ticket['ticket'] is Map
        ? ticket['ticket'] as Map
        : (detailOrder?['ticket'] is Map
            ? detailOrder!['ticket'] as Map
            : null);

    final eventName = (event?['nama_event'] ??
            ticket['_local_event_name'] ??
            ticket['nama_event'] ??
            'E-Ticket #${ticket['id'] ?? ''}')
        .toString();
    final ticketType =
        (ticketInfo?['kategori'] ?? ticket['_local_ticket_name'] ?? '')
            .toString();
    final kodeQr = (ticket['kode_qr'] ?? '').toString();
    final shortCode = kodeQr.isEmpty
        ? 'N/A'
        : kodeQr.length > 8
            ? kodeQr.substring(0, 8)
            : kodeQr;
    final status = (ticket['status_validasi'] ?? (isActive ? 'valid' : 'used'))
        .toString()
        .toLowerCase();

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => DetailTiketPage(ticket: ticket),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          color: surfaceColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: borderColor),
          boxShadow: isDark
              ? []
              : [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.04),
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image placeholder with status badge
            Container(
              height: 100,
              decoration: BoxDecoration(
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(16)),
                gradient: LinearGradient(
                  colors: [
                    AppColors.primary.withOpacity(0.3),
                    const Color(0xFF221910).withOpacity(0.8),
                  ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
              child: Stack(
                children: [
                  Center(
                    child: Icon(Icons.confirmation_number,
                        size: 40, color: Colors.white.withOpacity(0.3)),
                  ),
                  Positioned(
                    top: 12,
                    right: 12,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: _statusColor(status),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        status.toUpperCase(),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Content
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    eventName,
                    style: GoogleFonts.playfairDisplay(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: textColor,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (ticketType.isNotEmpty) ...[
                    const SizedBox(height: 6),
                    Text(ticketType,
                        style: TextStyle(
                            color: AppColors.primary,
                            fontSize: 13,
                            fontWeight: FontWeight.w600)),
                  ],
                  const SizedBox(height: 12),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.05),
                      borderRadius: BorderRadius.circular(8),
                      border:
                          Border.all(color: AppColors.primary.withOpacity(0.1)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.qr_code,
                            size: 16, color: AppColors.primary),
                        const SizedBox(width: 8),
                        Text(
                          'KODE TIKET',
                          style: TextStyle(
                            color: mutedColor,
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 0.5,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          shortCode,
                          style: const TextStyle(
                            color: AppColors.primary,
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _statusColor(String status) {
    switch (status.toLowerCase()) {
      case 'valid':
        return Colors.green;
      case 'used':
        return Colors.grey;
      case 'expired':
        return Colors.red;
      default:
        return AppColors.primary;
    }
  }

  Widget _buildShimmer(bool isDark) {
    return Shimmer.fromColors(
      baseColor: isDark ? Colors.grey[800]! : Colors.grey[300]!,
      highlightColor: isDark ? Colors.grey[700]! : Colors.grey[100]!,
      child: ListView.builder(
        padding: const EdgeInsets.all(20),
        itemCount: 3,
        itemBuilder: (_, __) => Container(
          height: 200,
          margin: const EdgeInsets.only(bottom: 16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
          ),
        ),
      ),
    );
  }

  Widget _buildErrorState(Color mutedColor) {
    if (_error == 'login_required') {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.lock_outline, size: 48, color: mutedColor),
            const SizedBox(height: 12),
            Text('Silakan login untuk melihat tiket',
                style: TextStyle(color: mutedColor)),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (_) => const LoginPage()),
                  (_) => false,
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
              ),
              child: const Text('Login'),
            ),
          ],
        ),
      );
    }
    // Error biasa
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.error_outline, size: 48, color: Colors.red),
          const SizedBox(height: 12),
          Text(_error ?? 'Terjadi kesalahan',
              style: TextStyle(color: mutedColor)),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: _loadTickets,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
            ),
            child: const Text('Coba Lagi'),
          ),
        ],
      ),
    );
  }
}
