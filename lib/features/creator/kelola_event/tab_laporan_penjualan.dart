import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:pentasera_app/main.dart';

class TabLaporanPenjualan extends StatefulWidget {
  final Map<String, dynamic> stats;
  final Map<String, dynamic> reportData;
  final List<Map<String, dynamic>> tickets;

  const TabLaporanPenjualan({
    super.key,
    required this.stats,
    required this.reportData,
    required this.tickets,
  });

  @override
  State<TabLaporanPenjualan> createState() => _TabLaporanPenjualanState();
}

class _TabLaporanPenjualanState extends State<TabLaporanPenjualan>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  final _currencyFormatter =
      NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);

  int _parseNum(dynamic v) {
    if (v == null) return 0;
    if (v is int) return v;
    if (v is double) return v.toInt();
    return int.tryParse(v.toString().replaceAll(RegExp(r'[^0-9]'), '')) ?? 0;
  }

  List<Map<String, dynamic>> get _transactions {
    final raw = widget.reportData['transactions'] ??
        widget.reportData['recent_transactions'] ??
        widget.reportData['data'] ??
        [];
    if (raw is List) {
      return raw
          .whereType<Map>()
          .map((e) => Map<String, dynamic>.from(e))
          .toList();
    }
    return [];
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? AppColors.textDark : AppColors.textLight;
    final mutedColor = isDark ? AppColors.mutedDark : AppColors.mutedLight;
    final surfaceColor =
        isDark ? AppColors.surfaceDark : AppColors.surfaceLight;
    final borderColor = isDark ? AppColors.borderDark : AppColors.borderLight;

    final revenue = _parseNum(widget.stats['revenue']);
    final sold = _parseNum(widget.stats['sold']);
    final txCount = _parseNum(
        widget.stats['total_transactions'] ??
        widget.stats['transactions_count'] ??
        _transactions.length);
    final avgPerTx = txCount > 0 ? (revenue / txCount).round() : 0;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Header ──
          Text(
            'Statistik Penjualan',
            style: TextStyle(
              color: textColor,
              fontSize: 20,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Ringkasan performa finansial event Anda.',
            style: TextStyle(color: mutedColor, fontSize: 13),
          ),
          const SizedBox(height: 24),

          // ── Summary Cards (3-kolom grid) ──
          Row(
            children: [
              Expanded(
                child: _buildSummaryCard(
                  'Total Pendapatan',
                  _currencyFormatter.format(revenue),
                  'IDR',
                  Icons.trending_up,
                  Colors.green,
                  surfaceColor,
                  borderColor,
                  textColor,
                  mutedColor,
                  isDark,
                ),
              ),
              const SizedBox(width: 6),
              Expanded(
                child: _buildSummaryCard(
                  'Tiket Terjual',
                  NumberFormat('#,###', 'id_ID').format(sold),
                  'Tiket',
                  Icons.confirmation_number_outlined,
                  AppColors.primary,
                  surfaceColor,
                  borderColor,
                  textColor,
                  mutedColor,
                  isDark,
                ),
              ),
              const SizedBox(width: 6),
              Expanded(
                child: _buildSummaryCard(
                  'Rata-rata',
                  _currencyFormatter.format(avgPerTx),
                  'Per Transaksi',
                  Icons.bar_chart,
                  Colors.amber[700]!,
                  surfaceColor,
                  borderColor,
                  textColor,
                  mutedColor,
                  isDark,
                ),
              ),
            ],
          ),
          const SizedBox(height: 32),

          // ── Distribusi Tiket ──
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: isDark
                  ? AppColors.surfaceDark.withOpacity(0.7)
                  : const Color(0xFFF6F5F2),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: borderColor),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Distribusi Tiket',
                  style: TextStyle(
                    color: textColor,
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 24),
                if (widget.tickets.isEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    child: Text(
                      'Belum ada tiket.',
                      style: TextStyle(color: mutedColor, fontSize: 13),
                    ),
                  )
                else
                  ...widget.tickets.map((ticket) {
                    final kuota = _parseNum(ticket['kuota']);
                    final sisaKuota = _parseNum(ticket['sisa_kuota']);
                    final soldQty =
                        _parseNum(ticket['sold_quantity'] ?? (kuota - sisaKuota));
                    final occupancy =
                        kuota > 0 ? ((soldQty / kuota) * 100).round() : 0;

                    return Padding(
                      padding: const EdgeInsets.only(bottom: 20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                (ticket['kategori'] ?? 'Tiket')
                                    .toString()
                                    .toUpperCase(),
                                style: TextStyle(
                                  color: textColor,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w900,
                                  letterSpacing: 0.5,
                                ),
                              ),
                              Text(
                                '$occupancy%',
                                style: TextStyle(
                                  color: AppColors.primary,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(4),
                            child: LinearProgressIndicator(
                              value: occupancy / 100,
                              minHeight: 8,
                              backgroundColor: isDark
                                  ? Colors.white.withOpacity(0.05)
                                  : Colors.black.withOpacity(0.05),
                              valueColor: AlwaysStoppedAnimation<Color>(
                                  AppColors.primary),
                            ),
                          ),
                        ],
                      ),
                    );
                  }),
              ],
            ),
          ),
          const SizedBox(height: 32),

          // ── Transaksi Terbaru ──
          Container(
            width: double.infinity,
            decoration: BoxDecoration(
              color: surfaceColor,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: borderColor),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Transaksi Terbaru',
                              style: TextStyle(
                                color: textColor,
                                fontSize: 17,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Daftar transaksi masuk real-time',
                              style:
                                  TextStyle(color: mutedColor, fontSize: 12),
                            ),
                          ],
                        ),
                      ),
                      if (_transactions.length > 5)
                        TextButton(
                          onPressed: () =>
                              _showAllTransactions(isDark, textColor,
                                  mutedColor, surfaceColor, borderColor),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                'LIHAT SEMUA',
                                style: TextStyle(
                                  color: AppColors.primary,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w900,
                                  letterSpacing: 1,
                                ),
                              ),
                              const SizedBox(width: 4),
                              Icon(Icons.arrow_forward,
                                  size: 16, color: AppColors.primary),
                            ],
                          ),
                        ),
                    ],
                  ),
                ),
                Divider(height: 1, color: borderColor),

                // Transactions list
                if (_transactions.isEmpty)
                  Padding(
                    padding: const EdgeInsets.all(24),
                    child: Center(
                      child: Column(
                        children: [
                          Icon(Icons.receipt_long_outlined,
                              size: 40,
                              color: mutedColor.withOpacity(0.3)),
                          const SizedBox(height: 12),
                          Text(
                            'Belum ada transaksi untuk event ini.',
                            style:
                                TextStyle(color: mutedColor, fontSize: 13),
                          ),
                        ],
                      ),
                    ),
                  )
                else
                  ...(_transactions.take(5).map(
                    (tx) => _buildTransactionTile(
                        tx, isDark, textColor, mutedColor, borderColor),
                  )),

                const SizedBox(height: 8),
              ],
            ),
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  // ─── Widget builders ──────────────────────

  Widget _buildSummaryCard(
    String label,
    String value,
    String unit,
    IconData icon,
    Color accentColor,
    Color surfaceColor,
    Color borderColor,
    Color textColor,
    Color mutedColor,
    bool isDark,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 14),
      decoration: BoxDecoration(
        color: surfaceColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderColor),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.2 : 0.04),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Icon(icon, size: 14, color: accentColor),
              const SizedBox(width: 5),
              Expanded(
                child: Text(
                  label.toUpperCase(),
                  style: TextStyle(
                    color: mutedColor,
                    fontSize: 8,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 0.5,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              color: textColor,
              fontSize: 13,
              fontWeight: FontWeight.w900,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          Text(
            unit,
            style: TextStyle(
              color: mutedColor,
              fontSize: 9,
              fontWeight: FontWeight.w600,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildTransactionTile(
    Map<String, dynamic> tx,
    bool isDark,
    Color textColor,
    Color mutedColor,
    Color borderColor,
  ) {
    // Parse transaction data
    final order = tx['order'] is Map ? tx['order'] as Map : null;
    final buyer =
        order != null && order['user'] is Map ? order['user'] as Map : null;
    final ticket = tx['ticket'] is Map ? tx['ticket'] as Map : null;

    final buyerName = (buyer?['nama'] ?? 'Pembeli').toString();
    final buyerEmail = (buyer?['email'] ?? '-').toString();
    final ticketCategory = (ticket?['kategori'] ?? tx['kategori'] ?? '-').toString();
    final statusOrder = (order?['status_order'] ?? tx['status'] ?? '-').toString();
    final subtotal = _parseNum(tx['subtotal']);
    final createdAt = tx['created_at']?.toString();

    // Build initials
    final nameParts = buyerName.split(' ');
    final initials = nameParts
        .take(2)
        .map((p) => p.isNotEmpty ? p[0].toUpperCase() : '')
        .join();

    // Format time
    String timeDisplay = '-';
    if (createdAt != null && createdAt.isNotEmpty) {
      try {
        final dt = DateTime.parse(createdAt);
        final diff = DateTime.now().difference(dt);
        if (diff.inMinutes < 60) {
          timeDisplay = '${diff.inMinutes} mnt lalu';
        } else if (diff.inHours < 24) {
          timeDisplay = '${diff.inHours} jam lalu';
        } else if (diff.inDays < 30) {
          timeDisplay = '${diff.inDays} hari lalu';
        } else {
          timeDisplay = DateFormat('dd MMM yyyy').format(dt);
        }
      } catch (_) {
        timeDisplay = createdAt;
      }
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: borderColor.withOpacity(0.5))),
      ),
      child: Row(
        children: [
          // Avatar
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.primary.withOpacity(0.1),
              border: Border.all(color: Colors.white, width: 2),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.08),
                  blurRadius: 4,
                ),
              ],
            ),
            child: Center(
              child: Text(
                initials,
                style: TextStyle(
                  color: AppColors.primary,
                  fontSize: 12,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),

          // Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  buyerName,
                  style: TextStyle(
                    color: textColor,
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        ticketCategory.toUpperCase(),
                        style: TextStyle(
                          color: AppColors.primary,
                          fontSize: 8,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 6,
                          height: 6,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: _statusColor(statusOrder),
                          ),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          statusOrder.toUpperCase(),
                          style: TextStyle(
                            color: _statusColor(statusOrder),
                            fontSize: 9,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Amount & Time
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                _currencyFormatter.format(subtotal),
                style: TextStyle(
                  color: textColor,
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                timeDisplay,
                style: TextStyle(
                  color: mutedColor,
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Color _statusColor(String status) {
    switch (status.toLowerCase()) {
      case 'paid':
      case 'berhasil':
      case 'completed':
      case 'success':
        return Colors.green;
      case 'pending':
      case 'waiting':
        return Colors.orange;
      case 'failed':
      case 'gagal':
      case 'cancelled':
        return Colors.red;
      default:
        return Colors.green;
    }
  }

  void _showAllTransactions(
    bool isDark,
    Color textColor,
    Color mutedColor,
    Color surfaceColor,
    Color borderColor,
  ) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.85,
        ),
        decoration: BoxDecoration(
          color: surfaceColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          children: [
            // Handle
            Container(
              margin: const EdgeInsets.only(top: 12),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: mutedColor.withOpacity(0.3),
                borderRadius: BorderRadius.circular(2),
              ),
            ),

            // Header
            Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Icon(Icons.receipt_long,
                        color: AppColors.primary, size: 22),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Riwayat Transaksi',
                          style: TextStyle(
                            color: textColor,
                            fontSize: 17,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          'Kelola dan pantau semua penjualan tiket',
                          style:
                              TextStyle(color: mutedColor, fontSize: 11),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(ctx),
                    icon: Icon(Icons.close, color: mutedColor),
                  ),
                ],
              ),
            ),
            Divider(height: 1, color: borderColor),

            // Count
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: Row(
                children: [
                  Text(
                    'Menampilkan ${_transactions.length} transaksi',
                    style: TextStyle(color: mutedColor, fontSize: 11),
                  ),
                ],
              ),
            ),

            // List
            Expanded(
              child: ListView.builder(
                itemCount: _transactions.length,
                itemBuilder: (_, i) => _buildTransactionTile(
                  _transactions[i],
                  isDark,
                  textColor,
                  mutedColor,
                  borderColor,
                ),
              ),
            ),

            // Close button
            SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(ctx),
                    style: ElevatedButton.styleFrom(
                      backgroundColor:
                          isDark ? Colors.grey[800] : Colors.grey[100],
                      foregroundColor: textColor,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                      elevation: 0,
                    ),
                    child: const Text(
                      'Tutup',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
