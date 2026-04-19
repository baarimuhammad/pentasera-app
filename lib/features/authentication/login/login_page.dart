import 'package:flutter/material.dart';
import 'dart:ui';
import 'package:pentasera_app/features/authentication/lupa_password/forget_password.dart';
import 'package:pentasera_app/features/authentication/register/register_page.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pentasera_app/services/auth_service.dart';
import 'package:pentasera_app/core/app_router.dart';
import 'package:pentasera_app/main.dart' as app;

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  bool _obscurePassword = true;
  bool _isLoading = false;
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = const Color(0xFFD97736);
    final bgColor = isDark ? const Color(0xFF18181B) : const Color(0xFFFDFCF8);
    final surfaceColor = isDark ? const Color(0xFF27272A) : Colors.white;
    final textColor = isDark ? Colors.white : const Color(0xFF3F2E26);
    final mutedColor = isDark ? Colors.grey[400] : Colors.grey[500];

    return Scaffold(
      backgroundColor: bgColor,
      body: Stack(
        children: [
          // Background Glow Effect (Top Right)
          Positioned(
            top: -100,
            right: -100,
            child: Container(
              width: 250,
              height: 250,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: primaryColor.withOpacity(0.1),
              ),
            ),
          ),
          // Background Glow Effect (Bottom Left)
          Positioned(
            bottom: -100,
            left: -100,
            child: Container(
              width: 250,
              height: 250,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: primaryColor.withOpacity(0.1),
              ),
            ),
          ),
          // Blur Filter
          Positioned.fill(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 50, sigmaY: 50),
              child: const SizedBox(),
            ),
          ),

          // Main Content
          SafeArea(
            child: Stack(
              children: [
                // Theme Toggle Button
                Positioned(
                  top: 16,
                  right: 16,
                  child: IconButton(
                    onPressed: () {
                      // Toggle between light and dark theme
                      final currentTheme = app.themeNotifier.value;
                      if (currentTheme == ThemeMode.light) {
                        app.themeNotifier.value = ThemeMode.dark;
                      } else {
                        app.themeNotifier.value = ThemeMode.light;
                      }
                    },
                    icon: Icon(
                      isDark ? Icons.light_mode : Icons.dark_mode,
                      color: primaryColor,
                      size: 24,
                    ),
                  ),
                ),
                // Center Content
                Center(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 24.0, vertical: 32.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Logo & Title
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Image.asset(
                              'assets/images/logo_pentasera.png',
                              width: 48,
                              height: 48,
                              fit: BoxFit.contain,
                            ),
                            const SizedBox(width: 16),
                            Text(
                              'PENTASERA',
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                fontFamily: GoogleFonts.montserrat().fontFamily,
                                letterSpacing: 1.5,
                                color: textColor,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Masuk untuk menjelajahi budaya nusantara',
                          style: TextStyle(
                            color: mutedColor,
                            fontSize: 14,
                            fontFamily: GoogleFonts.poppins().fontFamily,
                          ),
                        ),
                        const SizedBox(height: 40),

                        // Email Field
                        _buildTextField(
                          label: 'Email',
                          hint: 'namaemail@email.com',
                          icon: Icons.mail_outline,
                          isDark: isDark,
                          surfaceColor: surfaceColor,
                          textColor: textColor,
                          primaryColor: primaryColor,
                          controller:
                              _emailController, // ← terhubung ke controller
                        ),
                        const SizedBox(height: 16),

                        // Password Field
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text('Kata Sandi',
                                    style: TextStyle(
                                        fontFamily:
                                            GoogleFonts.poppins().fontFamily,
                                        fontSize: 14,
                                        fontWeight: FontWeight.w500,
                                        color: textColor)),
                                GestureDetector(
                                  onTap: () {
                                    Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (_) =>
                                                const ForgotPasswordPage()));
                                  },
                                  child: Text('Lupa Kata Sandi?',
                                      style: TextStyle(
                                          fontSize: 12,
                                          fontFamily:
                                              GoogleFonts.poppins().fontFamily,
                                          fontWeight: FontWeight.w600,
                                          color: primaryColor)),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            TextField(
                              controller:
                                  _passwordController, // ← terhubung ke controller
                              obscureText: _obscurePassword,
                              style: TextStyle(color: textColor),
                              decoration: InputDecoration(
                                hintText: '••••••••',
                                hintStyle: TextStyle(color: Colors.grey[400]),
                                prefixIcon: Icon(Icons.lock_outline,
                                    color: Colors.grey[400], size: 20),
                                suffixIcon: IconButton(
                                  icon: Icon(
                                    _obscurePassword
                                        ? Icons.visibility_off_outlined
                                        : Icons.visibility_outlined,
                                    color: Colors.grey[400],
                                    size: 20,
                                  ),
                                  onPressed: () => setState(() =>
                                      _obscurePassword = !_obscurePassword),
                                ),
                                filled: true,
                                fillColor: surfaceColor,
                                contentPadding:
                                    const EdgeInsets.symmetric(vertical: 16),
                                border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: BorderSide(
                                        color: isDark
                                            ? Colors.grey[800]!
                                            : Colors.grey[200]!)),
                                enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: BorderSide(
                                        color: isDark
                                            ? Colors.grey[800]!
                                            : Colors.grey[200]!)),
                                focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: BorderSide(
                                        color: primaryColor, width: 2)),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),

                        // Login Button
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: _isLoading
                                ? null
                                : () async {
                                    // Validasi field kosong
                                    if (_emailController.text.isEmpty ||
                                        _passwordController.text.isEmpty) {
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
                                        const SnackBar(
                                          content: Text(
                                              'Email dan kata sandi tidak boleh kosong'),
                                          backgroundColor: Colors.red,
                                        ),
                                      );
                                      return;
                                    }

                                    setState(() => _isLoading = true);

                                    final result = await AuthService.login(
                                      _emailController.text.trim(),
                                      _passwordController.text,
                                    );

                                    setState(() => _isLoading = false);

                                    if (result['success']) {
                                      // Login berhasil → navigasi berdasarkan role
                                      final role = result['data']?['user']?['role'] ?? 'buyer';
                                      Navigator.pushAndRemoveUntil(
                                        context,
                                        MaterialPageRoute(
                                            builder: (_) => RoleBasedShell(role: role)),
                                        (route) => false,
                                      );
                                    } else {
                                      // Login gagal → tampilkan pesan error
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
                                        SnackBar(
                                          content: Text(result['message']),
                                          backgroundColor: Colors.red,
                                        ),
                                      );
                                    }
                                  },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: primaryColor,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12)),
                              elevation: 2,
                            ),
                            // Tampilkan loading spinner saat proses login
                            child: _isLoading
                                ? const SizedBox(
                                    height: 20,
                                    width: 20,
                                    child: CircularProgressIndicator(
                                        color: Colors.white, strokeWidth: 2),
                                  )
                                : const Text('Masuk',
                                    style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold)),
                          ),
                        ),
                        const SizedBox(height: 32),

                        // Divider
                        Row(
                          children: [
                            Expanded(
                                child: Divider(
                                    color: isDark
                                        ? Colors.grey[800]
                                        : Colors.grey[200])),
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 16),
                              child: Text('Atau masuk dengan',
                                  style: TextStyle(
                                      color: mutedColor, fontSize: 12)),
                            ),
                            Expanded(
                                child: Divider(
                                    color: isDark
                                        ? Colors.grey[800]
                                        : Colors.grey[200])),
                          ],
                        ),
                        const SizedBox(height: 24),

                        // Social Buttons
                        Row(
                          children: [
                            Expanded(
                                child: _buildSocialButton(
                                    'Google',
                                    'assets/images/google_logo.png',
                                    surfaceColor,
                                    textColor,
                                    isDark)),
                            const SizedBox(width: 16),
                            Expanded(
                                child: _buildSocialButton(
                                    'Facebook',
                                    'assets/images/facebook_logo.png',
                                    surfaceColor,
                                    textColor,
                                    isDark)),
                          ],
                        ),
                        const SizedBox(height: 32),

                        // Register Link
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text('Belum punya akun? ',
                                style: TextStyle(
                                    color: mutedColor,
                                    fontSize: 14,
                                    fontFamily:
                                        GoogleFonts.poppins().fontFamily)),
                            GestureDetector(
                              onTap: () {
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (_) => const RegisterPage()));
                              },
                              child: Text('Daftar Sekarang',
                                  style: TextStyle(
                                      color: primaryColor,
                                      fontSize: 14,
                                      fontFamily:
                                          GoogleFonts.poppins().fontFamily,
                                      fontWeight: FontWeight.bold)),
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),

                        // Guest Login
                        TextButton.icon(
                          onPressed: () {
                            Navigator.pushAndRemoveUntil(
                              context,
                              MaterialPageRoute(
                                  builder: (_) => const RoleBasedShell(role: 'buyer')),
                              (route) => false,
                            );
                          },
                          icon: Text('Masuk sebagai Tamu',
                              style: TextStyle(
                                  color: mutedColor,
                                  fontSize: 12,
                                  fontFamily:
                                      GoogleFonts.poppins().fontFamily)),
                          label: Icon(Icons.arrow_forward,
                              size: 14, color: mutedColor),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField({
    required String label,
    required String hint,
    required IconData icon,
    required bool isDark,
    required Color surfaceColor,
    required Color textColor,
    required Color primaryColor,
    TextEditingController? controller, // ← parameter baru
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: TextStyle(
                fontFamily: GoogleFonts.poppins().fontFamily,
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: textColor)),
        const SizedBox(height: 8),
        TextField(
          controller: controller, // ← dihubungkan
          style: TextStyle(
              color: textColor, fontFamily: GoogleFonts.poppins().fontFamily),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(
                color: Colors.grey[400],
                fontFamily: GoogleFonts.poppins().fontFamily),
            prefixIcon: Icon(icon, color: Colors.grey[400], size: 20),
            filled: true,
            fillColor: surfaceColor,
            contentPadding: const EdgeInsets.symmetric(vertical: 16),
            border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                    color: isDark ? Colors.grey[800]! : Colors.grey[200]!)),
            enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                    color: isDark ? Colors.grey[800]! : Colors.grey[200]!)),
            focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: primaryColor, width: 2)),
          ),
        ),
      ],
    );
  }

  Widget _buildSocialButton(String text, String iconUrl, Color surfaceColor,
      Color textColor, bool isDark) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: surfaceColor,
        border:
            Border.all(color: isDark ? Colors.grey[800]! : Colors.grey[200]!),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () {},
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.network(iconUrl,
                    height: 20,
                    width: 20,
                    errorBuilder: (c, e, s) =>
                        const Icon(Icons.language, size: 20)),
                const SizedBox(width: 8),
                Text(text,
                    style: TextStyle(
                        color: textColor,
                        fontSize: 14,
                        fontWeight: FontWeight.w500)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
