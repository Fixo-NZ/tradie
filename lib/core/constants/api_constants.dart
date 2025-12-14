class ApiConstants {
  static const String baseUrl = 'http://10.0.2.2:8000/api';
  
  // ============================================================================
  // AUTH_OTP ENDPOINTS (features/auth_otp) - ACTIVE ENDPOINTS
  // ============================================================================
  static const String requestOtp = '/tradie/request-otp';
  static const String verifyOtp = '/tradie/verify-otp';
  static const String login = '/tradie/login';
  static const String register = '/tradie/register';
  static const String resetPasswordRequest = '/tradie/reset-password-request';
  static const String resetPasswordRoute = '/tradie/reset-password';
  static const String me = '/tradie/me';
  static const String logout = '/tradie/logout';

  // Legacy endpoints (deprecated)
  static const String loginEndpoint = '/tradie/login';
  static const String registerEndpoint = '/tradie/register';
  static const String logoutEndpoint = '/tradie/logout';
  static const String refreshTokenEndpoint = '/tradie/refresh';

  // Headers
  static const String contentType = 'application/json';
  static const String accept = 'application/json';
  static const String authorization = 'Authorization';
  static const String bearer = 'Bearer';

  // Timeout durations
  static const Duration connectTimeout = Duration(seconds: 30);
  static const Duration receiveTimeout = Duration(seconds: 30);

  // Storage keys
  static const String tokenKey = 'auth_token';
  static const String userKey = 'user_data';
}
