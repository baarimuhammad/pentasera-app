import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shimmer/shimmer.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:intl/intl.dart';
import 'package:pentasera_app/main.dart';
import 'package:pentasera_app/services/event_service.dart';
import 'package:pentasera_app/services/auth_service.dart';
import 'package:pentasera_app/features/authentication/login/login_page.dart';
import 'package:pentasera_app/features/buyer/checkout/checkout_page.dart';

class DetailEventPage extends StatefulWidget {
  final dynamic eventId;
  const DetailEventPage({super.key, required this.eventId});

  @override
  State<DetailEventPage> createState() => _DetailEventPageState();
}

class _DetailEventPageState extends State<DetailEventPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  Map<String, dynamic>? _event;
  List<dynamic> _tickets = [];
  bool _isLoading = true;
  String? _error;

  // Quantity tracker per ticket
  final Map<dynamic, int> _quantities = {};

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    final eventResult = await EventService.getEventById(widget.eventId);
    if (eventResult['success']) {
      _event = eventResult['data'];
    } else {
      _error = eventResult['message'];
    }

    final ticketResult =
        await EventService.getTicketsByEvent(widget.eventId);
    if (ticketResult['success'] && ticketResult['data'] is List) {
      _tickets = ticketResult['data'];
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
    final surfaceColor =
        isDark ? AppColors.surfaceDark : AppColors.surfaceLight;

    if (_isLoading) return _buildLoadingSkeleton(isDark);
    if (_error != null) return _buildError();

    final event = _event!;
    final imageUrl = event['foto'] ?? event['image'] ?? event['gambar'] ?? '';
    final eventName = event['nama'] ?? event['name'] ?? 'Event';
    final tanggal = event['tanggal_mulai'] ?? event['tanggal'] ?? event['date'] ?? '';
    final lokasi = event['lokasi'] ?? event['location'] ?? '';
    final organizer = event['organizer']?['nama'] ?? event['organizer_name'] ?? '';
    final deskripsi = event['deskripsi'] ?? event['description'] ?? '';
    final kategori = event['kategori'] ?? event['category'] ?? '';
    final tanggalSelesai = event['tanggal_selesai'] ?? '';
    final kapasitas = event['kapasitas'] ?? event['capacity'] ?? '';

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // Hero Image
          SliverAppBar(
            expandedHeight: 280,
            pinned: true,
            backgroundColor: isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
            leading: IconButton(
              icon: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.3),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.arrow_back, color: Colors.white, size: 20),
              ),
              onPressed: () => Navigator.pop(context),
            ),
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: [
                  imageUrl.isNotEmpty
                      ? CachedNetworkImage(
                          imageUrl: imageUrl,
                          fit: BoxFit.cover,
                          placeholder: (_, __) => Container(
                            color: AppColors.primary.withOpacity(0.1),
                          ),
                          errorWidget: (_, __, ___) => Container(
                            color: AppColors.primary.withOpacity(0.1),
                            child: const Icon(Icons.image, size: 64, color: AppColors.primary),
                          ),
                        )
                      : Container(
                          color: AppColors.primary.withOpacity(0.1),
                          child: const Icon(Icons.event, size: 64, color: AppColors.primary),
                        ),
                  // Gradient overlay
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.bottomCenter,
                        end: Alignment.topCenter,
                        colors: [
                          (isDark ? AppColors.backgroundDark : AppColors.backgroundLight),
                          Colors.transparent,
                        ],
                        stops: const [0.0, 0.6],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Content
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Organizer badge
                  if (organizer.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        organizer.toUpperCase(),
                        style: const TextStyle(
                          color: AppColors.primary,
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 1,
                        ),
                      ),
                    ),
                  ],

                  const SizedBox(height: 12),

                  // Event name
                  Text(
                    eventName,
                    style: GoogleFonts.playfairDisplay(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: textColor,
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Date & Location
                  _buildInfoRow(
                    Icons.calendar_today_outlined,
                    'TANGGAL',
                    _formatDate(tanggal),
                    mutedColor,
                    textColor,
                  ),
                  const SizedBox(height: 12),
                  _buildInfoRow(
                    Icons.location_on_outlined,
                    'LOKASI',
                    lokasi,
                    mutedColor,
                    textColor,
                  ),

                  const SizedBox(height: 24),

                  // Tab Bar
                  Container(
                    decoration: BoxDecoration(
                      color: isDark
                          ? AppColors.primary.withOpacity(0.05)
                          : AppColors.primary.withOpacity(0.05),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: TabBar(
                      controller: _tabController,
                      labelColor: AppColors.primary,
                      unselectedLabelColor: mutedColor,
                      indicatorSize: TabBarIndicatorSize.tab,
                      indicator: BoxDecoration(
                        color: AppColors.primary.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      labelStyle: const TextStyle(
                          fontSize: 13, fontWeight: FontWeight.w600),
                      dividerColor: Colors.transparent,
                      tabs: const [
                        Tab(text: 'Deskripsi'),
                        Tab(text: 'Informasi'),
                        Tab(text: 'Pilih Tiket'),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Tab Content
          SliverFillRemaining(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: TabBarView(
                controller: _tabController,
                children: [
                  // Tab 1: Deskripsi
                  SingleChildScrollView(
                    padding: const EdgeInsets.only(top: 20, bottom: 100),
                    child: Text(
                      deskripsi.isNotEmpty
                          ? deskripsi
                          : 'Deskripsi belum tersedia untuk event ini.',
                      style: TextStyle(
                        color: textColor,
                        fontSize: 14,
                        height: 1.6,
                      ),
                    ),
                  ),

                  // Tab 2: Informasi Event
                  SingleChildScrollView(
                    padding: const EdgeInsets.only(top: 20, bottom: 100),
                    child: Column(
                      children: [
                        _buildDetailCard('Kategori', kategori, Icons.category, surfaceColor, textColor, mutedColor, isDark),
                        _buildDetailCard('Tanggal Mulai', _formatDate(tanggal), Icons.event, surfaceColor, textColor, mutedColor, isDark),
                        if (tanggalSelesai.isNotEmpty)
                          _buildDetailCard('Tanggal Selesai', _formatDate(tanggalSelesai), Icons.event_available, surfaceColor, textColor, mutedColor, isDark),
                        _buildDetailCard('Lokasi', lokasi, Icons.place, surfaceColor, textColor, mutedColor, isDark),
                        if (kapasitas.toString().isNotEmpty)
                          _buildDetailCard('Kapasitas', '$kapasitas orang', Icons.people, surfaceColor, textColor, mutedColor, isDark),
                        if (organizer.isNotEmpty)
                          _buildDetailCard('Penyelenggara', organizer, Icons.business, surfaceColor, textColor, mutedColor, isDark),
                      ],
                    ),
                  ),

                  // Tab 3: Pilih Tiket
                  _tickets.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.confirmation_number_outlined,
                                  size: 48, color: mutedColor),
                              const SizedBox(height: 12),
                              Text('Belum ada tiket tersedia',
                                  style: TextStyle(color: mutedColor)),
                            ],
                          ),
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.only(top: 16, bottom: 100),
                          itemCount: _tickets.length,
                          itemBuilder: (context, i) => _buildTicketCard(
                            _tickets[i],
                            surfaceColor,
                            textColor,
                            mutedColor,
                            isDark,
                          ),
                        ),
                ],
              ),
            ),
          ),
        ],
      ),

      // Bottom CTA
      bottomNavigationBar: _tickets.isNotEmpty
          ? Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: surfaceColor,
                border: Border(
                  top: BorderSide(
                      color: isDark
                          ? AppColors.borderDark
                          : AppColors.borderLight),
                ),
              ),
              child: SafeArea(
                child: SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    onPressed: () => _handleOrder(eventName),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                      elevation: 0,
                    ),
                    child: const Text(
                      'Pesan Sekarang',
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ),
            )
          : null,
    );
  }

  // ── Helpers ──

  Widget _buildInfoRow(IconData icon, String label, String value,
      Color mutedColor, Color textColor) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: AppColors.primary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: AppColors.primary, size: 20),
        ),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label,
                style: TextStyle(
                    color: mutedColor,
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.5)),
            const SizedBox(height: 2),
            Text(value,
                style: TextStyle(
                    color: textColor,
                    fontSize: 14,
                    fontWeight: FontWeight.w600)),
          ],
        ),
      ],
    );
  }

  Widget _buildDetailCard(String label, String value, IconData icon,
      Color surface, Color text, Color muted, bool isDark) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
            color: isDark ? AppColors.borderDark : AppColors.borderLight),
      ),
      child: Row(
        children: [
          Icon(icon, color: AppColors.primary, size: 22),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label,
                    style: TextStyle(
                        color: muted,
                        fontSize: 11,
                        fontWeight: FontWeight.w500)),
                const SizedBox(height: 4),
                Text(value.isNotEmpty ? value : '-',
                    style: TextStyle(
                        color: text,
                        fontSize: 14,
                        fontWeight: FontWeight.w600)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTicketCard(Map<String, dynamic> ticket, Color surface,
      Color text, Color muted, bool isDark) {
    final nama = ticket['nama'] ?? ticket['name'] ?? 'Tiket';
    final harga = ticket['harga'] ?? ticket['price'] ?? 0;
    final stok = ticket['stok'] ?? ticket['stock'] ?? 0;
    final desc = ticket['deskripsi'] ?? ticket['description'] ?? '';
    final id = ticket['id'];
    final qty = _quantities[id] ?? 0;
    final available = stok is int ? stok > 0 : true;

    final formatter = NumberFormat.currency(
        locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
            color: isDark ? AppColors.borderDark : AppColors.borderLight),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  nama,
                  style: GoogleFonts.playfairDisplay(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                  ),
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: available
                      ? Colors.green.withOpacity(0.1)
                      : Colors.red.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  available ? '$stok Sisa' : 'Habis',
                  style: TextStyle(
                    color: available ? Colors.green : Colors.red,
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          if (desc.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(desc, style: TextStyle(color: muted, fontSize: 13, height: 1.4)),
          ],
          const SizedBox(height: 12),
          Text('Harga mulai dari',
              style: TextStyle(color: muted, fontSize: 11)),
          const SizedBox(height: 4),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                formatter.format(harga is String ? int.tryParse(harga) ?? 0 : harga),
                style: TextStyle(
                  color: text,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              // Qty selector
              if (available)
                Row(
                  children: [
                    _qtyButton(Icons.remove, () {
                      if (qty > 0) {
                        setState(() => _quantities[id] = qty - 1);
                      }
                    }),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      child: Text('$qty',
                          style: TextStyle(
                              color: text,
                              fontSize: 16,
                              fontWeight: FontWeight.bold)),
                    ),
                    _qtyButton(Icons.add, () {
                      setState(() => _quantities[id] = qty + 1);
                    }),
                  ],
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _qtyButton(IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: AppColors.primary.withOpacity(0.1),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: AppColors.primary, size: 20),
      ),
    );
  }

  Future<void> _handleOrder(String eventName) async {
    // Find selected ticket
    final selectedEntry = _quantities.entries.where((e) => e.value > 0);
    if (selectedEntry.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Pilih minimal 1 tiket terlebih dahulu'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Check login
    final loggedIn = await AuthService.isLoggedIn();
    if (!loggedIn) {
      if (mounted) {
        Navigator.push(
            context, MaterialPageRoute(builder: (_) => const LoginPage()));
      }
      return;
    }

    // Navigate to checkout with first selected ticket
    final entry = selectedEntry.first;
    final ticket = _tickets.firstWhere((t) => t['id'] == entry.key);
    final price = ticket['harga'] ?? ticket['price'] ?? 0;

    if (mounted) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => CheckoutPage(
            eventId: widget.eventId,
            ticketId: entry.key,
            ticketName: ticket['nama'] ?? ticket['name'] ?? 'Tiket',
            price: price is String ? int.tryParse(price) ?? 0 : price,
            qty: entry.value,
            eventName: eventName,
          ),
        ),
      );
    }
  }

  String _formatDate(String? dateStr) {
    if (dateStr == null || dateStr.isEmpty) return '-';
    try {
      final date = DateTime.parse(dateStr);
      return DateFormat('dd MMM yyyy', 'id_ID').format(date);
    } catch (_) {
      return dateStr;
    }
  }

  Scaffold _buildLoadingSkeleton(bool isDark) {
    final baseColor =
        isDark ? Colors.grey[800]! : Colors.grey[300]!;
    final highlightColor =
        isDark ? Colors.grey[700]! : Colors.grey[100]!;

    return Scaffold(
      body: Shimmer.fromColors(
        baseColor: baseColor,
        highlightColor: highlightColor,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(height: 280, color: Colors.white),
              Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                        height: 20,
                        width: 120,
                        decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(8))),
                    const SizedBox(height: 12),
                    Container(
                        height: 32,
                        width: 250,
                        decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(8))),
                    const SizedBox(height: 16),
                    Container(
                        height: 16,
                        width: 200,
                        decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(8))),
                    const SizedBox(height: 8),
                    Container(
                        height: 16,
                        width: 180,
                        decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(8))),
                    const SizedBox(height: 24),
                    Container(
                        height: 44,
                        decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12))),
                    const SizedBox(height: 24),
                    Container(
                        height: 120,
                        decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16))),
                    const SizedBox(height: 16),
                    Container(
                        height: 120,
                        decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16))),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Scaffold _buildError() {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, size: 48, color: Colors.red),
            const SizedBox(height: 16),
            Text(_error ?? 'Terjadi kesalahan',
                style: TextStyle(
                    color: Theme.of(context).colorScheme.onSurface)),
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
      ),
    );
  }
}
