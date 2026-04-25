import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pentasera_app/services/auth_service.dart';
import 'package:pentasera_app/core/app_router.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _agreedToTerms = false;
  bool _isLoading = false;

  // ← Controller untuk setiap field
  final TextEditingController _namaController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();

  @override
  void dispose() {
    _namaController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  // ← Fungsi validasi sebelum kirim ke API
  String? _validate() {
    if (_namaController.text.trim().isEmpty) {
      return 'Nama lengkap tidak boleh kosong';
    }
    if (_emailController.text.trim().isEmpty) {
      return 'Email tidak boleh kosong';
    }
    if (!_emailController.text.contains('@')) {
      return 'Format email tidak valid';
    }
    if (_passwordController.text.isEmpty) {
      return 'Kata sandi tidak boleh kosong';
    }
    if (_passwordController.text.length < 6) {
      return 'Kata sandi minimal 6 karakter';
    }
    if (_confirmPasswordController.text != _passwordController.text) {
      return 'Konfirmasi kata sandi tidak cocok';
    }
    if (!_agreedToTerms) {
      return 'Kamu harus menyetujui syarat & ketentuan';
    }
    return null; // null = tidak ada error
  }

  // ← Fungsi utama untuk daftar
  Future<void> _handleRegister() async {
    final error = _validate();
    if (error != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error), backgroundColor: Colors.red),
      );
      return;
    }

    setState(() => _isLoading = true);

    final result = await AuthService.register(
      nama: _namaController.text.trim(),
      email: _emailController.text.trim(),
      password: _passwordController.text,
      passwordConfirmation: _confirmPasswordController.text,
      role: 'buyer', // default role saat daftar adalah buyer
    );

    if (!mounted) return;
    setState(() => _isLoading = false);

    if (result['success'] == true) {
      // Registrasi berhasil → langsung masuk berdasarkan role
      final role = await AuthService.getUserRole() ?? 'buyer';
      if (!mounted) return;
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => RoleBasedShell(role: role)),
        (route) => false,
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text(result['message'] ?? 'Registrasi gagal'),
            backgroundColor: Colors.red),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = const Color(0xFFC25E26);
    final bgColor = isDark ? const Color(0xFF121212) : const Color(0xFFFDFBF7);
    final surfaceColor = isDark ? const Color(0xFF1E1E1E) : Colors.white;
    final textColor = isDark ? const Color(0xFFEDEDED) : const Color(0xFF1A1A1A);
    final mutedColor = isDark ? const Color(0xFFA1A1A1) : const Color(0xFF666666);
    final borderColor = isDark ? const Color(0xFF333333) : const Color(0xFFE5E5E5);

    return Scaffold(
      backgroundColor: bgColor,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Header
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image.asset(
                          'assets/images/logo_pentasera.png',
                          width: 48,
                          height: 48,
                          fit: BoxFit.contain,
                        ),
                    const SizedBox(width: 8),
                    Text(
                      'PENTASERA',
                      style: TextStyle(
                          fontFamily: GoogleFonts.montserrat().fontFamily,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: textColor,
                          letterSpacing: 1.5),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  'Bergabung dan rasakan keajaiban budaya nusantara',
                  style: TextStyle(color: mutedColor, fontSize: 14, fontFamily: GoogleFonts.poppins().fontFamily),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 32),

                // Form Card
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: surfaceColor,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: borderColor),
                    boxShadow: isDark
                        ? []
                        : [
                            BoxShadow(
                                color: Colors.black.withOpacity(0.05),
                                blurRadius: 10,
                                offset: const Offset(0, 4))
                          ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Center(
                        child: Text('Buat Akun Baru',
                            style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                                fontFamily: GoogleFonts.montserrat().fontFamily,
                                color: textColor)),
                      ),
                      const SizedBox(height: 24),

                      // Nama Lengkap
                      _buildInput(
                        label: 'Nama Lengkap',
                        hint: 'Masukkan nama lengkap',
                        icon: Icons.person_outline,
                        controller: _namaController, // ← terhubung
                        isDark: isDark,
                        textColor: textColor,
                        primaryColor: primaryColor,
                        bgColor: bgColor,
                        borderColor: borderColor,
                      ),
                      const SizedBox(height: 16),

                      // Email
                      _buildInput(
                        label: 'Email',
                        hint: 'nama@email.com',
                        icon: Icons.mail_outline,
                        controller: _emailController, // ← terhubung
                        keyboardType: TextInputType.emailAddress,
                        isDark: isDark,
                        textColor: textColor,
                        primaryColor: primaryColor,
                        bgColor: bgColor,
                        borderColor: borderColor,
                      ),
                      const SizedBox(height: 16),

                      // Kata Sandi
                      _buildPasswordInput(
                        label: 'Kata Sandi',
                        hint: 'Minimal 6 karakter',
                        controller: _passwordController, // ← terhubung
                        isObscure: _obscurePassword,
                        onToggle: () => setState(
                            () => _obscurePassword = !_obscurePassword),
                        isDark: isDark,
                        textColor: textColor,
                        primaryColor: primaryColor,
                        bgColor: bgColor,
                        borderColor: borderColor,
                      ),
                      const SizedBox(height: 16),

                      // Konfirmasi Kata Sandi
                      _buildPasswordInput(
                        label: 'Konfirmasi Kata Sandi',
                        hint: 'Ulangi kata sandi',
                        controller: _confirmPasswordController, // ← terhubung
                        isObscure: _obscureConfirmPassword,
                        onToggle: () => setState(() =>
                            _obscureConfirmPassword = !_obscureConfirmPassword),
                        isDark: isDark,
                        textColor: textColor,
                        primaryColor: primaryColor,
                        bgColor: bgColor,
                        borderColor: borderColor,
                      ),
                      const SizedBox(height: 16),

                      // Terms & Conditions
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(
                            height: 24,
                            width: 24,
                            child: Checkbox(
                              value: _agreedToTerms,
                              onChanged: (val) =>
                                  setState(() => _agreedToTerms = val!),
                              activeColor: primaryColor,
                              side: BorderSide(color: borderColor),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: RichText(
                              text: TextSpan(
                                style: TextStyle(
                                    color: mutedColor,
                                    fontSize: 12,
                                    fontFamily: GoogleFonts.poppins().fontFamily),
                                children: [
                                  const TextSpan(text: 'Saya menyetujui '),
                                  TextSpan(
                                      text: 'Syarat & Ketentuan',
                                      style: TextStyle(
                                          color: primaryColor,
                                          fontWeight: FontWeight.w500)),
                                  const TextSpan(text: ' serta '),
                                  TextSpan(
                                      text: 'Kebijakan Privasi',
                                      style: TextStyle(
                                          color: primaryColor,
                                          fontWeight: FontWeight.w500)),
                                  const TextSpan(text: ' yang berlaku.'),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),

                      // Tombol Daftar
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _isLoading ? null : _handleRegister,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: primaryColor,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12)),
                          ),
                          child: _isLoading
                              ? const SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(
                                      color: Colors.white, strokeWidth: 2),
                                )
                              : const Text('Daftar',
                                  style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold)),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),

                // Kembali ke Login
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('Sudah punya akun? ',
                        style: TextStyle(color: mutedColor, fontSize: 14)),
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Text('Masuk disini',
                          style: TextStyle(
                              color: primaryColor,
                              fontSize: 14,
                              fontWeight: FontWeight.bold)),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInput({
    required String label,
    required String hint,
    required IconData icon,
    required TextEditingController controller, // ← wajib ada
    required bool isDark,
    required Color textColor,
    required Color primaryColor,
    required Color bgColor,
    required Color borderColor,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                fontFamily: GoogleFonts.montserrat().fontFamily,
                color: textColor)),
        const SizedBox(height: 8),
        TextField(
          controller: controller, // ← dihubungkan
          keyboardType: keyboardType,
          style: TextStyle(color: textColor),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(color: Colors.grey, fontSize: 10, fontFamily: 'Poppins'),
            prefixIcon: Icon(icon, color: Colors.grey, size: 20),
            filled: true,
            fillColor: bgColor,
            contentPadding: const EdgeInsets.symmetric(vertical: 14),
            border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: borderColor)),
            enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: borderColor)),
            focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: primaryColor, width: 2)),
          ),
        ),
      ],
    );
  }

  Widget _buildPasswordInput({
    required String label,
    required String hint,
    required TextEditingController controller, // ← wajib ada
    required bool isObscure,
    required VoidCallback onToggle,
    required bool isDark,
    required Color textColor,
    required Color primaryColor,
    required Color bgColor,
    required Color borderColor,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                fontFamily: GoogleFonts.montserrat().fontFamily,
                color: textColor)),
        const SizedBox(height: 8),
        TextField(
          controller: controller, // ← dihubungkan
          obscureText: isObscure,
          style: TextStyle(color: textColor),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(color: Colors.grey, fontSize: 10, fontFamily: 'Poppins'),
            prefixIcon:
                const Icon(Icons.lock_outline, color: Colors.grey, size: 20),
            suffixIcon: IconButton(
              icon: Icon(
                  isObscure
                      ? Icons.visibility_off_outlined
                      : Icons.visibility_outlined,
                  color: Colors.grey,
                  size: 20),
              onPressed: onToggle,
            ),
            filled: true,
            fillColor: bgColor,
            contentPadding: const EdgeInsets.symmetric(vertical: 14),
            border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: borderColor)),
            enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: borderColor)),
            focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: primaryColor, width: 2)),
          ),
        ),
      ],
    );
  }
}
