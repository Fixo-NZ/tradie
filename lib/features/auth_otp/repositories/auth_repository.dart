import 'dart:convert';
import 'package:dio/dio.dart';
import '../../../core/network/api_client.dart';
import '../../../core/network/dio_client.dart';
import '../../../core/constants/api_constants.dart';
import '../../../core/storage/secure_storage_service.dart';
import '../models/auth_models.dart';

class AuthRepository {
  final ApiClient _apiClient = ApiClient();
  final SecureStorageService _storage = SecureStorageService();
  
  /// Save token to both storage services to ensure synchronization
  Future<void> _saveTokenToAllStorages(String token) async {
    await _storage.saveToken(token);
    await DioClient.instance.setToken(token);
  }

  /// Request OTP for phone number
  Future<OtpResponse> requestOtp(String phoneNumber) async {
    try {
      final response = await _apiClient.post(
        ApiConstants.requestOtp,
        data: {'phone': phoneNumber}, // Laravel expects 'phone' not 'phone_number'
      );

      final responseData = response.data;
      if (responseData == null || responseData is! Map<String, dynamic>) {
        throw Exception('Invalid OTP response format');
      }
      
      // Laravel returns { success: true, message: "...", otp_code: "123456" }
      return OtpResponse(
        success: responseData['success'] is bool ? responseData['success'] as bool : true,
        message: responseData['message'] is String ? responseData['message'] as String : 'OTP sent successfully',
        otpCode: responseData['otp_code'] is String ? responseData['otp_code'] as String : null,
      );
    } catch (e) {
      rethrow;
    }
  }

  /// Verify OTP code
  Future<OtpVerificationResponse> verifyOtp({
    required String phoneNumber,
    required String otp,
  }) async {
    try {
      final response = await _apiClient.post(
        ApiConstants.verifyOtp,
        data: {'phone': phoneNumber, 'otp_code': otp}, // Laravel expects 'phone' and 'otp_code'
      );

      final responseData = response.data;
      if (responseData == null || responseData is! Map<String, dynamic>) {
        throw Exception('Invalid OTP verification response format');
      }
      
      // Parse Laravel response structure
      User? user;
      String? token;
      
      if (responseData['status'] == 'existing_user') {
        // Extract user from data.user
        if (responseData['data'] != null && 
            responseData['data'] is Map<String, dynamic>) {
          final dataMap = responseData['data'] as Map<String, dynamic>;
          if (dataMap['user'] != null && dataMap['user'] is Map<String, dynamic>) {
            final userData = dataMap['user'] as Map<String, dynamic>;
            
            // Laravel verify-otp returns simplified user object, but we need full user
            // So we'll fetch the full user profile after getting the token
            // For now, create a minimal user object
            user = User(
              id: userData['id'] is int
                  ? userData['id'] as int
                  : (userData['id'] != null ? int.tryParse(userData['id'].toString()) ?? 0 : 0),
              firstName: userData['first_name'] is String
                  ? userData['first_name'] as String
                  : (userData['first_name']?.toString() ?? ''),
              lastName: userData['last_name'] is String
                  ? userData['last_name'] as String
                  : (userData['last_name']?.toString() ?? ''),
              email: userData['email'] is String
                  ? userData['email'] as String
                  : (userData['email']?.toString() ?? ''),
              phone: userData['phone'] is String ? userData['phone'] as String : null,
              status: userData['status'] is String
                  ? userData['status'] as String
                  : (userData['status']?.toString() ?? 'active'),
              middleName: userData['middle_name'] is String ? userData['middle_name'] as String : null,
              address: userData['address'] is String ? userData['address'] as String : null,
              city: userData['city'] is String ? userData['city'] as String : null,
              region: userData['region'] is String ? userData['region'] as String : null,
              postalCode: userData['postal_code'] is String ? userData['postal_code'] as String : null,
            );
          }
        }
        
        // Extract token from authorisation.access_token
        if (responseData['authorisation'] != null &&
            responseData['authorisation'] is Map<String, dynamic>) {
          final auth = responseData['authorisation'] as Map<String, dynamic>;
          if (auth['access_token'] is String) {
            token = auth['access_token'] as String;
          }
        }
        
        // Save token and user data
        if (token != null) {
          await _saveTokenToAllStorages(token);
          
          // Fetch full user profile after getting token
          try {
            final fullUser = await getCurrentUser();
            user = fullUser;
            await _storage.saveUserData(jsonEncode(fullUser.toJson()));
          } catch (e) {
            // If fetching full user fails, save the partial user data
            if (user != null) {
              await _storage.saveUserData(jsonEncode(user.toJson()));
            }
          }
        } else if (user != null) {
          await _storage.saveUserData(jsonEncode(user.toJson()));
        }
      }
      
      final otpResponse = OtpVerificationResponse(
        status: responseData['status'] is String ? responseData['status'] as String : 'new_user',
        message: responseData['message'] is String ? responseData['message'] as String : '',
        user: user,
        token: token,
      );

      return otpResponse;
    } catch (e) {
      rethrow;
    }
  }

  /// Login with email and password
  Future<LoginResponse> login({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _apiClient.post(
        ApiConstants.login,
        data: {'email': email, 'password': password},
      );

      final responseData = response.data;
      if (responseData == null || responseData is! Map<String, dynamic>) {
        throw Exception('Invalid login response format');
      }
      
      // Laravel tradie login returns: { success: true, data: { user: {...}, token: "..." } }
      User? user;
      String? token;
      
      // Get user from data.user
      Map<String, dynamic>? userJson;
      if (responseData['data'] != null && responseData['data'] is Map<String, dynamic>) {
        final data = responseData['data'] as Map<String, dynamic>;
        
        if (data['user'] != null && data['user'] is Map<String, dynamic>) {
          userJson = data['user'] as Map<String, dynamic>;
        }
        
        // Get token from data.token
        if (data['token'] is String) {
          token = data['token'] as String;
        }
      }
      
      if (userJson == null) {
        throw Exception('User data not found in login response');
      }
      
      if (token == null || token.isEmpty) {
        throw Exception('Token not found in login response');
      }
      
      // Parse user
      user = User(
        id: userJson['id'] is int
            ? userJson['id'] as int
            : (userJson['id'] != null ? int.tryParse(userJson['id'].toString()) ?? 0 : 0),
        firstName: userJson['first_name'] is String
            ? userJson['first_name'] as String
            : (userJson['first_name']?.toString() ?? ''),
        lastName: userJson['last_name'] is String
            ? userJson['last_name'] as String
            : (userJson['last_name']?.toString() ?? ''),
        email: userJson['email'] is String
            ? userJson['email'] as String
            : (userJson['email']?.toString() ?? ''),
        phone: userJson['phone'] is String ? userJson['phone'] as String : null,
        middleName: userJson['middle_name'] is String ? userJson['middle_name'] as String : null,
        address: userJson['address'] is String ? userJson['address'] as String : null,
        city: userJson['city'] is String ? userJson['city'] as String : null,
        region: userJson['region'] is String ? userJson['region'] as String : null,
        postalCode: userJson['postal_code'] is String ? userJson['postal_code'] as String : null,
        status: userJson['status'] is String
            ? userJson['status'] as String
            : (userJson['status']?.toString() ?? 'active'),
        createdAt: userJson['created_at'] is String ? userJson['created_at'] as String : null,
        updatedAt: userJson['updated_at'] is String ? userJson['updated_at'] as String : null,
      );
      
      final loginResponse = LoginResponse(
        user: user,
        token: token,
        message: responseData['message'] is String
            ? responseData['message'] as String
            : 'Login successful',
      );

      // Save token and user data to all storage services
      await _saveTokenToAllStorages(token);
      await _storage.saveUserData(jsonEncode(user.toJson()));

      return loginResponse;
    } on DioException catch (e) {
      String errorMessage = 'Login failed';
      if (e.response != null) {
        final errorData = e.response?.data;
        if (errorData != null && errorData is Map<String, dynamic>) {
          final errorObj = errorData['error'];
          if (errorObj != null && errorObj is Map<String, dynamic>) {
            errorMessage = errorObj['message'] is String ? errorObj['message'] as String : 'Login failed';
          } else {
            errorMessage = (errorData['message'] is String ? errorData['message'] as String : null) ?? 
                        'Login failed: ${e.response?.statusCode}';
          }
        } else {
          errorMessage = 'Login failed: ${e.response?.statusCode} - ${e.response?.statusMessage}';
        }
      } else {
        errorMessage = e.message ?? 'Network error during login';
      }
      throw Exception(errorMessage);
    } catch (e) {
      throw Exception('Login error: ${e.toString()}');
    }
  }

  /// Register new user
  Future<RegistrationResponse> register(RegistrationRequest request) async {
    try {
      final response = await _apiClient.post(
        ApiConstants.register,
        data: request.toJson(),
      );

      final responseData = response.data;
      if (responseData == null || responseData is! Map<String, dynamic>) {
        throw Exception('Invalid registration response format');
      }
      
      // Laravel returns { success: true, data: { user: {...}, token: "..." } }
      final data = responseData['data'];
      if (data == null || data is! Map<String, dynamic>) {
        throw Exception('Invalid registration response: data field missing');
      }
      
      final userData = data['user'];
      Map<String, dynamic>? userJson;
      if (userData != null && userData is Map<String, dynamic>) {
        userJson = userData;
      } else {
        throw Exception('User data not found in registration response');
      }
      
      final user = User(
        id: userJson['id'] is int
            ? userJson['id'] as int
            : (userJson['id'] != null ? int.tryParse(userJson['id'].toString()) ?? 0 : 0),
        firstName: userJson['first_name'] is String
            ? userJson['first_name'] as String
            : (userJson['first_name']?.toString() ?? ''),
        lastName: userJson['last_name'] is String
            ? userJson['last_name'] as String
            : (userJson['last_name']?.toString() ?? ''),
        email: userJson['email'] is String
            ? userJson['email'] as String
            : (userJson['email']?.toString() ?? ''),
        phone: userJson['phone'] is String ? userJson['phone'] as String : null,
        middleName: userJson['middle_name'] is String ? userJson['middle_name'] as String : null,
        address: userJson['address'] is String ? userJson['address'] as String : null,
        city: userJson['city'] is String ? userJson['city'] as String : null,
        region: userJson['region'] is String ? userJson['region'] as String : null,
        postalCode: userJson['postal_code'] is String ? userJson['postal_code'] as String : null,
        status: userJson['status'] is String
            ? userJson['status'] as String
            : (userJson['status']?.toString() ?? 'active'),
        createdAt: userJson['created_at'] is String ? userJson['created_at'] as String : null,
        updatedAt: userJson['updated_at'] is String ? userJson['updated_at'] as String : null,
      );
      
      String? token;
      if (data['token'] is String) {
        token = data['token'] as String;
      } else if (responseData['token'] is String) {
        token = responseData['token'] as String;
      }
      
      if (token == null || token.isEmpty) {
        throw Exception('Token not found in registration response');
      }
      
      final registrationResponse = RegistrationResponse(
        user: user,
        token: token,
        message: responseData['message'] is String
            ? responseData['message'] as String
            : 'Registration successful',
      );

      // Save token and user data to all storage services
      await _saveTokenToAllStorages(token);
      await _storage.saveUserData(jsonEncode(user.toJson()));

      return registrationResponse;
    } catch (e) {
      rethrow;
    }
  }

  /// Request password reset OTP
  Future<PasswordResetResponse> requestPasswordReset(String email) async {
    try {
      final response = await _apiClient.post(
        ApiConstants.resetPasswordRequest,
        data: {'email': email},
      );

      final responseData = response.data;
      if (responseData == null || responseData is! Map<String, dynamic>) {
        throw Exception('Invalid password reset response format');
      }
      
      return PasswordResetResponse(
        message: responseData['message'] is String ? responseData['message'] as String : 'OTP sent successfully',
        otp: null,
      );
    } catch (e) {
      rethrow;
    }
  }

  /// Reset password with OTP
  /// Note: Laravel route is PUT /tradie/reset-password (no userId in URL, uses authenticated user)
  Future<void> resetPassword({
    required int userId, // Not used in URL but kept for compatibility
    required String otp, // Not used by Laravel API, but kept for compatibility
    required String newPassword,
  }) async {
    try {
      // Laravel expects PUT request to /tradie/reset-password with new_password
      await _apiClient.put(
        ApiConstants.resetPasswordRoute,
        data: {
          'new_password': newPassword,
          'new_password_confirmation': newPassword,
        },
      );
    } catch (e) {
      rethrow;
    }
  }

  /// Get current user information
  Future<User> getCurrentUser() async {
    try {
      final response = await _apiClient.get(ApiConstants.me);
      final responseData = response.data;
      if (responseData == null || responseData is! Map<String, dynamic>) {
        throw Exception('Invalid user response format');
      }
      
      // Laravel returns { success: true, data: { user: {...} } }
      final data = responseData['data'];
      if (data == null || data is! Map<String, dynamic>) {
        throw Exception('Invalid user response: data field missing');
      }
      
      final userData = data['user'];
      if (userData == null || userData is! Map<String, dynamic>) {
        throw Exception('Invalid user response: user field missing');
      }
      
      final user = User.fromJson(userData);

      // Update stored user data
      await _storage.saveUserData(jsonEncode(user.toJson()));

      return user;
    } catch (e) {
      rethrow;
    }
  }

  /// Logout user
  Future<void> logout() async {
    try {
      await _apiClient.post(ApiConstants.logout);
    } catch (e) {
      // Continue with local logout even if API call fails
    } finally {
      // Clear all stored data from all storage services
      await _storage.clearAll();
      await DioClient.instance.clearToken();
    }
  }

  /// Check if user is authenticated
  Future<bool> isAuthenticated() async {
    final token = await _storage.getToken();
    return token != null && token.isNotEmpty;
  }

  /// Get stored user data
  Future<User?> getStoredUser() async {
    try {
      final userDataString = await _storage.getUserData();
      if (userDataString != null) {
        final userData = jsonDecode(userDataString);
        return User.fromJson(userData);
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  /// Get stored token
  Future<String?> getStoredToken() async {
    return await _storage.getToken();
  }
}
