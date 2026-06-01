import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:pentasera_app/main.dart';
import 'package:pentasera_app/services/auth_service.dart';
import 'package:pentasera_app/services/order_service.dart';
import 'package:pentasera_app/features/buyer/checkout/e_ticket_page.dart';

class CheckoutPage extends StatefulWidget {
  final dynamic eventId;
  final dynamic ticketId;
  final String ticketName;
  final int price;
  final int qty;
  final String eventName;

  const CheckoutPage({
    super.key,
    required this.eventId,
    required this.ticketId,
    required this.ticketName,
    required this.price,
    required this.qty,
    required this.eventName,
  });

  @override
  State<CheckoutPage> createState() => _CheckoutPageState();
}

class _CheckoutPageState extends State<CheckoutPage> {
  final _namaController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _ownerNameController = TextEditingController();
  final _ownerEmailController = TextEditingController();

  bool _sameAsBooker = true;
  String _paymentMethod = 'transfer_bank';
  bool _isLoading = false;
  bool _isLoadingProfile = true;

  final _formatter =
      NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    final result = await AuthService.getMe();
    if (result['success'] == true && mounted) {
      final data = result['data'];
      _namaController.text =
          data is Map ? (data['nama'] ?? '').toString() : '';
      _emailController.text =
          data is Map ? (data['email'] ?? '').toString() : '';
    } else {
      _namaController.text = await AuthService.getUserNama() ?? '';
      _emailController.text = await AuthService.getUserEmail() ?? '';
    }
    if (mounted) setState(() => _isLoadingProfile = false);
  }

  int get _total => widget.price * widget.qty;

  @override
  void dispose() {
    _namaController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _ownerNameController.dispose();
    _ownerEmailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? AppColors.textDark : AppColors.textLight;
    final mutedColor = isDark ? AppColors.mutedDark : AppColors.mutedLight;
    final surfaceColor =
        isDark ? AppColors.surfaceDark : AppColors.surfaceLight;
    final borderColor = isDark ? AppColors.borderDark : AppColors.borderLight;

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
        title: const Text(
          'Pentasera',
          style: TextStyle(
            color: AppColors.primary,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        centerTitle: true,
      ),
      body: _isLoadingProfile
          ? const Center(
              child: CircularProgressIndicator(color: AppColors.primary))
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header
                  Text(
                    'Checkout',
                    style: GoogleFonts.playfairDisplay(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: textColor,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Selesaikan pembayaran untuk mengamankan tiket Anda.',
                    style: TextStyle(color: mutedColor, fontSize: 13),
                  ),
                  const SizedBox(height: 24),

                  // Event Info Card
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: surfaceColor,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: borderColor),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 60,
                          height: 60,
                          decoration: BoxDecoration(
                            color: AppColors.primary.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(Icons.event,
                              color: AppColors.primary, size: 28),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(widget.eventName,
                                  style: TextStyle(
                                      color: textColor,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 15),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis),
                              const SizedBox(height: 4),
                              Text(
                                '${widget.ticketName} × ${widget.qty}',
                                style:
                                    TextStyle(color: mutedColor, fontSize: 12),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Data Pemesan
                  _sectionTitle('Data Pemesan', textColor),
                  const SizedBox(height: 12),
                  _buildField('Nama Lengkap', _namaController, isDark,
                      textColor, surfaceColor, borderColor),
                  const SizedBox(height: 12),
                  _buildField('Email', _emailController, isDark, textColor,
                      surfaceColor, borderColor,
                      type: TextInputType.emailAddress),
                  const SizedBox(height: 12),
                  _buildField('Nomor Telepon', _phoneController, isDark,
                      textColor, surfaceColor, borderColor,
                      type: TextInputType.phone, prefix: '+62'),
                  const SizedBox(height: 24),

                  // Data Pemilik Tiket
                  _sectionTitle('Data Pemilik Tiket', textColor),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      SizedBox(
                        height: 24,
                        width: 24,
                        child: Checkbox(
                          value: _sameAsBooker,
                          onChanged: (val) =>
                              setState(() => _sameAsBooker = val!),
                          activeColor: AppColors.primary,
                          side: BorderSide(color: borderColor),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text('Sama dengan Data Pemesan',
                          style: TextStyle(color: textColor, fontSize: 13)),
                    ],
                  ),
                  if (!_sameAsBooker) ...[
                    const SizedBox(height: 12),
                    _buildField('Nama Pemilik', _ownerNameController, isDark,
                        textColor, surfaceColor, borderColor),
                    const SizedBox(height: 12),
                    _buildField('Email Pemilik', _ownerEmailController, isDark,
                        textColor, surfaceColor, borderColor,
                        type: TextInputType.emailAddress),
                  ],
                  const SizedBox(height: 24),

                  // Metode Pembayaran — mapped to backend values
                  _sectionTitle('Metode Pembayaran', textColor),
                  const SizedBox(height: 12),
                  _buildPaymentOption(
                      'transfer_bank',
                      'Transfer Bank',
                      'BCA, Mandiri, BNI, BRI',
                      Icons.account_balance,
                      isDark, textColor, surfaceColor, borderColor),
                  const SizedBox(height: 8),
                  _buildPaymentOption(
                      'gopay',
                      'E-Wallet (GoPay)',
                      'GoPay, OVO, Dana, ShopeePay',
                      Icons.account_balance_wallet,
                      isDark, textColor, surfaceColor, borderColor),
                  const SizedBox(height: 8),
                  _buildPaymentOption(
                      'qris',
                      'QRIS',
                      'Scan QR dari aplikasi apapun',
                      Icons.qr_code,
                      isDark, textColor, surfaceColor, borderColor),
                  const SizedBox(height: 24),

                  // Ringkasan Pesanan
                  _sectionTitle('Ringkasan Pesanan', textColor),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: surfaceColor,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: borderColor),
                    ),
                    child: Column(
                      children: [
                        _summaryRow(
                            widget.ticketName,
                            _formatter.format(_total),
                            textColor,
                            mutedColor),
                        _summaryRow(
                            '${widget.qty}x ${_formatter.format(widget.price)}',
                            '',
                            mutedColor,
                            mutedColor,
                            isSubtext: true),
                        const Padding(
                          padding: EdgeInsets.symmetric(vertical: 12),
                          child: Divider(),
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('Total Pembayaran',
                                style: TextStyle(
                                    color: textColor,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 15)),
                            Text(
                              _formatter.format(_total),
                              style: const TextStyle(
                                color: AppColors.primary,
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 100),
                ],
              ),
            ),

      // Bottom CTA
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: surfaceColor,
          border: Border(top: BorderSide(color: borderColor)),
        ),
        child: SafeArea(
          child: Row(
            children: [
              Expanded(
                flex: 2,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('TOTAL PEMBAYARAN',
                        style: TextStyle(
                            color: mutedColor,
                            fontSize: 10,
                            fontWeight: FontWeight.w600)),
                    Text(
                      _formatter.format(_total),
                      style: const TextStyle(
                        color: AppColors.primary,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                flex: 3,
                child: SizedBox(
                  height: 50,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _handlePayment,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                      elevation: 0,
                    ),
                    child: _isLoading
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                                color: Colors.white, strokeWidth: 2),
                          )
                        : const Text('Bayar Sekarang',
                            style: TextStyle(
                                fontSize: 15, fontWeight: FontWeight.bold)),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _sectionTitle(String title, Color textColor) {
    return Text(title,
        style: TextStyle(
            color: textColor, fontSize: 16, fontWeight: FontWeight.bold));
  }

  Widget _buildField(String label, TextEditingController controller,
      bool isDark, Color textColor, Color surfaceColor, Color borderColor,
      {TextInputType type = TextInputType.text, String? prefix}) {
    return TextField(
      controller: controller,
      keyboardType: type,
      style: TextStyle(color: textColor, fontSize: 14),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(
            color: isDark ? AppColors.mutedDark : AppColors.mutedLight,
            fontSize: 13),
        prefixText: prefix != null ? '$prefix  ' : null,
        prefixStyle: TextStyle(color: textColor, fontSize: 14),
        filled: true,
        fillColor: surfaceColor,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
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
          borderSide: const BorderSide(color: AppColors.primary, width: 2),
        ),
      ),
    );
  }

  Widget _buildPaymentOption(
      String value,
      String title,
      String subtitle,
      IconData icon,
      bool isDark,
      Color textColor,
      Color surfaceColor,
      Color borderColor) {
    final selected = _paymentMethod == value;
    return GestureDetector(
      onTap: () => setState(() => _paymentMethod = value),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: surfaceColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: selected ? AppColors.primary : borderColor,
            width: selected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: selected ? AppColors.primary : borderColor,
                  width: 2,
                ),
              ),
              child: selected
                  ? Center(
                      child: Container(
                        width: 10,
                        height: 10,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppColors.primary,
                        ),
                      ),
                    )
                  : null,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      style: TextStyle(
                          color: textColor,
                          fontWeight: FontWeight.w600,
                          fontSize: 14)),
                  Text(subtitle,
                      style: TextStyle(
                          color: isDark
                              ? AppColors.mutedDark
                              : AppColors.mutedLight,
                          fontSize: 11)),
                ],
              ),
            ),
            Icon(icon, color: AppColors.primary, size: 24),
          ],
        ),
      ),
    );
  }

  Widget _summaryRow(
      String label, String value, Color textColor, Color mutedColor,
      {bool isSubtext = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label,
              style: TextStyle(
                  color: isSubtext ? mutedColor : textColor,
                  fontSize: isSubtext ? 12 : 14)),
          if (value.isNotEmpty)
            Text(value,
                style: TextStyle(
                    color: textColor,
                    fontSize: 14,
                    fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }

  Future<void> _handlePayment() async {
    if (_namaController.text.trim().isEmpty ||
        _emailController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Lengkapi data pemesan terlebih dahulu'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      // Get user_id from SharedPreferences (saved during login)
      int? userId = await AuthService.getUserId();
      if (userId == null || userId == 0) {
        // Fallback: fetch from /me
        final meResult = await AuthService.getMe();
        if (meResult['success'] != true) {
          _showError('Gagal memuat data pengguna');
          return;
        }
        final meData = meResult['data'];
        userId = meData is Map ? meData['id'] : null;
        if (userId == null) {
          _showError('Data pengguna tidak valid');
          return;
        }
      }

      // Step 1: Buat Order — per claude.md: {user_id, total_harga}
      final orderResult = await OrderService.createOrder({
        'user_id': userId,
        'total_harga': _total,
      });
      if (orderResult['success'] != true) {
        _showError(orderResult['message'] ?? 'Gagal membuat pesanan');
        return;
      }
      final orderData = orderResult['data'];
      final orderId = orderData is Map ? orderData['id'] : null;
      if (orderId == null) {
        _showError('Data pesanan tidak valid');
        return;
      }

      final ticketId = widget.ticketId ?? 0;
      if (ticketId == 0) {
        _showError('Data tiket tidak valid');
        return;
      }

      // Step 2: Buat Detail Order — per claude.md: {order_id, ticket_id, jumlah}
      // subtotal dihitung otomatis oleh backend (harga × jumlah)
      final detailResult = await OrderService.createDetailOrder({
        'order_id': orderId,
        'ticket_id': ticketId,
        'jumlah': widget.qty,
      });
      if (detailResult['success'] != true) {
        _showError(detailResult['message'] ?? 'Gagal membuat detail pesanan');
        return;
      }
      final detailData = detailResult['data'];
      final detailOrderId = detailData is Map ? detailData['id'] : null;
      if (detailOrderId == null) {
        _showError('Data detail pesanan tidak valid');
        return;
      }

      // Step 3: Buat Payment — per claude.md: {order_id, metode, jumlah_bayar}
      final paymentResult = await OrderService.createPayment({
        'order_id': orderId,
        'metode': _paymentMethod,
        'jumlah_bayar': _total,
      });
      if (paymentResult['success'] != true) {
        _showError(paymentResult['message'] ?? 'Pembayaran gagal');
        return;
      }

      // Step 4: Buat E-Ticket — per claude.md: {detail_order_id}
      final eTicketResult = await OrderService.createETicket({
        'detail_order_id': detailOrderId,
      });
      if (eTicketResult['success'] != true) {
        _showError(eTicketResult['message'] ?? 'Gagal membuat e-tiket');
        return;
      }

      // Get kode_qr from response
      final eTicketData = eTicketResult['data'];
      final kodeQr = eTicketData is Map
          ? (eTicketData['kode_qr'] ?? orderId).toString()
          : orderId.toString();

      // Save ticket info locally for Tiket Saya page
      await _saveTicketLocally(
        detailOrderId: detailOrderId,
        kodeQr: kodeQr,
        eTicketData: eTicketData,
      );

      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => ETicketPage(
              eventName: widget.eventName,
              ticketName: widget.ticketName,
              holderName: _sameAsBooker
                  ? _namaController.text
                  : _ownerNameController.text,
              orderId: orderId.toString(),
              eTicketData: eTicketData,
              kodeQr: kodeQr,
            ),
          ),
        );
      }
    } catch (e) {
      _showError('Terjadi kesalahan: $e');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  /// Save ticket info locally so Tiket Saya can display event details
  Future<void> _saveTicketLocally({
    required dynamic detailOrderId,
    required String kodeQr,
    required dynamic eTicketData,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final existing = prefs.getStringList('local_tickets') ?? [];
      // Store as simple format: kodeQr|eventName|ticketName|eventId|holderName
      final holderName = _sameAsBooker
          ? _namaController.text
          : _ownerNameController.text;
      existing.add('$kodeQr|${widget.eventName}|${widget.ticketName}|${widget.eventId}|$holderName');
      await prefs.setStringList('local_tickets', existing);
    } catch (_) {}
  }

  void _showError(String message) {
    if (mounted) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message), backgroundColor: Colors.red),
      );
    }
  }
}
