import 'package:flutter/material.dart';

class ForgotPasswordPage extends StatelessWidget {
  const ForgotPasswordPage({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = const Color(0xFFC26027);
    final bgColor = isDark ? const Color(0xFF18181B) : const Color(0xFFFDFBF7);
    final surfaceColor = isDark ? const Color(0xFF27272A) : Colors.white;
    final textColor = isDark ? const Color(0xFFF3F4F6) : const Color(0xFF1F2937);
    final mutedColor = isDark ? const Color(0xFF9CA3AF) : const Color(0xFF6B7280);
    final borderColor = isDark ? const Color(0xFF3F3F46) : const Color(0xFFE5E7EB);

    return Scaffold(
      backgroundColor: bgColor,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Container(
              constraints: const BoxConstraints(maxWidth: 450),
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(
                color: surfaceColor,
                borderRadius: BorderRadius.circular(32),
                border: Border.all(color: borderColor),
                boxShadow: isDark ? [] : [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 20, offset: const Offset(0, 10))],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Back Button
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: isDark ? bgColor : Colors.grey[100],
                        shape: BoxShape.circle,
                      ),
                      child: Icon(Icons.arrow_back, color: textColor),
                    ),
                  ),
                  const SizedBox(height: 32),

                  // Icon Box
                  Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      color: primaryColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Icon(Icons.lock_reset, color: primaryColor, size: 32),
                  ),
                  const SizedBox(height: 24),

                  // Title & Desc
                  Text(
                    'Lupa Kata Sandi?',
                    style: TextStyle(fontFamily: 'Playfair Display', fontSize: 28, fontWeight: FontWeight.bold, color: textColor, letterSpacing: -0.5),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Jangan khawatir. Masukkan email yang terdaftar pada akun Anda dan kami akan mengirimkan instruksi pemulihan kata sandi.',
                    style: TextStyle(color: mutedColor, fontSize: 14, height: 1.5),
                  ),
                  const SizedBox(height: 32),

                  // Email Input
                  Text('Email', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: textColor)),
                  const SizedBox(height: 8),
                  TextField(
                    style: TextStyle(color: textColor),
                    decoration: InputDecoration(
                      hintText: 'nama@email.com',
                      hintStyle: TextStyle(color: mutedColor, fontSize: 14),
                      prefixIcon: Icon(Icons.mail_outline, color: mutedColor, size: 20),
                      filled: true,
                      fillColor: isDark ? bgColor : Colors.grey[50],
                      contentPadding: const EdgeInsets.symmetric(vertical: 16),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: borderColor)),
                      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: borderColor)),
                      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: primaryColor, width: 2)),
                    ),
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
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        elevation: 0,
                      ),
                      child: const Text('Kirim Instruksi', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                    ),
                  ),
                  const SizedBox(height: 32),

                  // Back to Login Link
                  Center(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text('Ingat kata sandi Anda? ', style: TextStyle(color: mutedColor, fontSize: 14)),
                        GestureDetector(
                          onTap: () => Navigator.pop(context),
                          child: Text('Masuk sekarang', style: TextStyle(color: primaryColor, fontSize: 14, fontWeight: FontWeight.bold)),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}