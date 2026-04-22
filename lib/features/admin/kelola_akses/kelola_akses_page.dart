import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import 'package:pentasera_app/main.dart';
import 'package:pentasera_app/services/user_service.dart';

class KelolAksesPage extends StatefulWidget {
  const KelolAksesPage({super.key});

  @override
  State<KelolAksesPage> createState() => _KelolAksesPageState();
}

class _KelolAksesPageState extends State<KelolAksesPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  List<dynamic> _users = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadUsers();
  }

  Future<void> _loadUsers() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    final result = await UserService.getUsers();
    if (result['success']) {
      _users = result['data'] is List ? result['data'] : [];
    } else {
      _error = result['message'];
    }

    if (mounted) setState(() => _isLoading = false);
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

    return Scaffold(
      backgroundColor:
          isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text('Kelola Akses',
            style: TextStyle(
                color: textColor, fontWeight: FontWeight.bold, fontSize: 18)),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(Icons.refresh, color: mutedColor),
            onPressed: _loadUsers,
          ),
        ],
      ),
      body: Column(
        children: [
          // Tab bar
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
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
                labelStyle:
                    const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                dividerColor: Colors.transparent,
                tabs: const [
                  Tab(text: 'Daftar Pengguna'),
                  Tab(text: 'Atur Role'),
                ],
              ),
            ),
          ),

          Expanded(
            child: _isLoading
                ? _buildShimmer(isDark)
                : _error != null
                    ? _buildError(mutedColor)
                    : TabBarView(
                        controller: _tabController,
                        children: [
                          _buildUserList(isDark, textColor, mutedColor,
                              canChangeRole: false),
                          _buildUserList(isDark, textColor, mutedColor,
                              canChangeRole: true),
                        ],
                      ),
          ),
        ],
      ),
    );
  }

  Widget _buildUserList(bool isDark, Color textColor, Color mutedColor,
      {required bool canChangeRole}) {
    if (_users.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.people_outline, size: 48, color: mutedColor),
            const SizedBox(height: 12),
            Text('Belum ada pengguna', style: TextStyle(color: mutedColor)),
          ],
        ),
      );
    }

    return RefreshIndicator(
      color: AppColors.primary,
      onRefresh: _loadUsers,
      child: ListView.builder(
        padding: const EdgeInsets.all(20),
        itemCount: _users.length,
        itemBuilder: (context, i) => _buildUserCard(
            _users[i], isDark, textColor, mutedColor, canChangeRole),
      ),
    );
  }

  Widget _buildUserCard(Map<String, dynamic> user, bool isDark, Color textColor,
      Color mutedColor, bool canChangeRole) {
    final surfaceColor =
        isDark ? AppColors.surfaceDark : AppColors.surfaceLight;
    final borderColor = isDark ? AppColors.borderDark : AppColors.borderLight;

    final nama = user['nama'] ?? user['name'] ?? 'User';
    final email = user['email'] ?? '';
    final role = user['role'] ?? 'buyer';
    final isActive = user['is_active'] ?? user['status'] ?? true;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: surfaceColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: borderColor),
      ),
      child: Row(
        children: [
          // Avatar
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: _roleColor(role).withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                nama.toString().substring(0, 1).toUpperCase(),
                style: TextStyle(
                  color: _roleColor(role),
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(nama,
                    style: TextStyle(
                        color: textColor,
                        fontWeight: FontWeight.w600,
                        fontSize: 14)),
                const SizedBox(height: 2),
                Text(email, style: TextStyle(color: mutedColor, fontSize: 12)),
                const SizedBox(height: 6),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: _roleColor(role).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        role.toString().toUpperCase(),
                        style: TextStyle(
                          color: _roleColor(role),
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: (isActive == true || isActive == 1)
                            ? Colors.green.withOpacity(0.1)
                            : Colors.red.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        (isActive == true || isActive == 1)
                            ? 'AKTIF'
                            : 'NONAKTIF',
                        style: TextStyle(
                          color: (isActive == true || isActive == 1)
                              ? Colors.green
                              : Colors.red,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          if (canChangeRole)
            IconButton(
              icon: const Icon(Icons.edit, color: AppColors.primary, size: 20),
              onPressed: () => _showRoleDialog(user),
            ),
        ],
      ),
    );
  }

  Color _roleColor(String role) {
    switch (role.toLowerCase()) {
      case 'admin':
        return Colors.red;
      case 'creator':
        return Colors.blue;
      default:
        return AppColors.primary;
    }
  }

  void _showRoleDialog(Map<String, dynamic> user) {
    String selectedRole = user['role'] ?? 'buyer';
    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          title: const Text('Ubah Role'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Ubah role untuk ${user['nama'] ?? user['name']}'),
              const SizedBox(height: 16),
              ...[
                'buyer',
                'creator',
                'admin'
              ].map((role) => RadioListTile<String>(
                    value: role,
                    groupValue: selectedRole,
                    title: Text(role.toUpperCase()),
                    activeColor: AppColors.primary,
                    onChanged: (v) => setDialogState(() => selectedRole = v!),
                  )),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Batal'),
            ),
            ElevatedButton(
              onPressed: () async {
                Navigator.pop(ctx);
                final result = await UserService.updateUser({
                  'id': user['id'],
                  'role': selectedRole,
                });
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(result['success']
                          ? 'Role berhasil diubah'
                          : result['message'] ?? 'Gagal mengubah role'),
                      backgroundColor:
                          result['success'] ? Colors.green : Colors.red,
                    ),
                  );
                  _loadUsers();
                }
              },
              style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white),
              child: const Text('Simpan'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildShimmer(bool isDark) {
    return Shimmer.fromColors(
      baseColor: isDark ? Colors.grey[800]! : Colors.grey[300]!,
      highlightColor: isDark ? Colors.grey[700]! : Colors.grey[100]!,
      child: ListView.builder(
        padding: const EdgeInsets.all(20),
        itemCount: 5,
        itemBuilder: (_, __) => Container(
          height: 80,
          margin: const EdgeInsets.only(bottom: 12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }

  Widget _buildError(Color mutedColor) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.error_outline, size: 48, color: Colors.red),
          const SizedBox(height: 12),
          Text(_error ?? 'Terjadi kesalahan',
              style: TextStyle(color: mutedColor)),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: _loadUsers,
            style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white),
            child: const Text('Coba Lagi'),
          ),
        ],
      ),
    );
  }
}
