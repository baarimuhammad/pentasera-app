import 'package:flutter/material.dart';
import 'dart:ui';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pentasera_app/features/authentication/providers/auth_provider.dart';
import 'package:pentasera_app/main.dart' as app;
import 'package:pentasera_app/shared/widgets/app_snackbar.dart';
import 'package:pentasera_app/shared/widgets/app_text_field.dart';
import 'package:pentasera_app/shared/widgets/app_button.dart';

class LoginPage extends ConsumerStatefulWidget {
  const LoginPage({super.key});

  @override
  ConsumerState<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends ConsumerState<LoginPage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _handleLogin() {
    final email = _emailController.text.trim();
    final password = _passwordController.text;

    if (email.isEmpty || password.isEmpty) {
      AppSnackbar.error(context, 'Email dan kata sandi tidak boleh kosong');
      return;
    }

    ref.read(authProvider.notifier).login(
          email: email,
          password: password,
        );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    const primaryColor = Color(0xFFD97736);
    final bgColor = isDark ? const Color(0xFF18181B) : const Color(0xFFFDFCF8);
    final textColor = isDark ? Colors.white : const Color(0xFF3F2E26);
    final mutedColor = isDark ? Colors.grey[400] : Colors.grey[500];

    final authState = ref.watch(authProvider);
    final isLoading = authState is AuthLoading;

    // Listen for auth state changes to show errors
    ref.listen<AuthState>(authProvider, (previous, next) {
      if (next is AuthError) {
        AppSnackbar.error(context, next.message);
      }
      if (next is EmailVerificationRequired && next.message != null) {
        AppSnackbar.warning(context, next.message!);
      }
    });

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
                                fontFamily:
                                    GoogleFonts.montserrat().fontFamily,
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
                        AppTextField(
                          label: 'Email',
                          hint: 'namaemail@email.com',
                          prefixIcon: Icons.mail_outline,
                          controller: _emailController,
                          keyboardType: TextInputType.emailAddress,
                          enabled: !isLoading,
                        ),
                        const SizedBox(height: 16),

                        // Password Field with Forgot Password
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment:
                                  MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Kata Sandi',
                                  style: TextStyle(
                                    fontFamily:
                                        GoogleFonts.poppins().fontFamily,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                    color: textColor,
                                  ),
                                ),
                                GestureDetector(
                                  onTap: isLoading
                                      ? null
                                      : () {
                                          // Navigate to forgot password
                                          // Keep using Navigator for pages not yet migrated
                                          try {
                                            context.push('/forgot-password');
                                          } catch (_) {
                                            // Fallback if route not registered
                                          }
                                        },
                                  child: Text(
                                    'Lupa Kata Sandi?',
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontFamily:
                                          GoogleFonts.poppins().fontFamily,
                                      fontWeight: FontWeight.w600,
                                      color: primaryColor,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            AppPasswordField(
                              label: '',
                              hint: '••••••••',
                              controller: _passwordController,
                              enabled: !isLoading,
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),

                        // Login Button
                        AppButton(
                          text: 'Masuk',
                          isLoading: isLoading,
                          onPressed: _handleLogin,
                        ),
                        const SizedBox(height: 32),

                        // Divider
                        Row(
                          children: [
                            Expanded(
                              child: Divider(
                                color: isDark
                                    ? Colors.grey[800]
                                    : Colors.grey[200],
                              ),
                            ),
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 16),
                              child: Text(
                                'Atau masuk dengan',
                                style: TextStyle(
                                    color: mutedColor, fontSize: 12),
                              ),
                            ),
                            Expanded(
                              child: Divider(
                                color: isDark
                                    ? Colors.grey[800]
                                    : Colors.grey[200],
                              ),
                            ),
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
                                isDark,
                                textColor,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: _buildSocialButton(
                                'Facebook',
                                'assets/images/facebook_logo.png',
                                isDark,
                                textColor,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 32),

                        // Register Link
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'Belum punya akun? ',
                              style: TextStyle(
                                color: mutedColor,
                                fontSize: 14,
                                fontFamily:
                                    GoogleFonts.poppins().fontFamily,
                              ),
                            ),
                            GestureDetector(
                              onTap: isLoading
                                  ? null
                                  : () => context.go('/register'),
                              child: Text(
                                'Daftar Sekarang',
                                style: TextStyle(
                                  color: primaryColor,
                                  fontSize: 14,
                                  fontFamily:
                                      GoogleFonts.poppins().fontFamily,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),

                        // Guest Login
                        TextButton.icon(
                          onPressed: isLoading
                              ? null
                              : () => context.go('/'),
                          icon: Text(
                            'Masuk sebagai Tamu',
                            style: TextStyle(
                              color: mutedColor,
                              fontSize: 12,
                              fontFamily:
                                  GoogleFonts.poppins().fontFamily,
                            ),
                          ),
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

  Widget _buildSocialButton(
      String text, String iconPath, bool isDark, Color textColor) {
    final surfaceColor = isDark ? const Color(0xFF27272A) : Colors.white;
    final borderColor = isDark ? Colors.grey[800]! : Colors.grey[200]!;

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: surfaceColor,
        border: Border.all(color: borderColor),
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
                Image.asset(
                  iconPath,
                  height: 20,
                  width: 20,
                  errorBuilder: (c, e, s) =>
                      const Icon(Icons.language, size: 20),
                ),
                const SizedBox(width: 8),
                Text(
                  text,
                  style: TextStyle(
                    color: textColor,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
