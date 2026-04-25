import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pentasera_app/main.dart';
import 'package:pentasera_app/services/auth_service.dart';
import 'package:pentasera_app/features/authentication/login/login_page.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:pentasera_app/core/app_router.dart';

class ProfilPage extends StatefulWidget {
  const ProfilPage({super.key});

  @override
  State<ProfilPage> createState() => _ProfilPageState();
}

class _ProfilPageState extends State<ProfilPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  Map<String, dynamic>? _userData;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    setState(() => _isLoading = true);
    final result = await AuthService.getMe();
    final savedNama = await AuthService.getUserNama() ?? '';
    final savedEmail = await AuthService.getUserEmail() ?? '';
    final savedRole = await AuthService.getUserRole() ?? '';
    final savedCreatedAt = await AuthService.getUserCreatedAt() ?? '';

    if (result['success'] == true && result['data'] is Map) {
      _userData = Map<String, dynamic>.from(result['data'] as Map);
      _userData!['nama'] = _resolveProfileField(
              _userData, ['nama', 'name', 'full_name', 'username']) ??
          savedNama;
      _userData!['email'] =
          _resolveProfileField(_userData, ['email', 'user_email']) ??
              savedEmail;
      _userData!['role'] =
          _resolveProfileField(_userData, ['role']) ?? savedRole;
      _userData!['created_at'] = _resolveProfileField(_userData, [
            'created_at',
            'createdAt',
            'joined_at',
            'joinedAt',
            'tanggal_daftar'
          ]) ??
          savedCreatedAt;
    } else {
      _userData = {
        'nama': savedNama,
        'email': savedEmail,
        'role': savedRole,
        'created_at': savedCreatedAt,
      };
    }

    // Override role with local preference for role switching
    final prefs = await SharedPreferences.getInstance();
    final localRole = prefs.getString('user_role');
    if (localRole != null && localRole.isNotEmpty) {
      _userData?['role'] = localRole;
    }

    if (mounted) setState(() => _isLoading = false);
  }

  String? _resolveProfileField(Map<String, dynamic>? data, List<String> keys) {
    if (data == null) return null;
    for (final key in keys) {
      final value = data[key];
      if (value != null && value.toString().trim().isNotEmpty) {
        return value.toString();
      }
    }
    return null;
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? AppColors.textDark : AppColors.textLight;
    final mutedColor = isDark ? AppColors.mutedDark : AppColors.mutedLight;
    final surfaceColor =
        isDark ? AppColors.surfaceDark : AppColors.surfaceLight;
    final borderColor = isDark ? AppColors.borderDark : AppColors.borderLight;
    final userName = (_userData?['nama'] ?? '').toString();
    final userEmail = (_userData?['email'] ?? '').toString();
    final userRole = (_userData?['role'] ?? 'buyer').toString();
    final initial = userName.trim().isNotEmpty
        ? userName.trim().substring(0, 1).toUpperCase()
        : 'U';

    return Scaffold(
      backgroundColor:
          isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text('Profil',
            style: TextStyle(
                color: textColor, fontWeight: FontWeight.bold, fontSize: 18)),
        centerTitle: true,
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: AppColors.primary))
          : Column(
              children: [
                // Profile header
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Column(
                    children: [
                      // Avatar
                      Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          color: AppColors.primary.withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: Text(
                            initial,
                            style: GoogleFonts.playfairDisplay(
                              fontSize: 32,
                              fontWeight: FontWeight.bold,
                              color: AppColors.primary,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        userName.isNotEmpty ? userName : 'User',
                        style: TextStyle(
                          color: textColor,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          userRole.toUpperCase(),
                          style: const TextStyle(
                            color: AppColors.primary,
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 1,
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                    ],
                  ),
                ),

                // Tab Bar
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Container(
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.05),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: TabBar(
                      controller: _tabController,
                      labelColor: Colors.white,
                      unselectedLabelColor: AppColors.primary,
                      indicator: BoxDecoration(
                        color: AppColors.primary,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      indicatorSize: TabBarIndicatorSize.tab,
                      labelStyle: const TextStyle(
                          fontSize: 13, fontWeight: FontWeight.w600),
                      dividerColor: Colors.transparent,
                      tabs: const [
                        Tab(text: 'Informasi Dasar'),
                        Tab(text: 'Pengaturan'),
                      ],
                    ),
                  ),
                ),

                // Tab Content
                Expanded(
                  child: TabBarView(
                    controller: _tabController,
                    children: [
                      // Tab 1: Info Dasar
                      SingleChildScrollView(
                        padding: const EdgeInsets.all(24),
                        child: Column(
                          children: [
                            _infoCard(
                                Icons.person_outline,
                                'Nama Lengkap',
                                userName.isNotEmpty ? userName : '-',
                                surfaceColor,
                                borderColor,
                                textColor,
                                mutedColor),
                            const SizedBox(height: 12),
                            _infoCard(
                                Icons.email_outlined,
                                'Email',
                                userEmail.isNotEmpty ? userEmail : '-',
                                surfaceColor,
                                borderColor,
                                textColor,
                                mutedColor),
                            const SizedBox(height: 12),
                            _infoCard(
                                Icons.badge_outlined,
                                'Role',
                                userRole.toUpperCase(),
                                surfaceColor,
                                borderColor,
                                AppColors.primary,
                                mutedColor),
                            const SizedBox(height: 12),
                            _infoCard(
                                Icons.calendar_today_outlined,
                                'Bergabung Sejak',
                                _formatJoinedDate(_userData?['created_at']),
                                surfaceColor,
                                borderColor,
                                textColor,
                                mutedColor),
                          ],
                        ),
                      ),

                      // Tab 2: Pengaturan
                      SingleChildScrollView(
                        padding: const EdgeInsets.all(24),
                        child: Column(
                          children: [
                            // Role switch (Buyer/Organizer)
                            Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: surfaceColor,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: borderColor),
                              ),
                              child: Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(10),
                                    decoration: BoxDecoration(
                                      color: AppColors.primary.withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: Icon(
                                      _userData?['role'] == 'creator'
                                          ? Icons.business_center
                                          : Icons.person,
                                      color: AppColors.primary,
                                      size: 20,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text('Mode Organizer',
                                            style: TextStyle(
                                                color: textColor,
                                                fontWeight: FontWeight.w600,
                                                fontSize: 14)),
                                        Text(
                                            _userData?['role'] == 'creator'
                                                ? 'Aktif - Dapat membuat event'
                                                : 'Nonaktif - Mode pembeli',
                                            style: TextStyle(
                                                color: mutedColor,
                                                fontSize: 12)),
                                      ],
                                    ),
                                  ),
                                  Switch(
                                    value: _userData?['role'] == 'creator',
                                    onChanged: (val) async {
                                      final newRole = val ? 'creator' : 'buyer';
                                      // Update shared preferences
                                      final prefs =
                                          await SharedPreferences.getInstance();
                                      await prefs.setString(
                                          'user_role', newRole);
                                      // Update local data
                                      setState(() {
                                        _userData?['role'] = newRole;
                                      });
                                      // Navigate to new shell with new role
                                      if (mounted) {
                                        Navigator.pushAndRemoveUntil(
                                          context,
                                          MaterialPageRoute(
                                              builder: (_) => RoleBasedShell(
                                                  role: newRole)),
                                          (route) => false,
                                        );
                                      }
                                    },
                                    activeColor: AppColors.primary,
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 16),

                            // Dark mode toggle
                            Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: surfaceColor,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: borderColor),
                              ),
                              child: Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(10),
                                    decoration: BoxDecoration(
                                      color: AppColors.primary.withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: Icon(
                                      isDark
                                          ? Icons.dark_mode
                                          : Icons.light_mode,
                                      color: AppColors.primary,
                                      size: 20,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text('Mode Gelap',
                                            style: TextStyle(
                                                color: textColor,
                                                fontWeight: FontWeight.w600,
                                                fontSize: 14)),
                                        Text(isDark ? 'Aktif' : 'Nonaktif',
                                            style: TextStyle(
                                                color: mutedColor,
                                                fontSize: 12)),
                                      ],
                                    ),
                                  ),
                                  Switch(
                                    value: isDark,
                                    onChanged: (val) {
                                      themeNotifier.value = val
                                          ? ThemeMode.dark
                                          : ThemeMode.light;
                                    },
                                    activeColor: AppColors.primary,
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 32),

                            // Logout button
                            SizedBox(
                              width: double.infinity,
                              height: 50,
                              child: ElevatedButton.icon(
                                onPressed: () => _handleLogout(),
                                icon: const Icon(Icons.logout),
                                label: const Text('Keluar',
                                    style: TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.bold)),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.red,
                                  foregroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12)),
                                  elevation: 0,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
    );
  }

  String _formatJoinedDate(dynamic value) {
    final text = value?.toString() ?? '';
    if (text.length >= 10) return text.substring(0, 10);
    return text.isNotEmpty ? text : '-';
  }

  Widget _infoCard(
      IconData icon,
      String label,
      String value,
      Color surfaceColor,
      Color borderColor,
      Color textColor,
      Color mutedColor) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: surfaceColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: borderColor),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: AppColors.primary, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label,
                    style: TextStyle(
                        color: mutedColor,
                        fontSize: 11,
                        fontWeight: FontWeight.w500)),
                const SizedBox(height: 4),
                Text(value,
                    style: TextStyle(
                        color: textColor,
                        fontSize: 14,
                        fontWeight: FontWeight.w600)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _handleLogout() async {
    await AuthService.logout();
    if (mounted) {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const LoginPage()),
        (_) => false,
      );
    }
  }
}
