import 'package:flutter/material.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _agreedToTerms = false;

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
                    Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(color: primaryColor, shape: BoxShape.circle),
                      child: const Icon(Icons.theater_comedy, color: Colors.white, size: 20),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'PENTASARA',
                      style: TextStyle(fontFamily: 'Playfair Display', fontSize: 24, fontWeight: FontWeight.bold, color: primaryColor, letterSpacing: 1.5),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text('Bergabung dan rasakan keajaiban budaya nusantara', style: TextStyle(color: mutedColor, fontSize: 14), textAlign: TextAlign.center),
                const SizedBox(height: 32),

                // Form Card
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: surfaceColor,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: borderColor),
                    boxShadow: isDark ? [] : [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4))],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Center(child: Text('Buat Akun Baru', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600, color: textColor))),
                      const SizedBox(height: 24),
                      
                      _buildInput(label: 'Nama Lengkap', hint: 'Masukkan nama lengkap', icon: Icons.person_outline, isDark: isDark, textColor: textColor, primaryColor: primaryColor, bgColor: bgColor, borderColor: borderColor),
                      const SizedBox(height: 16),
                      _buildInput(label: 'Email', hint: 'nama@email.com', icon: Icons.mail_outline, isDark: isDark, textColor: textColor, primaryColor: primaryColor, bgColor: bgColor, borderColor: borderColor),
                      const SizedBox(height: 16),
                      
                      _buildPasswordInput(label: 'Kata Sandi', hint: 'Minimal 8 karakter', isObscure: _obscurePassword, onToggle: () => setState(() => _obscurePassword = !_obscurePassword), isDark: isDark, textColor: textColor, primaryColor: primaryColor, bgColor: bgColor, borderColor: borderColor),
                      const SizedBox(height: 16),
                      _buildPasswordInput(label: 'Konfirmasi Kata Sandi', hint: 'Ulangi kata sandi', isObscure: _obscureConfirmPassword, onToggle: () => setState(() => _obscureConfirmPassword = !_obscureConfirmPassword), isDark: isDark, textColor: textColor, primaryColor: primaryColor, bgColor: bgColor, borderColor: borderColor),
                      const SizedBox(height: 16),

                      // Terms
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(
                            height: 24,
                            width: 24,
                            child: Checkbox(
                              value: _agreedToTerms,
                              onChanged: (val) => setState(() => _agreedToTerms = val!),
                              activeColor: primaryColor,
                              side: BorderSide(color: borderColor),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: RichText(
                              text: TextSpan(
                                style: TextStyle(color: mutedColor, fontSize: 12, fontFamily: 'Plus Jakarta Sans'),
                                children: [
                                  const TextSpan(text: 'Saya menyetujui '),
                                  TextSpan(text: 'Syarat & Ketentuan', style: TextStyle(color: primaryColor, fontWeight: FontWeight.w500)),
                                  const TextSpan(text: ' serta '),
                                  TextSpan(text: 'Kebijakan Privasi', style: TextStyle(color: primaryColor, fontWeight: FontWeight.w500)),
                                  const TextSpan(text: ' yang berlaku.'),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),

                      // Submit Button
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () {},
                          style: ElevatedButton.styleFrom(
                            backgroundColor: primaryColor,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                          child: const Text('Daftar', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),

                // Back to Login Link
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('Sudah punya akun? ', style: TextStyle(color: mutedColor, fontSize: 14)),
                    GestureDetector(
                      onTap: () => Navigator.pop(context), // Kembali ke halaman Login
                      child: Text('Masuk disini', style: TextStyle(color: primaryColor, fontSize: 14, fontWeight: FontWeight.bold)),
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

  Widget _buildInput({required String label, required String hint, required IconData icon, required bool isDark, required Color textColor, required Color primaryColor, required Color bgColor, required Color borderColor}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: textColor)),
        const SizedBox(height: 8),
        TextField(
          style: TextStyle(color: textColor),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(color: Colors.grey, fontSize: 14),
            prefixIcon: Icon(icon, color: Colors.grey, size: 20),
            filled: true,
            fillColor: bgColor,
            contentPadding: const EdgeInsets.symmetric(vertical: 14),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: borderColor)),
            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: borderColor)),
            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: primaryColor, width: 2)),
          ),
        ),
      ],
    );
  }

  Widget _buildPasswordInput({required String label, required String hint, required bool isObscure, required VoidCallback onToggle, required bool isDark, required Color textColor, required Color primaryColor, required Color bgColor, required Color borderColor}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: textColor)),
        const SizedBox(height: 8),
        TextField(
          obscureText: isObscure,
          style: TextStyle(color: textColor),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(color: Colors.grey, fontSize: 14),
            prefixIcon: const Icon(Icons.lock_outline, color: Colors.grey, size: 20),
            suffixIcon: IconButton(
              icon: Icon(isObscure ? Icons.visibility_off_outlined : Icons.visibility_outlined, color: Colors.grey, size: 20),
              onPressed: onToggle,
            ),
            filled: true,
            fillColor: bgColor,
            contentPadding: const EdgeInsets.symmetric(vertical: 14),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: borderColor)),
            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: borderColor)),
            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: primaryColor, width: 2)),
          ),
        ),
      ],
    );
  }
}