import 'package:flutter/material.dart';
import 'package:pentasera_app/features/authentication/login/login_page.dart';
import 'package:google_fonts/google_fonts.dart';

// Variabel global untuk mengatur tema (Default: mengikuti sistem HP)
final ValueNotifier<ThemeMode> themeNotifier = ValueNotifier(ThemeMode.system);

// Definisi warna dasar aplikasi (diambil dari desain HTML kamu)
class AppColors {
  static const Color primary = Color(0xFFD97736);
  static const Color backgroundLight = Color(0xFFFDFCF8);
  static const Color backgroundDark = Color(0xFF18181B);
  static const Color slate900 = Color(0xFF0f172a);
  static const Color slate100 = Color(0xFFf1f5f9);
}

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Membungkus aplikasi dengan ValueListenableBuilder agar peka terhadap perubahan tema
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: themeNotifier,
      builder: (_, ThemeMode currentMode, __) {
        return MaterialApp(
          title: 'Pentasera',
          debugShowCheckedModeBanner: false,
          themeMode: currentMode,

          // --- PENGATURAN TEMA TERANG ---
          theme: ThemeData(
            brightness: Brightness.light,
            scaffoldBackgroundColor: AppColors.backgroundLight,
            primaryColor: AppColors.primary,
            fontFamily: 'Plus Jakarta Sans', // Font utama
            colorScheme: const ColorScheme.light(
              primary: AppColors.primary,
              surface: Colors.white,
              onSurface: AppColors.slate900,
            ),
            useMaterial3: true,
          ),

          // --- PENGATURAN TEMA GELAP ---
          darkTheme: ThemeData(
            brightness: Brightness.dark,
            scaffoldBackgroundColor: AppColors.backgroundDark,
            primaryColor: AppColors.primary,
            fontFamily: 'Plus Jakarta Sans',
            colorScheme: const ColorScheme.dark(
              primary: AppColors.primary,
              surface: Color(0xFF27272A),
              onSurface: AppColors.slate100,
            ),
            useMaterial3: true,
          ),

          home: const LoginPage(),
          
        );
      },
    );
  }
}


