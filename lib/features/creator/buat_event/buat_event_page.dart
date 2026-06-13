import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:pentasera_app/main.dart';
import 'package:pentasera_app/services/event_service.dart';
import 'package:pentasera_app/core/app_router.dart';

// ─── Model untuk tiket sementara sebelum submit ───────────────────────
class _TicketDraft {
  String nama;
  bool isGratis;
  int harga;
  int kuota;
  DateTime? saleStart;
  DateTime? saleEnd;

  _TicketDraft({
    this.nama = '',
    this.isGratis = false,
    this.harga = 0,
    this.kuota = 0,
    this.saleStart,
    this.saleEnd,
  });
}

class BuatEventPage extends StatefulWidget {
  const BuatEventPage({super.key});

  @override
  State<BuatEventPage> createState() => _BuatEventPageState();
}

class _BuatEventPageState extends State<BuatEventPage>
    with SingleTickerProviderStateMixin {
  int _currentStep = 0;
  bool _isLoading = false;
  late TabController _tabController;

  // Image picker
  File? _selectedImage;
  final ImagePicker _imagePicker = ImagePicker();

  // ─── Step 1: Info Event ───────────────────────────────────────────────
  final _namaController = TextEditingController();
  final _deskripsiController = TextEditingController();
  final _lokasiController = TextEditingController();

  // Kategori sesuai web backend
  String _kategori = 'Seni Pertunjukan';
  final List<String> _categories = [
    'Seni Pertunjukan',
    'Festival Budaya',
    'Pameran Seni',
    'Workshop',
  ];

  DateTime? _tanggalMulai;
  TimeOfDay? _waktuMulai;

  // ─── Step 2: Tiket ───────────────────────────────────────────────────
  final List<_TicketDraft> _tickets = [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    // Tambah 1 tiket default
    _tickets.add(_TicketDraft(nama: '', isGratis: false, harga: 0, kuota: 0));
  }

  @override
  void dispose() {
    _namaController.dispose();
    _deskripsiController.dispose();
    _lokasiController.dispose();
    _tabController.dispose();
    super.dispose();
  }

  // ─── Build ────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? AppColors.textDark : AppColors.textLight;
    final mutedColor = isDark ? AppColors.mutedDark : AppColors.mutedLight;
    final surfaceColor = isDark ? AppColors.surfaceDark : AppColors.surfaceLight;
    final borderColor = isDark ? AppColors.borderDark : AppColors.borderLight;
    final bgColor =
        isDark ? AppColors.backgroundDark : AppColors.backgroundLight;

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          'Buat Event',
          style: TextStyle(
              color: textColor, fontWeight: FontWeight.bold, fontSize: 18),
        ),
        centerTitle: true,
        iconTheme: IconThemeData(color: textColor),
      ),
      body: Theme(
        data: Theme.of(context).copyWith(
          colorScheme:
              Theme.of(context).colorScheme.copyWith(primary: AppColors.primary),
        ),
        child: Stepper(
          currentStep: _currentStep,
          onStepContinue: () {
            if (_currentStep < 1) setState(() => _currentStep += 1);
          },
          onStepCancel: () {
            if (_currentStep > 0) setState(() => _currentStep -= 1);
          },
          controlsBuilder: (context, details) =>
              _buildControls(context, details, mutedColor),
          steps: [
            // Step 1
            Step(
              title: Text('Informasi Event',
                  style: TextStyle(
                      color: textColor, fontWeight: FontWeight.w600)),
              isActive: _currentStep >= 0,
              state:
                  _currentStep > 0 ? StepState.complete : StepState.indexed,
              content: _buildStep1(
                  isDark, textColor, mutedColor, surfaceColor, borderColor),
            ),
            // Step 2
            Step(
              title: Text('Tiket & Publikasi',
                  style: TextStyle(
                      color: textColor, fontWeight: FontWeight.w600)),
              isActive: _currentStep >= 1,
              content: _buildStep2(
                  isDark, textColor, mutedColor, surfaceColor, borderColor),
            ),
          ],
        ),
      ),
    );
  }

  // ─── Controls ─────────────────────────────────────────────────────────
  Widget _buildControls(BuildContext context, ControlsDetails details,
      Color mutedColor) {
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
                onPressed: _isLoading ? null : () => _handleSubmit('draft'),
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
                onPressed:
                    _isLoading ? null : () => _handleSubmit('published'),
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
                        style: TextStyle(fontWeight: FontWeight.bold)),
              ),
            ),
          ],
          if (_currentStep > 0) ...[
            const SizedBox(width: 12),
            TextButton(
              onPressed: details.onStepCancel,
              child: Text('Kembali', style: TextStyle(color: mutedColor)),
            ),
          ],
        ],
      ),
    );
  }

  // ══════════════════════════════════════════════════════════════════════
  // STEP 1 — INFORMASI EVENT
  // ══════════════════════════════════════════════════════════════════════
  Widget _buildStep1(bool isDark, Color textColor, Color mutedColor,
      Color surfaceColor, Color borderColor) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ── Banner Upload ─────────────────────────────────────────────
        _sectionLabel('Banner Event', textColor),
        const SizedBox(height: 8),
        GestureDetector(
          onTap: _pickImage,
          child: Container(
            height: 180,
            width: double.infinity,
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.04),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: AppColors.primary.withOpacity(0.25),
                style: BorderStyle.solid,
              ),
            ),
            child: _selectedImage == null
                ? Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: 52,
                        height: 52,
                        decoration: BoxDecoration(
                          color: AppColors.primary.withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(Icons.image_outlined,
                            color: AppColors.primary.withOpacity(0.7),
                            size: 28),
                      ),
                      const SizedBox(height: 12),
                      Text('Klik untuk unggah banner',
                          style: TextStyle(
                              color: mutedColor,
                              fontSize: 13,
                              fontWeight: FontWeight.w500)),
                      const SizedBox(height: 4),
                      Text('Rasio 16:9, Maks. 5MB (JPG, PNG)',
                          style: TextStyle(color: mutedColor, fontSize: 11)),
                    ],
                  )
                : Stack(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: Image.file(_selectedImage!,
                            fit: BoxFit.cover,
                            width: double.infinity,
                            height: 180),
                      ),
                      Positioned(
                        top: 8,
                        right: 8,
                        child: GestureDetector(
                          onTap: () => setState(() => _selectedImage = null),
                          child: Container(
                            padding: const EdgeInsets.all(5),
                            decoration: BoxDecoration(
                              color: Colors.red,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: const Icon(Icons.close,
                                color: Colors.white, size: 16),
                          ),
                        ),
                      ),
                      Positioned(
                        bottom: 8,
                        right: 8,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 5),
                          decoration: BoxDecoration(
                            color: Colors.black54,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Text('Ganti',
                              style: TextStyle(
                                  color: Colors.white, fontSize: 11)),
                        ),
                      ),
                    ],
                  ),
          ),
        ),
        const SizedBox(height: 20),

        // ── Nama Event + Kategori (2 kolom) ──────────────────────────
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              flex: 3,
              child: _buildInputField('Nama Event *', _namaController, isDark,
                  textColor, surfaceColor, borderColor,
                  hint: 'Contoh: Pentas Tari Kecak'),
            ),
            const SizedBox(width: 12),
            Expanded(
              flex: 2,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _sectionLabel('Kategori *', textColor),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14),
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
                        style: TextStyle(color: textColor, fontSize: 13),
                        items: _categories
                            .map((c) => DropdownMenuItem(
                                value: c, child: Text(c)))
                            .toList(),
                        onChanged: (v) => setState(() => _kategori = v!),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),

        // ── Tanggal + Waktu (row) ─────────────────────────────────────
        Row(
          children: [
            Expanded(
              child: _buildDatePicker(
                'Tanggal Event *',
                _tanggalMulai,
                (d) => setState(() => _tanggalMulai = d),
                isDark, textColor, surfaceColor, borderColor, mutedColor,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildTimePicker(
                'Waktu Mulai *',
                _waktuMulai,
                (t) => setState(() => _waktuMulai = t),
                isDark, textColor, surfaceColor, borderColor, mutedColor,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),

        // ── Lokasi ───────────────────────────────────────────────────
        _buildInputField('Lokasi *', _lokasiController, isDark, textColor,
            surfaceColor, borderColor,
            hint: 'Nama tempat/gedung',
            prefixIcon: Icons.location_on_outlined),
        const SizedBox(height: 16),

        // ── Deskripsi ─────────────────────────────────────────────────
        _buildInputField('Deskripsi Event', _deskripsiController, isDark,
            textColor, surfaceColor, borderColor,
            maxLines: 5, hint: 'Ceritakan detail event Anda...'),
        const SizedBox(height: 8),
      ],
    );
  }

  // ══════════════════════════════════════════════════════════════════════
  // STEP 2 — TIKET & PUBLIKASI
  // ══════════════════════════════════════════════════════════════════════
  Widget _buildStep2(bool isDark, Color textColor, Color mutedColor,
      Color surfaceColor, Color borderColor) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ── Preview Event ─────────────────────────────────────────────
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                AppColors.primary.withOpacity(0.08),
                AppColors.primary.withOpacity(0.03),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppColors.primary.withOpacity(0.15)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text('Preview',
                        style: TextStyle(
                            color: AppColors.primary,
                            fontSize: 10,
                            fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Text(
                _namaController.text.isEmpty
                    ? 'Nama Event'
                    : _namaController.text,
                style: GoogleFonts.playfairDisplay(
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                  color: textColor,
                ),
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  Icon(Icons.category_outlined, size: 12, color: mutedColor),
                  const SizedBox(width: 4),
                  Text(_kategori,
                      style: TextStyle(color: mutedColor, fontSize: 11)),
                  if (_lokasiController.text.isNotEmpty) ...[
                    Text('  •  ',
                        style: TextStyle(color: mutedColor, fontSize: 11)),
                    Icon(Icons.location_on_outlined,
                        size: 12, color: mutedColor),
                    const SizedBox(width: 2),
                    Flexible(
                      child: Text(_lokasiController.text,
                          style: TextStyle(color: mutedColor, fontSize: 11),
                          overflow: TextOverflow.ellipsis),
                    ),
                  ],
                ],
              ),
              if (_tanggalMulai != null) ...[
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(Icons.calendar_today_outlined,
                        size: 12, color: mutedColor),
                    const SizedBox(width: 4),
                    Text(
                      DateFormat('EEEE, dd MMM yyyy').format(_tanggalMulai!) +
                          (_waktuMulai != null
                              ? '  ${_waktuMulai!.format(context)}'
                              : ''),
                      style: TextStyle(color: mutedColor, fontSize: 11),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
        const SizedBox(height: 24),

        // ── Daftar Tiket ──────────────────────────────────────────────
        Row(
          children: [
            Text('Tiket Event',
                style: TextStyle(
                    color: textColor,
                    fontSize: 15,
                    fontWeight: FontWeight.bold)),
            const Spacer(),
            TextButton.icon(
              onPressed: () {
                setState(() {
                  _tickets.add(_TicketDraft());
                });
              },
              icon: const Icon(Icons.add, size: 16),
              label: const Text('Tambah Tiket', style: TextStyle(fontSize: 12)),
              style: TextButton.styleFrom(
                foregroundColor: AppColors.primary,
                padding: const EdgeInsets.symmetric(horizontal: 8),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),

        ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: _tickets.length,
          separatorBuilder: (_, __) => const SizedBox(height: 16),
          itemBuilder: (context, index) => _buildTicketCard(
            index,
            isDark,
            textColor,
            mutedColor,
            surfaceColor,
            borderColor,
          ),
        ),

        const SizedBox(height: 8),
      ],
    );
  }

  // ─── Ticket Card ──────────────────────────────────────────────────────
  Widget _buildTicketCard(int index, bool isDark, Color textColor,
      Color mutedColor, Color surfaceColor, Color borderColor) {
    final ticket = _tickets[index];

    return _TicketCardWidget(
      key: ValueKey(index),
      ticket: ticket,
      index: index,
      canDelete: _tickets.length > 1,
      onDelete: () => setState(() => _tickets.removeAt(index)),
      onChanged: () => setState(() {}),
      isDark: isDark,
      textColor: textColor,
      mutedColor: mutedColor,
      surfaceColor: surfaceColor,
      borderColor: borderColor,
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
        _sectionLabel(label, textColor),
        const SizedBox(height: 8),
        GestureDetector(
          onTap: () async {
            final date = await showDatePicker(
              context: context,
              initialDate: value ?? DateTime.now(),
              firstDate: DateTime.now(),
              lastDate: DateTime.now().add(const Duration(days: 365 * 2)),
              builder: (ctx, child) => Theme(
                data: Theme.of(ctx).copyWith(
                  colorScheme: Theme.of(ctx)
                      .colorScheme
                      .copyWith(primary: AppColors.primary),
                ),
                child: child!,
              ),
            );
            if (date != null) onPick(date);
          },
          child: Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
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
                      : 'Pilih Tanggal',
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

  Widget _buildTimePicker(
    String label,
    TimeOfDay? value,
    ValueChanged<TimeOfDay> onPick,
    bool isDark,
    Color textColor,
    Color surfaceColor,
    Color borderColor,
    Color mutedColor,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionLabel(label, textColor),
        const SizedBox(height: 8),
        GestureDetector(
          onTap: () async {
            final time = await showTimePicker(
              context: context,
              initialTime: value ?? TimeOfDay.now(),
              builder: (ctx, child) => Theme(
                data: Theme.of(ctx).copyWith(
                  colorScheme: Theme.of(ctx)
                      .colorScheme
                      .copyWith(primary: AppColors.primary),
                ),
                child: child!,
              ),
            );
            if (time != null) onPick(time);
          },
          child: Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
            decoration: BoxDecoration(
              color: surfaceColor,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: borderColor),
            ),
            child: Row(
              children: [
                Icon(Icons.access_time_outlined, size: 16, color: mutedColor),
                const SizedBox(width: 8),
                Text(
                  value != null
                      ? value.format(context)
                      : 'Pilih Waktu',
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

  // ─── Image Picker ─────────────────────────────────────────────────────
  Future<void> _pickImage() async {
    try {
      final XFile? pickedFile = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1920,
        maxHeight: 1080,
        imageQuality: 85,
      );
      if (pickedFile != null) {
        setState(() => _selectedImage = File(pickedFile.path));
      }
    } catch (e) {
      debugPrint('[_pickImage] Error: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Gagal memilih gambar'),
          backgroundColor: Colors.red,
        ));
      }
    }
  }

  // ─── Submit ───────────────────────────────────────────────────────────
  Future<void> _handleSubmit(String status) async {
    // Validasi Step 1
    if (_namaController.text.trim().isEmpty) {
      _showSnack('Nama event tidak boleh kosong', isError: true);
      setState(() => _currentStep = 0);
      return;
    }
    if (_lokasiController.text.trim().isEmpty) {
      _showSnack('Lokasi tidak boleh kosong', isError: true);
      setState(() => _currentStep = 0);
      return;
    }
    if (_tanggalMulai == null) {
      _showSnack('Pilih tanggal event terlebih dahulu', isError: true);
      setState(() => _currentStep = 0);
      return;
    }

    // Validasi tiket
    for (int i = 0; i < _tickets.length; i++) {
      final t = _tickets[i];
      if (t.nama.trim().isEmpty) {
        _showSnack('Nama tiket ${i + 1} tidak boleh kosong', isError: true);
        return;
      }
      if (t.kuota <= 0) {
        _showSnack('Jumlah tiket ${i + 1} harus lebih dari 0', isError: true);
        return;
      }
      if (!t.isGratis && t.harga <= 0) {
        _showSnack('Harga tiket ${i + 1} harus lebih dari 0', isError: true);
        return;
      }
    }

    setState(() => _isLoading = true);

    // Format datetime dengan waktu
    final time = _waktuMulai ?? const TimeOfDay(hour: 0, minute: 0);
    final eventDt = DateTime(
      _tanggalMulai!.year,
      _tanggalMulai!.month,
      _tanggalMulai!.day,
      time.hour,
      time.minute,
    );
    final eventDatetime = DateFormat('yyyy-MM-dd HH:mm:ss').format(eventDt);

    debugPrint('[BuatEvent] Creating event: nama=${_namaController.text} '
        'kategori=$_kategori status=$status datetime=$eventDatetime');

    // 1. Create Event
    final eventResult = await EventService.createEvent(
      namaEvent: _namaController.text.trim(),
      lokasi: _lokasiController.text.trim(),
      eventDatetime: eventDatetime,
      deskripsi: _deskripsiController.text.trim().isEmpty
          ? null
          : _deskripsiController.text.trim(),
      kategoriEvent: _kategori,
      status: status,
    );

    debugPrint('[BuatEvent] createEvent result: $eventResult');

    if (!eventResult['success']) {
      _showSnack('Error: ${eventResult['message'] ?? 'Gagal membuat event'}',
          isError: true);
      setState(() => _isLoading = false);
      return;
    }

    final eventData = eventResult['data'];
    final eventId = eventData is Map ? eventData['id'] : null;
    debugPrint('[BuatEvent] eventId=$eventId');

    if (eventId == null) {
      _showSnack('Event dibuat tapi ID tidak ditemukan', isError: true);
      setState(() => _isLoading = false);
      return;
    }

    final parsedEventId = int.tryParse(eventId.toString()) ?? 0;

    // 2. Create Tiket (semua tiket yang ada)
    for (int i = 0; i < _tickets.length; i++) {
      final t = _tickets[i];
      debugPrint('[BuatEvent] Creating ticket[$i]: '
          'nama=${t.nama} harga=${t.isGratis ? 0 : t.harga} kuota=${t.kuota}');

      final saleStartStr = t.saleStart != null
          ? DateFormat('yyyy-MM-dd HH:mm:ss').format(t.saleStart!)
          : null;
      final saleEndStr = t.saleEnd != null
          ? DateFormat('yyyy-MM-dd HH:mm:ss').format(t.saleEnd!)
          : null;

      final ticketResult = await EventService.createTicket(
        eventId: parsedEventId,
        kategori: t.nama.trim(),
        harga: t.isGratis ? 0 : t.harga,
        kuota: t.kuota,
        saleStart: saleStartStr,
        saleEnd: saleEndStr,
      );

      debugPrint('[BuatEvent] createTicket[$i] result: $ticketResult');

      if (!ticketResult['success']) {
        _showSnack(
          'Gagal buat tiket "${t.nama}": ${ticketResult['message']}',
          isError: true,
        );
        setState(() => _isLoading = false);
        return;
      }
    }

    // 3. Upload Image (jika ada)
    if (_selectedImage != null) {
      debugPrint('[BuatEvent] Uploading image for event $parsedEventId');
      final imageResult = await EventService.uploadEventImage(
        eventId: parsedEventId,
        imagePath: _selectedImage!.path,
      );
      debugPrint('[BuatEvent] uploadImage result: $imageResult');
      if (!imageResult['success']) {
        debugPrint('[BuatEvent] WARNING: image upload failed — non-critical');
      }
    }

    // 4. Sukses
    if (mounted) {
      _showSnack(
        status == 'draft'
            ? 'Event tersimpan sebagai draft ✓'
            : 'Event berhasil dipublikasikan!',
        isError: false,
      );
      await Future.delayed(const Duration(seconds: 1));
      if (mounted) {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(
              builder: (_) => const RoleBasedShell(role: 'creator')),
          (route) => false,
        );
      }
    }
  }

  void _showSnack(String message, {required bool isError}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(message),
      backgroundColor: isError ? Colors.red : Colors.green,
      duration: const Duration(seconds: 3),
    ));
  }

  // ─── Helpers ──────────────────────────────────────────────────────────
  Widget _sectionLabel(String text, Color color) {
    return Text(
      text,
      style: TextStyle(
        color: color,
        fontSize: 12,
        fontWeight: FontWeight.w600,
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
    String? hint,
    int maxLines = 1,
    IconData? prefixIcon,
  }) {
    final mutedColor = isDark ? AppColors.mutedDark : AppColors.mutedLight;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionLabel(label, textColor),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          maxLines: maxLines,
          style: TextStyle(color: textColor, fontSize: 14),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(color: mutedColor, fontSize: 13),
            prefixIcon: prefixIcon != null
                ? Icon(prefixIcon, size: 18, color: mutedColor)
                : null,
            filled: true,
            fillColor: surfaceColor,
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: borderColor)),
            enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: borderColor)),
            focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide:
                    const BorderSide(color: AppColors.primary, width: 2)),
          ),
        ),
      ],
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════════
// _TicketCardWidget — StatefulWidget agar TextEditingController stabil
// ══════════════════════════════════════════════════════════════════════════════
class _TicketCardWidget extends StatefulWidget {
  final _TicketDraft ticket;
  final int index;
  final bool canDelete;
  final VoidCallback onDelete;
  final VoidCallback onChanged;
  final bool isDark;
  final Color textColor;
  final Color mutedColor;
  final Color surfaceColor;
  final Color borderColor;

  const _TicketCardWidget({
    super.key,
    required this.ticket,
    required this.index,
    required this.canDelete,
    required this.onDelete,
    required this.onChanged,
    required this.isDark,
    required this.textColor,
    required this.mutedColor,
    required this.surfaceColor,
    required this.borderColor,
  });

  @override
  State<_TicketCardWidget> createState() => _TicketCardWidgetState();
}

class _TicketCardWidgetState extends State<_TicketCardWidget> {
  late TextEditingController _namaController;
  late TextEditingController _hargaController;
  late TextEditingController _kuotaController;

  @override
  void initState() {
    super.initState();
    _namaController = TextEditingController(text: widget.ticket.nama);
    _hargaController = TextEditingController(
        text: widget.ticket.harga == 0 ? '' : widget.ticket.harga.toString());
    _kuotaController = TextEditingController(
        text: widget.ticket.kuota == 0 ? '' : widget.ticket.kuota.toString());
  }

  @override
  void dispose() {
    _namaController.dispose();
    _hargaController.dispose();
    _kuotaController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final t = widget.ticket;
    final textColor = widget.textColor;
    final surfaceColor = widget.surfaceColor;
    final borderColor = widget.borderColor;
    final isDark = widget.isDark;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: surfaceColor,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Header ────────────────────────────────────────────────────
          Row(
            children: [
              Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text('${widget.index + 1}',
                      style: const TextStyle(
                          color: AppColors.primary,
                          fontSize: 12,
                          fontWeight: FontWeight.bold)),
                ),
              ),
              const SizedBox(width: 8),
              Text('Tiket ${widget.index + 1}',
                  style: TextStyle(
                      color: textColor,
                      fontSize: 13,
                      fontWeight: FontWeight.w600)),
              const Spacer(),
              if (widget.canDelete)
                GestureDetector(
                  onTap: widget.onDelete,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: Colors.red.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: const Icon(Icons.delete_outline,
                        color: Colors.red, size: 16),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 16),

          // ── Toggle Tipe ───────────────────────────────────────────────
          Text('Tipe Tiket',
              style: TextStyle(
                  color: textColor, fontSize: 12, fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: _typeCard(
                  label: 'Berbayar',
                  icon: Icons.payments_outlined,
                  selected: !t.isGratis,
                  onTap: () {
                    setState(() => t.isGratis = false);
                    widget.onChanged();
                  },
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _typeCard(
                  label: 'Gratis',
                  icon: Icons.card_giftcard_outlined,
                  selected: t.isGratis,
                  onTap: () {
                    setState(() {
                      t.isGratis = true;
                      t.harga = 0;
                      _hargaController.clear();
                    });
                    widget.onChanged();
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // ── Nama Tiket ────────────────────────────────────────────────
          _label('Nama Tiket *', textColor),
          const SizedBox(height: 8),
          _inputField(
            controller: _namaController,
            hint: t.isGratis
                ? 'Contoh: Tiket Gratis'
                : 'Contoh: VIP, Regular, Early Bird',
            isDark: isDark,
            textColor: textColor,
            surfaceColor: surfaceColor,
            borderColor: borderColor,
            onChanged: (v) => t.nama = v,
          ),
          const SizedBox(height: 12),

          // ── Harga + Kuota ────────────────────────────────────────────
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (!t.isGratis) ...[
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _label('Harga (Rp) *', textColor),
                      const SizedBox(height: 8),
                      _inputField(
                        controller: _hargaController,
                        hint: '50000',
                        isDark: isDark,
                        textColor: textColor,
                        surfaceColor: surfaceColor,
                        borderColor: borderColor,
                        keyboardType: TextInputType.number,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly
                        ],
                        onChanged: (v) => t.harga = int.tryParse(v) ?? 0,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
              ],
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _label('Jumlah Tiket *', textColor),
                    const SizedBox(height: 8),
                    _inputField(
                      controller: _kuotaController,
                      hint: '100',
                      isDark: isDark,
                      textColor: textColor,
                      surfaceColor: surfaceColor,
                      borderColor: borderColor,
                      keyboardType: TextInputType.number,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      onChanged: (v) => t.kuota = int.tryParse(v) ?? 0,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // ── Tanggal Penjualan ─────────────────────────────────────────
          _label('Periode Penjualan', textColor),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: _buildSaleDatePicker(
                  label: 'Mulai Jual',
                  value: t.saleStart,
                  onPicked: (dt) {
                    setState(() => t.saleStart = dt);
                    widget.onChanged();
                  },
                  isDark: isDark,
                  textColor: textColor,
                  surfaceColor: surfaceColor,
                  borderColor: borderColor,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildSaleDatePicker(
                  label: 'Selesai Jual',
                  value: t.saleEnd,
                  onPicked: (dt) {
                    setState(() => t.saleEnd = dt);
                    widget.onChanged();
                  },
                  isDark: isDark,
                  textColor: textColor,
                  surfaceColor: surfaceColor,
                  borderColor: borderColor,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _label(String text, Color color) {
    return Text(text,
        style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.w600));
  }

  Widget _typeCard({
    required String label,
    required IconData icon,
    required bool selected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        decoration: BoxDecoration(
          color: selected
              ? AppColors.primary
              : AppColors.primary.withOpacity(0.03),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: selected
                ? AppColors.primary
                : AppColors.primary.withOpacity(0.2),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon,
                size: 18,
                color: selected ? Colors.white : AppColors.primary),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                color: selected ? Colors.white : AppColors.primary,
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _inputField({
    required TextEditingController controller,
    required String hint,
    required bool isDark,
    required Color textColor,
    required Color surfaceColor,
    required Color borderColor,
    TextInputType keyboardType = TextInputType.text,
    List<TextInputFormatter>? inputFormatters,
    ValueChanged<String>? onChanged,
  }) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      inputFormatters: inputFormatters,
      style: TextStyle(color: textColor, fontSize: 14),
      onChanged: onChanged,
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
            borderSide: BorderSide(color: borderColor)),
        enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: borderColor)),
        focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: AppColors.primary, width: 2)),
      ),
    );
  }

  Widget _buildSaleDatePicker({
    required String label,
    required DateTime? value,
    required ValueChanged<DateTime> onPicked,
    required bool isDark,
    required Color textColor,
    required Color surfaceColor,
    required Color borderColor,
  }) {
    final mutedColor = isDark ? AppColors.mutedDark : AppColors.mutedLight;
    return GestureDetector(
      onTap: () async {
        final date = await showDatePicker(
          context: context,
          initialDate: value ?? DateTime.now(),
          firstDate: DateTime(2020),
          lastDate: DateTime.now().add(const Duration(days: 365 * 3)),
          builder: (ctx, child) => Theme(
            data: Theme.of(ctx).copyWith(
              colorScheme: Theme.of(ctx)
                  .colorScheme
                  .copyWith(primary: AppColors.primary),
            ),
            child: child!,
          ),
        );
        if (date == null || !mounted) return;
        final time = await showTimePicker(
          context: context,
          initialTime: value != null
              ? TimeOfDay.fromDateTime(value)
              : TimeOfDay.now(),
          builder: (ctx, child) => Theme(
            data: Theme.of(ctx).copyWith(
              colorScheme: Theme.of(ctx)
                  .colorScheme
                  .copyWith(primary: AppColors.primary),
            ),
            child: child!,
          ),
        );
        if (time == null) return;
        onPicked(DateTime(date.year, date.month, date.day, time.hour, time.minute));
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        decoration: BoxDecoration(
          color: surfaceColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: borderColor),
        ),
        child: Row(
          children: [
            Icon(Icons.calendar_today_outlined, size: 14, color: mutedColor),
            const SizedBox(width: 6),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label,
                      style: TextStyle(
                          color: mutedColor,
                          fontSize: 9,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.5)),
                  const SizedBox(height: 2),
                  Text(
                    value != null
                        ? DateFormat('dd/MM/yy HH:mm').format(value)
                        : 'Pilih',
                    style: TextStyle(
                      color: value != null ? textColor : mutedColor,
                      fontSize: 12,
                      fontWeight: value != null ? FontWeight.w600 : FontWeight.normal,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
