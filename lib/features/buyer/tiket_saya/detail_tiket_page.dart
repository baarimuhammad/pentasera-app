import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:intl/intl.dart';
import 'package:pentasera_app/main.dart';

class DetailTiketPage extends StatelessWidget {
  final Map<String, dynamic> ticket;

  const DetailTiketPage({super.key, required this.ticket});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? AppColors.textDark : AppColors.textLight;
    final mutedColor = isDark ? AppColors.mutedDark : AppColors.mutedLight;
    final surfaceColor =
        isDark ? AppColors.surfaceDark : AppColors.surfaceLight;
    final borderColor =
        isDark ? AppColors.borderDark : AppColors.borderLight;

    final detailOrder = _asMap(ticket['detail_order']);
    final ticketInfo =
        _asMap(ticket['ticket']) ?? _asMap(detailOrder?['ticket']);
    final event = _asMap(ticket['event']) ?? _asMap(ticketInfo?['event']);

    final eventName = _text(
      event?['nama_event'] ?? ticket['event_name'] ?? ticket['nama_event'],
    );
    final lokasi =
        _text(event?['lokasi'] ?? ticket['lokasi'] ?? ticket['location']);
    final tanggal = _text(
      event?['event_datetime'] ??
          ticket['event_datetime'] ??
          ticket['tanggal'] ??
          ticket['date'],
    );
    final kategori = _text(
      ticketInfo?['kategori'] ?? ticket['kategori'] ?? ticket['category'],
    );
    final kodeQr = _text(ticket['kode_qr']);
    final qrData = kodeQr.isNotEmpty
        ? kodeQr
        : _text(ticket['id'] ?? ticket['detail_order_id'], fallback: '-');
    final status = _text(ticket['status_validasi'], fallback: 'valid')
        .toLowerCase();
    final holderName = _text(
      ticket['nama_pemegang'] ?? ticket['holder_name'] ?? ticket['nama'],
    );
    final ticketType = _text(
      ticketInfo?['kategori'] ?? ticket['tipe_tiket'] ?? ticket['ticket_name'],
    );
    final waktu = _text(event?['waktu'] ?? ticket['waktu']);

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
        title: Text('Tiket Saya',
            style: TextStyle(
              color: AppColors.primary,
              fontWeight: FontWeight.bold,
              fontSize: 18,
            )),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(Icons.more_vert, color: mutedColor),
            onPressed: () {},
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            // Top image/category area
            Container(
              width: double.infinity,
              height: 160,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    const Color(0xFF2D2318),
                    AppColors.primary.withOpacity(0.3),
                  ],
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Stack(
                children: [
                  Center(
                    child: Icon(Icons.theater_comedy,
                        size: 64,
                        color: AppColors.primary.withOpacity(0.3)),
                  ),
                  if (kategori.isNotEmpty)
                    Positioned(
                      bottom: 12,
                      left: 12,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: AppColors.primary,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          kategori.toString().toUpperCase(),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                    ),
                  Positioned(
                    top: 12,
                    right: 12,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: _statusColor(status),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        status.toUpperCase(),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Event Name
            Text(
              eventName.isNotEmpty ? eventName : 'Event',
              textAlign: TextAlign.center,
              style: GoogleFonts.playfairDisplay(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: textColor,
              ),
            ),
            if (lokasi.isNotEmpty) ...[
              const SizedBox(height: 4),
              Text(lokasi,
                  style: TextStyle(color: mutedColor, fontSize: 13)),
            ],

            const SizedBox(height: 32),

            // QR Code Card
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: surfaceColor,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: borderColor),
              ),
              child: Column(
                children: [
                  // Corner brackets decoration
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: isDark
                          ? const Color(0xFF1a1510)
                          : const Color(0xFFF8F7F5),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: QrImageView(
                      data: qrData,
                      version: QrVersions.auto,
                      size: 220,
                      backgroundColor: isDark
                          ? const Color(0xFF1a1510)
                          : const Color(0xFFF8F7F5),
                      eyeStyle: QrEyeStyle(
                        eyeShape: QrEyeShape.square,
                        color: isDark
                            ? AppColors.textDark
                            : const Color(0xFF221910),
                      ),
                      dataModuleStyle: QrDataModuleStyle(
                        dataModuleShape: QrDataModuleShape.square,
                        color: isDark
                            ? AppColors.textDark
                            : const Color(0xFF221910),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'ID: ${kodeQr.isNotEmpty ? kodeQr : '-'}',
                    style: TextStyle(
                      color: mutedColor,
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      letterSpacing: 1,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Details Grid
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: surfaceColor,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: borderColor),
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: _detailItem(
                          'Tanggal',
                          _formatDate(tanggal),
                          textColor,
                          mutedColor,
                        ),
                      ),
                      Expanded(
                        child: _detailItem(
                          'Waktu',
                          waktu.isNotEmpty ? waktu : '-',
                          textColor,
                          mutedColor,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: _detailItem(
                          'Kategori',
                          ticketType.isNotEmpty ? ticketType : '-',
                          AppColors.primary,
                          mutedColor,
                        ),
                      ),
                      Expanded(
                        child: _detailItem(
                          'Nama Pemesan',
                          holderName.isNotEmpty ? holderName : '-',
                          textColor,
                          mutedColor,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Action Button
            SizedBox(
              width: double.infinity,
              height: 50,
              child: OutlinedButton.icon(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Fitur tambah ke kalender segera hadir!'),
                      backgroundColor: AppColors.primary,
                    ),
                  );
                },
                icon: const Icon(Icons.calendar_today_outlined),
                label: const Text('Tambahkan ke Kalender',
                    style:
                        TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.primary,
                  side: const BorderSide(color: AppColors.primary),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _detailItem(
      String label, String value, Color valueColor, Color labelColor) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: TextStyle(
                color: labelColor,
                fontSize: 11,
                fontWeight: FontWeight.w500)),
        const SizedBox(height: 4),
        Text(value,
            style: TextStyle(
                color: valueColor,
                fontSize: 14,
                fontWeight: FontWeight.bold)),
      ],
    );
  }

  Map<String, dynamic>? _asMap(dynamic value) {
    if (value is Map<String, dynamic>) return value;
    if (value is Map) return Map<String, dynamic>.from(value);
    return null;
  }

  String _text(dynamic value, {String fallback = ''}) {
    final text = value?.toString() ?? '';
    return text.isNotEmpty ? text : fallback;
  }

  Color _statusColor(String status) {
    switch (status.toLowerCase()) {
      case 'valid':
        return Colors.green;
      case 'used':
        return Colors.grey;
      case 'expired':
        return Colors.red;
      default:
        return AppColors.primary;
    }
  }

  String _formatDate(String? dateStr) {
    if (dateStr == null || dateStr.isEmpty) return '-';
    try {
      final date = DateTime.parse(dateStr);
      return DateFormat('dd MMMM yyyy', 'id_ID').format(date);
    } catch (_) {
      return dateStr;
    }
  }
}
