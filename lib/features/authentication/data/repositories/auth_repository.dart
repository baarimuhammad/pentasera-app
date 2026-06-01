import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pentasera_app/core/constants/api_constants.dart';
import 'package:pentasera_app/core/errors/app_exception.dart';
import 'package:pentasera_app/core/network/dio_client.dart';
import 'package:pentasera_app/features/authentication/data/models/user_model.dart';

/// Result of a register operation.
class RegisterResult {
  final UserModel user;
  final String? token;
  final bool requiresVerification;

  const RegisterResult({
    required this.user,
    this.token,
    this.requiresVerification = false,
  });
}

/// Result of a login operation.
class LoginResult {
  final UserModel user;
  final String token;

  const LoginResult({
    required this.user,
    required this.token,
  });
}

/// Repository handling all authentication API calls via Dio.
class AuthRepository {
  final Dio _dio;

  AuthRepository({required Dio dio}) : _dio = dio;

  // ─────────────────────────────────────────
  // REGISTER
  // POST /api/register
  // ─────────────────────────────────────────
  Future<RegisterResult> register({
    required String nama,
    required String email,
    required String password,
    required String passwordConfirmation,
    String role = 'buyer',
  }) async {
    try {
      final response = await _dio.post(
        ApiConstants.register,
        data: {
          'nama': nama,
          'email': email,
          'password': password,
          'password_confirmation': passwordConfirmation,
          'role': role,
        },
      );

      final data = response.data as Map<String, dynamic>;
      final user = UserModel.fromJson(data['user'] as Map<String, dynamic>);
      final requiresVerification =
          data['requires_verification'] == true;
      final token = data['token'] as String?;

      return RegisterResult(
        user: user,
        token: token,
        requiresVerification: requiresVerification,
      );
    } on DioException catch (e) {
      throw AppException.fromDioException(e);
    }
  }

  // ─────────────────────────────────────────
  // LOGIN
  // POST /api/login
  // ─────────────────────────────────────────
  Future<LoginResult> login({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _dio.post(
        ApiConstants.login,
        data: {
          'email': email,
          'password': password,
        },
      );

      final data = response.data as Map<String, dynamic>;
      final user = UserModel.fromJson(data['user'] as Map<String, dynamic>);
      final token = data['token'] as String;

      return LoginResult(user: user, token: token);
    } on DioException catch (e) {
      throw AppException.fromDioException(e);
    }
  }

  // ─────────────────────────────────────────
  // RESEND VERIFICATION
  // POST /api/email/resend-verification
  // ─────────────────────────────────────────
  Future<String> resendVerification({required String email}) async {
    try {
      final response = await _dio.post(
        ApiConstants.resendVerification,
        data: {'email': email},
      );

      final data = response.data as Map<String, dynamic>;
      return data['message'] as String? ??
          'Email verifikasi berhasil dikirim ulang.';
    } on DioException catch (e) {
      throw AppException.fromDioException(e);
    }
  }

  // ─────────────────────────────────────────
  // GET ME
  // GET /api/me (requires auth token)
  // ─────────────────────────────────────────
  Future<UserModel> getMe() async {
    try {
      final response = await _dio.get(ApiConstants.me);
      final data = response.data as Map<String, dynamic>;

      // Backend returns {"user": {...}}
      final userData = data['user'] as Map<String, dynamic>? ??
          data['data'] as Map<String, dynamic>? ??
          data;

      return UserModel.fromJson(userData);
    } on DioException catch (e) {
      throw AppException.fromDioException(e);
    }
  }

  // ─────────────────────────────────────────
  // LOGOUT
  // POST /api/logout (requires auth token)
  // ─────────────────────────────────────────
  Future<void> logout() async {
    try {
      await _dio.post(ApiConstants.logout);
    } on DioException {
      // Silently ignore logout errors — we clear local data regardless
    }
  }
}

/// Riverpod provider for AuthRepository.
final authRepositoryProvider = Provider<AuthRepository>((ref) {
  final dioClient = ref.watch(dioClientProvider);
  return AuthRepository(dio: dioClient.dio);
});
