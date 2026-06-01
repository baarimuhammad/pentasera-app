/// Immutable user model matching the Laravel backend response.
class UserModel {
  final int id;
  final String nama;
  final String email;
  final String role;
  final String? status;
  final bool emailVerified;
  final String? emailVerifiedAt;
  final String? createdAt;

  const UserModel({
    required this.id,
    required this.nama,
    required this.email,
    required this.role,
    this.status,
    this.emailVerified = false,
    this.emailVerifiedAt,
    this.createdAt,
  });

  /// Parse from JSON response.
  /// Handles both login response (email_verified as bool) and
  /// /me response (email_verified as bool + email_verified_at).
  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as int,
      nama: json['nama'] as String? ?? '',
      email: json['email'] as String? ?? '',
      role: json['role'] as String? ?? 'buyer',
      status: json['status'] as String?,
      emailVerified: json['email_verified'] == true ||
          json['email_verified'] == 1 ||
          json['email_verified_at'] != null,
      emailVerifiedAt: json['email_verified_at'] as String?,
      createdAt: json['created_at'] as String?,
    );
  }

  /// Convert to JSON for local storage.
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nama': nama,
      'email': email,
      'role': role,
      'status': status,
      'email_verified': emailVerified,
      'email_verified_at': emailVerifiedAt,
      'created_at': createdAt,
    };
  }

  /// Create a copy with optional field overrides.
  UserModel copyWith({
    int? id,
    String? nama,
    String? email,
    String? role,
    String? status,
    bool? emailVerified,
    String? emailVerifiedAt,
    String? createdAt,
  }) {
    return UserModel(
      id: id ?? this.id,
      nama: nama ?? this.nama,
      email: email ?? this.email,
      role: role ?? this.role,
      status: status ?? this.status,
      emailVerified: emailVerified ?? this.emailVerified,
      emailVerifiedAt: emailVerifiedAt ?? this.emailVerifiedAt,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  String toString() =>
      'UserModel(id: $id, nama: $nama, email: $email, role: $role, emailVerified: $emailVerified)';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UserModel &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          email == other.email;

  @override
  int get hashCode => id.hashCode ^ email.hashCode;
}
