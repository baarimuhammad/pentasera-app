import 'package:flutter/material.dart';
import 'dart:ui';
import 'package:pentasera_app/main.dart';
import 'package:pentasera_app/features/public_pages/detail_event/detail_event_page.dart';
import 'package:pentasera_app/features/public_pages/tentang_kami/tentang_kami_page.dart';
import 'package:pentasera_app/features/public_pages/kontak/kontak_page.dart';
import 'package:pentasera_app/features/public_pages/legal/legal_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? AppColors.slate100 : AppColors.slate900;

    return Scaffold(
      appBar: _buildAppBar(textColor),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.only(bottom: 24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSearchBar(isDark),
              _buildHeroBanner(),
              _buildCategories(textColor, isDark),
              _buildEventTerdekat(textColor, isDark),
              _buildTopEvent(textColor, isDark),
              _buildEventBerakhir(textColor),
              const SizedBox(height: 32),
              _buildFooterLinks(context, textColor, isDark),
            ],
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

 // Pastikan kamu meng-import main.dart di bagian atas file untuk memanggil themeNotifier
// import '../../../main.dart'; // Sesuaikan path ini dengan struktur foldermu

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
    leading: Padding(
      padding: const EdgeInsets.all(8.0),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.primary.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: const Icon(Icons.menu, color: AppColors.primary),
      ),
    ),
    title: RichText(
      text: const TextSpan(
        style: TextStyle(
          color: AppColors.primary,
          fontSize: 24,
          fontWeight: FontWeight.bold,
          letterSpacing: -0.5,
        ),
        children: [
          TextSpan(text: 'Pentase'),
          TextSpan(
            text: 'ra',
            style: TextStyle(fontSize: 24, letterSpacing: -1.0),
          ),
        ],
      ),
    ),
    centerTitle: true,
    actions: [
      // TOMBOL SWITCH THEME BARU
      IconButton(
        icon: Icon(
          isDark ? Icons.light_mode : Icons.dark_mode, // Ikon berubah sesuai tema
          color: AppColors.primary,
        ),
        onPressed: () {
          // Logika untuk menukar tema
          themeNotifier.value = isDark ? ThemeMode.light : ThemeMode.dark;
        },
      ),
      Padding(
        padding: const EdgeInsets.all(8.0),
        child: Container(
          width: 40,
          decoration: BoxDecoration(
            color: AppColors.primary.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.account_circle, color: AppColors.primary),
        ),
      ),
    ],
  );
}
  Widget _buildSearchBar(bool isDark) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: TextField(
        style:
            TextStyle(color: isDark ? AppColors.slate100 : AppColors.slate900),
        decoration: InputDecoration(
          hintText: 'Cari tari, wayang, atau teater...',
          hintStyle: TextStyle(
              color: AppColors.primary.withOpacity(0.5), fontSize: 14),
          prefixIcon: const Icon(Icons.search, color: AppColors.primary),
          suffixIcon:
              Icon(Icons.tune, color: AppColors.primary.withOpacity(0.6)),
          filled: true,
          fillColor: AppColors.primary.withOpacity(0.05),
          contentPadding: const EdgeInsets.symmetric(vertical: 16),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: AppColors.primary.withOpacity(0.2)),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: AppColors.primary.withOpacity(0.2)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: AppColors.primary, width: 1),
          ),
        ),
      ),
    );
  }

  Widget _buildHeroBanner() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Container(
        height: 220,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
          image: const DecorationImage(
            image: NetworkImage(
                "https://picsum.photos/seed/dance/600/400"), // Replaced with reliable placeholder
            fit: BoxFit.cover,
          ),
        ),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            gradient: LinearGradient(
              begin: Alignment.bottomCenter,
              end: Alignment.topCenter,
              colors: [
                const Color(0xFF221910).withOpacity(0.9),
                const Color(0xFF221910).withOpacity(0.2),
                Colors.transparent,
              ],
              stops: const [0.0, 0.6, 1.0],
            ),
          ),
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Text(
                  'FEATURED EVENT',
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1),
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Experience the Magic',
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 4),
              Text(
                'Saksikan keindahan tari tradisional langsung di Jakarta Art Center',
                style: TextStyle(
                    color: Colors.white.withOpacity(0.8),
                    fontSize: 12,
                    fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  Navigator.push(context, MaterialPageRoute(builder: (_) => const DetailEventPage(eventId: 1)));
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8)),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                ),
                child: const Text('Beli Tiket',
                    style:
                        TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCategories(Color textColor, bool isDark) {
    final categories = [
      {'icon': Icons.festival, 'name': 'Tari'},
      {'icon': Icons.theater_comedy, 'name': 'Wayang'},
      {'icon': Icons.masks, 'name': 'Teater'},
      {'icon': Icons.music_note, 'name': 'Musik'},
      {'icon': Icons.palette, 'name': 'Pameran'},
    ];

    return Padding(
      padding: const EdgeInsets.only(top: 32.0, left: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Kategori Budaya',
              style: TextStyle(
                  color: textColor, fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: categories.map((cat) {
                return Padding(
                  padding: const EdgeInsets.only(right: 16.0),
                  child: Column(
                    children: [
                      Container(
                        width: 64,
                        height: 64,
                        decoration: BoxDecoration(
                          color: AppColors.primary.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Icon(cat['icon'] as IconData,
                            color: AppColors.primary, size: 32),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        cat['name'] as String,
                        style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: isDark
                                ? AppColors.slate400
                                : AppColors.slate600),
                      ),
                    ],
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
    return Padding(
      padding: const EdgeInsets.only(top: 32.0, left: 16.0),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0, bottom: 16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Event Terdekat',
                    style: TextStyle(
                        color: textColor,
                        fontSize: 18,
                        fontWeight: FontWeight.bold)),
                const Text('Lihat Semua',
                    style: TextStyle(
                        color: AppColors.primary,
                        fontSize: 14,
                        fontWeight: FontWeight.bold)),
              ],
            ),
          ),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _buildEventCard(
                  isDark: isDark,
                  textColor: textColor,
                  imageUrl: 'https://picsum.photos/seed/wayang/400/300',
                  date: '15 OKT',
                  category: 'WAYANG KULIT',
                  title: 'Lakon Bimo Suci',
                  location: 'Taman Mini, Jakarta',
                ),
                _buildEventCard(
                  isDark: isDark,
                  textColor: textColor,
                  imageUrl: 'https://picsum.photos/seed/saman/400/300',
                  date: '18 OKT',
                  category: 'FESTIVAL TARI',
                  title: 'Gema Saman Gayo',
                  location: 'Istora Senayan',
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEventCard(
      {required bool isDark,
      required Color textColor,
      required String imageUrl,
      required String date,
      required String category,
      required String title,
      required String location}) {
    return GestureDetector(
      onTap: () {
        Navigator.push(context, MaterialPageRoute(builder: (_) => const DetailEventPage(eventId: 1)));
      },
      child: Container(
        width: 240,
        margin: const EdgeInsets.only(right: 16.0, bottom: 8.0),
        decoration: BoxDecoration(
          color: isDark ? AppColors.primary.withOpacity(0.05) : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.primary.withOpacity(0.05)),
          boxShadow: isDark
              ? []
              : [
                  BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 4,
                      offset: const Offset(0, 2))
                ],
        ),
        child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 128,
            decoration: BoxDecoration(
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(16)),
              image: DecorationImage(
                  image: NetworkImage(imageUrl), fit: BoxFit.cover),
            ),
            alignment: Alignment.topRight,
            padding: const EdgeInsets.all(8),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: isDark
                    ? AppColors.backgroundDark.withOpacity(0.9)
                    : Colors.white.withOpacity(0.9),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(date,
                  style: const TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary)),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(category,
                    style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary)),
                const SizedBox(height: 4),
                Text(title,
                    style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: textColor),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(Icons.location_on,
                        size: 14,
                        color:
                            isDark ? AppColors.slate400 : AppColors.slate600),
                    const SizedBox(width: 4),
                    Text(location,
                        style: TextStyle(
                            fontSize: 12,
                            color: isDark
                                ? AppColors.slate400
                                : AppColors.slate600)),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    ));
  }

  Widget _buildTopEvent(Color textColor, bool isDark) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 32.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Top Event Terpopuler',
              style: TextStyle(
                  color: textColor, fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          _buildRankTile(
              isDark,
              textColor,
              '01',
              'https://picsum.photos/seed/kecak/200',
              'Kecak Fire Dance Spectacular',
              '4.9 (2.4k views)'),
          const SizedBox(height: 16),
          _buildRankTile(
              isDark,
              textColor,
              '02',
              'https://picsum.photos/seed/serimpi/200',
              'Mahakarya Tari Serimpi',
              '4.7 (1.8k views)'),
        ],
      ),
    );
  }

  Widget _buildRankTile(bool isDark, Color textColor, String rank,
      String imageUrl, String title, String ratingText) {
    return GestureDetector(
      onTap: () {
        Navigator.push(context, MaterialPageRoute(builder: (_) => const DetailEventPage(eventId: 1)));
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.primary.withOpacity(0.05),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.primary.withOpacity(0.1)),
        ),
        child: Row(
        children: [
          Text(rank,
              style: TextStyle(
                  fontSize: 32,
                  fontStyle: FontStyle.italic,
                  fontWeight: FontWeight.w900,
                  color: AppColors.primary.withOpacity(0.3))),
          const SizedBox(width: 16),
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.network(imageUrl,
                width: 64, height: 64, fit: BoxFit.cover),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: textColor,
                        fontSize: 14)),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(Icons.star, color: AppColors.primary, size: 14),
                    const SizedBox(width: 4),
                    Text(ratingText,
                        style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: isDark
                                ? AppColors.slate400
                                : AppColors.slate600)),
                  ],
                ),
              ],
            ),
          ),
          const Icon(Icons.arrow_forward_ios,
              color: AppColors.primary, size: 16),
        ],
      ),
    ));
  }

  Widget _buildEventBerakhir(Color textColor) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Event Berakhir',
              style: TextStyle(
                  color: textColor, fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildPastEventCard(
                    'https://picsum.photos/seed/jazz/300',
                    'Borobudur Jazz Festival 2023',
                    'Selesai: Aug 2023'),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildPastEventCard(
                    'https://picsum.photos/seed/mask/300',
                    'Pesta Kesenian Bali XLV',
                    'Selesai: July 2023'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPastEventCard(String imageUrl, String title, String date) {
    return GestureDetector(
      onTap: () {
        Navigator.push(context, MaterialPageRoute(builder: (_) => const DetailEventPage(eventId: 1)));
      },
      child: AspectRatio(
        aspectRatio: 1,
        child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          image: DecorationImage(
            image: NetworkImage(imageUrl),
            fit: BoxFit.cover,
            colorFilter: const ColorFilter.mode(
                Colors.grey, BlendMode.saturation), // Grayscale effect
          ),
        ),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            gradient: LinearGradient(
              begin: Alignment.bottomCenter,
              end: Alignment.topCenter,
              colors: [Colors.black.withOpacity(0.8), Colors.transparent],
              stops: const [0.0, 0.5],
            ),
          ),
          padding: const EdgeInsets.all(12),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title,
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold)),
              const SizedBox(height: 2),
              Text(date,
                  style: TextStyle(
                      color: Colors.white.withOpacity(0.7), fontSize: 10)),
            ],
          ),
        ),
      ),
    ));
  }
}
