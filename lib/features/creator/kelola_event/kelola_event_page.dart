import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shimmer/shimmer.dart';
import 'package:pentasera_app/main.dart';
import 'package:pentasera_app/services/event_service.dart';
import 'tab_informasi_event.dart';
import 'tab_tiket_harga.dart';
import 'tab_laporan_penjualan.dart';

class KelolaEventPage extends StatefulWidget {
  final int eventId;
  const KelolaEventPage({super.key, required this.eventId});

  @override
  State<KelolaEventPage> createState() => _KelolaEventPageState();
}

class _KelolaEventPageState extends State<KelolaEventPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  bool _isLoading = true;
  bool _isSaving = false;
  String? _error;

  Map<String, dynamic> _eventData = {};
  Map<String, dynamic> _stats = {};
  Map<String, dynamic> _reportData = {};
  List<Map<String, dynamic>> _tickets = [];

  // Form controllers
  final _namaController = TextEditingController();
  final _lokasiController = TextEditingController();
  final _deskripsiController = TextEditingController();
  final ValueNotifier<String> _kategoriNotifier =
      ValueNotifier('Lainnya');
  final ValueNotifier<DateTime?> _datetimeNotifier = ValueNotifier(null);
  final ValueNotifier<String?> _imagePathNotifier = ValueNotifier(null);

  final _currencyFormatter =
      NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _namaController.dispose();
    _lokasiController.dispose();
    _deskripsiController.dispose();
    _kategoriNotifier.dispose();
    _datetimeNotifier.dispose();
    _imagePathNotifier.dispose();
    super.dispose();
  }

  int _parseNum(dynamic v) {
    if (v == null) return 0;
    if (v is int) return v;
    if (v is double) return v.toInt();
    return int.tryParse(v.toString().replaceAll(RegExp(r'[^0-9]'), '')) ?? 0;
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      // Parallel fetch
      final results = await Future.wait([
        EventService.getEventById(widget.eventId),
        EventService.getEventStats(widget.eventId),
        EventService.getEventReport(widget.eventId),
      ]);

      final eventResult = results[0];
      final statsResult = results[1];
      final reportResult = results[2];

      if (eventResult['success'] == true) {
        _eventData = Map<String, dynamic>.from(eventResult['data'] ?? {});

        // Parse tickets from event data
        final ticketsList = _eventData['tickets'];
        if (ticketsList is List) {
          _tickets = ticketsList
              .whereType<Map>()
              .map((t) => Map<String, dynamic>.from(t))
              .toList();
        }

        // Populate form controllers
        _namaController.text =
            (_eventData['nama_event'] ?? '').toString();
        _lokasiController.text =
            (_eventData['lokasi'] ?? '').toString();
        _deskripsiController.text =
            (_eventData['deskripsi'] ?? '').toString();
        _kategoriNotifier.value =
            (_eventData['kategori_event'] ?? 'Lainnya').toString();

        final dtStr = (_eventData['event_datetime'] ?? '').toString();
        if (dtStr.isNotEmpty) {
          try {
            _datetimeNotifier.value = DateTime.parse(dtStr);
          } catch (_) {}
        }
      } else {
        _error = eventResult['message'] ?? 'Gagal memuat event';
      }

      if (statsResult['success'] == true) {
        _stats = Map<String, dynamic>.from(statsResult['data'] ?? {});
      }

      if (reportResult['success'] == true) {
        _reportData = Map<String, dynamic>.from(reportResult['data'] ?? {});
      }
    } catch (e) {
      _error = 'Terjadi kesalahan: $e';
    }

    if (mounted) setState(() => _isLoading = false);
  }

  Future<void> _reloadTickets() async {
    final result = await EventService.getEventById(widget.eventId);
    if (result['success'] == true && mounted) {
      final data = Map<String, dynamic>.from(result['data'] ?? {});
      final ticketsList = data['tickets'];
      if (ticketsList is List) {
        setState(() {
          _tickets = ticketsList
              .whereType<Map>()
              .map((t) => Map<String, dynamic>.from(t))
              .toList();
          _eventData = data;
        });
      }
    }

    // Also refresh stats
    final statsResult = await EventService.getEventStats(widget.eventId);
    if (statsResult['success'] == true && mounted) {
      setState(() {
        _stats = Map<String, dynamic>.from(statsResult['data'] ?? {});
      });
    }
  }

  Future<void> _saveChanges() async {
    final nama = _namaController.text.trim();
    final lokasi = _lokasiController.text.trim();
    final deskripsi = _deskripsiController.text.trim();
    final kategori = _kategoriNotifier.value;
    final datetime = _datetimeNotifier.value;
    final imagePath = _imagePathNotifier.value;

    if (nama.isEmpty || lokasi.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Judul event dan lokasi wajib diisi'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() => _isSaving = true);

    final dtStr = datetime != null
        ? '${datetime.year}-${datetime.month.toString().padLeft(2, '0')}-${datetime.day.toString().padLeft(2, '0')} ${datetime.hour.toString().padLeft(2, '0')}:${datetime.minute.toString().padLeft(2, '0')}:00'
        : (_eventData['event_datetime'] ?? '').toString();

    final result = await EventService.updateEventWithImage(
      eventId: widget.eventId,
      namaEvent: nama,
      lokasi: lokasi,
      eventDatetime: dtStr,
      deskripsi: deskripsi,
      kategoriEvent: kategori,
      imagePath: imagePath,
    );

    if (!mounted) return;
    setState(() => _isSaving = false);

    if (result['success'] == true) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Perubahan event berhasil disimpan!'),
          backgroundColor: Colors.green,
        ),
      );
      // Update local data if banner changed
      if (result['data'] is Map) {
        final updated = Map<String, dynamic>.from(result['data']);
        if (updated['image_src'] != null) {
          setState(() {
            _eventData['image_src'] = updated['image_src'];
            _imagePathNotifier.value = null;
          });
        }
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result['message'] ?? 'Gagal menyimpan perubahan'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  // ── Status helpers ──
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
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: textColor),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Kelola Event',
          style: TextStyle(
            color: textColor,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
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
              : _buildContent(isDark, textColor, mutedColor, surfaceColor,
                  borderColor),
    );
  }

  Widget _buildContent(bool isDark, Color textColor, Color mutedColor,
      Color surfaceColor, Color borderColor) {
    final eventStatus =
        (_eventData['event_status'] ?? 'draft').toString();
    final eventName = (_eventData['nama_event'] ?? 'Event').toString();
    final eventLokasi = (_eventData['lokasi'] ?? '-').toString();
    final eventId = _parseNum(_eventData['id']);

    final sold = _parseNum(_stats['sold']);
    final capacity = _parseNum(_stats['capacity']);
    final revenue = _parseNum(_stats['revenue']);
    final occupancy = _parseNum(_stats['occupancy']);
    final txCount = _parseNum(_stats['total_transactions'] ??
        _stats['transactions_count']);

    return Column(
      children: [
        // ── Event Header ──
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Status & ID
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 3),
                    decoration: BoxDecoration(
                      color: _statusColor(eventStatus).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      _statusLabel(eventStatus),
                      style: TextStyle(
                        color: _statusColor(eventStatus),
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    'ID: #EVT-${eventId.toString().padLeft(3, '0')}',
                    style: TextStyle(
                      color: mutedColor,
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),

              // Event name
              Text(
                eventName,
                style: TextStyle(
                  color: textColor,
                  fontSize: 22,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 4),

              // Location
              Row(
                children: [
                  Icon(Icons.location_on_outlined,
                      size: 14, color: mutedColor),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      eventLokasi,
                      style: TextStyle(color: mutedColor, fontSize: 13),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // ── Quick Stats (3-kolom grid) ──
              Row(
                children: [
                  Expanded(
                    child: _buildStatCard(
                      Icons.confirmation_number_outlined,
                      'Tiket Terjual',
                      '$sold/$capacity',
                      '$occupancy% Terisi',
                      surfaceColor,
                      borderColor,
                      textColor,
                      mutedColor,
                      isDark,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: _buildStatCard(
                      Icons.trending_up,
                      'Total Penjualan',
                      _currencyFormatter.format(revenue),
                      'IDR',
                      surfaceColor,
                      borderColor,
                      textColor,
                      mutedColor,
                      isDark,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: _buildStatCard(
                      Icons.shopping_cart_outlined,
                      'Total Transaksi',
                      '$txCount',
                      'Transaksi',
                      surfaceColor,
                      borderColor,
                      textColor,
                      mutedColor,
                      isDark,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),

        // ── Tabs ──
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
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
                fontSize: 11,
                fontWeight: FontWeight.w700,
              ),
              unselectedLabelStyle: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
              ),
              dividerColor: Colors.transparent,
              tabs: const [
                Tab(text: 'Info'),
                Tab(text: 'Tiket'),
                Tab(text: 'Laporan'),
              ],
            ),
          ),
        ),

        // ── Tab Content ──
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: [
              TabInformasiEvent(
                eventData: _eventData,
                namaController: _namaController,
                lokasiController: _lokasiController,
                deskripsiController: _deskripsiController,
                kategoriNotifier: _kategoriNotifier,
                datetimeNotifier: _datetimeNotifier,
                imagePathNotifier: _imagePathNotifier,
                bannerUrl: (_eventData['image_src'] ?? '').toString(),
              ),
              TabTiketHarga(
                eventId: widget.eventId,
                tickets: _tickets,
                onTicketsChanged: _reloadTickets,
              ),
              TabLaporanPenjualan(
                stats: _stats,
                reportData: _reportData,
                tickets: _tickets,
              ),
            ],
          ),
        ),
      ],
    );

  }

  Widget _buildStatCard(
    IconData icon,
    String label,
    String value,
    String unit,
    Color surfaceColor,
    Color borderColor,
    Color textColor,
    Color mutedColor,
    bool isDark,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
      decoration: BoxDecoration(
        color: surfaceColor,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Icon(icon, size: 13, color: AppColors.primary),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  label,
                  style: TextStyle(
                    color: mutedColor,
                    fontSize: 9,
                    fontWeight: FontWeight.w700,
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

  // ── Save FAB ──
  Widget _buildSaveFab(bool isDark) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: SizedBox(
        width: double.infinity,
        height: 52,
        child: ElevatedButton.icon(
          onPressed: _isSaving ? null : _saveChanges,
          icon: _isSaving
              ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                )
              : const Icon(Icons.save_outlined, size: 18),
          label: Text(
            _isSaving ? 'Menyimpan...' : 'Simpan Perubahan',
            style: const TextStyle(
              fontWeight: FontWeight.w800,
              fontSize: 14,
            ),
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
            elevation: 6,
            shadowColor: AppColors.primary.withOpacity(0.4),
          ),
        ),
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
            Container(
              width: 100,
              height: 24,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            const SizedBox(height: 12),
            Container(
              width: double.infinity,
              height: 28,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            const SizedBox(height: 8),
            Container(
              width: 200,
              height: 16,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              height: 90,
              child: Row(
                children: List.generate(
                  3,
                  (_) => Expanded(
                    child: Container(
                      margin: const EdgeInsets.only(right: 10),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),
            Container(
              width: double.infinity,
              height: 48,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            const SizedBox(height: 24),
            Container(
              width: double.infinity,
              height: 300,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
              ),
            ),
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
          Text(_error!, style: TextStyle(color: mutedColor)),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: _loadData,
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
