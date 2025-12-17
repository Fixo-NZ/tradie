import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../models/auth_models.dart';
import '../../../core/network/api_result.dart';
import '../../../core/network/dio_client.dart';
import '../../../core/constants/api_constants.dart';

class AuthRepository {
  final DioClient _dioClient;
  final FlutterSecureStorage _secureStorage;

  // Use tradie-specific keys
  static const String _tokenKey = 'tradie_access_token';
  static const String _userIdKey = 'tradie_user_id';

  AuthRepository._internal()
    : _dioClient = DioClient.instance,
      _secureStorage = const FlutterSecureStorage();

  factory AuthRepository() {
    return _instance;
  }
  static final AuthRepository _instance = AuthRepository._internal();

  AuthRepository.withClient(this._dioClient, this._secureStorage);

  Future<ApiResult<AuthResponse>> login(LoginRequest request) async {
    try {
      print('🔍 Sending login request...');
      print('📤 URL: ${ApiConstants.baseUrl}${ApiConstants.loginEndpoint}');
      print('📦 Request data: ${request.toJson()}');
      
      final response = await _dioClient.dio.post(
        ApiConstants.loginEndpoint,
        data: request.toJson(),
      );

      print('✅ Login Response received');
      print('📥 Status Code: ${response.statusCode}');
      print('📄 Full Response: ${response.data}');
      print('📄 Response type: ${response.data.runtimeType}');
      
      final responseData = response.data;
      
      // DEBUG: Check what we're getting
      if (responseData is Map<String, dynamic>) {
        print('🔍 Response keys: ${responseData.keys.toList()}');
        if (responseData.containsKey('data')) {
          print('🔍 Found "data" key, value type: ${responseData['data'].runtimeType}');
          print('🔍 Data content: ${responseData['data']}');
        }
      }
      
      // Try to parse the response
      dynamic dataToParse;
      
      if (responseData is Map<String, dynamic>) {
        if (responseData.containsKey('data')) {
          dataToParse = responseData['data'];
          print('🔍 Using response.data[\'data\']');
        } else {
          dataToParse = responseData;
          print('🔍 Using response.data directly');
        }
      } else {
        dataToParse = responseData;
        print('🔍 Using response.data (not a map)');
      }
      
      print('🔍 Data to parse: $dataToParse');
      
      final authResponse = AuthResponse.fromJson(dataToParse);
      
      // Store token using DioClient (uses tradie_access_token)
      await _dioClient.setToken(authResponse.accessToken);
      
      // Store user ID
      await _secureStorage.write(
        key: _userIdKey,
        value: authResponse.user.id.toString()
      );

      print('✅ Login successful, user ID: ${authResponse.user.id}');
      return Success(authResponse);
    } on DioException catch (e) {
      print('❌ Login DioException: ${e.message}');
      print('❌ Response: ${e.response?.data}');
      return _handleDioError(e);
    } catch (e, stackTrace) {
      print('❌ Login Error: $e');
      print('📋 Stack trace: $stackTrace');
      return Failure(message: 'An unexpected error occurred: $e');
    }
  }

  Future<ApiResult<AuthResponse>> register(RegisterRequest request) async {
    try {
      print('🔍 Sending register request...');
      print('📤 URL: ${ApiConstants.baseUrl}${ApiConstants.registerEndpoint}');
      print('📦 Request data: ${request.toJson()}');
      
      final response = await _dioClient.dio.post(
        ApiConstants.registerEndpoint,
        data: request.toJson(),
      );

      print('✅ Register Response received');
      print('📥 Status Code: ${response.statusCode}');
      print('📄 Full Response: ${response.data}');
      print('📄 Response type: ${response.data.runtimeType}');
      
      final responseData = response.data;
      
      // DEBUG: Check what we're getting
      if (responseData is Map<String, dynamic>) {
        print('🔍 Response keys: ${responseData.keys.toList()}');
        if (responseData.containsKey('data')) {
          print('🔍 Found "data" key, value type: ${responseData['data'].runtimeType}');
          print('🔍 Data content: ${responseData['data']}');
        }
      }
      
      // Try to parse the response
      dynamic dataToParse;
      
      if (responseData is Map<String, dynamic>) {
        if (responseData.containsKey('data')) {
          dataToParse = responseData['data'];
          print('🔍 Using response.data[\'data\']');
        } else {
          dataToParse = responseData;
          print('🔍 Using response.data directly');
        }
      } else {
        dataToParse = responseData;
        print('🔍 Using response.data (not a map)');
      }
      
      print('🔍 Data to parse: $dataToParse');
      
      final authResponse = AuthResponse.fromJson(dataToParse);
      
      // Store both token and user ID
      await _secureStorage.write(key: _tokenKey, value: authResponse.accessToken);
      await _secureStorage.write(
        key: _userIdKey,
        value: authResponse.user.id.toString()
      );
      await _dioClient.setToken(authResponse.accessToken);

      print('✅ Registration successful, user ID: ${authResponse.user.id}');
      return Success(authResponse);
    } on DioException catch (e) {
      print('❌ Register DioException: ${e.message}');
      print('❌ Response: ${e.response?.data}');
      return _handleDioError(e);
    } catch (e, stackTrace) {
      print('❌ Register Error: $e');
      print('📋 Stack trace: $stackTrace');
      return Failure(message: 'An unexpected error occurred: $e');
    }
  }

  // GET CURRENT USER ID
  Future<int?> getCurrentUserId() async {
    final userIdString = await _secureStorage.read(key: _userIdKey);
    if (userIdString != null && userIdString.isNotEmpty) {
      return int.tryParse(userIdString);
    }
    return null;
  }

  Future<ApiResult<void>> logout() async {
    try {
      await _dioClient.dio.post(ApiConstants.logoutEndpoint);
      await _dioClient.clearToken(); // Clears tradie_access_token and tradie_user_id
      await _secureStorage.delete(key: _tokenKey);
      await _secureStorage.delete(key: _userIdKey);
      return const Success(null);
    } on DioException catch (e) {
      await _dioClient.clearToken();
      await _secureStorage.delete(key: _tokenKey);
      return _handleDioError(e);
    } catch (e) {
      await _dioClient.clearToken();
      await _secureStorage.delete(key: _tokenKey);
      return Failure(message: 'An unexpected error occurred: $e');
    }
  }

  Future<bool> isLoggedIn() async {
    final token = await _secureStorage.read(key: _tokenKey);
    if (token != null) {
      await _dioClient.setToken(token);
      return true;
    }
    return false;
  }

  ApiResult<T> _handleDioError<T>(DioException e) {
    if (e.response != null) {
      final data = e.response!.data;
      print('❌ DioError Response: $data');
      
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