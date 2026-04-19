import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:pentasera_app/main.dart';
import 'package:pentasera_app/services/event_service.dart';

class BuatEventPage extends StatefulWidget {
  const BuatEventPage({super.key});

  @override
  State<BuatEventPage> createState() => _BuatEventPageState();
}

class _BuatEventPageState extends State<BuatEventPage> {
  int _currentStep = 0;
  bool _isLoading = false;

  // Step 1: Info Event
  final _namaController = TextEditingController();
  final _deskripsiController = TextEditingController();
  final _lokasiController = TextEditingController();
  final _kapasitasController = TextEditingController();
  String _kategori = 'Tari';
  DateTime? _tanggalMulai;
  DateTime? _tanggalSelesai;

  // Step 2: Publikasi
  final _namaTicketController = TextEditingController();
  final _hargaController = TextEditingController();
  final _stokController = TextEditingController();
  String _status = 'draft';

  final List<String> _categories = [
    'Tari',
    'Wayang',
    'Teater',
    'Musik',
    'Pameran',
    'Festival',
  ];

  @override
  void dispose() {
    _namaController.dispose();
    _deskripsiController.dispose();
    _lokasiController.dispose();
    _kapasitasController.dispose();
    _namaTicketController.dispose();
    _hargaController.dispose();
    _stokController.dispose();
    super.dispose();
  }

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
        title: Text('Buat Event',
            style: TextStyle(
                color: textColor, fontWeight: FontWeight.bold, fontSize: 18)),
        centerTitle: true,
        iconTheme: IconThemeData(color: textColor),
      ),
      body: Theme(
        data: Theme.of(context).copyWith(
          colorScheme: Theme.of(context).colorScheme.copyWith(
                primary: AppColors.primary,
              ),
        ),
        child: Stepper(
          currentStep: _currentStep,
          onStepContinue: () {
            if (_currentStep < 1) {
              setState(() => _currentStep += 1);
            }
          },
          onStepCancel: () {
            if (_currentStep > 0) {
              setState(() => _currentStep -= 1);
            }
          },
          controlsBuilder: (context, details) {
            return Padding(
              padding: const EdgeInsets.only(top: 16),
              child: Row(
                children: [
                  if (_currentStep < 1)
                    Expanded(
                      child: ElevatedButton(
                        onPressed: details.onStepContinue,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12)),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                        ),
                        child: const Text('Lanjut',
                            style: TextStyle(fontWeight: FontWeight.bold)),
                      ),
                    )
                  else ...[
                    Expanded(
                      child: OutlinedButton(
                        onPressed: _isLoading
                            ? null
                            : () => _handleSubmit('draft'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppColors.primary,
                          side: const BorderSide(color: AppColors.primary),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12)),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                        ),
                        child: const Text('Simpan Draft',
                            style: TextStyle(fontWeight: FontWeight.bold)),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: _isLoading
                            ? null
                            : () => _handleSubmit('publikasi'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12)),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                        ),
                        child: _isLoading
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                    color: Colors.white, strokeWidth: 2),
                              )
                            : const Text('Publikasikan',
                                style:
                                    TextStyle(fontWeight: FontWeight.bold)),
                      ),
                    ),
                  ],
                  if (_currentStep > 0) ...[
                    const SizedBox(width: 12),
                    TextButton(
                      onPressed: details.onStepCancel,
                      child: Text('Kembali',
                          style: TextStyle(color: mutedColor)),
                    ),
                  ],
                ],
              ),
            );
          },
          steps: [
            // Step 1: Informasi Event
            Step(
              title: Text('Informasi Event',
                  style: TextStyle(
                      color: textColor, fontWeight: FontWeight.w600)),
              isActive: _currentStep >= 0,
              state: _currentStep > 0
                  ? StepState.complete
                  : StepState.indexed,
              content: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildInputField('Nama Event', _namaController,
                      isDark, textColor, surfaceColor, borderColor),
                  const SizedBox(height: 16),

                  // Kategori dropdown
                  Text('Kategori',
                      style: TextStyle(
                          color: textColor,
                          fontSize: 13,
                          fontWeight: FontWeight.w500)),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    decoration: BoxDecoration(
                      color: surfaceColor,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: borderColor),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: _kategori,
                        isExpanded: true,
                        dropdownColor: surfaceColor,
                        style: TextStyle(color: textColor, fontSize: 14),
                        items: _categories
                            .map((c) => DropdownMenuItem(
                                value: c, child: Text(c)))
                            .toList(),
                        onChanged: (v) =>
                            setState(() => _kategori = v!),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  _buildInputField('Deskripsi', _deskripsiController,
                      isDark, textColor, surfaceColor, borderColor,
                      maxLines: 4),
                  const SizedBox(height: 16),

                  // Date pickers
                  Row(
                    children: [
                      Expanded(
                        child: _buildDatePicker(
                          'Tanggal Mulai',
                          _tanggalMulai,
                          (d) => setState(() => _tanggalMulai = d),
                          isDark,
                          textColor,
                          surfaceColor,
                          borderColor,
                          mutedColor,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildDatePicker(
                          'Tanggal Selesai',
                          _tanggalSelesai,
                          (d) => setState(() => _tanggalSelesai = d),
                          isDark,
                          textColor,
                          surfaceColor,
                          borderColor,
                          mutedColor,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  _buildInputField('Lokasi', _lokasiController,
                      isDark, textColor, surfaceColor, borderColor),
                  const SizedBox(height: 16),

                  _buildInputField('Kapasitas', _kapasitasController,
                      isDark, textColor, surfaceColor, borderColor,
                      type: TextInputType.number),
                  const SizedBox(height: 16),

                  // Photo placeholder
                  Text('Foto Event',
                      style: TextStyle(
                          color: textColor,
                          fontSize: 13,
                          fontWeight: FontWeight.w500)),
                  const SizedBox(height: 8),
                  Container(
                    height: 120,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.05),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                          color: AppColors.primary.withOpacity(0.2),
                          style: BorderStyle.solid),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.cloud_upload_outlined,
                            color: AppColors.primary.withOpacity(0.5),
                            size: 32),
                        const SizedBox(height: 8),
                        Text('Tap untuk upload foto',
                            style: TextStyle(
                                color: mutedColor, fontSize: 12)),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Step 2: Publikasi
            Step(
              title: Text('Publikasi Event',
                  style: TextStyle(
                      color: textColor, fontWeight: FontWeight.w600)),
              isActive: _currentStep >= 1,
              content: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Preview
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.05),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                          color: AppColors.primary.withOpacity(0.1)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Preview',
                            style: TextStyle(
                                color: AppColors.primary,
                                fontSize: 12,
                                fontWeight: FontWeight.w600)),
                        const SizedBox(height: 8),
                        Text(
                          _namaController.text.isEmpty
                              ? 'Nama Event'
                              : _namaController.text,
                          style: GoogleFonts.playfairDisplay(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: textColor,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text('$_kategori • ${_lokasiController.text}',
                            style: TextStyle(color: mutedColor, fontSize: 12)),
                        if (_tanggalMulai != null)
                          Text(
                            DateFormat('dd MMM yyyy').format(_tanggalMulai!),
                            style: TextStyle(
                                color: mutedColor, fontSize: 12),
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Ticket info
                  Text('Informasi Tiket',
                      style: TextStyle(
                          color: textColor,
                          fontSize: 15,
                          fontWeight: FontWeight.bold)),
                  const SizedBox(height: 12),
                  _buildInputField('Nama Tiket', _namaTicketController,
                      isDark, textColor, surfaceColor, borderColor,
                      hint: 'Contoh: VIP, Regular, dll'),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: _buildInputField(
                            'Harga (Rp)', _hargaController,
                            isDark, textColor, surfaceColor, borderColor,
                            type: TextInputType.number),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildInputField(
                            'Stok', _stokController,
                            isDark, textColor, surfaceColor, borderColor,
                            type: TextInputType.number),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // Status
                  Text('Status Event',
                      style: TextStyle(
                          color: textColor,
                          fontSize: 13,
                          fontWeight: FontWeight.w500)),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      _statusChip('draft', 'Draft', isDark, textColor,
                          surfaceColor, borderColor),
                      const SizedBox(width: 12),
                      _statusChip('publikasi', 'Publikasi', isDark,
                          textColor, surfaceColor, borderColor),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInputField(
    String label,
    TextEditingController controller,
    bool isDark,
    Color textColor,
    Color surfaceColor,
    Color borderColor, {
    int maxLines = 1,
    TextInputType type = TextInputType.text,
    String? hint,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: TextStyle(
                color: textColor,
                fontSize: 13,
                fontWeight: FontWeight.w500)),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          maxLines: maxLines,
          keyboardType: type,
          style: TextStyle(color: textColor, fontSize: 14),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(
                color: isDark ? AppColors.mutedDark : AppColors.mutedLight,
                fontSize: 13),
            filled: true,
            fillColor: surfaceColor,
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: borderColor),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: borderColor),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide:
                  const BorderSide(color: AppColors.primary, width: 2),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDatePicker(
    String label,
    DateTime? value,
    ValueChanged<DateTime> onPick,
    bool isDark,
    Color textColor,
    Color surfaceColor,
    Color borderColor,
    Color mutedColor,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: TextStyle(
                color: textColor,
                fontSize: 13,
                fontWeight: FontWeight.w500)),
        const SizedBox(height: 8),
        GestureDetector(
          onTap: () async {
            final date = await showDatePicker(
              context: context,
              initialDate: value ?? DateTime.now(),
              firstDate: DateTime.now(),
              lastDate: DateTime.now().add(const Duration(days: 365 * 2)),
              builder: (ctx, child) {
                return Theme(
                  data: Theme.of(ctx).copyWith(
                    colorScheme: Theme.of(ctx).colorScheme.copyWith(
                          primary: AppColors.primary,
                        ),
                  ),
                  child: child!,
                );
              },
            );
            if (date != null) onPick(date);
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: surfaceColor,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: borderColor),
            ),
            child: Row(
              children: [
                Icon(Icons.calendar_today_outlined,
                    size: 16, color: mutedColor),
                const SizedBox(width: 8),
                Text(
                  value != null
                      ? DateFormat('dd/MM/yyyy').format(value)
                      : 'Pilih',
                  style: TextStyle(
                      color: value != null ? textColor : mutedColor,
                      fontSize: 13),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _statusChip(String value, String label, bool isDark, Color textColor,
      Color surfaceColor, Color borderColor) {
    final selected = _status == value;
    return GestureDetector(
      onTap: () => setState(() => _status = value),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        decoration: BoxDecoration(
          color: selected ? AppColors.primary : surfaceColor,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
              color: selected ? AppColors.primary : borderColor),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: selected ? Colors.white : textColor,
            fontSize: 13,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  Future<void> _handleSubmit(String status) async {
    if (_namaController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Nama event tidak boleh kosong'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    final eventData = {
      'nama': _namaController.text.trim(),
      'kategori': _kategori,
      'deskripsi': _deskripsiController.text.trim(),
      'tanggal_mulai': _tanggalMulai?.toIso8601String(),
      'tanggal_selesai': _tanggalSelesai?.toIso8601String(),
      'lokasi': _lokasiController.text.trim(),
      'kapasitas': int.tryParse(_kapasitasController.text) ?? 0,
      'status': status,
    };

    final eventResult = await EventService.createEvent(eventData);

    if (!eventResult['success']) {
      _showError(eventResult['message'] ?? 'Gagal membuat event');
      return;
    }

    // Create ticket if publishing
    if (status == 'publikasi' &&
        _namaTicketController.text.trim().isNotEmpty) {
      final eventId = eventResult['data']['id'];
      await EventService.createTicket({
        'event_id': eventId,
        'nama': _namaTicketController.text.trim(),
        'harga': int.tryParse(_hargaController.text) ?? 0,
        'stok': int.tryParse(_stokController.text) ?? 0,
      });
    }

    if (mounted) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(status == 'draft'
              ? 'Event tersimpan sebagai draft'
              : 'Event berhasil dipublikasikan!'),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.pop(context);
    }
  }

  void _showError(String msg) {
    if (mounted) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(msg), backgroundColor: Colors.red),
      );
    }
  }
}
