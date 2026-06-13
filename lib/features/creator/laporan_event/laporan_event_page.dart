import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import 'package:intl/intl.dart';
import 'package:pentasera_app/main.dart';
import 'package:pentasera_app/services/event_service.dart';
import 'sales_trend_chart.dart';
import 'csv_exporter.dart';

class LaporanEventPage extends StatefulWidget {
  final int eventId;
  const LaporanEventPage({super.key, required this.eventId});

  @override
  State<LaporanEventPage> createState() => _LaporanEventPageState();
}

class _LaporanEventPageState extends State<LaporanEventPage> {
  bool _isLoading = true;
  String? _error;
  
  Map<String, dynamic> _reportData = {};
  Map<String, dynamic> _event = {};
  Map<String, dynamic> _stats = {};
  List<Map<String, dynamic>> _ticketsBreakdown = [];
  List<Map<String, dynamic>> _dailySales = [];
  List<Map<String, dynamic>> _recentTransactions = [];

  @override
  void initState() {
    super.initState();
    _loadReport();
  }

  Future<void> _loadReport() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    final result = await EventService.getEventReport(widget.eventId);
    if (result['success'] == true) {
      final data = Map<String, dynamic>.from(result['data'] ?? {});
      _reportData = data;
      _event = Map<String, dynamic>.from(data['event'] ?? {});
      _stats = Map<String, dynamic>.from(data['stats'] ?? {});
      
      final breakdownList = data['tickets_breakdown'];
      if (breakdownList is List) {
        _ticketsBreakdown = breakdownList.whereType<Map>().map((e) => Map<String, dynamic>.from(e)).toList();
      }

      final salesList = data['daily_sales'];
      if (salesList is List) {
        _dailySales = salesList.whereType<Map>().map((e) => Map<String, dynamic>.from(e)).toList();
      }

      final txList = data['recent_transactions'];
      if (txList is List) {
        _recentTransactions = txList.whereType<Map>().map((e) => Map<String, dynamic>.from(e)).toList();
      }
    } else {
      _error = result['message'] ?? 'Gagal memuat laporan event';
    }

    if (mounted) setState(() => _isLoading = false);
  }

  int _parseNum(dynamic v) {
    if (v == null) return 0;
    if (v is int) return v;
    if (v is double) return v.toInt();
    return int.tryParse(v.toString().replaceAll(RegExp(r'[^0-9]'), '')) ?? 0;
  }
  
  double _parseOccupancy(dynamic v) {
    if (v == null) return 0.0;
    final str = v.toString().replaceAll('%', '');
    return double.tryParse(str) ?? 0.0;
  }

  // ── Helpers ──
  Color _statusColor(String? status) {
    switch (status?.toLowerCase()) {
      case 'published':
        return Colors.green;
      case 'draft':
        return Colors.orange;
      case 'cancelled':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  String _statusLabel(String? status) {
    switch (status?.toLowerCase()) {
      case 'published':
        return 'AKTIF';
      case 'draft':
        return 'DRAF';
      case 'cancelled':
        return 'DIBATALKAN';
      default:
        return (status ?? 'UNKNOWN').toUpperCase();
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? AppColors.textDark : AppColors.textLight;
    final mutedColor = isDark ? AppColors.mutedDark : AppColors.mutedLight;
    final surfaceColor = isDark ? AppColors.surfaceDark : AppColors.surfaceLight;
    final borderColor = isDark ? AppColors.borderDark : AppColors.borderLight;

    return Scaffold(
      backgroundColor: isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: textColor),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: _isLoading
          ? _buildShimmer(isDark)
          : _error != null
              ? _buildError(mutedColor)
              : _buildContent(isDark, textColor, mutedColor, surfaceColor, borderColor),
    );
  }

  Widget _buildContent(bool isDark, Color textColor, Color mutedColor, Color surfaceColor, Color borderColor) {
    final eventStatus = (_event['event_status'] ?? 'draft').toString();
    final eventName = (_event['nama_event'] ?? 'Event').toString();
    
    final revenueStr = (_stats['revenue_formatted'] ?? 'Rp 0').toString();
    final sold = _parseNum(_stats['tiket_terjual']);
    final capacity = _parseNum(_stats['capacity']);
    final occupancyStr = (_stats['occupancy'] ?? '0.0%').toString();

    // Target calculation based on capacity (if sold matches capacity then 100%)
    double targetPerc = 0.0;
    if (capacity > 0) {
      targetPerc = (sold / capacity) * 100;
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Header ──
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: _statusColor(eventStatus).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  _statusLabel(eventStatus),
                  style: TextStyle(
                    color: _statusColor(eventStatus),
                    fontSize: 9,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                'Laporan Event #EVT-${widget.eventId.toString().padLeft(3, '0')}',
                style: TextStyle(
                  color: mutedColor,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            eventName,
            style: TextStyle(
              color: textColor,
              fontSize: 24,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 16),
          
          // Action Buttons
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Tautan laporan disalin ke clipboard!')),
                    );
                  },
                  icon: const Icon(Icons.share_outlined, size: 16),
                  label: const Text('Bagikan', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: textColor,
                    side: BorderSide(color: borderColor),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () {
                    CsvExporter.exportTransactions(
                      transactions: _recentTransactions,
                      eventName: eventName,
                      context: context,
                    );
                  },
                  icon: const Icon(Icons.download_outlined, size: 16),
                  label: const Text('Export CSV', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    elevation: 4,
                    shadowColor: AppColors.primary.withOpacity(0.4),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // ── Stats Overview ──
          Row(
            children: [
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: surfaceColor,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: borderColor),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(isDark ? 0.2 : 0.02),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      )
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'TOTAL PENDAPATAN',
                        style: TextStyle(
                          color: mutedColor,
                          fontSize: 9,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 1,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        revenueStr,
                        style: TextStyle(
                          color: textColor,
                          fontSize: 18,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        capacity > 0 ? '${targetPerc.toStringAsFixed(1)}% Target tercapai' : 'Belum ada tiket',
                        style: const TextStyle(
                          color: Colors.green,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: surfaceColor,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: borderColor),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(isDark ? 0.2 : 0.02),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      )
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'TIKET TERJUAL',
                        style: TextStyle(
                          color: mutedColor,
                          fontSize: 9,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 1,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '${NumberFormat('#,###').format(sold).replaceAll(',', '.')} / ${NumberFormat('#,###').format(capacity).replaceAll(',', '.')}',
                        style: TextStyle(
                          color: textColor,
                          fontSize: 18,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '$occupancyStr Terisi',
                        style: const TextStyle(
                          color: AppColors.primary,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // ── Sales Trend Chart ──
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: surfaceColor,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: borderColor),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(isDark ? 0.2 : 0.02),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                )
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'TREN PENJUALAN TIKET',
                      style: TextStyle(
                        color: textColor,
                        fontSize: 12,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 0.5,
                      ),
                    ),
                    Row(
                      children: [
                        Container(width: 8, height: 8, decoration: const BoxDecoration(color: AppColors.primary, shape: BoxShape.circle)),
                        const SizedBox(width: 6),
                        Text(
                          'Tiket Terjual',
                          style: TextStyle(color: mutedColor, fontSize: 9, fontWeight: FontWeight.bold, letterSpacing: 0.5),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                SalesTrendChart(dailySales: _dailySales),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // ── Rincian Per Kategori ──
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: surfaceColor,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: borderColor),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'RINCIAN PER KATEGORI',
                  style: TextStyle(
                    color: textColor,
                    fontSize: 12,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 16),
                if (_ticketsBreakdown.isEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    child: Center(child: Text('Belum ada tiket', style: TextStyle(color: mutedColor, fontSize: 12))),
                  )
                else
                  ..._ticketsBreakdown.map((tb) {
                    final kat = tb['kategori']?.toString() ?? '-';
                    final harga = tb['harga_formatted']?.toString() ?? tb['harga']?.toString() ?? 'Rp 0';
                    final terjual = _parseNum(tb['terjual']);
                    final revenue = tb['revenue_formatted']?.toString() ?? 'Rp 0';
                    final okPerc = _parseOccupancy(tb['occupancy']);

                    return Container(
                      margin: const EdgeInsets.only(bottom: 16),
                      padding: const EdgeInsets.only(bottom: 16),
                      decoration: BoxDecoration(
                        border: Border(bottom: BorderSide(color: borderColor)),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Expanded(
                            flex: 2,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(kat, style: TextStyle(color: textColor, fontSize: 12, fontWeight: FontWeight.bold)),
                                Text(harga, style: TextStyle(color: mutedColor, fontSize: 9, fontWeight: FontWeight.bold)),
                              ],
                            ),
                          ),
                          Expanded(
                            flex: 1,
                            child: Center(
                              child: Text(terjual.toString(), style: TextStyle(color: textColor, fontSize: 12, fontWeight: FontWeight.bold)),
                            ),
                          ),
                          Expanded(
                            flex: 2,
                            child: Align(
                              alignment: Alignment.centerRight,
                              child: Text(revenue, style: TextStyle(color: textColor, fontSize: 12, fontWeight: FontWeight.bold)),
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // ── Ringkasan Transaksi ──
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: surfaceColor,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: borderColor),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'RINGKASAN TRANSAKSI',
                  style: TextStyle(
                    color: textColor,
                    fontSize: 12,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('TOTAL ORDER', style: TextStyle(color: textColor, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 0.5)),
                    Text(_recentTransactions.length.toString(), style: const TextStyle(color: AppColors.primary, fontSize: 14, fontWeight: FontWeight.w900)),
                  ],
                ),
                const SizedBox(height: 16),
                if (_ticketsBreakdown.isEmpty)
                   Text('Belum ada data', style: TextStyle(color: mutedColor, fontSize: 12))
                else
                  ..._ticketsBreakdown.map((tb) {
                    final kat = tb['kategori']?.toString() ?? '-';
                    final okPerc = _parseOccupancy(tb['occupancy']);
                    final widthRatio = (okPerc / 100).clamp(0.0, 1.0);

                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(kat.toUpperCase(), style: TextStyle(color: textColor, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 0.5)),
                              Text('${okPerc.toStringAsFixed(1)}%', style: const TextStyle(color: AppColors.primary, fontSize: 10, fontWeight: FontWeight.w900)),
                            ],
                          ),
                          const SizedBox(height: 6),
                          Container(
                            height: 6,
                            width: double.infinity,
                            decoration: BoxDecoration(
                              color: isDark ? Colors.grey[800] : Colors.grey[200],
                              borderRadius: BorderRadius.circular(3),
                            ),
                            alignment: Alignment.centerLeft,
                            child: FractionallySizedBox(
                              widthFactor: widthRatio,
                              child: Container(
                                decoration: BoxDecoration(
                                  color: AppColors.primary,
                                  borderRadius: BorderRadius.circular(3),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // ── Transaksi Terbaru ──
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: surfaceColor,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: borderColor),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'TRANSAKSI TERBARU',
                  style: TextStyle(
                    color: textColor,
                    fontSize: 12,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 16),
                if (_recentTransactions.isEmpty)
                  Center(child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    child: Text('Belum ada transaksi', style: TextStyle(color: mutedColor, fontSize: 12)),
                  ))
                else
                  ..._recentTransactions.take(5).map((tx) {
                    final name = tx['buyer_name']?.toString() ?? '-';
                    final tickets = tx['tickets']?.toString() ?? '-';
                    final qty = _parseNum(tx['qty']);
                    final total = tx['total_formatted']?.toString() ?? 'Rp 0';
                    final dateStr = tx['date']?.toString() ?? '';
                    
                    String formattedDate = dateStr;
                    try {
                      if (dateStr.isNotEmpty) {
                        formattedDate = DateFormat('dd MMM yyyy').format(DateTime.parse(dateStr));
                      }
                    } catch (_) {}

                    return Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: const EdgeInsets.only(bottom: 12),
                      decoration: BoxDecoration(
                        border: Border(bottom: BorderSide(color: borderColor)),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(name, style: TextStyle(color: textColor, fontSize: 12, fontWeight: FontWeight.bold), maxLines: 1, overflow: TextOverflow.ellipsis),
                                const SizedBox(height: 2),
                                Text('$tickets • ${qty}x', style: TextStyle(color: mutedColor, fontSize: 10)),
                              ],
                            ),
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(total, style: TextStyle(color: textColor, fontSize: 12, fontWeight: FontWeight.bold)),
                              const SizedBox(height: 2),
                              Text(formattedDate, style: TextStyle(color: mutedColor, fontSize: 10)),
                            ],
                          ),
                        ],
                      ),
                    );
                  }).toList(),
              ],
            ),
          ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _buildShimmer(bool isDark) {
    return Shimmer.fromColors(
      baseColor: isDark ? Colors.grey[800]! : Colors.grey[300]!,
      highlightColor: isDark ? Colors.grey[700]! : Colors.grey[100]!,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(width: 100, height: 20, color: Colors.white),
            const SizedBox(height: 12),
            Container(width: 250, height: 32, color: Colors.white),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(child: Container(height: 48, color: Colors.white)),
                const SizedBox(width: 12),
                Expanded(child: Container(height: 48, color: Colors.white)),
              ],
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(child: Container(height: 120, decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)))),
                const SizedBox(width: 12),
                Expanded(child: Container(height: 120, decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)))),
              ],
            ),
            const SizedBox(height: 24),
            Container(height: 250, decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16))),
            const SizedBox(height: 24),
            Container(height: 200, decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16))),
          ],
        ),
      ),
    );
  }

  Widget _buildError(Color mutedColor) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.error_outline, size: 48, color: Colors.red),
          const SizedBox(height: 12),
          Text(_error ?? 'Terjadi kesalahan', style: TextStyle(color: mutedColor)),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: _loadReport,
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
