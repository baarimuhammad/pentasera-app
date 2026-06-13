import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:pentasera_app/main.dart';
import 'package:pentasera_app/services/event_service.dart';

class TabTiketHarga extends StatefulWidget {
  final int eventId;
  final List<Map<String, dynamic>> tickets;
  final VoidCallback onTicketsChanged;

  const TabTiketHarga({
    super.key,
    required this.eventId,
    required this.tickets,
    required this.onTicketsChanged,
  });

  @override
  State<TabTiketHarga> createState() => _TabTiketHargaState();
}

class _TabTiketHargaState extends State<TabTiketHarga>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  final _currencyFormatter =
      NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);

  int _parseNum(dynamic v) {
    if (v == null) return 0;
    if (v is int) return v;
    if (v is double) return v.toInt();
    return int.tryParse(v.toString().replaceAll(RegExp(r'[^0-9]'), '')) ?? 0;
  }

  // ── Delete Ticket ──
  Future<void> _deleteTicket(Map<String, dynamic> ticket) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor:
            Theme.of(context).brightness == Brightness.dark
                ? AppColors.surfaceDark
                : AppColors.surfaceLight,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Hapus Tiket'),
        content: Text(
            'Yakin ingin menghapus tiket "${ticket['kategori']}"?\n\nTiket yang sudah memiliki pesanan tidak bisa dihapus.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red, foregroundColor: Colors.white),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );

    if (confirmed != true || !mounted) return;

    final result = await EventService.deleteTicket(_parseNum(ticket['id']));
    if (!mounted) return;

    if (result['success'] == true) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Tiket berhasil dihapus!'),
          backgroundColor: Colors.green,
        ),
      );
      widget.onTicketsChanged();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result['message'] ?? 'Gagal menghapus tiket'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  // ── Add / Edit Ticket Bottom Sheet ──
  void _showTicketBottomSheet({Map<String, dynamic>? existingTicket}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => _TicketFormSheet(
        eventId: widget.eventId,
        existingTicket: existingTicket,
        onSaved: () {
          Navigator.pop(ctx);
          widget.onTicketsChanged();
        },
      ),
    );
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

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Header ──
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: surfaceColor,
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(16)),
              border: Border.all(color: borderColor),
            ),
            child: Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: const Icon(Icons.confirmation_number_outlined,
                      color: Colors.white, size: 22),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'KATEGORI TIKET',
                        style: TextStyle(
                          color: textColor,
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Daftar tiket yang tersedia untuk event ini',
                        style: TextStyle(
                          color: mutedColor,
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // ── Ticket Cards ──
          ...widget.tickets.map(
            (ticket) => _buildTicketCard(
                ticket, isDark, textColor, mutedColor, surfaceColor, borderColor),
          ),

          // ── Add Ticket Button ──
          const SizedBox(height: 16),
          InkWell(
            onTap: () => _showTicketBottomSheet(),
            borderRadius: BorderRadius.circular(16),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 28),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: mutedColor.withOpacity(0.3),
                  width: 2,
                  strokeAlign: BorderSide.strokeAlignInside,
                ),
              ),
              child: Column(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: surfaceColor,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: borderColor),
                    ),
                    child:
                        Icon(Icons.add, color: mutedColor.withOpacity(0.5)),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'TAMBAH KATEGORI TIKET',
                    style: TextStyle(
                      color: mutedColor.withOpacity(0.6),
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 1.5,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildTicketCard(
    Map<String, dynamic> ticket,
    bool isDark,
    Color textColor,
    Color mutedColor,
    Color surfaceColor,
    Color borderColor,
  ) {
    final harga = _parseNum(ticket['harga']);
    final kuota = _parseNum(ticket['kuota']);
    final sisaKuota = _parseNum(ticket['sisa_kuota']);
    final sold = kuota - sisaKuota;
    final isFree = harga == 0;
    final isAvailable = sisaKuota > 0;

    return Container(
      margin: const EdgeInsets.only(top: 1),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: surfaceColor,
        border: Border(
          left: BorderSide(color: borderColor),
          right: BorderSide(color: borderColor),
          bottom: BorderSide(color: borderColor),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  ticket['kategori'] ?? 'Tiket',
                  style: TextStyle(
                    color: textColor,
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: isAvailable
                      ? Colors.green.withOpacity(0.1)
                      : Colors.red.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: isAvailable
                        ? Colors.green.withOpacity(0.2)
                        : Colors.red.withOpacity(0.2),
                  ),
                ),
                child: Text(
                  isAvailable ? 'TERSEDIA' : 'HABIS',
                  style: TextStyle(
                    color: isAvailable ? Colors.green[600] : Colors.red[600],
                    fontSize: 9,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              _buildTicketStat(
                'Harga',
                isFree ? 'Gratis' : _currencyFormatter.format(harga),
                AppColors.primary,
                textColor,
                mutedColor,
              ),
              _buildTicketStat(
                  'Kapasitas', '$kuota', Colors.blue, textColor, mutedColor),
              _buildTicketStat(
                  'Terjual', '$sold', AppColors.primary, textColor, mutedColor),
              _buildTicketStat(
                  'Sisa', '$sisaKuota', Colors.grey, textColor, mutedColor),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              _buildActionButton(
                Icons.edit_outlined,
                'Edit',
                AppColors.primary,
                () => _showTicketBottomSheet(existingTicket: ticket),
                isDark,
              ),
              const SizedBox(width: 8),
              _buildActionButton(
                Icons.delete_outline,
                'Hapus',
                Colors.red,
                () => _deleteTicket(ticket),
                isDark,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTicketStat(
      String label, String value, Color accent, Color textColor, Color muted) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label.toUpperCase(),
            style: TextStyle(
              color: muted,
              fontSize: 9,
              fontWeight: FontWeight.w700,
              letterSpacing: 1,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              color: textColor,
              fontSize: 13,
              fontWeight: FontWeight.bold,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton(IconData icon, String label, Color color,
      VoidCallback onTap, bool isDark) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: color.withOpacity(0.08),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 14, color: color),
            const SizedBox(width: 4),
            Text(
              label,
              style: TextStyle(
                color: color,
                fontSize: 11,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────
// Ticket Form Bottom Sheet
// ─────────────────────────────────────────────────────
class _TicketFormSheet extends StatefulWidget {
  final int eventId;
  final Map<String, dynamic>? existingTicket;
  final VoidCallback onSaved;

  const _TicketFormSheet({
    required this.eventId,
    this.existingTicket,
    required this.onSaved,
  });

  @override
  State<_TicketFormSheet> createState() => _TicketFormSheetState();
}

class _TicketFormSheetState extends State<_TicketFormSheet>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _isPaid = true;
  bool _isSaving = false;

  final _nameController = TextEditingController();
  final _qtyController = TextEditingController(text: '0');
  final _priceController = TextEditingController();
  final _descController = TextEditingController();
  DateTime? _startDate;
  DateTime? _endDate;

  bool get _isEditing => widget.existingTicket != null;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);

    if (_isEditing) {
      final t = widget.existingTicket!;
      _nameController.text = (t['kategori'] ?? '').toString();
      _qtyController.text = (t['kuota'] ?? 0).toString();
      final harga = int.tryParse(t['harga']?.toString() ?? '0') ?? 0;
      _isPaid = harga > 0;
      _priceController.text = harga > 0 ? harga.toString() : '';

      // Pre-fill sale dates from existing ticket
      if (t['sale_start'] != null && t['sale_start'].toString().isNotEmpty) {
        _startDate = DateTime.tryParse(t['sale_start'].toString());
      }
      if (t['sale_end'] != null && t['sale_end'].toString().isNotEmpty) {
        _endDate = DateTime.tryParse(t['sale_end'].toString());
      }
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    _nameController.dispose();
    _qtyController.dispose();
    _priceController.dispose();
    _descController.dispose();
    super.dispose();
  }

  bool get _isDetailValid {
    final hasName = _nameController.text.trim().isNotEmpty;
    final hasQty = (int.tryParse(_qtyController.text) ?? 0) > 0;
    final hasPrice = !_isPaid ||
        (int.tryParse(_priceController.text.replaceAll(RegExp(r'[^0-9]'), '')) ??
                0) >
            0;
    return hasName && hasQty && hasPrice;
  }

  bool get _isSalesValid => _startDate != null && _endDate != null;

  Future<void> _saveTicket() async {
    if (_isSaving) return;
    setState(() => _isSaving = true);

    final name = _nameController.text.trim();
    final qty = int.tryParse(_qtyController.text) ?? 0;
    final price = _isPaid
        ? (int.tryParse(
                _priceController.text.replaceAll(RegExp(r'[^0-9]'), '')) ??
            0)
        : 0;

    Map<String, dynamic> result;

    final saleStartStr = _startDate != null
        ? '${_startDate!.year.toString().padLeft(4, '0')}-${_startDate!.month.toString().padLeft(2, '0')}-${_startDate!.day.toString().padLeft(2, '0')} ${_startDate!.hour.toString().padLeft(2, '0')}:${_startDate!.minute.toString().padLeft(2, '0')}:00'
        : null;
    final saleEndStr = _endDate != null
        ? '${_endDate!.year.toString().padLeft(4, '0')}-${_endDate!.month.toString().padLeft(2, '0')}-${_endDate!.day.toString().padLeft(2, '0')} ${_endDate!.hour.toString().padLeft(2, '0')}:${_endDate!.minute.toString().padLeft(2, '0')}:00'
        : null;

    if (_isEditing) {
      final ticketId =
          int.tryParse(widget.existingTicket!['id']?.toString() ?? '0') ?? 0;
      result = await EventService.updateTicket(
        ticketId: ticketId,
        kategori: name,
        harga: price,
        kuota: qty,
        saleStart: saleStartStr,
        saleEnd: saleEndStr,
      );
    } else {
      result = await EventService.createTicket(
        eventId: widget.eventId,
        kategori: name,
        harga: price,
        kuota: qty,
        saleStart: saleStartStr,
        saleEnd: saleEndStr,
      );
    }

    if (!mounted) return;
    setState(() => _isSaving = false);

    if (result['success'] == true) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_isEditing
              ? 'Tiket berhasil diperbarui!'
              : 'Tiket berhasil ditambahkan!'),
          backgroundColor: Colors.green,
        ),
      );
      widget.onSaved();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result['message'] ?? 'Gagal menyimpan tiket'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _pickDate(bool isStart) async {
    final initial = (isStart ? _startDate : _endDate) ?? DateTime.now();
    final date = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
      builder: (ctx, child) => Theme(
        data: Theme.of(ctx).copyWith(
          colorScheme:
              Theme.of(ctx).colorScheme.copyWith(primary: AppColors.primary),
        ),
        child: child!,
      ),
    );
    if (date == null || !mounted) return;

    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(initial),
      builder: (ctx, child) => Theme(
        data: Theme.of(ctx).copyWith(
          colorScheme:
              Theme.of(ctx).colorScheme.copyWith(primary: AppColors.primary),
        ),
        child: child!,
      ),
    );
    if (time == null) return;

    final dt =
        DateTime(date.year, date.month, date.day, time.hour, time.minute);
    setState(() {
      if (isStart) {
        _startDate = dt;
      } else {
        _endDate = dt;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? AppColors.textDark : AppColors.textLight;
    final mutedColor = isDark ? AppColors.mutedDark : AppColors.mutedLight;
    final surfaceColor =
        isDark ? AppColors.surfaceDark : AppColors.surfaceLight;
    final borderColor = isDark ? AppColors.borderDark : AppColors.borderLight;
    final inputFill = isDark
        ? AppColors.backgroundDark.withOpacity(0.5)
        : const Color(0xFFFAFAF8);
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.85,
      ),
      decoration: BoxDecoration(
        color: surfaceColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // ── Handle ──
          Container(
            margin: const EdgeInsets.only(top: 12),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: mutedColor.withOpacity(0.3),
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          // ── Category Selection (only for new) ──
          if (!_isEditing) ...[
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 8),
              child: Text(
                'Pilih Kategori Tiket',
                style: TextStyle(
                  color: textColor,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  Expanded(
                    child: _buildCategoryCard(
                      'Berbayar',
                      Icons.payments_outlined,
                      _isPaid,
                      () => setState(() => _isPaid = true),
                      isDark,
                      textColor,
                      mutedColor,
                      borderColor,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildCategoryCard(
                      'Gratis',
                      Icons.card_giftcard_outlined,
                      !_isPaid,
                      () => setState(() => _isPaid = false),
                      isDark,
                      textColor,
                      mutedColor,
                      borderColor,
                    ),
                  ),
                ],
              ),
            ),
          ],

          // ── Tabs ──
          Container(
            margin: const EdgeInsets.only(top: 16),
            decoration: BoxDecoration(
              border: Border(bottom: BorderSide(color: borderColor)),
            ),
            child: TabBar(
              controller: _tabController,
              labelColor: AppColors.primary,
              unselectedLabelColor: mutedColor,
              indicatorColor: AppColors.primary,
              indicatorWeight: 2,
              labelStyle: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w800,
                letterSpacing: 1,
              ),
              tabs: const [
                Tab(text: 'DETAIL TIKET'),
                Tab(text: 'TANGGAL PENJUALAN'),
              ],
            ),
          ),

          // ── Tab Content ──
          Flexible(
            child: Padding(
              padding: EdgeInsets.only(bottom: bottomInset),
              child: TabBarView(
                controller: _tabController,
                children: [
                  // Tab 1: Detail
                  SingleChildScrollView(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildFormLabel('Nama Tiket *', mutedColor),
                        const SizedBox(height: 8),
                        _buildFormInput(
                          controller: _nameController,
                          hint: 'Contoh: Early Bird',
                          inputFill: inputFill,
                          textColor: textColor,
                          isDark: isDark,
                        ),
                        const SizedBox(height: 20),
                        _buildFormLabel('Jumlah Tiket *', mutedColor),
                        const SizedBox(height: 8),
                        _buildFormInput(
                          controller: _qtyController,
                          hint: '0',
                          inputFill: inputFill,
                          textColor: textColor,
                          isDark: isDark,
                          keyboardType: TextInputType.number,
                        ),
                        if (_isPaid) ...[
                          const SizedBox(height: 20),
                          _buildFormLabel('Harga *', mutedColor),
                          const SizedBox(height: 8),
                          _buildFormInput(
                            controller: _priceController,
                            hint: 'Rp 0',
                            inputFill: inputFill,
                            textColor: textColor,
                            isDark: isDark,
                            keyboardType: TextInputType.number,
                            prefixText: 'Rp ',
                          ),
                        ],
                        const SizedBox(height: 20),
                        _buildFormLabel('Deskripsi Tiket', mutedColor),
                        const SizedBox(height: 8),
                        _buildFormInput(
                          controller: _descController,
                          hint: 'Info tambahan tentang tiket ini...',
                          inputFill: inputFill,
                          textColor: textColor,
                          isDark: isDark,
                          maxLines: 3,
                        ),
                        const SizedBox(height: 24),
                        SizedBox(
                          width: double.infinity,
                          height: 50,
                          child: ElevatedButton(
                            onPressed: _isDetailValid
                                ? () => _tabController.animateTo(1)
                                : null,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primary,
                              foregroundColor: Colors.white,
                              disabledBackgroundColor:
                                  AppColors.primary.withOpacity(0.3),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              elevation: 0,
                            ),
                            child: const Text(
                              'SELANJUTNYA',
                              style: TextStyle(
                                fontWeight: FontWeight.w800,
                                letterSpacing: 1.5,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Tab 2: Sales Dates
                  SingleChildScrollView(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildFormLabel('Tanggal Mulai *', mutedColor),
                        const SizedBox(height: 8),
                        _buildDateButton(
                          _startDate,
                          'Pilih tanggal mulai',
                          () => _pickDate(true),
                          inputFill,
                          textColor,
                          mutedColor,
                        ),
                        const SizedBox(height: 20),
                        _buildFormLabel('Tanggal Berakhir *', mutedColor),
                        const SizedBox(height: 8),
                        _buildDateButton(
                          _endDate,
                          'Pilih tanggal berakhir',
                          () => _pickDate(false),
                          inputFill,
                          textColor,
                          mutedColor,
                        ),
                        const SizedBox(height: 20),

                        // Info box
                        Container(
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withOpacity(0.05),
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(
                              color: AppColors.primary.withOpacity(0.1),
                            ),
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Icon(Icons.info_outline,
                                  size: 18,
                                  color: AppColors.primary.withOpacity(0.7)),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  'Pastikan jadwal penjualan selaras dengan waktu pelaksanaan event.',
                                  style: TextStyle(
                                    color: AppColors.primary.withOpacity(0.7),
                                    fontSize: 11,
                                    height: 1.4,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 28),
                        Row(
                          children: [
                            // Back button
                            InkWell(
                              onTap: () => _tabController.animateTo(0),
                              borderRadius: BorderRadius.circular(12),
                              child: Container(
                                width: 50,
                                height: 50,
                                decoration: BoxDecoration(
                                  color: isDark
                                      ? Colors.grey[800]
                                      : Colors.grey[100],
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Icon(Icons.chevron_left,
                                    color: mutedColor),
                              ),
                            ),
                            const SizedBox(width: 12),
                            // Save button
                            Expanded(
                              child: SizedBox(
                                height: 50,
                                child: ElevatedButton(
                                  onPressed: (_isDetailValid && _isSalesValid &&
                                          !_isSaving)
                                      ? _saveTicket
                                      : null,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: AppColors.primary,
                                    foregroundColor: Colors.white,
                                    disabledBackgroundColor:
                                        AppColors.primary.withOpacity(0.3),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    elevation: 4,
                                    shadowColor:
                                        AppColors.primary.withOpacity(0.3),
                                  ),
                                  child: _isSaving
                                      ? const SizedBox(
                                          width: 20,
                                          height: 20,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2,
                                            color: Colors.white,
                                          ),
                                        )
                                      : Text(
                                          _isEditing
                                              ? 'SIMPAN PERUBAHAN'
                                              : (_isPaid
                                                  ? 'SIMPAN TIKET BERBAYAR'
                                                  : 'SIMPAN TIKET GRATIS'),
                                          style: const TextStyle(
                                            fontWeight: FontWeight.w800,
                                            letterSpacing: 1,
                                            fontSize: 12,
                                          ),
                                        ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ─── Helper Widgets ──────────────────────

  Widget _buildCategoryCard(
    String label,
    IconData icon,
    bool isSelected,
    VoidCallback onTap,
    bool isDark,
    Color textColor,
    Color mutedColor,
    Color borderColor,
  ) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primary.withOpacity(0.05)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected
                ? AppColors.primary
                : borderColor,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: isSelected
                    ? AppColors.primary.withOpacity(0.1)
                    : (isDark ? Colors.grey[800] : Colors.grey[100]),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                icon,
                size: 20,
                color: isSelected ? AppColors.primary : mutedColor,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    isSelected ? 'PILIH' : 'OPSI',
                    style: TextStyle(
                      color: isSelected ? AppColors.primary : mutedColor,
                      fontSize: 8,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 1.5,
                    ),
                  ),
                  Text(
                    label,
                    style: TextStyle(
                      color: isSelected ? textColor : mutedColor,
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isSelected ? AppColors.primary : Colors.transparent,
                border: Border.all(
                  color: isSelected ? AppColors.primary : borderColor,
                  width: 2,
                ),
              ),
              child: isSelected
                  ? const Icon(Icons.check, size: 16, color: Colors.white)
                  : null,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFormLabel(String text, Color mutedColor) {
    return Text(
      text.toUpperCase(),
      style: TextStyle(
        color: mutedColor,
        fontSize: 10,
        fontWeight: FontWeight.w800,
        letterSpacing: 1.2,
      ),
    );
  }

  Widget _buildFormInput({
    required TextEditingController controller,
    required String hint,
    required Color inputFill,
    required Color textColor,
    required bool isDark,
    int maxLines = 1,
    TextInputType? keyboardType,
    String? prefixText,
  }) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      keyboardType: keyboardType,
      onChanged: (_) => setState(() {}),
      style: TextStyle(
        color: textColor,
        fontSize: 14,
        fontWeight: FontWeight.w600,
      ),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(
          color: (isDark ? AppColors.mutedDark : AppColors.mutedLight)
              .withOpacity(0.4),
          fontWeight: FontWeight.normal,
        ),
        prefixText: prefixText,
        prefixStyle: TextStyle(
          color: textColor,
          fontSize: 14,
          fontWeight: FontWeight.w600,
        ),
        filled: true,
        fillColor: inputFill,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide:
              BorderSide(color: AppColors.primary.withOpacity(0.4), width: 2),
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
    );
  }

  Widget _buildDateButton(
    DateTime? date,
    String placeholder,
    VoidCallback onTap,
    Color inputFill,
    Color textColor,
    Color mutedColor,
  ) {
    final display = date != null
        ? '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}  •  ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}'
        : placeholder;

    return InkWell(
      onTap: onTap,
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
              display,
              style: TextStyle(
                color: date != null ? textColor : mutedColor.withOpacity(0.4),
                fontSize: 14,
                fontWeight: date != null ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
