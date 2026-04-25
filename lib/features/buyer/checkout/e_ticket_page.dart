import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:pentasera_app/main.dart';
import 'package:pentasera_app/core/app_router.dart';
import 'package:pentasera_app/features/buyer/tiket_saya/tiket_saya_page.dart';
import 'package:pentasera_app/services/auth_service.dart';

class ETicketPage extends StatelessWidget {
  final String eventName;
  final String ticketName;
  final String holderName;
  final String orderId;
  final dynamic eTicketData;
  final String kodeQr;

  const ETicketPage({
    super.key,
    required this.eventName,
    required this.ticketName,
    required this.holderName,
    required this.orderId,
    this.eTicketData,
    required this.kodeQr,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? AppColors.textDark : AppColors.textLight;
    final mutedColor = isDark ? AppColors.mutedDark : AppColors.mutedLight;
    final surfaceColor =
        isDark ? AppColors.surfaceDark : AppColors.surfaceLight;
    final borderColor = isDark ? AppColors.borderDark : AppColors.borderLight;

    // bookingCode no longer needed - using kodeQr parameter directly
    final backendKodeQr =
        eTicketData is Map ? eTicketData['kode_qr']?.toString() : null;

    return Scaffold(
      backgroundColor:
          isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              const SizedBox(height: 32),

              // Success Icon
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.check_circle,
                    color: Colors.green, size: 48),
              ),
              const SizedBox(height: 20),

              Text(
                'Pembayaran Berhasil!',
                style: GoogleFonts.playfairDisplay(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: textColor,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Tiket Anda sudah siap. Tunjukkan QR code di bawah saat masuk venue.',
                textAlign: TextAlign.center,
                style: TextStyle(color: mutedColor, fontSize: 14, height: 1.5),
              ),
              const SizedBox(height: 32),

              // Ticket Card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: surfaceColor,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: borderColor),
                  boxShadow: isDark
                      ? []
                      : [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 20,
                            offset: const Offset(0, 4),
                          ),
                        ],
                ),
                child: Column(
                  children: [
                    // Event Name
                    Text(
                      eventName,
                      textAlign: TextAlign.center,
                      style: GoogleFonts.playfairDisplay(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: textColor,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(ticketName,
                        style: TextStyle(
                            color: AppColors.primary,
                            fontSize: 13,
                            fontWeight: FontWeight.w600)),

                    const SizedBox(height: 24),

                    // QR Code
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: QrImageView(
                        data: kodeQr,
                        version: QrVersions.auto,
                        size: 200,
                        backgroundColor: Colors.white,
                        eyeStyle: const QrEyeStyle(
                          eyeShape: QrEyeShape.square,
                          color: Color(0xFF221910),
                        ),
                        dataModuleStyle: const QrDataModuleStyle(
                          dataModuleShape: QrDataModuleShape.square,
                          color: Color(0xFF221910),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Kode QR: $kodeQr',
                      style: TextStyle(
                          color: mutedColor,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          letterSpacing: 1),
                    ),
                    if (backendKodeQr != null && backendKodeQr.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: Text(
                          backendKodeQr,
                          style: TextStyle(
                              color: mutedColor,
                              fontSize: 11,
                              fontStyle: FontStyle.italic),
                        ),
                      ),
                    const SizedBox(height: 24),

                    // Dashed divider
                    Row(
                      children: List.generate(
                        30,
                        (index) => Expanded(
                          child: Container(
                            margin: const EdgeInsets.symmetric(horizontal: 2),
                            height: 1,
                            color: borderColor,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 20),

                    // Details
                    Row(
                      children: [
                        Expanded(
                          child: _detailItem('Nama Pemegang', holderName,
                              textColor, mutedColor),
                        ),
                        Expanded(
                          child: _detailItem(
                              'Tiket', ticketName, textColor, mutedColor),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 32),

              // Buttons
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(builder: (_) => const TiketSayaPage()),
                      (_) => false,
                    );
                  },
                  icon: const Icon(Icons.confirmation_number_outlined),
                  label: const Text('Lihat Tiket Saya',
                      style:
                          TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                    elevation: 0,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: OutlinedButton.icon(
                  onPressed: () async {
                    final role = await AuthService.getUserRole() ?? 'buyer';
                    if (context.mounted) {
                      Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(
                            builder: (_) => RoleBasedShell(role: role)),
                        (_) => false,
                      );
                    }
                  },
                  icon: const Icon(Icons.home_outlined),
                  label: const Text('Kembali ke Home',
                      style:
                          TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
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
      ),
    );
  }

  Widget _detailItem(
      String label, String value, Color textColor, Color mutedColor) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: TextStyle(
                color: mutedColor, fontSize: 11, fontWeight: FontWeight.w500)),
        const SizedBox(height: 4),
        Text(value,
            style: TextStyle(
                color: textColor, fontSize: 14, fontWeight: FontWeight.w600)),
      ],
    );
  }
}
