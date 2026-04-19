import 'package:flutter/material.dart';
import 'package:pentasera_app/main.dart';
import 'package:pentasera_app/features/public_pages/home/home.dart';
import 'package:pentasera_app/features/buyer/tiket_saya/tiket_saya_page.dart';
import 'package:pentasera_app/features/buyer/profil/profil_page.dart';
import 'package:pentasera_app/features/creator/dashboard/creator_dashboard_page.dart';
import 'package:pentasera_app/features/creator/event_saya/event_saya_page.dart';
import 'package:pentasera_app/features/creator/buat_event/buat_event_page.dart';
import 'package:pentasera_app/features/admin/kelola_akses/kelola_akses_page.dart';
import 'package:pentasera_app/features/admin/informasi_dasar/informasi_dasar_admin_page.dart';
import 'package:pentasera_app/features/authentication/login/login_page.dart';
import 'package:pentasera_app/services/auth_service.dart';

// ─────────────────────────────────────────
// Auth Guard — redirect ke login jika belum auth
// ─────────────────────────────────────────
Future<bool> checkAuth(BuildContext context) async {
  final token = await AuthService.getToken();
  if (token == null || token.isEmpty) {
    if (context.mounted) {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const LoginPage()),
        (_) => false,
      );
    }
    return false;
  }
  return true;
}

// ─────────────────────────────────────────
// RoleBasedShell — Bottom Nav sesuai role
// ─────────────────────────────────────────
class RoleBasedShell extends StatefulWidget {
  final String role;
  const RoleBasedShell({super.key, required this.role});

  @override
  State<RoleBasedShell> createState() => _RoleBasedShellState();
}

class _RoleBasedShellState extends State<RoleBasedShell> {
  int _currentIndex = 0;

  List<Widget> _pages() {
    switch (widget.role) {
      case 'creator':
        return [
          const CreatorDashboardPage(),
          const EventSayaPage(),
          const BuatEventPage(),
          const ProfilPage(),
        ];
      case 'admin':
        return [
          const KelolAksesPage(),
          const InformasiDasarAdminPage(),
          const ProfilPage(),
        ];
      default: // buyer
        return [
          const HomePage(),
          const HomePage(), // Eksplor — untuk sementara pakai HomePage
          const TiketSayaPage(),
          const ProfilPage(),
        ];
    }
  }

  List<BottomNavigationBarItem> _navItems() {
    switch (widget.role) {
      case 'creator':
        return const [
          BottomNavigationBarItem(
              icon: Icon(Icons.dashboard_outlined),
              activeIcon: Icon(Icons.dashboard),
              label: 'Dashboard'),
          BottomNavigationBarItem(
              icon: Icon(Icons.event_outlined),
              activeIcon: Icon(Icons.event),
              label: 'Event Saya'),
          BottomNavigationBarItem(
              icon: Icon(Icons.add_circle_outline),
              activeIcon: Icon(Icons.add_circle),
              label: 'Buat Event'),
          BottomNavigationBarItem(
              icon: Icon(Icons.person_outline),
              activeIcon: Icon(Icons.person),
              label: 'Profil'),
        ];
      case 'admin':
        return const [
          BottomNavigationBarItem(
              icon: Icon(Icons.admin_panel_settings_outlined),
              activeIcon: Icon(Icons.admin_panel_settings),
              label: 'Kelola Akses'),
          BottomNavigationBarItem(
              icon: Icon(Icons.info_outline),
              activeIcon: Icon(Icons.info),
              label: 'Info Dasar'),
          BottomNavigationBarItem(
              icon: Icon(Icons.person_outline),
              activeIcon: Icon(Icons.person),
              label: 'Profil'),
        ];
      default: // buyer
        return const [
          BottomNavigationBarItem(
              icon: Icon(Icons.home_outlined),
              activeIcon: Icon(Icons.home),
              label: 'Home'),
          BottomNavigationBarItem(
              icon: Icon(Icons.explore_outlined),
              activeIcon: Icon(Icons.explore),
              label: 'Eksplor'),
          BottomNavigationBarItem(
              icon: Icon(Icons.confirmation_number_outlined),
              activeIcon: Icon(Icons.confirmation_number),
              label: 'Tiket Saya'),
          BottomNavigationBarItem(
              icon: Icon(Icons.person_outline),
              activeIcon: Icon(Icons.person),
              label: 'Profil'),
        ];
    }
  }

  @override
  Widget build(BuildContext context) {
    final pages = _pages();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: pages,
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          border: Border(
            top: BorderSide(
              color: AppColors.primary.withOpacity(0.1),
            ),
          ),
        ),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (i) => setState(() => _currentIndex = i),
          backgroundColor: isDark
              ? AppColors.backgroundDark
              : AppColors.backgroundLight,
          type: BottomNavigationBarType.fixed,
          selectedItemColor: AppColors.primary,
          unselectedItemColor:
              isDark ? AppColors.mutedDark : AppColors.mutedLight,
          selectedLabelStyle:
              const TextStyle(fontSize: 11, fontWeight: FontWeight.w600),
          unselectedLabelStyle:
              const TextStyle(fontSize: 11, fontWeight: FontWeight.w500),
          elevation: 0,
          items: _navItems(),
        ),
      ),
    );
  }
}
