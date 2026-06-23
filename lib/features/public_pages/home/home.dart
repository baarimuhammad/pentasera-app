import 'package:flutter/material.dart';
import 'dart:ui';
import 'package:intl/intl.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:pentasera_app/main.dart';
import 'package:pentasera_app/features/public_pages/detail_event/detail_event_page.dart';
import 'package:pentasera_app/features/public_pages/tentang_kami/tentang_kami_page.dart';
import 'package:pentasera_app/features/public_pages/kontak/kontak_page.dart';
import 'package:pentasera_app/features/public_pages/legal/legal_page.dart';
import 'package:pentasera_app/services/event_service.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<Map<String, dynamic>> _events = [];
  bool _isLoading = true;
  String? _selectedCategory;
  final _searchController = TextEditingController();
  String _searchQuery = '';

  List<Map<String, dynamic>>
   _getFilteredEvents() {
    return _events.where((event) {
      // 1. Filter berdasarkan Kategori Budaya (jika terpilih)
      final matchesCategory = _selectedCategory == null || 
          event['kategori_event'] == _selectedCategory;
      // 2. Filter berdasarkan Search Bar query
      final name = (event['nama_event'] ?? '').toString().toLowerCase();
      final location = (event['lokasi'] ?? '').toString().toLowerCase();
      final desc = (event['deskripsi'] ?? '').toString().toLowerCase();
      final matchesSearch = _searchQuery.isEmpty || 
          name.contains(_searchQuery) || 
          location.contains(_searchQuery) ||
          desc.contains(_searchQuery);
      return matchesCategory && matchesSearch;
    }).toList();
  }


  @override
  void initState() {
    super.initState();
    _loadEvents();
  }

  Future<void> _loadEvents() async {
    setState(() => _isLoading = true);
    final result = await EventService.getEvents();
    if (result['success'] == true) {
      final allEvents = (result['data'] as List?)
              ?.whereType<Map>()
              .map((e) => Map<String, dynamic>.from(e))
              .toList() ??
          [];
      debugPrint('[HomePage] Total events from API: ${allEvents.length}');
      for (final e in allEvents) {
        debugPrint('[HomePage] event: ${e['nama_event']} | event_status=${e['event_status']} | status=${e['status']}');
      }
      _events = allEvents
          .where((e) {
            final s = (e['event_status'] ?? e['status'] ?? '').toString().toLowerCase();
            return s == 'published';
          })
          .toList();
      debugPrint('[HomePage] Published events: ${_events.length}');
    }
    if (mounted) setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? AppColors.slate100 : AppColors.slate900;

    return Scaffold(
      appBar: _buildAppBar(textColor),
      body: RefreshIndicator(
        color: AppColors.primary,
        onRefresh: _loadEvents,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Padding(
            padding: const EdgeInsets.only(bottom: 24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildSearchBar(isDark),
                _buildHeroBanner(isDark),
                _buildCategories(textColor, isDark),
                _buildEventTerdekat(textColor, isDark),
                _buildTopEvent(textColor, isDark),
                const SizedBox(height: 32),
                _buildFooterLinks(context, textColor, isDark),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFooterLinks(BuildContext context, Color textColor, bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      decoration: BoxDecoration(
        color: isDark ? AppColors.primary.withOpacity(0.05) : Colors.white,
        border: Border(top: BorderSide(color: AppColors.primary.withOpacity(0.1))),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              TextButton(
                onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const TentangKamiPage())),
                child: Text('Tentang Kami', style: TextStyle(color: textColor)),
              ),
              TextButton(
                onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const KontakPage())),
                child: Text('Kontak', style: TextStyle(color: textColor)),
              ),
              TextButton(
                onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const LegalPage(type: 'syarat'))),
                child: Text('Legal', style: TextStyle(color: textColor)),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            '© 2024 Pentasera. All rights reserved.',
            style: TextStyle(color: isDark ? AppColors.slate400 : AppColors.slate600, fontSize: 12),
          ),
        ],
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(Color textColor) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      flexibleSpace: ClipRect(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10.0, sigmaY: 10.0),
          child: Container(
            decoration: BoxDecoration(
              color: Theme.of(context).scaffoldBackgroundColor.withOpacity(0.8),
              border: Border(bottom: BorderSide(color: AppColors.primary.withOpacity(0.1))),
            ),
          ),
        ),
      ),

      title: RichText(
        text: const TextSpan(
          style: TextStyle(color: AppColors.primary, fontSize: 24, fontWeight: FontWeight.bold, letterSpacing: -0.5),
          children: [
            TextSpan(text: 'Pentase'),
            TextSpan(text: 'ra', style: TextStyle(fontSize: 24, letterSpacing: -1.0)),
          ],
        ),
      ),
      centerTitle: true,
      actions: [
        IconButton(
          icon: Icon(isDark ? Icons.light_mode : Icons.dark_mode, color: AppColors.primary),
          onPressed: () => themeNotifier.value = isDark ? ThemeMode.light : ThemeMode.dark,
        ),
      ],
    );
  }

   Widget _buildSearchBar(bool isDark) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: TextField(
        controller: _searchController, // Hubungkan controller
        onChanged: (value) {
          setState(() {
            _searchQuery = value.toLowerCase(); // Simpan input query pencarian
          });
        },
        style: TextStyle(color: isDark ? AppColors.slate100 : AppColors.slate900),
        decoration: InputDecoration(
          hintText: 'Cari event...',
          hintStyle: TextStyle(color: AppColors.primary.withOpacity(0.5), fontSize: 14),
          prefixIcon: const Icon(Icons.search, color: AppColors.primary),
          // Tambahkan tombol silang (clear) jika sedang mengetik sesuatu
          suffixIcon: _searchQuery.isNotEmpty 
              ? IconButton(
                  icon: const Icon(Icons.clear, color: AppColors.primary),
                  onPressed: () {
                    _searchController.clear();
                    setState(() {
                      _searchQuery = '';
                    });
                  },
                )
              : null,
          filled: true,
          fillColor: AppColors.primary.withOpacity(0.05),
          contentPadding: const EdgeInsets.symmetric(vertical: 16),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: AppColors.primary.withOpacity(0.2))),
          enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: AppColors.primary.withOpacity(0.2))),
          focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.primary, width: 1)),
        ),
      ),
    );
  }


  Widget _buildHeroBanner(bool isDark) {
    if (_isLoading) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
        child: Container(
          height: 220,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            color: AppColors.primary.withOpacity(0.1),
          ),
          child: const Center(child: CircularProgressIndicator(color: AppColors.primary)),
        ),
      );
    }

    final featured = _events.isNotEmpty ? _events.first : null;
    final imageUrl = (featured?['image_src'] ?? '').toString();
    final title = (featured?['nama_event'] ?? 'Jelajahi Event Budaya').toString();
    final desc = (featured?['deskripsi'] ?? 'Saksikan keindahan seni budaya nusantara').toString();
    final eventId = featured?['id'];

    final featuredImageUrl = imageUrl.isNotEmpty
        ? imageUrl
        : 'https://images.unsplash.com/photo-1514525253161-7a46d19cd819?q=80&w=1000&auto=format&fit=crop';

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Container(
        height: 220,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          boxShadow: [BoxShadow(color: AppColors.primary.withOpacity(0.1), blurRadius: 10, offset: const Offset(0, 4))],
          color: AppColors.primary.withOpacity(0.1),
          image: DecorationImage(
            image: CachedNetworkImageProvider(featuredImageUrl),
            fit: BoxFit.cover,
          ),
        ),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            gradient: LinearGradient(
              begin: Alignment.bottomCenter,
              end: Alignment.topCenter,
              colors: [const Color(0xFF221910).withOpacity(0.9), const Color(0xFF221910).withOpacity(0.2), Colors.transparent],
              stops: const [0.0, 0.6, 1.0],
            ),
          ),
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(color: AppColors.primary, borderRadius: BorderRadius.circular(20)),
                child: const Text('FEATURED EVENT', style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1)),
              ),
              const SizedBox(height: 8),
              Text(title, style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold), maxLines: 1, overflow: TextOverflow.ellipsis),
              const SizedBox(height: 4),
              Text(desc, style: TextStyle(color: Colors.white.withOpacity(0.8), fontSize: 12, fontWeight: FontWeight.w500), maxLines: 2, overflow: TextOverflow.ellipsis),
              const SizedBox(height: 16),
              if (eventId != null)
                ElevatedButton(
                  onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => DetailEventPage(eventId: eventId))),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  ),
                  child: const Text('Beli Tiket', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                ),
            ],
          ),
        ),
      ),
    );
  }

    Widget _buildCategories(Color textColor, bool isDark) {
    final categories = [
      {'icon': Icons.theater_comedy, 'name': 'Seni Pertunjukan'},
      {'icon': Icons.festival, 'name': 'Festival Budaya'},
      {'icon': Icons.palette, 'name': 'Pameran Seni'},
      {'icon': Icons.school, 'name': 'Workshop'},
    ];
    
    return Padding(
      padding: const EdgeInsets.only(top: 32.0, left: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Kategori Budaya', style: TextStyle(color: textColor, fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: categories.map((cat) {
                final isSelected = _selectedCategory == cat['name'];
                return Padding(
                  padding: const EdgeInsets.only(right: 16.0),
                  child: GestureDetector(
                    onTap: () {
                      setState(() {
                        // Toggle: jika kategori yang sama diklik lagi, batalkan filter
                        _selectedCategory = isSelected ? null : cat['name'] as String;
                      });
                    },
                    child: Column(children: [
                      Container(
                        width: 64, height: 64,
                        decoration: BoxDecoration(
                          // Highlight warna jika kategori sedang terpilih
                          color: isSelected 
                              ? AppColors.primary 
                              : AppColors.primary.withOpacity(0.1), 
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Icon(
                          cat['icon'] as IconData, 
                          color: isSelected ? Colors.white : AppColors.primary, 
                          size: 32,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        cat['name'] as String, 
                        style: TextStyle(
                          fontSize: 12, 
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.w600, 
                          color: isSelected ? AppColors.primary : (isDark ? AppColors.slate400 : AppColors.slate600),
                        ),
                      ),
                    ]),
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }


  Widget _buildEventTerdekat(Color textColor, bool isDark) {
    // Sort by event_datetime ascending (upcoming first)
    final upcoming = _getFilteredEvents();
    upcoming.sort((a, b) {
      final da = DateTime.tryParse((a['event_datetime'] ?? '').toString()) ?? DateTime(2099);
      final db = DateTime.tryParse((b['event_datetime'] ?? '').toString()) ?? DateTime(2099);
      return da.compareTo(db);
    });
    final displayEvents = upcoming.take(5).toList();

    return Padding(
      padding: const EdgeInsets.only(top: 32.0, left: 16.0),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0, bottom: 16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Event Terdekat', style: TextStyle(color: textColor, fontSize: 18, fontWeight: FontWeight.bold)),
                const Text('Lihat Semua', style: TextStyle(color: AppColors.primary, fontSize: 14, fontWeight: FontWeight.bold)),
              ],
            ),
          ),
          if (_isLoading)
            const Padding(padding: EdgeInsets.all(32), child: CircularProgressIndicator(color: AppColors.primary))
          else if (displayEvents.isEmpty)
            Padding(
              padding: const EdgeInsets.all(32),
              child: Text('Belum ada event', style: TextStyle(color: isDark ? AppColors.slate400 : AppColors.slate600)),
            )
          else
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: displayEvents.map((event) => _buildEventCard(event, isDark, textColor)).toList(),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildEventCard(Map<String, dynamic> event, bool isDark, Color textColor) {
    final imageUrl = (event['image_src'] ?? '').toString();
    final title = (event['nama_event'] ?? 'Event').toString();
    final lokasi = (event['lokasi'] ?? '').toString();
    final kategori = (event['kategori_event'] ?? '').toString().toUpperCase();
    final eventId = event['id'];
    final tanggal = (event['event_datetime'] ?? '').toString();
    String dateLabel = '';
    try {
      final dt = DateTime.parse(tanggal);
      dateLabel = DateFormat('dd MMM').format(dt).toUpperCase();
    } catch (_) {}

    return GestureDetector(
      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => DetailEventPage(eventId: eventId))),
      child: Container(
        width: 240,
        margin: const EdgeInsets.only(right: 16.0, bottom: 8.0),
        decoration: BoxDecoration(
          color: isDark ? AppColors.primary.withOpacity(0.05) : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.primary.withOpacity(0.05)),
          boxShadow: isDark ? [] : [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 4, offset: const Offset(0, 2))],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: 128,
              decoration: BoxDecoration(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                color: AppColors.primary.withOpacity(0.1),
                image: imageUrl.isNotEmpty ? DecorationImage(image: CachedNetworkImageProvider(imageUrl), fit: BoxFit.cover) : null,
              ),
              alignment: Alignment.topRight,
              padding: const EdgeInsets.all(8),
              child: dateLabel.isNotEmpty
                  ? Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: isDark ? AppColors.backgroundDark.withOpacity(0.9) : Colors.white.withOpacity(0.9),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(dateLabel, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppColors.primary)),
                    )
                  : null,
            ),
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (kategori.isNotEmpty)
                    Text(kategori, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.primary)),
                  const SizedBox(height: 4),
                  Text(title, style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: textColor), maxLines: 1, overflow: TextOverflow.ellipsis),
                  const SizedBox(height: 8),
                  Row(children: [
                    Icon(Icons.location_on, size: 14, color: isDark ? AppColors.slate400 : AppColors.slate600),
                    const SizedBox(width: 4),
                    Expanded(child: Text(lokasi, style: TextStyle(fontSize: 12, color: isDark ? AppColors.slate400 : AppColors.slate600), maxLines: 1, overflow: TextOverflow.ellipsis)),
                  ]),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTopEvent(Color textColor, bool isDark) {
    final topEvents = _getFilteredEvents().take(3).toList();
    if (topEvents.isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 32.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Top Event', style: TextStyle(color: textColor, fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          ...topEvents.asMap().entries.map((entry) {
            final idx = entry.key;
            final event = entry.value;
            final rank = '0${idx + 1}';
            final imageUrl = (event['image_src'] ?? '').toString();
            final title = (event['nama_event'] ?? 'Event').toString();
            final lokasi = (event['lokasi'] ?? '').toString();
            final eventId = event['id'];
            return Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: GestureDetector(
                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => DetailEventPage(eventId: eventId))),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.primary.withOpacity(0.1)),
                  ),
                  child: Row(children: [
                    Text(rank, style: TextStyle(fontSize: 32, fontStyle: FontStyle.italic, fontWeight: FontWeight.w900, color: AppColors.primary.withOpacity(0.3))),
                    const SizedBox(width: 16),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: imageUrl.isNotEmpty
                          ? CachedNetworkImage(imageUrl: imageUrl, width: 64, height: 64, fit: BoxFit.cover, errorWidget: (_, __, ___) => _placeholderBox())
                          : _placeholderBox(),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        Text(title, style: TextStyle(fontWeight: FontWeight.bold, color: textColor, fontSize: 14), maxLines: 1, overflow: TextOverflow.ellipsis),
                        const SizedBox(height: 4),
                        Row(children: [
                          Icon(Icons.location_on, size: 14, color: isDark ? AppColors.slate400 : AppColors.slate600),
                          const SizedBox(width: 4),
                          Expanded(child: Text(lokasi, style: TextStyle(fontSize: 12, color: isDark ? AppColors.slate400 : AppColors.slate600), maxLines: 1, overflow: TextOverflow.ellipsis)),
                        ]),
                      ]),
                    ),
                    const Icon(Icons.arrow_forward_ios, color: AppColors.primary, size: 16),
                  ]),
                ),
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _placeholderBox() {
    return Container(width: 64, height: 64, decoration: BoxDecoration(color: AppColors.primary.withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
      child: const Icon(Icons.event, color: AppColors.primary, size: 28));
  }
}
