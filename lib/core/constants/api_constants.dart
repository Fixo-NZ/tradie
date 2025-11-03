class ApiConstants {
  static const String baseUrl = 'http://10.0.2.2:8000/api';

  // Auth
  static const String loginEndpoint = '/tradie/login';
  static const String registerEndpoint = '/tradie/register';
  static const String logoutEndpoint = '/tradie/logout';

  // Password Reset
  static const String requestPasswordResetEndpoint = '/tradie/reset-password-request';
  static const String verifyPasswordResetOtpEndpoint = '/tradie/verify-otp';
  static const String setNewPasswordEndpoint = '/tradie/reset-password';

  // Headers
  static const String contentType = 'application/json';
  static const String accept = 'application/json';
  static const String authorization = 'Authorization';
  static const String bearer = 'Bearer';
}