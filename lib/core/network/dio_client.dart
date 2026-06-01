import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pentasera_app/core/constants/api_constants.dart';
import 'package:pentasera_app/core/network/auth_interceptor.dart';
import 'package:pentasera_app/core/storage/secure_storage.dart';

/// Provides a configured Dio instance with auth interceptor and logging.
class DioClient {
  late final Dio _dio;

  Dio get dio => _dio;

  DioClient({
    required SecureStorageService storage,
    VoidCallback? onUnauthorized,
  }) {
    _dio = Dio(
      BaseOptions(
        baseUrl: ApiConstants.baseUrl,
        connectTimeout: ApiConstants.connectTimeout,
        receiveTimeout: ApiConstants.receiveTimeout,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );

    // Add auth interceptor — auto attaches token and handles 401
    _dio.interceptors.add(
      AuthInterceptor(
        storage: storage,
        onUnauthorized: onUnauthorized,
      ),
    );

    // Add logging interceptor in debug mode
    if (kDebugMode) {
      _dio.interceptors.add(
        LogInterceptor(
          requestBody: true,
          responseBody: true,
          requestHeader: false,
          responseHeader: false,
          error: true,
          logPrint: (log) => debugPrint('[DIO] $log'),
        ),
      );
    }
  }
}

/// Riverpod provider for DioClient.
/// The onUnauthorized callback will be wired up in auth_provider.
final dioClientProvider = Provider<DioClient>((ref) {
  final storage = ref.watch(secureStorageProvider);
  return DioClient(storage: storage);
});
