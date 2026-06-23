import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shimmer/shimmer.dart';
import 'package:pentasera_app/main.dart';
import 'package:pentasera_app/services/admin_service.dart';

class AdminDashboardPage extends StatefulWidget {
  const AdminDashboardPage({super.key});

  @override
  State<AdminDashboardPage> createState() => _AdminDashboardPageState();
}

class _AdminDashboardPageState extends State<AdminDashboardPage> {
  bool _isLoading = true;
  String? _error;

  // Stats
  int _totalUsers = 0;
  int _totalEvents = 0;
  int _pendingApproval = 0;
  String _revenueFormatted = 'Rp 0';
  int _totalCreators = 0;
  int _totalBuyers = 0;
  int _totalTransactions = 0;

  // Pending events
  List<Map<String, dynamic>> _pendingEvents = [];

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

    final results = await Future.wait([
      AdminService.getStats(),
      AdminService.getPendingEvents(),
    ]);

    final statsResult = results[0];
    final pendingResult = results[1];

    if (statsResult['success'] == true) {
      final s = statsResult['data'] as Map<String, dynamic>;
      _totalUsers = _toInt(s['total_users']);
      _totalEvents = _toInt(s['total_events']);
      _pendingApproval = _toInt(s['pending_approval']);
      _revenueFormatted =
          s['revenue_formatted']?.toString() ?? 'Rp 0';
      _totalCreators = _toInt(s['total_creators']);
      _totalBuyers = _toInt(s['total_buyers']);
      _totalTransactions = _toInt(s['total_transactions']);
    } else {
      _error = statsResult['message'];
    }

    if (pendingResult['success'] == true) {
      _pendingEvents = (pendingResult['data'] as List?)
              ?.whereType<Map>()
              .map((e) => Map<String, dynamic>.from(e))
              .toList() ??
          [];
    }

    if (mounted) setState(() => _isLoading = false);
  }

  int _toInt(dynamic v) {
    if (v is int) return v;
    if (v is double) return v.toInt();
    return int.tryParse(v?.toString() ?? '') ?? 0;
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
        title: Text('Dashboard Admin',
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
                        _buildStatsGrid(isDark, textColor, mutedColor),
                        const SizedBox(height: 24),
                        _buildPendingSection(isDark, textColor, mutedColor),
                      ],
                    ),
                  ),
                ),
    );
  }

  // ══════════════════════════════════════════
  // STATS GRID
  // ══════════════════════════════════════════
  Widget _buildStatsGrid(bool isDark, Color textColor, Color mutedColor) {
    final surfaceColor =
        isDark ? AppColors.surfaceDark : AppColors.surfaceLight;
    final borderColor = isDark ? AppColors.borderDark : AppColors.borderLight;

    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _statCard(
                icon: Icons.people_outline,
                iconBg: const Color(0xFF3B82F6),
                label: 'Total Pengguna',
                value: '$_totalUsers',
                sub: '$_totalCreators creator, $_totalBuyers buyer',
                surfaceColor: surfaceColor,
                borderColor: borderColor,
                textColor: textColor,
                mutedColor: mutedColor,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _statCard(
                icon: Icons.event_outlined,
                iconBg: const Color(0xFF10B981),
                label: 'Total Event',
                value: '$_totalEvents',
                sub: '$_pendingApproval menunggu review',
                surfaceColor: surfaceColor,
                borderColor: borderColor,
                textColor: textColor,
                mutedColor: mutedColor,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _statCard(
                icon: Icons.hourglass_top_outlined,
                iconBg: const Color(0xFFF59E0B),
                label: 'Menunggu Approval',
                value: '$_pendingApproval',
                sub: 'Event perlu ditinjau',
                surfaceColor: surfaceColor,
                borderColor: borderColor,
                textColor: textColor,
                mutedColor: mutedColor,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _statCard(
                icon: Icons.account_balance_wallet_outlined,
                iconBg: const Color(0xFF8B5CF6),
                label: 'Total Pendapatan',
                value: _revenueFormatted,
                sub: '$_totalTransactions transaksi',
                surfaceColor: surfaceColor,
                borderColor: borderColor,
                textColor: textColor,
                mutedColor: mutedColor,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _statCard({
    required IconData icon,
    required Color iconBg,
    required String label,
    required String value,
    required String sub,
    required Color surfaceColor,
    required Color borderColor,
    required Color textColor,
    required Color mutedColor,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: surfaceColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: iconBg.withOpacity(0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: iconBg, size: 20),
          ),
          const SizedBox(height: 12),
          Text(label,
              style: TextStyle(
                  color: mutedColor,
                  fontSize: 11,
                  fontWeight: FontWeight.w600)),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              color: textColor,
              fontSize: 18,
              fontWeight: FontWeight.w900,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 2),
          Text(sub,
              style: TextStyle(color: mutedColor, fontSize: 10),
              maxLines: 1,
              overflow: TextOverflow.ellipsis),
        ],
      ),
    );
  }

  // ══════════════════════════════════════════
  // PENDING EVENTS SECTION
  // ══════════════════════════════════════════
  Widget _buildPendingSection(
      bool isDark, Color textColor, Color mutedColor) {
    final surfaceColor =
        isDark ? AppColors.surfaceDark : AppColors.surfaceLight;
    final borderColor = isDark ? AppColors.borderDark : AppColors.borderLight;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section Header
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: Colors.amber.withOpacity(0.12),
                borderRadius: BorderRadius.circular(8),
              ),
              child:
                  const Icon(Icons.pending_actions, color: Colors.amber, size: 18),
            ),
            const SizedBox(width: 10),
            Text(
              'Event Menunggu Persetujuan',
              style: TextStyle(
                color: textColor,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            if (_pendingEvents.isNotEmpty) ...[
              const SizedBox(width: 8),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.amber,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  '${_pendingEvents.length}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ],
        ),
        const SizedBox(height: 16),

        // Event List or Empty State
        if (_pendingEvents.isEmpty)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 40),
            decoration: BoxDecoration(
              color: surfaceColor,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: borderColor),
            ),
            child: Column(
              children: [
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: Colors.green.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.check_circle_outline,
                      color: Colors.green, size: 28),
                ),
                const SizedBox(height: 12),
                Text('Semua Beres!',
                    style: TextStyle(
                        color: textColor,
                        fontSize: 16,
                        fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                Text('Tidak ada event yang menunggu persetujuan.',
                    style: TextStyle(color: mutedColor, fontSize: 13)),
              ],
            ),
          )
        else
          ...List.generate(
            _pendingEvents.length,
            (i) => _buildPendingCard(
                _pendingEvents[i], isDark, textColor, mutedColor,
                surfaceColor: surfaceColor, borderColor: borderColor),
          ),
      ],
    );
  }

  Widget _buildPendingCard(
    Map<String, dynamic> event,
    bool isDark,
    Color textColor,
    Color mutedColor, {
    required Color surfaceColor,
    required Color borderColor,
  }) {
    final nama = (event['nama_event'] ?? 'Event').toString();
    final kategori = (event['kategori_event'] ?? '-').toString();
    final lokasi = (event['lokasi'] ?? '-').toString();
    final creatorName = (event['creator_name'] ?? '-').toString();
    final tanggal = (event['event_datetime'] ?? '').toString();
    final totalTickets = _toInt(event['total_tickets']);
    final totalCapacity = _toInt(event['total_capacity']);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: surfaceColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title + Category
          Row(
            children: [
              Expanded(
                child: Text(nama,
                    style: TextStyle(
                        color: textColor,
                        fontSize: 15,
                        fontWeight: FontWeight.bold),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(kategori,
                    style: TextStyle(
                        color: AppColors.primary,
                        fontSize: 10,
                        fontWeight: FontWeight.w600)),
              ),
            ],
          ),
          const SizedBox(height: 10),

          // Info rows
          _infoRow(Icons.person_outline, 'Creator: $creatorName', mutedColor),
          const SizedBox(height: 4),
          _infoRow(Icons.location_on_outlined, lokasi, mutedColor),
          const SizedBox(height: 4),
          _infoRow(Icons.calendar_today_outlined, _formatDate(tanggal),
              mutedColor),
          const SizedBox(height: 4),
          _infoRow(Icons.confirmation_number_outlined,
              '$totalTickets tiket • $totalCapacity kapasitas', mutedColor),
          const SizedBox(height: 14),

          // Action buttons
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => _showRejectDialog(event),
                  icon: const Icon(Icons.close, size: 16),
                  label:
                      const Text('Tolak', style: TextStyle(fontSize: 13)),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.red,
                    side: const BorderSide(color: Colors.red),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
                    padding: const EdgeInsets.symmetric(vertical: 10),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () => _handleApprove(event),
                  icon: const Icon(Icons.check, size: 16),
                  label: const Text('Setujui',
                      style: TextStyle(fontSize: 13)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    elevation: 0,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _infoRow(IconData icon, String text, Color color) {
    return Row(
      children: [
        Icon(icon, size: 14, color: color),
        const SizedBox(width: 6),
        Expanded(
          child: Text(text,
              style: TextStyle(color: color, fontSize: 12),
              maxLines: 1,
              overflow: TextOverflow.ellipsis),
        ),
      ],
    );
  }

  // ══════════════════════════════════════════
  // ACTIONS
  // ══════════════════════════════════════════
  Future<void> _handleApprove(Map<String, dynamic> event) async {
    final eventId = _toInt(event['id']);
    if (eventId <= 0) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Setujui Event'),
        content: Text(
            'Setujui "${event['nama_event']}" untuk dipublikasikan?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white),
            child: const Text('Setujui'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    final result = await AdminService.approveEvent(eventId);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(result['success']
            ? 'Event berhasil disetujui ✓'
            : result['message'] ?? 'Gagal menyetujui event'),
        backgroundColor: result['success'] ? Colors.green : Colors.red,
      ));
      if (result['success']) _loadData();
    }
  }

  void _showRejectDialog(Map<String, dynamic> event) {
    final alasanController = TextEditingController();
    final eventId = _toInt(event['id']);

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Tolak Event'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Tolak "${event['nama_event']}"?',
                style: const TextStyle(fontSize: 14)),
            const SizedBox(height: 12),
            TextField(
              controller: alasanController,
              maxLines: 3,
              decoration: InputDecoration(
                hintText: 'Alasan penolakan (opsional)...',
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10)),
                contentPadding: const EdgeInsets.all(12),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(ctx);
              final result = await AdminService.rejectEvent(
                  eventId, alasanController.text.trim());
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                  content: Text(result['success']
                      ? 'Event ditolak dan dikembalikan ke draft'
                      : result['message'] ?? 'Gagal menolak event'),
                  backgroundColor:
                      result['success'] ? Colors.orange : Colors.red,
                ));
                if (result['success']) _loadData();
              }
            },
            style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white),
            child: const Text('Tolak Event'),
          ),
        ],
      ),
    );
  }

  // ══════════════════════════════════════════
  // HELPERS
  // ══════════════════════════════════════════
  String _formatDate(String? dateStr) {
    if (dateStr == null || dateStr.isEmpty) return '-';
    try {
      final date = DateTime.parse(dateStr);
      return DateFormat('dd MMM yyyy, HH:mm', 'id_ID').format(date);
    } catch (_) {
      return dateStr;
    }
  }

  Widget _buildShimmer(bool isDark) {
    return Shimmer.fromColors(
      baseColor: isDark ? Colors.grey[800]! : Colors.grey[300]!,
      highlightColor: isDark ? Colors.grey[700]! : Colors.grey[100]!,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(child: _shimmerBox(120)),
                const SizedBox(width: 12),
                Expanded(child: _shimmerBox(120)),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(child: _shimmerBox(120)),
                const SizedBox(width: 12),
                Expanded(child: _shimmerBox(120)),
              ],
            ),
            const SizedBox(height: 24),
            _shimmerBox(200),
            const SizedBox(height: 12),
            _shimmerBox(200),
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
