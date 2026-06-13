import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:pentasera_app/main.dart';
import 'dart:io';

class TabInformasiEvent extends StatefulWidget {
  final Map<String, dynamic> eventData;
  final TextEditingController namaController;
  final TextEditingController lokasiController;
  final TextEditingController deskripsiController;
  final ValueNotifier<String> kategoriNotifier;
  final ValueNotifier<DateTime?> datetimeNotifier;
  final ValueNotifier<String?> imagePathNotifier;
  final String? bannerUrl;

  const TabInformasiEvent({
    super.key,
    required this.eventData,
    required this.namaController,
    required this.lokasiController,
    required this.deskripsiController,
    required this.kategoriNotifier,
    required this.datetimeNotifier,
    required this.imagePathNotifier,
    this.bannerUrl,
  });

  @override
  State<TabInformasiEvent> createState() => _TabInformasiEventState();
}

class _TabInformasiEventState extends State<TabInformasiEvent>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  // Settings state (local only — no backend endpoint yet)
  int _maxTicketsPerTransaction = 5;
  bool _oneEmailOneTransaction = false;
  bool _oneTicketOneData = true;

  static const List<String> _categories = [
    'Seni Tari',
    'Musik Tradisional',
    'Pertunjukan',
    'Festival',
    'Workshop',
    'Pameran',
    'Lainnya',
  ];

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 1920,
      maxHeight: 1080,
      imageQuality: 85,
    );
    if (picked != null) {
      widget.imagePathNotifier.value = picked.path;
      if (mounted) setState(() {});
    }
  }

  Future<void> _pickDateTime() async {
    final current = widget.datetimeNotifier.value ?? DateTime.now();
    final date = await showDatePicker(
      context: context,
      initialDate: current,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
      builder: (ctx, child) => Theme(
        data: Theme.of(ctx).copyWith(
          colorScheme: Theme.of(ctx).colorScheme.copyWith(
                primary: AppColors.primary,
              ),
        ),
        child: child!,
      ),
    );
    if (date == null || !mounted) return;

    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(current),
      builder: (ctx, child) => Theme(
        data: Theme.of(ctx).copyWith(
          colorScheme: Theme.of(ctx).colorScheme.copyWith(
                primary: AppColors.primary,
              ),
        ),
        child: child!,
      ),
    );
    if (time == null) return;

    widget.datetimeNotifier.value = DateTime(
      date.year,
      date.month,
      date.day,
      time.hour,
      time.minute,
    );
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? AppColors.textDark : AppColors.textLight;
    final mutedColor = isDark ? AppColors.mutedDark : AppColors.mutedLight;
    final surfaceColor =
        isDark ? AppColors.surfaceDark : AppColors.surfaceLight;
    final borderColor = isDark ? AppColors.borderDark : AppColors.borderLight;
    final inputFill = isDark
        ? AppColors.backgroundDark.withOpacity(0.5)
        : const Color(0xFFFAFAF8);

    final organizer = widget.eventData['organizer'];
    final organizerName =
        organizer is Map ? (organizer['organizer_name'] ?? '') : '';
    final organizerEmail =
        organizer is Map ? (organizer['contact_email'] ?? '') : '';
    final organizerPhone =
        organizer is Map ? (organizer['contact_phone'] ?? '') : '';

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Banner Image ──
          _buildBannerSection(isDark, surfaceColor, borderColor),
          const SizedBox(height: 24),

          // ── Form Fields ──
          _buildCard(
            isDark,
            surfaceColor,
            borderColor,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildLabel('Judul Event', mutedColor),
                const SizedBox(height: 8),
                _buildTextField(
                  controller: widget.namaController,
                  hint: 'Masukkan judul event',
                  isDark: isDark,
                  inputFill: inputFill,
                  textColor: textColor,
                ),
                const SizedBox(height: 20),

                _buildLabel('Kategori', mutedColor),
                const SizedBox(height: 8),
                _buildCategoryDropdown(
                    isDark, inputFill, textColor, borderColor),
                const SizedBox(height: 20),

                _buildLabel('Tanggal & Waktu', mutedColor),
                const SizedBox(height: 8),
                _buildDateTimePicker(
                    isDark, inputFill, textColor, mutedColor, borderColor),
                const SizedBox(height: 20),

                _buildLabel('Lokasi', mutedColor),
                const SizedBox(height: 8),
                _buildTextField(
                  controller: widget.lokasiController,
                  hint: 'Masukkan lokasi event',
                  isDark: isDark,
                  inputFill: inputFill,
                  textColor: textColor,
                  prefixIcon: Icons.location_on_outlined,
                ),
                const SizedBox(height: 20),

                _buildLabel('Deskripsi Event', mutedColor),
                const SizedBox(height: 8),
                _buildTextField(
                  controller: widget.deskripsiController,
                  hint: 'Tuliskan deskripsi event Anda...',
                  isDark: isDark,
                  inputFill: inputFill,
                  textColor: textColor,
                  maxLines: 5,
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // ── Informasi Kontak ──
          _buildCard(
            isDark,
            surfaceColor,
            borderColor,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      'Informasi Kontak',
                      style: TextStyle(
                        color: textColor,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      width: 8,
                      height: 8,
                      decoration: const BoxDecoration(
                        color: AppColors.primary,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                _buildContactField(
                  'Nama Narahubung',
                  organizerName.isEmpty ? '-' : organizerName,
                  Icons.person_outline,
                  mutedColor,
                  textColor,
                  surfaceColor,
                  isDark,
                ),
                const SizedBox(height: 12),
                _buildContactField(
                  'Email',
                  organizerEmail.isEmpty ? '-' : organizerEmail,
                  Icons.email_outlined,
                  mutedColor,
                  textColor,
                  surfaceColor,
                  isDark,
                ),
                const SizedBox(height: 12),
                _buildContactField(
                  'No. Ponsel',
                  organizerPhone.isEmpty ? '-' : organizerPhone,
                  Icons.phone_outlined,
                  mutedColor,
                  textColor,
                  surfaceColor,
                  isDark,
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // ── Pengaturan Tambahan ──
          _buildCard(
            isDark,
            surfaceColor,
            borderColor,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      'Pengaturan Tambahan',
                      style: TextStyle(
                        color: textColor,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      width: 8,
                      height: 8,
                      decoration: const BoxDecoration(
                        color: AppColors.primary,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // Max tickets per transaction
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: inputFill,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: borderColor),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Maks. tiket per transaksi',
                              style: TextStyle(
                                color: textColor,
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Batasi jumlah tiket per checkout',
                              style: TextStyle(
                                color: mutedColor,
                                fontSize: 11,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: surfaceColor,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: borderColor),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            _buildCounterButton(
                              Icons.remove,
                              () {
                                if (_maxTicketsPerTransaction > 1) {
                                  setState(
                                      () => _maxTicketsPerTransaction--);
                                }
                              },
                              isDark,
                            ),
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 12),
                              child: Text(
                                '$_maxTicketsPerTransaction',
                                style: TextStyle(
                                  color: AppColors.primary,
                                  fontSize: 20,
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                            ),
                            _buildCounterButton(
                              Icons.add,
                              () {
                                if (_maxTicketsPerTransaction < 10) {
                                  setState(
                                      () => _maxTicketsPerTransaction++);
                                }
                              },
                              isDark,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),

                // Toggle: 1 email 1 transaksi
                _buildToggleSetting(
                  '1 akun email – 1 kali transaksi',
                  'Mencegah pembelian berulang',
                  _oneEmailOneTransaction,
                  (v) => setState(() => _oneEmailOneTransaction = v),
                  isDark,
                  inputFill,
                  borderColor,
                  textColor,
                  mutedColor,
                ),
                const SizedBox(height: 12),

                // Toggle: 1 tiket 1 data
                _buildToggleSetting(
                  '1 tiket – 1 data pemesan',
                  'Identitas berbeda per tiket',
                  _oneTicketOneData,
                  (v) => setState(() => _oneTicketOneData = v),
                  isDark,
                  inputFill,
                  borderColor,
                  textColor,
                  mutedColor,
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  // ─── Widgets ─────────────────────────────────

  Widget _buildBannerSection(
      bool isDark, Color surfaceColor, Color borderColor) {
    final localPath = widget.imagePathNotifier.value;
    final hasLocal = localPath != null && localPath.isNotEmpty;

    return Container(
      height: 180,
      width: double.infinity,
      decoration: BoxDecoration(
        color: surfaceColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderColor),
        image: hasLocal
            ? DecorationImage(
                image: FileImage(File(localPath)),
                fit: BoxFit.cover,
              )
            : (widget.bannerUrl != null && widget.bannerUrl!.isNotEmpty)
                ? DecorationImage(
                    image: NetworkImage(widget.bannerUrl!),
                    fit: BoxFit.cover,
                  )
                : null,
      ),
      child: Stack(
        children: [
          if (!hasLocal &&
              (widget.bannerUrl == null || widget.bannerUrl!.isEmpty))
            Center(
              child: Icon(Icons.image_outlined,
                  size: 48, color: AppColors.primary.withOpacity(0.3)),
            ),
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    Colors.black.withOpacity(0.5),
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            bottom: 16,
            right: 16,
            child: Material(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              elevation: 4,
              child: InkWell(
                onTap: _pickImage,
                borderRadius: BorderRadius.circular(12),
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.camera_alt_outlined,
                          size: 16, color: AppColors.textLight),
                      const SizedBox(width: 6),
                      Text(
                        'Ganti Banner',
                        style: TextStyle(
                          color: AppColors.textLight,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCard(
    bool isDark,
    Color surfaceColor,
    Color borderColor, {
    required Widget child,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: surfaceColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderColor),
      ),
      child: child,
    );
  }

  Widget _buildLabel(String text, Color mutedColor) {
    return Text(
      text.toUpperCase(),
      style: TextStyle(
        color: mutedColor,
        fontSize: 10,
        fontWeight: FontWeight.w800,
        letterSpacing: 1.5,
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    required bool isDark,
    required Color inputFill,
    required Color textColor,
    int maxLines = 1,
    IconData? prefixIcon,
  }) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      style: TextStyle(
        color: textColor,
        fontSize: 14,
        fontWeight: FontWeight.w600,
      ),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(
          color: (isDark ? AppColors.mutedDark : AppColors.mutedLight)
              .withOpacity(0.5),
          fontWeight: FontWeight.normal,
        ),
        filled: true,
        fillColor: inputFill,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: AppColors.primary.withOpacity(0.4),
            width: 2,
          ),
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        prefixIcon: prefixIcon != null
            ? Icon(prefixIcon, size: 18, color: AppColors.primary)
            : null,
      ),
    );
  }

  Widget _buildCategoryDropdown(
      bool isDark, Color inputFill, Color textColor, Color borderColor) {
    return ValueListenableBuilder<String>(
      valueListenable: widget.kategoriNotifier,
      builder: (_, value, __) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: inputFill,
            borderRadius: BorderRadius.circular(12),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: _categories.contains(value) ? value : _categories.last,
              isExpanded: true,
              icon: Icon(Icons.keyboard_arrow_down,
                  color: isDark ? AppColors.mutedDark : AppColors.mutedLight),
              dropdownColor:
                  isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
              style: TextStyle(
                color: textColor,
                fontSize: 14,
                fontWeight: FontWeight.w600,
                fontFamily: 'Plus Jakarta Sans',
              ),
              items: _categories
                  .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                  .toList(),
              onChanged: (v) {
                if (v != null) widget.kategoriNotifier.value = v;
              },
            ),
          ),
        );
      },
    );
  }

  Widget _buildDateTimePicker(bool isDark, Color inputFill, Color textColor,
      Color mutedColor, Color borderColor) {
    final dt = widget.datetimeNotifier.value;
    final displayText = dt != null
        ? '${dt.day.toString().padLeft(2, '0')}/${dt.month.toString().padLeft(2, '0')}/${dt.year}  •  ${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}'
        : 'Pilih tanggal & waktu';

    return InkWell(
      onTap: _pickDateTime,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: inputFill,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Icon(Icons.calendar_today_outlined,
                size: 18, color: AppColors.primary),
            const SizedBox(width: 12),
            Text(
              displayText,
              style: TextStyle(
                color: dt != null ? textColor : mutedColor.withOpacity(0.5),
                fontSize: 14,
                fontWeight: dt != null ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContactField(
    String label,
    String value,
    IconData icon,
    Color mutedColor,
    Color textColor,
    Color surfaceColor,
    bool isDark,
  ) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isDark
            ? AppColors.backgroundDark.withOpacity(0.5)
            : const Color(0xFFFAFAF8),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          Icon(icon, size: 18, color: AppColors.primary),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label.toUpperCase(),
                  style: TextStyle(
                    color: mutedColor,
                    fontSize: 9,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1.5,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: TextStyle(
                    color: textColor,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildToggleSetting(
    String title,
    String subtitle,
    bool value,
    ValueChanged<bool> onChanged,
    bool isDark,
    Color inputFill,
    Color borderColor,
    Color textColor,
    Color mutedColor,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: inputFill,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: borderColor),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: textColor,
                    fontSize: 12,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: TextStyle(
                    color: mutedColor,
                    fontSize: 10,
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: AppColors.primary,
            activeTrackColor: AppColors.primary.withOpacity(0.3),
            inactiveThumbColor: isDark ? Colors.grey[400] : Colors.grey[300],
            inactiveTrackColor: isDark ? Colors.grey[700] : Colors.grey[200],
          ),
        ],
      ),
    );
  }

  Widget _buildCounterButton(
      IconData icon, VoidCallback onTap, bool isDark) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(
          color: AppColors.primary.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, size: 16, color: AppColors.primary),
      ),
    );
  }
}
