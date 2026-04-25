import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:shimmer/shimmer.dart';
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
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (_) => const LoginPage()),
          (_) => false,
        );
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

    final result = await OrderService.getETickets();
    if (result['success'] == true) {
      _tickets = (result['data'] as List?)
              ?.whereType<Map>()
              .map((item) => Map<String, dynamic>.from(item))
              .toList() ??
          [];
    } else {
      _error = result['message'];
    }

    if (mounted) setState(() => _isLoading = false);
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
                labelStyle: const TextStyle(
                    fontSize: 13, fontWeight: FontWeight.w600),
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
      Color textColor, Color mutedColor, {required bool isActive}) {
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
        itemBuilder: (context, index) =>
            _buildTicketCard(tickets[index], isDark, textColor, mutedColor, isActive),
      ),
    );
  }

  Widget _buildTicketCard(Map<String, dynamic> ticket, bool isDark,
      Color textColor, Color mutedColor, bool isActive) {
    final surfaceColor =
        isDark ? AppColors.surfaceDark : AppColors.surfaceLight;
    final borderColor =
        isDark ? AppColors.borderDark : AppColors.borderLight;

    final event = ticket['event'] is Map ? ticket['event'] as Map : null;
    final eventName = (event?['nama_event'] ??
            ticket['nama_event'] ??
            ticket['event_name'] ??
            '')
        .toString();
    final tanggal = (event?['event_datetime'] ??
            ticket['event_datetime'] ??
            ticket['tanggal'] ??
            ticket['date'] ??
            '')
        .toString();
    final lokasi =
        (event?['lokasi'] ?? ticket['lokasi'] ?? ticket['location'] ?? '')
            .toString();
    final kodeQr = (ticket['kode_qr'] ?? '').toString();
    final shortCode = kodeQr.isEmpty
        ? 'N/A'
        : kodeQr.length > 8
            ? kodeQr.substring(0, 8)
            : kodeQr;
    final status =
        (ticket['status_validasi'] ?? (isActive ? 'valid' : 'used'))
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
              height: 120,
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
                  // Status badge
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
                        status.toString().toUpperCase(),
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
                        eventName.isNotEmpty ? eventName : 'Event',
                    style: GoogleFonts.playfairDisplay(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: textColor,
                    ),
                  ),
                  const SizedBox(height: 12),
                  _infoRow(Icons.calendar_today_outlined, _formatDate(tanggal),
                      mutedColor),
                  const SizedBox(height: 6),
                  _infoRow(Icons.location_on_outlined, lokasi, mutedColor),

                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.05),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                          color: AppColors.primary.withOpacity(0.1)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.qr_code, size: 16, color: AppColors.primary),
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

  Widget _infoRow(IconData icon, String text, Color mutedColor) {
    return Row(
      children: [
        Icon(icon, size: 16, color: mutedColor),
        const SizedBox(width: 8),
        Expanded(
          child: Text(text,
              style: TextStyle(color: mutedColor, fontSize: 13),
              maxLines: 1,
              overflow: TextOverflow.ellipsis),
        ),
      ],
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

  String _formatDate(String? dateStr) {
    if (dateStr == null || dateStr.isEmpty) return '-';
    try {
      final date = DateTime.parse(dateStr);
      return DateFormat('EEEE, dd MMMM yyyy', 'id_ID').format(date);
    } catch (_) {
      return dateStr;
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
          height: 220,
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
                foregroundColor: Colors.white),
            child: const Text('Coba Lagi'),
          ),
        ],
      ),
    );
  }
}
