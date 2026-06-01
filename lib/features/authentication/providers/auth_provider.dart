import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pentasera_app/core/errors/app_exception.dart';
import 'package:pentasera_app/core/storage/secure_storage.dart';
import 'package:pentasera_app/features/authentication/data/models/user_model.dart';
import 'package:pentasera_app/features/authentication/data/repositories/auth_repository.dart';

// ─────────────────────────────────────────
// Auth State — sealed class hierarchy
// ─────────────────────────────────────────

/// Represents all possible authentication states.
sealed class AuthState {
  const AuthState();
}

/// Initial state — app just launched, haven't checked yet.
class AuthInitial extends AuthState {
  const AuthInitial();
}

/// Loading — checking session, logging in, registering.
class AuthLoading extends AuthState {
  const AuthLoading();
}

/// User is authenticated with a valid session.
class Authenticated extends AuthState {
  final UserModel user;
  final String token;

  const Authenticated({required this.user, required this.token});
}

/// User is not authenticated.
class Unauthenticated extends AuthState {
  const Unauthenticated();
}

/// Email verification required — user registered but hasn't verified.
class EmailVerificationRequired extends AuthState {
  final String email;
  final String? message;

  const EmailVerificationRequired({
    required this.email,
    this.message,
  });
}

/// An error occurred during auth operation.
class AuthError extends AuthState {
  final String message;
  final AuthState? previousState;

  const AuthError({required this.message, this.previousState});
}

// ─────────────────────────────────────────
// Auth Notifier — Riverpod Notifier
// ─────────────────────────────────────────

class AuthNotifier extends Notifier<AuthState> {
  late final AuthRepository _repository;
  late final SecureStorageService _storage;

  @override
  AuthState build() {
    _repository = ref.watch(authRepositoryProvider);
    _storage = ref.watch(secureStorageProvider);
    return const AuthInitial();
  }

  // ─────────────────────────────────────────
  // CHECK SESSION — called on app start
  // ─────────────────────────────────────────
  Future<void> checkSession() async {
    state = const AuthLoading();

    try {
      final hasToken = await _storage.hasToken();
      if (!hasToken) {
        state = const Unauthenticated();
        return;
      }

      // Token exists — verify with server
      final user = await _repository.getMe();
      final token = await _storage.getToken();

      if (token == null) {
        state = const Unauthenticated();
        return;
      }

      // Save fresh user data to storage
      await _storage.saveUserData(user.toJson());

      state = Authenticated(user: user, token: token);
    } on UnauthorizedException {
      // Token expired
      await _storage.clearAll();
      state = const Unauthenticated();
    } on AppException catch (e) {
      debugPrint('[AuthNotifier] checkSession error: $e');
      // Network error but we have cached data — try to use it
      final token = await _storage.getToken();
      final userData = await _storage.getUserData();
      if (token != null && userData != null) {
        state = Authenticated(
          user: UserModel.fromJson(userData),
          token: token,
        );
      } else {
        state = const Unauthenticated();
      }
    }
  }

  // ─────────────────────────────────────────
  // REGISTER
  // ─────────────────────────────────────────
  Future<void> register({
    required String nama,
    required String email,
    required String password,
    required String passwordConfirmation,
    String role = 'buyer',
  }) async {
    state = const AuthLoading();

    try {
      final result = await _repository.register(
        nama: nama,
        email: email,
        password: password,
        passwordConfirmation: passwordConfirmation,
        role: role,
      );

      if (result.requiresVerification) {
        // Email verification needed — redirect to verify screen
        state = EmailVerificationRequired(
          email: email,
          message: 'Registrasi berhasil. Silakan cek email untuk verifikasi.',
        );
      } else if (result.token != null) {
        // Direct login (no verification required)
        await _storage.saveToken(result.token!);
        await _storage.saveUserData(result.user.toJson());
        state = Authenticated(user: result.user, token: result.token!);
      } else {
        // Registration successful but no token — go to login
        state = EmailVerificationRequired(
          email: email,
          message: 'Registrasi berhasil. Silakan login.',
        );
      }
    } on AppException catch (e) {
      state = AuthError(message: e.message, previousState: const Unauthenticated());
    }
  }

  // ─────────────────────────────────────────
  // LOGIN
  // ─────────────────────────────────────────
  Future<void> login({
    required String email,
    required String password,
  }) async {
    state = const AuthLoading();

    try {
      final result = await _repository.login(
        email: email,
        password: password,
      );

      // Save token and user data
      await _storage.saveToken(result.token);
      await _storage.saveUserData(result.user.toJson());

      state = Authenticated(user: result.user, token: result.token);
    } on EmailNotVerifiedException catch (e) {
      // 403 — email not verified
      state = EmailVerificationRequired(
        email: e.email,
        message: e.message,
      );
    } on AppException catch (e) {
      state = AuthError(
        message: e.message,
        previousState: const Unauthenticated(),
      );
    }
  }

  // ─────────────────────────────────────────
  // RESEND VERIFICATION
  // ─────────────────────────────────────────
  Future<String> resendVerification({required String email}) async {
    try {
      return await _repository.resendVerification(email: email);
    } on AppException catch (e) {
      throw e;
    }
  }

  // ─────────────────────────────────────────
  // LOGOUT
  // ─────────────────────────────────────────
  Future<void> logout() async {
    try {
      await _repository.logout();
    } catch (_) {
      // Ignore logout API errors
    }

    await _storage.clearAll();
    state = const Unauthenticated();
  }

  // ─────────────────────────────────────────
  // RESET TO UNAUTHENTICATED
  // (e.g. after showing error, navigate back to login)
  // ─────────────────────────────────────────
  void resetToUnauthenticated() {
    state = const Unauthenticated();
  }

  // ─────────────────────────────────────────
  // SET EMAIL VERIFICATION REQUIRED
  // (e.g. from login page when 403 is detected)
  // ─────────────────────────────────────────
  void setEmailVerificationRequired(String email) {
    state = EmailVerificationRequired(email: email);
  }
}

// ─────────────────────────────────────────
// Provider
// ─────────────────────────────────────────

final authProvider = NotifierProvider<AuthNotifier, AuthState>(() {
  return AuthNotifier();
});
