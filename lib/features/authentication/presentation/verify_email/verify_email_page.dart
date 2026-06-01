import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pentasera_app/features/authentication/providers/auth_provider.dart';
import 'package:pentasera_app/main.dart';
import 'package:pentasera_app/shared/widgets/app_button.dart';
import 'package:pentasera_app/shared/widgets/app_snackbar.dart';

/// Email verification waiting screen.
/// Shows instructions, resend button with cooldown, and login redirect.
class VerifyEmailPage extends ConsumerStatefulWidget {
  const VerifyEmailPage({super.key});

  @override
  ConsumerState<VerifyEmailPage> createState() => _VerifyEmailPageState();
}

class _VerifyEmailPageState extends ConsumerState<VerifyEmailPage>
    with SingleTickerProviderStateMixin {
  bool _isResending = false;
  int _cooldownSeconds = 0;
  Timer? _cooldownTimer;

  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);

    _pulseAnimation = Tween<double>(begin: 0.95, end: 1.05).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _cooldownTimer?.cancel();
    _pulseController.dispose();
    super.dispose();
  }

  void _startCooldown() {
    setState(() => _cooldownSeconds = 60);
    _cooldownTimer?.cancel();
    _cooldownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_cooldownSeconds <= 1) {
        timer.cancel();
        if (mounted) setState(() => _cooldownSeconds = 0);
      } else {
        if (mounted) setState(() => _cooldownSeconds--);
      }
    });
  }

  Future<void> _handleResend(String email) async {
    if (_cooldownSeconds > 0 || _isResending) return;

    setState(() => _isResending = true);

    try {
      final message = await ref
          .read(authProvider.notifier)
          .resendVerification(email: email);
      if (mounted) {
        AppSnackbar.success(context, message);
        _startCooldown();
      }
    } catch (e) {
      if (mounted) {
        AppSnackbar.error(context, e.toString());
      }
    } finally {
      if (mounted) setState(() => _isResending = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    const primaryColor = Color(0xFFD97736);
    final bgColor = isDark ? const Color(0xFF18181B) : const Color(0xFFFDFCF8);
    final surfaceColor = isDark ? const Color(0xFF27272A) : Colors.white;
    final textColor = isDark ? Colors.white : const Color(0xFF3F2E26);
    final mutedColor = isDark ? Colors.grey[400]! : Colors.grey[500]!;
    final borderColor = isDark ? Colors.grey[800]! : Colors.grey[200]!;

    // Get email from auth state
    final authState = ref.watch(authProvider);
    final email = authState is EmailVerificationRequired ? authState.email : '';

    return Scaffold(
      backgroundColor: bgColor,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Animated email icon
                ScaleTransition(
                  scale: _pulseAnimation,
                  child: Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: primaryColor.withOpacity(0.1),
                    ),
                    child: Center(
                      child: Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: primaryColor.withOpacity(0.15),
                        ),
                        child: const Icon(
                          Icons.mark_email_unread_outlined,
                          size: 40,
                          color: primaryColor,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 32),

                // Title
                Text(
                  'Verifikasi Email Anda',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    fontFamily: GoogleFonts.montserrat().fontFamily,
                    color: textColor,
                  ),
                ),
                const SizedBox(height: 12),

                // Description
                Text(
                  'Kami telah mengirim link verifikasi ke:',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14,
                    fontFamily: GoogleFonts.poppins().fontFamily,
                    color: mutedColor,
                  ),
                ),
                const SizedBox(height: 8),

                // Email display
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  decoration: BoxDecoration(
                    color: surfaceColor,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: borderColor),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.email_outlined, size: 18, color: primaryColor),
                      const SizedBox(width: 8),
                      Flexible(
                        child: Text(
                          email,
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            fontFamily: GoogleFonts.poppins().fontFamily,
                            color: textColor,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Instructions card
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: primaryColor.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: primaryColor.withOpacity(0.2),
                    ),
                  ),
                  child: Column(
                    children: [
                      _buildStep(
                        '1',
                        'Buka aplikasi email Anda',
                        primaryColor,
                        textColor,
                        mutedColor,
                      ),
                      const SizedBox(height: 12),
                      _buildStep(
                        '2',
                        'Cari email dari Pentasera',
                        primaryColor,
                        textColor,
                        mutedColor,
                      ),
                      const SizedBox(height: 12),
                      _buildStep(
                        '3',
                        'Klik link verifikasi di email',
                        primaryColor,
                        textColor,
                        mutedColor,
                      ),
                      const SizedBox(height: 12),
                      _buildStep(
                        '4',
                        'Kembali ke app dan login',
                        primaryColor,
                        textColor,
                        mutedColor,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),

                // Resend button with cooldown
                AppButton(
                  text: _cooldownSeconds > 0
                      ? 'Kirim ulang (${_cooldownSeconds}s)'
                      : 'Kirim Ulang Email Verifikasi',
                  isLoading: _isResending,
                  isOutlined: true,
                  icon: Icons.refresh,
                  onPressed: _cooldownSeconds > 0
                      ? null
                      : () => _handleResend(email),
                ),
                const SizedBox(height: 16),

                // Login button
                AppButton(
                  text: 'Sudah Verifikasi? Masuk',
                  icon: Icons.login,
                  onPressed: () {
                    ref.read(authProvider.notifier).resetToUnauthenticated();
                    context.go('/login');
                  },
                ),
                const SizedBox(height: 24),

                // Hint text
                Text(
                  'Tidak menerima email? Cek folder spam atau\npastikan alamat email Anda benar.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 12,
                    fontFamily: GoogleFonts.poppins().fontFamily,
                    color: mutedColor,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStep(
    String number,
    String text,
    Color primaryColor,
    Color textColor,
    Color mutedColor,
  ) {
    return Row(
      children: [
        Container(
          width: 28,
          height: 28,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: primaryColor.withOpacity(0.15),
          ),
          child: Center(
            child: Text(
              number,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                fontFamily: GoogleFonts.poppins().fontFamily,
                color: primaryColor,
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              fontSize: 13,
              fontFamily: GoogleFonts.poppins().fontFamily,
              color: textColor.withOpacity(0.85),
            ),
          ),
        ),
      ],
    );
  }
}
