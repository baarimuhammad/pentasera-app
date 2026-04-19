import 'package:flutter/material.dart';
import 'package:pentasera_app/features/authentication/login/login_page.dart';
import 'package:pentasera_app/core/app_router.dart';
import 'package:pentasera_app/services/auth_service.dart';
import 'package:google_fonts/google_fonts.dart';

// ─────────────────────────────────────────
// Global theme notifier (default: ikuti sistem)
// ─────────────────────────────────────────
final ValueNotifier<ThemeMode> themeNotifier = ValueNotifier(ThemeMode.system);

// ─────────────────────────────────────────
// Design System — Warna
// ─────────────────────────────────────────
class AppColors {
  static const Color primary = Color(0xFFf27f0d);

  // Background
  static const Color backgroundLight = Color(0xFFf8f7f5);
  static const Color backgroundDark = Color(0xFF221910);

  // Surface (card, dialog)
  static const Color surfaceLight = Colors.white;
  static const Color surfaceDark = Color(0xFF2D2318);

  // Text
  static const Color textLight = Color(0xFF0f172a);
  static const Color textDark = Color(0xFFf1f5f9);

  // Muted text
  static const Color mutedLight = Color(0xFF475569);
  static const Color mutedDark = Color(0xFF94a3b8);

  // Border
  static const Color borderLight = Color(0xFFe2e8f0);
  static const Color borderDark = Color(0xFF3D2E22);

  // Legacy aliases
  static const Color slate900 = textLight;
  static const Color slate100 = textDark;
  static const Color slate400 = mutedDark;
  static const Color slate600 = mutedLight;
}

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: themeNotifier,
      builder: (_, ThemeMode currentMode, __) {
        return MaterialApp(
          title: 'Pentasera',
          debugShowCheckedModeBanner: false,
          themeMode: currentMode,

          // ── TEMA TERANG ──
          theme: ThemeData(
            brightness: Brightness.light,
            scaffoldBackgroundColor: AppColors.backgroundLight,
            primaryColor: AppColors.primary,
            fontFamily: 'Plus Jakarta Sans',
            colorScheme: const ColorScheme.light(
              primary: AppColors.primary,
              surface: AppColors.surfaceLight,
              onSurface: AppColors.textLight,
            ),
            useMaterial3: true,
          ),

          // ── TEMA GELAP ──
          darkTheme: ThemeData(
            brightness: Brightness.dark,
            scaffoldBackgroundColor: AppColors.backgroundDark,
            primaryColor: AppColors.primary,
            fontFamily: 'Plus Jakarta Sans',
            colorScheme: const ColorScheme.dark(
              primary: AppColors.primary,
              surface: AppColors.surfaceDark,
              onSurface: AppColors.textDark,
            ),
            useMaterial3: true,
          ),

          home: const SplashGate(),
        );
      },
    );
  }
}

// ─────────────────────────────────────────
// SplashGate — cek apakah user sudah login
// ─────────────────────────────────────────
class SplashGate extends StatefulWidget {
  const SplashGate({super.key});

  @override
  State<SplashGate> createState() => _SplashGateState();
}

class _SplashGateState extends State<SplashGate> {
  @override
  void initState() {
    super.initState();
    _checkAuth();
  }

  Future<void> _checkAuth() async {
    final loggedIn = await AuthService.isLoggedIn();
    if (!mounted) return;

    if (loggedIn) {
      final role = await AuthService.getUserRole() ?? 'buyer';
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => RoleBasedShell(role: role)),
        (_) => false,
      );
    } else {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const LoginPage()),
        (_) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: const Center(
        child: CircularProgressIndicator(color: AppColors.primary),
      ),
    );
  }
}
