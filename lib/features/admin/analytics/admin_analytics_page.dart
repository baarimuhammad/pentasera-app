import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shimmer/shimmer.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:pentasera_app/main.dart';
import 'package:pentasera_app/services/admin_service.dart';

class AdminAnalyticsPage extends StatefulWidget {
  const AdminAnalyticsPage({super.key});

  @override
  State<AdminAnalyticsPage> createState() => _AdminAnalyticsPageState();
}

class _AdminAnalyticsPageState extends State<AdminAnalyticsPage> {
  bool _isLoading = true;
  String? _error;

  // Overview
  int _totalUsers = 0;
  int _totalEvents = 0;
  int _totalTransactions = 0;
  String _revenueFormatted = 'Rp 0';

  // Charts data
  List<Map<String, dynamic>> _userGrowth = [];
  List<Map<String, dynamic>> _eventsByCategory = [];
  Map<String, dynamic> _eventsByStatus = {};
  List<Map<String, dynamic>> _topEvents = [];
  List<Map<String, dynamic>> _recentTransactions = [];

  final _currencyFormatter =
      NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);

  // Chart colors
  static const _chartColors = [
    Color(0xFFf27f0d), // primary/orange
    Color(0xFF3B82F6), // blue
    Color(0xFF10B981), // green
    Color(0xFF8B5CF6), // purple
    Color(0xFFF59E0B), // amber
    Color(0xFFEF4444), // red
    Color(0xFF06B6D4), // cyan
  ];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    final result = await AdminService.getAnalytics();

    if (result['success'] == true) {
      final data = result['data'] as Map<String, dynamic>;
      final overview =
          (data['overview'] as Map<String, dynamic>?) ?? {};

      _totalUsers = _toInt(overview['total_users']);
      _totalEvents = _toInt(overview['total_events']);
      _totalTransactions = _toInt(overview['total_transactions']);
      _revenueFormatted =
          overview['revenue_formatted']?.toString() ?? 'Rp 0';

      _userGrowth = _toListMap(data['user_growth']);
      _eventsByCategory = _toListMap(data['events_by_category']);
      _eventsByStatus =
          (data['events_by_status'] is Map)
              ? Map<String, dynamic>.from(data['events_by_status'])
              : {};
      _topEvents = _toListMap(data['top_events']);
      _recentTransactions = _toListMap(data['recent_transactions']);
    } else {
      _error = result['message'];
    }

    if (mounted) setState(() => _isLoading = false);
  }

  int _toInt(dynamic v) {
    if (v is int) return v;
    if (v is double) return v.toInt();
    return int.tryParse(v?.toString() ?? '') ?? 0;
  }

  List<Map<String, dynamic>> _toListMap(dynamic v) {
    if (v is List) {
      return v
          .whereType<Map>()
          .map((e) => Map<String, dynamic>.from(e))
          .toList();
    }
    return [];
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? AppColors.textDark : AppColors.textLight;
    final mutedColor = isDark ? AppColors.mutedDark : AppColors.mutedLight;
    final surfaceColor =
        isDark ? AppColors.surfaceDark : AppColors.surfaceLight;
    final borderColor = isDark ? AppColors.borderDark : AppColors.borderLight;

    return Scaffold(
      backgroundColor:
          isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text('Laporan & Analitik',
            style: TextStyle(
                color: textColor, fontWeight: FontWeight.bold, fontSize: 18)),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(Icons.refresh, color: mutedColor),
            onPressed: _loadData,
          ),
        ],
      ),
      body: _isLoading
          ? _buildShimmer(isDark)
          : _error != null
              ? _buildError(mutedColor)
              : RefreshIndicator(
                  color: AppColors.primary,
                  onRefresh: _loadData,
                  child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildOverviewStats(
                            isDark, textColor, mutedColor, surfaceColor, borderColor),
                        const SizedBox(height: 24),
                        _buildUserGrowthChart(
                            isDark, textColor, mutedColor, surfaceColor, borderColor),
                        const SizedBox(height: 20),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: _buildCategoryChart(isDark, textColor,
                                  mutedColor, surfaceColor, borderColor),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: _buildStatusChart(isDark, textColor,
                                  mutedColor, surfaceColor, borderColor),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        _buildTopEvents(
                            isDark, textColor, mutedColor, surfaceColor, borderColor),
                        const SizedBox(height: 20),
                        _buildRecentTransactions(
                            isDark, textColor, mutedColor, surfaceColor, borderColor),
                        const SizedBox(height: 20),
                      ],
                    ),
                  ),
                ),
    );
  }

  // ══════════════════════════════════════════
  // OVERVIEW STATS
  // ══════════════════════════════════════════
  Widget _buildOverviewStats(bool isDark, Color textColor, Color mutedColor,
      Color surfaceColor, Color borderColor) {
    return Column(
      children: [
        Row(children: [
          Expanded(
              child: _miniStat(Icons.people_outline, const Color(0xFF3B82F6),
                  'Total Pengguna', '$_totalUsers', surfaceColor, borderColor, textColor, mutedColor)),
          const SizedBox(width: 10),
          Expanded(
              child: _miniStat(Icons.event_outlined, const Color(0xFF10B981),
                  'Total Event', '$_totalEvents', surfaceColor, borderColor, textColor, mutedColor)),
        ]),
        const SizedBox(height: 10),
        Row(children: [
          Expanded(
              child: _miniStat(Icons.shopping_cart_outlined, const Color(0xFFF59E0B),
                  'Total Transaksi', '$_totalTransactions', surfaceColor, borderColor, textColor, mutedColor)),
          const SizedBox(width: 10),
          Expanded(
              child: _miniStat(Icons.account_balance_wallet_outlined, const Color(0xFF8B5CF6),
                  'Total Pendapatan', _revenueFormatted, surfaceColor, borderColor, textColor, mutedColor)),
        ]),
      ],
    );
  }

  Widget _miniStat(IconData icon, Color iconColor, String label, String value,
      Color surfaceColor, Color borderColor, Color textColor, Color mutedColor) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: surfaceColor,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: borderColor),
      ),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: iconColor.withOpacity(0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: iconColor, size: 18),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label,
                    style: TextStyle(
                        color: mutedColor,
                        fontSize: 10,
                        fontWeight: FontWeight.w600)),
                const SizedBox(height: 2),
                Text(value,
                    style: TextStyle(
                        color: textColor,
                        fontSize: 15,
                        fontWeight: FontWeight.w900),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ══════════════════════════════════════════
  // USER GROWTH BAR CHART
  // ══════════════════════════════════════════
  Widget _buildUserGrowthChart(bool isDark, Color textColor, Color mutedColor,
      Color surfaceColor, Color borderColor) {
    return _chartCard(
      title: 'Pertumbuhan Pengguna',
      subtitle: 'Pengguna baru per bulan (12 bulan terakhir)',
      surfaceColor: surfaceColor,
      borderColor: borderColor,
      textColor: textColor,
      mutedColor: mutedColor,
      child: SizedBox(
        height: 200,
        child: _userGrowth.isEmpty
            ? Center(
                child: Text('Belum ada data',
                    style: TextStyle(color: mutedColor, fontSize: 13)))
            : BarChart(
                BarChartData(
                  alignment: BarChartAlignment.spaceAround,
                  maxY: _userGrowth
                          .map((e) => _toInt(e['count']).toDouble())
                          .fold<double>(0, (a, b) => a > b ? a : b) *
                      1.3,
                  barTouchData: BarTouchData(
                    touchTooltipData: BarTouchTooltipData(
                      getTooltipItem: (group, groupIndex, rod, rodIndex) {
                        final month = _userGrowth[group.x.toInt()]['month'] ?? '';
                        return BarTooltipItem(
                          '$month\n${rod.toY.toInt()} pengguna',
                          TextStyle(color: Colors.white, fontSize: 11),
                        );
                      },
                    ),
                  ),
                  titlesData: FlTitlesData(
                    show: true,
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          final i = value.toInt();
                          if (i < 0 || i >= _userGrowth.length) {
                            return const SizedBox.shrink();
                          }
                          final month = (_userGrowth[i]['month'] ?? '')
                              .toString()
                              .split('-')
                              .last;
                          return Padding(
                            padding: const EdgeInsets.only(top: 6),
                            child: Text(month,
                                style:
                                    TextStyle(color: mutedColor, fontSize: 9)),
                          );
                        },
                        reservedSize: 24,
                      ),
                    ),
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 30,
                        getTitlesWidget: (value, meta) {
                          return Text(value.toInt().toString(),
                              style:
                                  TextStyle(color: mutedColor, fontSize: 9));
                        },
                      ),
                    ),
                    topTitles: const AxisTitles(
                        sideTitles: SideTitles(showTitles: false)),
                    rightTitles: const AxisTitles(
                        sideTitles: SideTitles(showTitles: false)),
                  ),
                  borderData: FlBorderData(show: false),
                  gridData: FlGridData(
                    show: true,
                    drawVerticalLine: false,
                    horizontalInterval: 1,
                    getDrawingHorizontalLine: (value) => FlLine(
                      color: borderColor,
                      strokeWidth: 0.5,
                    ),
                  ),
                  barGroups: List.generate(_userGrowth.length, (i) {
                    return BarChartGroupData(
                      x: i,
                      barRods: [
                        BarChartRodData(
                          toY: _toInt(_userGrowth[i]['count']).toDouble(),
                          color: AppColors.primary,
                          width: 14,
                          borderRadius: const BorderRadius.vertical(
                              top: Radius.circular(4)),
                        ),
                      ],
                    );
                  }),
                ),
              ),
      ),
    );
  }

  // ══════════════════════════════════════════
  // EVENTS BY CATEGORY (PIE)
  // ══════════════════════════════════════════
  Widget _buildCategoryChart(bool isDark, Color textColor, Color mutedColor,
      Color surfaceColor, Color borderColor) {
    return _chartCard(
      title: 'Distribusi Event',
      subtitle: 'Berdasarkan kategori',
      surfaceColor: surfaceColor,
      borderColor: borderColor,
      textColor: textColor,
      mutedColor: mutedColor,
      child: SizedBox(
        height: 180,
        child: _eventsByCategory.isEmpty
            ? Center(
                child: Text('Belum ada data',
                    style: TextStyle(color: mutedColor, fontSize: 12)))
            : Column(
                children: [
                  SizedBox(
                    height: 120,
                    child: PieChart(
                      PieChartData(
                        sectionsSpace: 2,
                        centerSpaceRadius: 22,
                        sections: List.generate(
                          _eventsByCategory.length,
                          (i) {
                            final item = _eventsByCategory[i];
                            final count = _toInt(item['count']).toDouble();
                            return PieChartSectionData(
                              value: count,
                              color: _chartColors[i % _chartColors.length],
                              radius: 28,
                              title: '${count.toInt()}',
                              titleStyle: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold),
                            );
                          },
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Expanded(
                    child: SingleChildScrollView(
                      child: Wrap(
                        spacing: 8,
                        runSpacing: 4,
                        children: List.generate(
                          _eventsByCategory.length,
                          (i) => _legendDot(
                            _chartColors[i % _chartColors.length],
                            (_eventsByCategory[i]['kategori_event'] ?? '-')
                                .toString(),
                            mutedColor,
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

  // ══════════════════════════════════════════
  // EVENTS BY STATUS (PIE)
  // ══════════════════════════════════════════
  Widget _buildStatusChart(bool isDark, Color textColor, Color mutedColor,
      Color surfaceColor, Color borderColor) {
    final statusColors = {
      'draft': Colors.orange,
      'pending_approval': Colors.amber,
      'published': Colors.green,
      'ended': Colors.grey,
      'cancelled': Colors.red,
    };

    final statusLabels = {
      'draft': 'Draft',
      'pending_approval': 'Pending',
      'published': 'Aktif',
      'ended': 'Selesai',
      'cancelled': 'Batal',
    };

    final entries = _eventsByStatus.entries.toList();

    return _chartCard(
      title: 'Status Event',
      subtitle: 'Distribusi status saat ini',
      surfaceColor: surfaceColor,
      borderColor: borderColor,
      textColor: textColor,
      mutedColor: mutedColor,
      child: SizedBox(
        height: 180,
        child: entries.isEmpty
            ? Center(
                child: Text('Belum ada data',
                    style: TextStyle(color: mutedColor, fontSize: 12)))
            : Column(
                children: [
                  SizedBox(
                    height: 120,
                    child: PieChart(
                      PieChartData(
                        sectionsSpace: 2,
                        centerSpaceRadius: 22,
                        sections: entries.map((e) {
                          final count = _toInt(e.value).toDouble();
                          final color = statusColors[e.key] ?? Colors.grey;
                          return PieChartSectionData(
                            value: count,
                            color: color,
                            radius: 28,
                            title: '${count.toInt()}',
                            titleStyle: const TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.bold),
                          );
                        }).toList(),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Expanded(
                    child: SingleChildScrollView(
                      child: Wrap(
                        spacing: 8,
                        runSpacing: 4,
                        children: entries.map((e) {
                          final color = statusColors[e.key] ?? Colors.grey;
                          final label = statusLabels[e.key] ?? e.key;
                          return _legendDot(color, label, mutedColor);
                        }).toList(),
                      ),
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  // ══════════════════════════════════════════
  // TOP 5 EVENTS
  // ══════════════════════════════════════════
  Widget _buildTopEvents(bool isDark, Color textColor, Color mutedColor,
      Color surfaceColor, Color borderColor) {
    return _chartCard(
      title: 'Top 5 Event',
      subtitle: 'Berdasarkan pendapatan tertinggi',
      surfaceColor: surfaceColor,
      borderColor: borderColor,
      textColor: textColor,
      mutedColor: mutedColor,
      child: _topEvents.isEmpty
          ? Padding(
              padding: const EdgeInsets.symmetric(vertical: 20),
              child: Center(
                  child: Text('Belum ada data',
                      style: TextStyle(color: mutedColor, fontSize: 13))),
            )
          : Column(
              children: List.generate(_topEvents.length, (i) {
                final event = _topEvents[i];
                final nama = (event['nama_event'] ?? '-').toString();
                final organizer = (event['organizer'] ?? '-').toString();
                final revenue = _toInt(event['revenue']);
                final sold = _toInt(event['tickets_sold']);

                return Container(
                  padding:
                      const EdgeInsets.symmetric(vertical: 10, horizontal: 4),
                  decoration: BoxDecoration(
                    border: i < _topEvents.length - 1
                        ? Border(bottom: BorderSide(color: borderColor, width: 0.5))
                        : null,
                  ),
                  child: Row(
                    children: [
                      // Rank badge
                      Container(
                        width: 28,
                        height: 28,
                        decoration: BoxDecoration(
                          color: i == 0
                              ? const Color(0xFFF59E0B)
                              : i == 1
                                  ? const Color(0xFF94A3B8)
                                  : i == 2
                                      ? const Color(0xFFCD7F32)
                                      : AppColors.primary.withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: Text(
                            '${i + 1}',
                            style: TextStyle(
                              color: i < 3 ? Colors.white : AppColors.primary,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(nama,
                                style: TextStyle(
                                    color: textColor,
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis),
                            Text(organizer,
                                style: TextStyle(
                                    color: mutedColor, fontSize: 11)),
                          ],
                        ),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            _currencyFormatter.format(revenue),
                            style: TextStyle(
                              color: textColor,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text('$sold tiket',
                              style: TextStyle(
                                  color: mutedColor, fontSize: 10)),
                        ],
                      ),
                    ],
                  ),
                );
              }),
            ),
    );
  }

  // ══════════════════════════════════════════
  // RECENT TRANSACTIONS TABLE
  // ══════════════════════════════════════════
  Widget _buildRecentTransactions(bool isDark, Color textColor,
      Color mutedColor, Color surfaceColor, Color borderColor) {
    return _chartCard(
      title: 'Transaksi Terakhir',
      subtitle: '10 transaksi terbaru',
      surfaceColor: surfaceColor,
      borderColor: borderColor,
      textColor: textColor,
      mutedColor: mutedColor,
      child: _recentTransactions.isEmpty
          ? Padding(
              padding: const EdgeInsets.symmetric(vertical: 20),
              child: Center(
                  child: Text('Belum ada transaksi',
                      style: TextStyle(color: mutedColor, fontSize: 13))),
            )
          : Column(
              children: List.generate(_recentTransactions.length, (i) {
                final tx = _recentTransactions[i];
                final code = (tx['order_code'] ?? '-').toString();
                final buyer = (tx['buyer_name'] ?? '-').toString();
                final event = (tx['event'] ?? '-').toString();
                final total = (tx['total_formatted'] ?? '-').toString();
                final date = (tx['date'] ?? '').toString();

                return Container(
                  padding:
                      const EdgeInsets.symmetric(vertical: 10, horizontal: 4),
                  decoration: BoxDecoration(
                    border: i < _recentTransactions.length - 1
                        ? Border(
                            bottom:
                                BorderSide(color: borderColor, width: 0.5))
                        : null,
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 34,
                        height: 34,
                        decoration: BoxDecoration(
                          color: AppColors.primary.withOpacity(0.08),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(Icons.receipt_long_outlined,
                            color: AppColors.primary, size: 16),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(code,
                                style: TextStyle(
                                    color: textColor,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600)),
                            Text('$buyer • $event',
                                style: TextStyle(
                                    color: mutedColor, fontSize: 10),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis),
                          ],
                        ),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(total,
                              style: TextStyle(
                                  color: textColor,
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold)),
                          Text(_formatShortDate(date),
                              style: TextStyle(
                                  color: mutedColor, fontSize: 10)),
                        ],
                      ),
                    ],
                  ),
                );
              }),
            ),
    );
  }

  // ══════════════════════════════════════════
  // SHARED WIDGETS
  // ══════════════════════════════════════════
  Widget _chartCard({
    required String title,
    required String subtitle,
    required Color surfaceColor,
    required Color borderColor,
    required Color textColor,
    required Color mutedColor,
    required Widget child,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: surfaceColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title,
              style: TextStyle(
                  color: textColor,
                  fontSize: 15,
                  fontWeight: FontWeight.bold)),
          const SizedBox(height: 2),
          Text(subtitle,
              style: TextStyle(color: mutedColor, fontSize: 11)),
          const SizedBox(height: 16),
          child,
        ],
      ),
    );
  }

  Widget _legendDot(Color color, String label, Color mutedColor) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 4),
        Text(label,
            style: TextStyle(color: mutedColor, fontSize: 9),
            maxLines: 1,
            overflow: TextOverflow.ellipsis),
      ],
    );
  }

  String _formatShortDate(String? dateStr) {
    if (dateStr == null || dateStr.isEmpty) return '-';
    try {
      final date = DateTime.parse(dateStr);
      return DateFormat('dd MMM').format(date);
    } catch (_) {
      return dateStr;
    }
  }

  // ══════════════════════════════════════════
  // LOADING & ERROR
  // ══════════════════════════════════════════
  Widget _buildShimmer(bool isDark) {
    return Shimmer.fromColors(
      baseColor: isDark ? Colors.grey[800]! : Colors.grey[300]!,
      highlightColor: isDark ? Colors.grey[700]! : Colors.grey[100]!,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Row(children: [
              Expanded(child: _shimmerBox(70)),
              const SizedBox(width: 10),
              Expanded(child: _shimmerBox(70)),
            ]),
            const SizedBox(height: 10),
            Row(children: [
              Expanded(child: _shimmerBox(70)),
              const SizedBox(width: 10),
              Expanded(child: _shimmerBox(70)),
            ]),
            const SizedBox(height: 20),
            _shimmerBox(220),
            const SizedBox(height: 16),
            Row(children: [
              Expanded(child: _shimmerBox(200)),
              const SizedBox(width: 12),
              Expanded(child: _shimmerBox(200)),
            ]),
            const SizedBox(height: 16),
            _shimmerBox(250),
          ],
        ),
      ),
    );
  }

  Widget _shimmerBox(double height) {
    return Container(
      height: height,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
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
          Text(_error ?? 'Terjadi kesalahan',
              style: TextStyle(color: mutedColor)),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: _loadData,
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
