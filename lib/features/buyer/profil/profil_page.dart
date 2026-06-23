import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:pentasera_app/main.dart';
import 'package:pentasera_app/services/auth_service.dart';
import 'package:pentasera_app/services/user_service.dart';
import 'package:pentasera_app/features/authentication/login/login_page.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:pentasera_app/core/app_router.dart';
import 'package:image_picker/image_picker.dart';

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
  bool _isSavingProfile = false;

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
    final savedUserId = await AuthService.getUserId();
    final savedNoHp = await AuthService.getUserNoHp() ?? '';
    final savedAvatarFullUrl = await AuthService.getUserAvatarFullUrl() ?? '';

    if (result['success'] == true && result['data'] is Map) {
      _userData = Map<String, dynamic>.from(result['data'] as Map);
      _userData!['id'] =
          _resolveProfileId(_userData, ['id', 'user_id']) ?? savedUserId;
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
      // Ensure no_hp and avatar_full_url are set (server data takes priority)
      _userData!['no_hp'] = _userData!['no_hp'] ?? savedNoHp;
      _userData!['avatar_full_url'] = _userData!['avatar_full_url'] ?? savedAvatarFullUrl;
    } else {
      _userData = {
        'id': savedUserId,
        'nama': savedNama,
        'email': savedEmail,
        'role': savedRole,
        'created_at': savedCreatedAt,
        'no_hp': savedNoHp,
        'avatar_full_url': savedAvatarFullUrl,
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

  int? _resolveProfileId(Map<String, dynamic>? data, List<String> keys) {
    final value = _resolveProfileField(data, keys);
    if (value == null) return null;
    return int.tryParse(value);
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
    final avatarFullUrl = (_userData?['avatar_full_url'] ?? '').toString();
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
                      GestureDetector(
                        onTap: _changeAvatar,
                        child: Stack(
                          children: [
                            Container(
                              width: 80,
                              height: 80,
                              decoration: BoxDecoration(
                                color: AppColors.primary.withOpacity(0.1),
                                shape: BoxShape.circle,
                                image: avatarFullUrl.isNotEmpty
                                    ? DecorationImage(
                                        image: NetworkImage(avatarFullUrl),
                                        fit: BoxFit.cover,
                                      )
                                    : null,
                              ),
                              child: avatarFullUrl.isEmpty
                                  ? Center(
                                      child: Text(
                                        initial,
                                        style: GoogleFonts.playfairDisplay(
                                          fontSize: 32,
                                          fontWeight: FontWeight.bold,
                                          color: AppColors.primary,
                                        ),
                                      ),
                                    )
                                  : null,
                            ),
                            Positioned(
                              bottom: 0,
                              right: 0,
                              child: Container(
                                padding: const EdgeInsets.all(4),
                                decoration: const BoxDecoration(
                                  color: AppColors.primary,
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.camera_alt,
                                  color: Colors.white,
                                  size: 16,
                                ),
                              ),
                            ),
                          ],
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
                                Icons.phone_outlined,
                                'Nomor Telepon',
                                _userData?['no_hp'] ?? '-',
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
                            const SizedBox(height: 20),
                            SizedBox(
                              width: double.infinity,
                              height: 48,
                              child: ElevatedButton.icon(
                                onPressed: _isSavingProfile
                                    ? null
                                    : _showEditProfileSheet,
                                icon: const Icon(Icons.edit_outlined, size: 18),
                                label: const Text('Ubah Nama & Email'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.primary,
                                  foregroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  elevation: 0,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Tab 2: Pengaturan
                      SingleChildScrollView(
                        padding: const EdgeInsets.all(24),
                        child: Column(
                          children: [
                            if (userRole != 'admin') ...[
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

                                        // Step 1: Ambil user id dari cache lokal
                                        // (tidak perlu hit /api/me — sudah di-cache saat login)
                                        final cachedId = _userData?['id'];
                                        final userId = (cachedId is int
                                                ? cachedId
                                                : int.tryParse(
                                                    cachedId?.toString() ?? '')) ??
                                            await AuthService.getUserId();

                                        // Jika userId null → kemungkinan guest / belum login
                                        if (userId == null || userId <= 0) {
                                          if (mounted) {
                                            ScaffoldMessenger.of(context)
                                                .showSnackBar(
                                              const SnackBar(
                                                content: Text(
                                                    'Silakan login terlebih dahulu untuk mengganti mode'),
                                                backgroundColor: Colors.red,
                                              ),
                                            );
                                          }
                                          return;
                                        }

                                        setState(() => _isLoading = true);
                                        try {
                                          // Step 2: Hit PATCH /api/users/{id} untuk update role di database
                                          final headers =
                                              await AuthService.authHeaders();
                                          final response = await http.patch(
                                            Uri.parse(
                                                '${AuthService.baseUrl}/users/$userId'),
                                            headers: headers,
                                            body: jsonEncode({'role': newRole}),
                                          );

                                          debugPrint(
                                              '[RoleUpdate] statusCode: ${response.statusCode}');
                                          debugPrint(
                                              '[RoleUpdate] body: ${response.body}');

                                          if (response.statusCode != 200) {
                                            // Tampilkan pesan error asli dari backend
                                            String errMsg =
                                                'Gagal update role, coba lagi';
                                            try {
                                              final errBody = jsonDecode(
                                                  response.body) as Map;
                                              errMsg = errBody['message']
                                                      ?.toString() ??
                                                  errMsg;
                                            } catch (_) {}
                                            if (mounted) {
                                              ScaffoldMessenger.of(context)
                                                  .showSnackBar(
                                                SnackBar(
                                                  content: Text(errMsg),
                                                  backgroundColor: Colors.red,
                                                ),
                                              );
                                            }
                                            setState(() => _isLoading = false);
                                            return;
                                          }

                                          // Step 3: Update SharedPreferences
                                          final prefs = await SharedPreferences
                                              .getInstance();
                                          await prefs.setString(
                                              'user_role', newRole);

                                          // Step 4: Update local state
                                          setState(() {
                                            _userData?['role'] = newRole;
                                            _isLoading = false;
                                          });

                                          // Step 5: Navigate ke RoleBasedShell yang sesuai
                                          if (mounted) {
                                            ScaffoldMessenger.of(context)
                                                .showSnackBar(
                                              SnackBar(
                                                content: Text(
                                                  val
                                                      ? 'Mode Organizer aktif!'
                                                      : 'Kembali ke mode Pembeli',
                                                ),
                                                backgroundColor: Colors.green,
                                              ),
                                            );
                                            await Future.delayed(const Duration(
                                                milliseconds: 800));
                                            if (mounted) {
                                              Navigator.pushAndRemoveUntil(
                                                context,
                                                MaterialPageRoute(
                                                  builder: (_) => RoleBasedShell(
                                                      role: newRole),
                                                ),
                                                (_) => false,
                                              );
                                            }
                                          }
                                        } catch (e) {
                                          setState(() => _isLoading = false);
                                          if (mounted) {
                                            ScaffoldMessenger.of(context)
                                                .showSnackBar(
                                              SnackBar(
                                                content: Text('Error: $e'),
                                                backgroundColor: Colors.red,
                                              ),
                                            );
                                          }
                                        }
                                      },
                                      activeColor: AppColors.primary,
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 16),
                            ],

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
    if (text.trim().isEmpty) return '-';

    final date = DateTime.tryParse(text);
    if (date == null) return text;

    const monthNames = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'Mei',
      'Jun',
      'Jul',
      'Agu',
      'Sep',
      'Okt',
      'Nov',
      'Des',
    ];
    final localDate = date.toLocal();
    return '${localDate.day} ${monthNames[localDate.month - 1]} ${localDate.year}';
  }

  Future<void> _changeAvatar() async {
    final picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery, imageQuality: 80);
    if (image == null) return;

    setState(() => _isLoading = true);
    final result = await UserService.uploadAvatar(image.path);
    if (!mounted) return;

    if (result['success'] == true) {
      final data = result['data'];
      final newAvatarUrl = (data is Map ? data['avatar_full_url'] : null)?.toString();

      if (newAvatarUrl != null && newAvatarUrl.isNotEmpty) {
        setState(() {
          _userData?['avatar_full_url'] = newAvatarUrl;
        });

        // Properly refresh and cache all user data from server
        await AuthService.getMe();

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Foto profil berhasil diperbarui'),
              backgroundColor: Colors.green,
            ),
          );
        }
      }
      setState(() => _isLoading = false);
    } else {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result['message'] ?? 'Gagal mengupload foto profil'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
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

  Future<void> _showEditProfileSheet() async {
    if (_isSavingProfile) return;

    setState(() => _isSavingProfile = true);
    final result = await showModalBottomSheet<Map<String, dynamic>>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _EditProfileSheet(userData: _userData),
    );

    if (!mounted) return;
    setState(() => _isSavingProfile = false);

    if (result == null) return;
    setState(() => _userData = result);
    _showProfileMessage(
      'Informasi dasar berhasil diperbarui',
      isError: false,
    );
  }

  void _showProfileMessage(String message, {bool isError = true}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red : Colors.green,
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

class _EditProfileSheet extends StatefulWidget {
  final Map<String, dynamic>? userData;

  const _EditProfileSheet({required this.userData});

  @override
  State<_EditProfileSheet> createState() => _EditProfileSheetState();
}

class _EditProfileSheetState extends State<_EditProfileSheet> {
  late final TextEditingController _namaController;
  late final TextEditingController _emailController;
  late final TextEditingController _noHpController;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _namaController = TextEditingController(
        text: (widget.userData?['nama'] ?? '').toString());
    _emailController = TextEditingController(
        text: (widget.userData?['email'] ?? '').toString());
    _noHpController = TextEditingController(
        text: (widget.userData?['no_hp'] ?? '').toString());
  }

  @override
  void dispose() {
    _namaController.dispose();
    _emailController.dispose();
    _noHpController.dispose();
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
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return Padding(
      padding: EdgeInsets.only(bottom: bottomInset),
      child: Container(
        padding: const EdgeInsets.fromLTRB(24, 20, 24, 24),
        decoration: BoxDecoration(
          color: surfaceColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: SafeArea(
          top: false,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      'Edit Informasi Dasar',
                      style: TextStyle(
                        color: textColor,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed:
                        _isSaving ? null : () => Navigator.of(context).pop(),
                    icon: Icon(Icons.close, color: mutedColor),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              _editProfileField(
                label: 'Nama Lengkap',
                controller: _namaController,
                icon: Icons.person_outline,
                enabled: !_isSaving,
                textColor: textColor,
                borderColor: borderColor,
                fillColor: isDark
                    ? AppColors.backgroundDark
                    : AppColors.backgroundLight,
                keyboardType: TextInputType.name,
              ),
              const SizedBox(height: 14),
              _editProfileField(
                label: 'Nomor Telepon',
                controller: _noHpController,
                icon: Icons.phone_outlined,
                enabled: !_isSaving,
                textColor: textColor,
                borderColor: borderColor,
                fillColor: isDark
                    ? AppColors.backgroundDark
                    : AppColors.backgroundLight,
                keyboardType: TextInputType.phone,
              ),
              const SizedBox(height: 14),
              _editProfileField(
                label: 'Email',
                controller: _emailController,
                icon: Icons.email_outlined,
                enabled: !_isSaving,
                textColor: textColor,
                borderColor: borderColor,
                fillColor: isDark
                    ? AppColors.backgroundDark
                    : AppColors.backgroundLight,
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 22),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: _isSaving ? null : _saveProfile,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    disabledBackgroundColor: AppColors.primary.withOpacity(0.6),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ),
                  child: _isSaving
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : const Text(
                          'Simpan Perubahan',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _editProfileField({
    required String label,
    required TextEditingController controller,
    required IconData icon,
    required bool enabled,
    required Color textColor,
    required Color borderColor,
    required Color fillColor,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            color: textColor,
            fontSize: 13,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          enabled: enabled,
          keyboardType: keyboardType,
          style: TextStyle(color: textColor, fontSize: 14),
          decoration: InputDecoration(
            prefixIcon: Icon(
              icon,
              color: AppColors.primary,
              size: 20,
            ),
            filled: true,
            fillColor: fillColor,
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: borderColor),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: borderColor),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.primary, width: 2),
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _saveProfile() async {
    final nama = _namaController.text.trim();
    final email = _emailController.text.trim();
    final noHp = _noHpController.text.trim();


    if (nama.isEmpty) {
      _showMessage('Nama lengkap tidak boleh kosong');
      return;
    }
    if (email.isEmpty || !email.contains('@')) {
      _showMessage('Format email tidak valid');
      return;
    }

    final userId = _resolveProfileId(widget.userData, ['id', 'user_id']) ??
        await AuthService.getUserId();
    if (userId == null || userId <= 0) {
      _showMessage('ID user tidak ditemukan. Silakan login ulang.');
      return;
    }

    setState(() => _isSaving = true);
    final result = await UserService.updateProfile(
      userId: userId,
      nama: nama,
      email: email,
      noHp: noHp,
    );

    if (!mounted) return;
    setState(() => _isSaving = false);

    if (result['success'] == true) {
      // Build updated user with nama and email from request (API might not return full user object)
      final updatedUser = {
        ...(widget.userData ?? <String, dynamic>{}),
        'id': userId,
        'nama': nama,
        'email': email,
        'no_hp': noHp,
        // Preserve avatar_full_url from existing userData
        'avatar_full_url': widget.userData?['avatar_full_url'] ?? '',
      };

      // Cache the updated user data
      await AuthService.cacheUserData(updatedUser);

      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Profil berhasil diperbarui'),
          backgroundColor: Colors.green,
          duration: Duration(seconds: 2),
        ),
      );

      if (!mounted) return;
      Navigator.of(context).pop(updatedUser);
    } else {
      _showMessage(result['message'] ?? 'Gagal memperbarui profil');
    }
  }

  int? _resolveProfileId(Map<String, dynamic>? data, List<String> keys) {
    if (data == null) return null;
    for (final key in keys) {
      final value = data[key];
      if (value is int) return value;
      if (value is num) return value.toInt();
      final parsed = int.tryParse(value?.toString() ?? '');
      if (parsed != null) return parsed;
    }
    return null;
  }

  void _showMessage(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }
}
