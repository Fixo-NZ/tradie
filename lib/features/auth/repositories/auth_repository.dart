import 'package:dio/dio.dart';
import '../models/auth_models.dart';
import '../../../core/network/api_result.dart';
import '../../../core/network/dio_client.dart';
import '../../../core/constants/api_constants.dart';

class AuthRepository {
  final DioClient _dioClient = DioClient.instance;

  // --- Your existing code ---
  Future<ApiResult<AuthResponse>> login(LoginRequest request) async {
    try {
      final response = await _dioClient.dio.post(
        ApiConstants.loginEndpoint,
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
      await _dioClient.clearToken(); // Clear token even if logout fails
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
  // --- End of your existing code ---


  // --- ADDED NEW FUNCTIONS FOR PASSWORD RESET ---

  Future<ApiResult<void>> requestPasswordReset(String email) async {
    // This is a placeholder. You'll need the real endpoint.
    // It probably expects: { "email": email }
    print("REPO: Requesting password reset for $email");

    // --- FAKE DELAY AND SUCCESS ---
    // Replace this with your actual Dio call
    await Future.delayed(const Duration(seconds: 1));
    return const Success(null);
    // --- END FAKE ---

    /* // REAL DIO CALL (EXAMPLE)
    try {
      await _dioClient.dio.post(
        ApiConstants.requestPasswordResetEndpoint, // Add this to api_constants.dart
        data: {'email': email},
      );
      return const Success(null);
    } on DioException catch (e) {
      return _handleDioError(e);
    } catch (e) {
      return Failure(message: 'An unexpected error occurred: $e');
    }
    */
  }

  Future<ApiResult<void>> verifyPasswordResetOtp(
      String email,
      String otp,
      ) async {
    // This is a placeholder. You'll need the real endpoint.
    // It probably expects: { "email": email, "token": otp }
    print("REPO: Verifying OTP $otp for $email");

    // --- FAKE DELAY AND SUCCESS ---
    await Future.delayed(const Duration(seconds: 1));
    if (otp == "000000") {
      // Faking a bad OTP
      return const Failure(message: "Invalid OTP");
    }
    return const Success(null);
    // --- END FAKE ---

    /* // REAL DIO CALL (EXAMPLE)
    try {
      await _dioClient.dio.post(
        ApiConstants.verifyPasswordResetOtpEndpoint, // Add this
        data: {'email': email, 'token': otp},
      );
      return const Success(null);
    } on DioException catch (e) {
      return _handleDioError(e);
    } catch (e) {
      return Failure(message: 'An unexpected error occurred: $e');
    }
    */
  }

  Future<ApiResult<void>> setNewPassword({
    required String email,
    required String password,
    required String passwordConfirmation,
  }) async {
    // This is a placeholder. You'll need the real endpoint.
    // It probably expects: { "email": email, "password": password, "password_confirmation": passwordConfirmation }
    print("REPO: Setting new password for $email");

    // --- FAKE DELAY AND SUCCESS ---
    await Future.delayed(const Duration(seconds: 1));
    return const Success(null);
    // --- END FAKE ---

    /* // REAL DIO CALL (EXAMPLE)
    try {
      await _dioClient.dio.post(
        ApiConstants.setNewPasswordEndpoint, // Add this
        data: {
          'email': email,
          'password': password,
          'password_confirmation': passwordConfirmation,
        },
      );
      return const Success(null);
    } on DioException catch (e) {
      return _handleDioError(e);
    } catch (e) {
      return Failure(message: 'An unexpected error occurred: $e');
    }
    */
  }

  // --- END OF NEW FUNCTIONS ---


  // --- Your existing error handler ---
  ApiResult<T> _handleDioError<T>(DioException e) {
    if (e.response != null) {
      final data = e.response!.data;
      if (data is Map<String, dynamic>) {
        final apiError = ApiError.fromJson(data);
        return Failure(
          message: apiError.message,
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