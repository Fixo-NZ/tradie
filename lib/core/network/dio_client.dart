import 'package:dio/dio.dart';
import '../constants/api_constants.dart';
import '../storage/secure_storage_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class DioClient {
  static DioClient? _instance;
  late Dio _dio;
  final SecureStorageService _storage = SecureStorageService();

  DioClient._internal() {
    _dio = Dio(
      BaseOptions(
        baseUrl: ApiConstants.baseUrl,
        connectTimeout: const Duration(seconds: 30),
        receiveTimeout: const Duration(seconds: 30),
        headers: {
          'Content-Type': ApiConstants.contentType,
          'Accept': ApiConstants.accept,
        },
      ),
    );

    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final token = await _storage.getToken();
          if (token != null && token.isNotEmpty) {
            final cleanToken = token.trim();
            options.headers[ApiConstants.authorization] =
                '${ApiConstants.bearer} $cleanToken';
          }
          handler.next(options);
        },
        onError: (error, handler) async {
          if (error.response?.statusCode == 401) {
            await _storage.deleteToken();
          }
          handler.next(error);
        },
      ),
    );
  }

  static DioClient get instance {
    _instance ??= DioClient._internal();
    return _instance!;
  }

  Dio get dio => _dio;

  Future<void> setToken(String token) async {
    await _storage.saveToken(token);
  }

  Future<void> clearToken() async {
    await _storage.deleteToken();
  }

  Future<String?> getToken() async {
    return await _storage.getToken();
  }
}

final dioProvider = Provider<Dio>((ref) => DioClient.instance.dio);

// Optional: provider for the DioClient itself
final dioClientProvider = Provider<DioClient>((ref) => DioClient.instance);
