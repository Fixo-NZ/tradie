import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import '../models/auth_models.dart';
import '../../../core/network/api_result.dart';
import '../../../core/network/dio_client.dart';
import '../../../core/constants/api_constants.dart';

class AuthRepository {
  final DioClient _dioClient = DioClient.instance;

  // LOGIN
  Future<ApiResult<AuthResponse>> login(LoginRequest request) async {
    try {
      final response = await _dioClient.dio.post(
        ApiConstants.loginEndpoint,
        data: request.toJson(),
      );
      if (kDebugMode) print('SUCCESSFUL LOGIN RESPONSE: ${response.data}');
      final authResponse = AuthResponse.fromJson(response.data);
      await _dioClient.setToken(authResponse.accessToken);
      return Success(authResponse);
    } on DioException catch (e) {
      return _handleDioError(e);
    } catch (e) {
      return Failure(message: 'Unexpected error: $e');
    }
  }

  // REGISTER
  Future<ApiResult<AuthResponse>> register(RegisterRequest request) async {
    try {
      final response = await _dioClient.dio.post(
        ApiConstants.registerEndpoint,
        data: request.toJson(),
      );
      final authResponse = AuthResponse.fromJson(response.data);
      await _dioClient.setToken(authResponse.accessToken);
      return Success(authResponse);
    } on DioException catch (e) {
      return _handleDioError(e);
    } catch (e) {
      return Failure(message: 'Unexpected error: $e');
    }
  }

  // LOGOUT
  Future<ApiResult<void>> logout() async {
    try {
      await _dioClient.dio.post(ApiConstants.logoutEndpoint);
      await _dioClient.clearToken();
      return const Success(null);
    } catch (e) {
      await _dioClient.clearToken();
      return Failure(message: 'Error during logout: $e');
    }
  }

  // IS LOGGED IN
  Future<bool> isLoggedIn() async {
    final token = await _dioClient.getToken();
    return token != null;
  }

  // REQUEST PASSWORD RESET
  Future<ApiResult<void>> requestPasswordReset(String email) async {
    try {
      await _dioClient.dio.post(
        ApiConstants.requestPasswordResetEndpoint,
        data: {'email': email},
      );
      return const Success(null);
    } on DioException catch (e) {
      return _handleDioError(e);
    } catch (e) {
      return Failure(message: 'Unexpected error: $e');
    }
  }

  // VERIFY OTP (Returns Token)
  Future<ApiResult<String>> verifyPasswordResetOtp(String email, String otp) async {
    try {
      final response = await _dioClient.dio.post(
        ApiConstants.verifyPasswordResetOtpEndpoint,
        data: {'email': email, 'otp_code': otp},
      );
      // Extract token from ['data']['password_reset_token']
      final token = response.data['data']['password_reset_token'];
      return Success(token);
    } on DioException catch (e) {
      return _handleDioError(e);
    } catch (e) {
      return Failure(message: 'Unexpected error: $e');
    }
  }

  // RESET PASSWORD (Takes Token)
  Future<ApiResult<void>> resetPassword({
    required String token,
    required String email,
    required String newPassword,
    required String confirmNewPassword,
  }) async {
    try {
      await _dioClient.dio.put(
        ApiConstants.setNewPasswordEndpoint,
        data: {
          'email': email,
          'new_password': newPassword,
          'new_password_confirmation': confirmNewPassword,
        },
        options: Options(
          headers: {'Authorization': 'Bearer $token'},
        ),
      );
      return const Success(null);
    } on DioException catch (e) {
      return _handleDioError(e);
    } catch (e) {
      return Failure(message: 'Unexpected error: $e');
    }
  }

  ApiResult<T> _handleDioError<T>(DioException e) {
    if (kDebugMode) print('DIO ERROR: ${e.response?.statusCode} - ${e.response?.data}');
    if (e.response != null && e.response!.data is Map<String, dynamic>) {
      final data = e.response!.data;
      final apiError = ApiError.fromJson(data);
      return Failure(
        message: apiError.error?.message ?? 'Unknown error',
        statusCode: e.response!.statusCode,
        errors: apiError.errors,
      );
    }
    return Failure(message: e.message ?? 'Network error');
  }
}