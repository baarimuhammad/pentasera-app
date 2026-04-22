import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
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
  final _voucherController = TextEditingController();

  bool _sameAsBooker = true;
  String _paymentMethod = 'e_wallet';
  bool _isLoading = false;
  bool _isLoadingProfile = true;
  String? _voucherApplied;
  int _discount = 0;

  final _formatter =
      NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    final result = await AuthService.getMe();
    if (result['success'] && mounted) {
      final data = result['data'];
      _namaController.text = data['nama'] ?? '';
      _emailController.text = data['email'] ?? '';
    } else {
      // Fallback from shared prefs
      _namaController.text = await AuthService.getUserNama() ?? '';
      _emailController.text = await AuthService.getUserEmail() ?? '';
    }
    if (mounted) setState(() => _isLoadingProfile = false);
  }

  int get _subtotal => widget.price * widget.qty;
  int get _serviceFee => 15000;
  int get _total => _subtotal + _serviceFee - _discount;

  @override
  void dispose() {
    _namaController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _ownerNameController.dispose();
    _ownerEmailController.dispose();
    _voucherController.dispose();
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
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: textColor),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
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

                  // Metode Pembayaran
                  _sectionTitle('Metode Pembayaran', textColor),
                  const SizedBox(height: 12),
                  _buildPaymentOption('e_wallet', 'E-Wallet',
                      'GoPay, OVO, Dana, ShopeePay', Icons.account_balance_wallet,
                      isDark, textColor, surfaceColor, borderColor),
                  const SizedBox(height: 8),
                  _buildPaymentOption('bank_transfer', 'Transfer Bank (Virtual Account)',
                      'BCA, Mandiri, BNI, BRI', Icons.account_balance,
                      isDark, textColor, surfaceColor, borderColor),
                  const SizedBox(height: 8),
                  _buildPaymentOption('credit_card', 'Kartu Kredit / Debit',
                      'Visa, Mastercard, JCB', Icons.credit_card,
                      isDark, textColor, surfaceColor, borderColor),
                  const SizedBox(height: 24),

                  // Voucher
                  _sectionTitle('Voucher', textColor),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _voucherController,
                          style: TextStyle(color: textColor, fontSize: 14),
                          decoration: InputDecoration(
                            hintText: 'Punya kode voucher?',
                            hintStyle:
                                TextStyle(color: mutedColor, fontSize: 13),
                            filled: true,
                            fillColor: surfaceColor,
                            contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 14),
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
                              borderSide: const BorderSide(
                                  color: AppColors.primary, width: 2),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      SizedBox(
                        height: 48,
                        child: ElevatedButton(
                          onPressed: () {
                            if (_voucherController.text.isNotEmpty) {
                              setState(() {
                                _voucherApplied = _voucherController.text;
                                _discount = 50000;
                              });
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Voucher berhasil digunakan!'),
                                  backgroundColor: Colors.green,
                                ),
                              );
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12)),
                          ),
                          child: const Text('Apply'),
                        ),
                      ),
                    ],
                  ),
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
                            '${widget.ticketName}',
                            _formatter.format(_subtotal),
                            textColor,
                            mutedColor),
                        _summaryRow(
                            '${widget.qty}x ${_formatter.format(widget.price)}',
                            '',
                            mutedColor,
                            mutedColor,
                            isSubtext: true),
                        const SizedBox(height: 8),
                        _summaryRow('Biaya Layanan',
                            _formatter.format(_serviceFee), textColor, mutedColor),
                        if (_voucherApplied != null) ...[
                          const SizedBox(height: 8),
                          _summaryRow(
                            'Diskon (${ _voucherApplied})',
                            '-${_formatter.format(_discount)}',
                            Colors.green,
                            mutedColor,
                          ),
                        ],
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

  Widget _buildField(
      String label,
      TextEditingController controller,
      bool isDark,
      Color textColor,
      Color surfaceColor,
      Color borderColor,
      {TextInputType type = TextInputType.text,
      String? prefix}) {
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
                      style: TextStyle(color:
                          isDark ? AppColors.mutedDark : AppColors.mutedLight,
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

  Widget _summaryRow(String label, String value, Color textColor,
      Color mutedColor,
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
      // Step 1: Create Order
      final orderResult = await OrderService.createOrder({
        'event_id': widget.eventId,
        'ticket_id': widget.ticketId,
        'qty': widget.qty,
        'total': _total,
      });

      if (!orderResult['success']) {
        _showError(orderResult['message'] ?? 'Gagal membuat pesanan');
        return;
      }

      final orderId = orderResult['data']['id'] ?? orderResult['data']['order_id'];

      // Step 2: Create Payment
      final paymentResult = await OrderService.createPayment({
        'order_id': orderId,
        'metode': _paymentMethod,
        'jumlah': _total,
      });

      if (!paymentResult['success']) {
        _showError(paymentResult['message'] ?? 'Pembayaran gagal');
        return;
      }

      // Step 3: Create E-Ticket
      final eTicketResult = await OrderService.createETicket({
        'order_id': orderId,
      });

      // Navigate to success page
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
              eTicketData: eTicketResult['data'],
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

  void _showError(String message) {
    if (mounted) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message), backgroundColor: Colors.red),
      );
    }
  }
}
