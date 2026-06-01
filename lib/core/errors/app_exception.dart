import 'package:dio/dio.dart';

/// Base exception for all app-level errors.
sealed class AppException implements Exception {
  final String message;
  final int? statusCode;

  const AppException(this.message, {this.statusCode});

  /// Factory to convert DioException into the appropriate AppException subtype.
  factory AppException.fromDioException(DioException e) {
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return const NetworkException('Koneksi timeout. Coba lagi.');

      case DioExceptionType.connectionError:
        return const NetworkException(
            'Tidak dapat terhubung ke server. Periksa koneksi internet Anda.');

      case DioExceptionType.badResponse:
        final statusCode = e.response?.statusCode;
        final data = e.response?.data;
        final message = _extractMessage(data);

        switch (statusCode) {
          case 401:
            return UnauthorizedException(
              message ?? 'Sesi telah berakhir. Silakan login kembali.',
            );
          case 403:
            // Check if this is an email verification error
            if (data is Map<String, dynamic> &&
                data['requires_verification'] == true) {
              return EmailNotVerifiedException(
                email: data['email'] as String? ?? '',
                message:
                    message ?? 'Email belum diverifikasi. Silakan cek email Anda.',
              );
            }
            return ServerException(
              message ?? 'Akses ditolak.',
              statusCode: 403,
            );
          case 422:
            final validationMsg = _extractValidationError(data);
            return ValidationException(
              validationMsg ?? message ?? 'Data tidak valid.',
              statusCode: 422,
            );
          case 404:
            return ServerException(
              message ?? 'Data tidak ditemukan.',
              statusCode: 404,
            );
          case 500:
            return ServerException(
              message ?? 'Terjadi kesalahan server.',
              statusCode: 500,
            );
          default:
            return ServerException(
              message ?? 'Terjadi kesalahan. Coba lagi.',
              statusCode: statusCode,
            );
        }

      case DioExceptionType.cancel:
        return const NetworkException('Permintaan dibatalkan.');

      case DioExceptionType.badCertificate:
        return const NetworkException('Sertifikat keamanan tidak valid.');

      case DioExceptionType.unknown:
      default:
        if (e.message?.contains('SocketException') == true ||
            e.message?.contains('Connection refused') == true) {
          return const NetworkException(
              'Tidak dapat terhubung ke server. Pastikan server berjalan.');
        }
        return NetworkException(
          e.message ?? 'Terjadi kesalahan yang tidak diketahui.',
        );
    }
  }

  static String? _extractMessage(dynamic data) {
    if (data is Map<String, dynamic>) {
      return data['message'] as String?;
    }
    return null;
  }

  static String? _extractValidationError(dynamic data) {
    if (data is Map<String, dynamic> && data['errors'] != null) {
      final errors = data['errors'] as Map<String, dynamic>;
      final firstField = errors.values.first;
      if (firstField is List && firstField.isNotEmpty) {
        return firstField[0] as String;
      }
    }
    return null;
  }

  @override
  String toString() => message;
}

/// Server returned an error response.
class ServerException extends AppException {
  const ServerException(super.message, {super.statusCode});
}

/// Network connectivity issue (no internet, timeout, etc.).
class NetworkException extends AppException {
  const NetworkException(super.message);
}

/// Token expired or invalid — user needs to re-authenticate.
class UnauthorizedException extends AppException {
  const UnauthorizedException(super.message) : super(statusCode: 401);
}

/// Email not verified — 403 with requires_verification flag.
class EmailNotVerifiedException extends AppException {
  final String email;

  const EmailNotVerifiedException({
    required this.email,
    String message = 'Email belum diverifikasi.',
  }) : super(message, statusCode: 403);
}

/// Validation error — 422 from backend.
class ValidationException extends AppException {
  const ValidationException(super.message, {super.statusCode = 422});
}
