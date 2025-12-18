import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../constants/api_constants.dart';

class DioClient {
  // Singleton pattern
  static final DioClient instance = DioClient._();

  final Dio _dio = Dio();
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  // Public getter
  Dio get dio => _dio;

  DioClient._() {
    _dio.options = BaseOptions(
      baseUrl: ApiConstants.baseUrl,
      connectTimeout: const Duration(seconds: 15),
      receiveTimeout: const Duration(seconds: 15),
      headers: {
        'Accept': 'application/json',
        'Content-Type': 'application/json',
      },
    );

    // --- 🚨 THE FIX: Add this Interceptor ---
    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        // 1. Read token from storage
        final token = await _storage.read(key: 'auth_token');

        // 2. Attach it to the header if it exists
        if (token != null) {
          options.headers['Authorization'] = 'Bearer $token';
        }

        return handler.next(options);
      },
      onError: (DioException e, handler) {
        // Optional: specific 401 handling
        if (e.response?.statusCode == 401) {
          print('🚨 Token expired or invalid.');
        }
        return handler.next(e);
      },
    ));
  }

  // Helper methods you likely use in AuthRepo
  Future<void> setToken(String token) async {
    await _storage.write(key: 'auth_token', value: token);
  }

  Future<void> clearToken() async {
    await _storage.delete(key: 'auth_token');
  }

  Future<String?> getToken() async {
    return await _storage.read(key: 'auth_token');
  }
}