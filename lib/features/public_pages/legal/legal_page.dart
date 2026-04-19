import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pentasera_app/main.dart';

class LegalPage extends StatelessWidget {
  final String type; // 'syarat' or 'privasi'

  const LegalPage({super.key, required this.type});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? AppColors.textDark : AppColors.textLight;
    final mutedColor = isDark ? AppColors.mutedDark : AppColors.mutedLight;

    final isSyarat = type == 'syarat';
    final title = isSyarat ? 'Syarat & Ketentuan' : 'Kebijakan Privasi';

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
        title: Text(title,
            style: TextStyle(
                color: textColor, fontWeight: FontWeight.bold, fontSize: 18)),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.05),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                    color: AppColors.primary.withOpacity(0.1)),
              ),
              child: Row(
                children: [
                  Icon(
                    isSyarat ? Icons.gavel : Icons.privacy_tip_outlined,
                    color: AppColors.primary,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(title,
                            style: TextStyle(
                                color: textColor,
                                fontWeight: FontWeight.bold,
                                fontSize: 15)),
                        Text('Terakhir diperbarui: 1 Januari 2026',
                            style: TextStyle(
                                color: mutedColor, fontSize: 12)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            ...(isSyarat ? _syaratContent(textColor, mutedColor) : _privasiContent(textColor, mutedColor)),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  List<Widget> _syaratContent(Color textColor, Color mutedColor) {
    return [
      _sectionTitle('1. Penerimaan Syarat', textColor),
      _sectionBody(
        'Dengan mengakses dan menggunakan layanan Pentasera, Anda menyetujui dan terikat oleh syarat dan ketentuan ini. Jika Anda tidak menyetujui syarat-syarat ini, mohon untuk tidak menggunakan layanan kami.',
        mutedColor,
      ),
      _sectionTitle('2. Deskripsi Layanan', textColor),
      _sectionBody(
        'Pentasera adalah platform pemesanan tiket pertunjukan budaya nusantara yang menghubungkan penyelenggara event dengan penonton. Kami menyediakan fitur pemesanan tiket, manajemen event, dan e-tiket digital.',
        mutedColor,
      ),
      _sectionTitle('3. Akun Pengguna', textColor),
      _sectionBody(
        'Anda bertanggung jawab untuk menjaga kerahasiaan informasi akun Anda, termasuk password. Anda setuju untuk memberikan informasi yang akurat dan terkini saat mendaftar dan menggunakan layanan.',
        mutedColor,
      ),
      _sectionTitle('4. Pembelian Tiket', textColor),
      _sectionBody(
        'Semua pembelian tiket bersifat final kecuali event dibatalkan oleh penyelenggara. Harga tiket ditentukan oleh penyelenggara event. Pentasera dapat membebankan biaya layanan tambahan.',
        mutedColor,
      ),
      _sectionTitle('5. Pembatalan dan Pengembalian Dana', textColor),
      _sectionBody(
        'Kebijakan pembatalan dan pengembalian dana bergantung pada kebijakan masing-masing penyelenggara event. Pentasera akan memfasilitasi proses pengembalian dana sesuai kebijakan yang berlaku.',
        mutedColor,
      ),
      _sectionTitle('6. Larangan', textColor),
      _sectionBody(
        'Pengguna dilarang: menggunakan layanan untuk tujuan ilegal, menjual kembali tiket tanpa izin, melakukan tindakan yang merugikan platform atau pengguna lain, serta mengakses sistem secara tidak sah.',
        mutedColor,
      ),
      _sectionTitle('7. Batasan Tanggung Jawab', textColor),
      _sectionBody(
        'Pentasera tidak bertanggung jawab atas kerugian yang timbul dari pembatalan event oleh penyelenggara, gangguan teknis di luar kendali kami, atau penggunaan platform yang tidak sesuai ketentuan.',
        mutedColor,
      ),
    ];
  }

  List<Widget> _privasiContent(Color textColor, Color mutedColor) {
    return [
      _sectionTitle('1. Informasi yang Kami Kumpulkan', textColor),
      _sectionBody(
        'Kami mengumpulkan informasi yang Anda berikan saat mendaftar, seperti nama, email, dan informasi kontak. Kami juga mengumpulkan data penggunaan untuk meningkatkan layanan.',
        mutedColor,
      ),
      _sectionTitle('2. Penggunaan Informasi', textColor),
      _sectionBody(
        'Informasi Anda digunakan untuk: memproses pesanan tiket, mengirimkan e-tiket dan notifikasi, meningkatkan pengalaman pengguna, serta keperluan keamanan akun.',
        mutedColor,
      ),
      _sectionTitle('3. Keamanan Data', textColor),
      _sectionBody(
        'Kami menerapkan langkah-langkah keamanan yang wajar untuk melindungi data pribadi Anda. Namun, kami tidak dapat menjamin keamanan mutlak dari setiap transmisi data melalui internet.',
        mutedColor,
      ),
      _sectionTitle('4. Berbagi Informasi', textColor),
      _sectionBody(
        'Kami tidak menjual data pribadi Anda kepada pihak ketiga. Informasi dapat dibagikan kepada penyelenggara event untuk keperluan tiket, atau jika diwajibkan oleh hukum.',
        mutedColor,
      ),
      _sectionTitle('5. Cookie dan Teknologi Pelacakan', textColor),
      _sectionBody(
        'Kami menggunakan teknologi pelacakan untuk menganalisis penggunaan platform dan meningkatkan layanan. Anda dapat mengatur preferensi cookie melalui pengaturan perangkat Anda.',
        mutedColor,
      ),
      _sectionTitle('6. Hak Pengguna', textColor),
      _sectionBody(
        'Anda memiliki hak untuk: mengakses data pribadi Anda, meminta perbaikan data yang tidak akurat, meminta penghapusan data, serta menarik persetujuan penggunaan data.',
        mutedColor,
      ),
      _sectionTitle('7. Kontak', textColor),
      _sectionBody(
        'Jika Anda memiliki pertanyaan terkait kebijakan privasi ini, silakan hubungi kami di support@pentasera.id.',
        mutedColor,
      ),
    ];
  }

  Widget _sectionTitle(String title, Color textColor) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8, top: 16),
      child: Text(
        title,
        style: TextStyle(
          color: textColor,
          fontSize: 15,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _sectionBody(String text, Color mutedColor) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        text,
        style: TextStyle(
          color: mutedColor,
          fontSize: 14,
          height: 1.6,
        ),
      ),
    );
  }
}
