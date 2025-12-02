import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import '../models/auth_models.dart';
import '../../../core/network/api_result.dart';
import '../../../core/network/dio_client.dart';
import '../../../core/constants/api_constants.dart';

class AuthRepository {
  final DioClient _dioClient = DioClient.instance;

  Future<ApiResult<AuthResponse>> login(LoginRequest request) async {
    try {
      final response = await _dioClient.dio.post(
        ApiConstants.loginEndpoint,
        data: request.toJson(),
      );

      if (kDebugMode) {
        print('SUCCESSFUL LOGIN RESPONSE: ${response.data}');
      }

      final authResponse = AuthResponse.fromJson(response.data);
      await _dioClient.setToken(authResponse.accessToken);

      return Success(authResponse);
    } on DioException catch (e) {
      return _handleDioError(e);
    } catch (e) {
      if (kDebugMode) {
        print('JSON PARSING CRASH: $e');
        print('STACK TRACE: ${e.toString()}');
      }
      return Failure(message: 'An unexpected error occurred: $e');
    }
  }

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
      return Failure(message: 'An unexpected error occurred: $e');
    }
  }

  Future<ApiResult<void>> logout() async {
    try {
      await _dioClient.dio.post(ApiConstants.logoutEndpoint);
      await _dioClient.clearToken();
      return const Success(null);
    } on DioException catch (e) {
      await _dioClient.clearToken();
      return _handleDioError(e);
    } catch (e) {
      await _dioClient.clearToken();
      return Failure(message: 'An unexpected error occurred: $e');
    }
  }

  Future<bool> isLoggedIn() async {
    final token = await _dioClient.getToken();
    return token != null;
  }

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
      return Failure(message: 'An unexpected error occurred: $e');
    }
  }

  // --- UPDATED: Returns the token string instead of void ---
  Future<ApiResult<String>> verifyPasswordResetOtp(
      String email,
      String otp,
      ) async {
    try {
      final response = await _dioClient.dio.post(
        ApiConstants.verifyPasswordResetOtpEndpoint,
        data: {
          'email': email,
          'otp_code': otp // Matches server expectation
        },
      );

      // --- FIX IS HERE ---
      // Extract token based on your NEW PHP structure:
      // ['data']['password_reset_token']
      final token = response.data['data']['password_reset_token'];

      return Success(token);
    } on DioException catch (e) {
      return _handleDioError(e);
    } catch (e) {
      return Failure(message: 'An unexpected error occurred: $e');
    }
  }

  // --- UPDATED: Accepts token, sends in header, uses correct field names ---
  Future<ApiResult<void>> setNewPassword({
    required String token,
    required String email,
    required String password,
    required String passwordConfirmation,
  }) async {
    try {
      await _dioClient.dio.post(
        ApiConstants.setNewPasswordEndpoint,
        data: {
          'email': email,
          'new_password': password, // Changed key to match PHP
          'new_password_confirmation': passwordConfirmation, // Changed key to match PHP
        },
        options: Options(
          headers: {
            'Authorization': 'Bearer $token', // Send the token here
          },
        ),
      );
      return const Success(null);
    } on DioException catch (e) {
      return _handleDioError(e);
    } catch (e) {
      return Failure(message: 'An unexpected error occurred: $e');
    }
  }

  ApiResult<T> _handleDioError<T>(DioException e) {
    if (kDebugMode) {
      print('DIO ERROR: ${e.response?.statusCode} - ${e.response?.data}');
    }

    if (e.response != null) {
      final data = e.response!.data;
      if (data is Map<String, dynamic>) {
        final apiError = ApiError.fromJson(data);

        String errorMessage = apiError.error?.message ??
            apiError.errors?.values.first.first ??
            'An unknown error occurred.';

        return Failure(
          message: errorMessage,
          statusCode: e.response!.statusCode,
          errors: apiError.errors,
        );
      }
    }

    switch (e.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return const Failure(message: 'Connection timeout. Please try again.');
      case DioExceptionType.connectionError:
        return const Failure(message: 'No internet connection.');
      default:
        return Failure(message: 'Network error: ${e.message}');
    }
  }
}