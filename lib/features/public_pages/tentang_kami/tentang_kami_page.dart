import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pentasera_app/main.dart';

class TentangKamiPage extends StatelessWidget {
  const TentangKamiPage({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? AppColors.textDark : AppColors.textLight;
    final mutedColor = isDark ? AppColors.mutedDark : AppColors.mutedLight;
    final surfaceColor =
        isDark ? AppColors.surfaceDark : AppColors.surfaceLight;
    final borderColor =
        isDark ? AppColors.borderDark : AppColors.borderLight;

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
        title: Text('Tentang Kami',
            style: TextStyle(
                color: textColor, fontWeight: FontWeight.bold, fontSize: 18)),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Hero
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF2D2318), Color(0xFFf27f0d)],
                  begin: Alignment.bottomLeft,
                  end: Alignment.topRight,
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: [
                  const Icon(Icons.theater_comedy,
                      size: 48, color: Colors.white),
                  const SizedBox(height: 16),
                  Text(
                    'Pentasera',
                    style: GoogleFonts.playfairDisplay(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Platform tiket pertunjukan budaya nusantara',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.8),
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),

            // Visi Misi
            Text(
              'Visi',
              style: GoogleFonts.playfairDisplay(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: textColor,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Menjadi platform terdepan yang menghubungkan masyarakat dengan seni pertunjukan budaya nusantara, melestarikan warisan budaya Indonesia melalui teknologi modern.',
              style: TextStyle(color: mutedColor, fontSize: 14, height: 1.6),
            ),
            const SizedBox(height: 24),

            Text(
              'Misi',
              style: GoogleFonts.playfairDisplay(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: textColor,
              ),
            ),
            const SizedBox(height: 12),
            _missionItem('1', 'Memudahkan akses ke pertunjukan budaya melalui pemesanan tiket digital.', textColor, mutedColor, surfaceColor, borderColor),
            _missionItem('2', 'Mendukung para kreator seni tradisional untuk menjangkau audiens yang lebih luas.', textColor, mutedColor, surfaceColor, borderColor),
            _missionItem('3', 'Melestarikan seni pertunjukan budaya Indonesia untuk generasi mendatang.', textColor, mutedColor, surfaceColor, borderColor),
            _missionItem('4', 'Membangun ekosistem seni pertunjukan yang berkelanjutan dan inklusif.', textColor, mutedColor, surfaceColor, borderColor),

            const SizedBox(height: 32),

            // Nilai Kami
            Text(
              'Nilai Kami',
              style: GoogleFonts.playfairDisplay(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: textColor,
              ),
            ),
            const SizedBox(height: 16),
            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              childAspectRatio: 1.2,
              children: [
                _valueCard(Icons.favorite, 'Budaya', 'Cinta pada warisan seni nusantara', surfaceColor, borderColor, textColor, mutedColor),
                _valueCard(Icons.people, 'Inklusif', 'Seni untuk semua lapisan masyarakat', surfaceColor, borderColor, textColor, mutedColor),
                _valueCard(Icons.lightbulb, 'Inovasi', 'Teknologi untuk pelestarian budaya', surfaceColor, borderColor, textColor, mutedColor),
                _valueCard(Icons.handshake, 'Kolaborasi', 'Bersama memajukan seni pertunjukan', surfaceColor, borderColor, textColor, mutedColor),
              ],
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _missionItem(String index, String text, Color textColor,
      Color mutedColor, Color surfaceColor, Color borderColor) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: surfaceColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: borderColor),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Center(
              child: Text(index,
                  style: const TextStyle(
                      color: AppColors.primary,
                      fontWeight: FontWeight.bold,
                      fontSize: 13)),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(text,
                style: TextStyle(
                    color: textColor, fontSize: 13, height: 1.5)),
          ),
        ],
      ),
    );
  }

  Widget _valueCard(IconData icon, String title, String desc,
      Color surfaceColor, Color borderColor, Color textColor, Color mutedColor) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: surfaceColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: borderColor),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: AppColors.primary, size: 24),
          ),
          const SizedBox(height: 10),
          Text(title,
              style: TextStyle(
                  color: textColor,
                  fontSize: 14,
                  fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          Text(desc,
              textAlign: TextAlign.center,
              style: TextStyle(color: mutedColor, fontSize: 11)),
        ],
      ),
    );
  }
}
