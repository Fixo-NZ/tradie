class ApiConstants {
  static const String baseUrl = 'http://10.0.2.2:8000/api';
  static const String loginEndpoint = '/tradie_test/login';
  static const String registerEndpoint = '/tradie_test/register';
  static const String logoutEndpoint = '/tradie_test/logout';
  static const String refreshTokenEndpoint = '/tradie_test/refresh';

  // Headers
  static const String contentType = 'application/json';
  static const String accept = 'application/json';
  static const String authorization = 'Authorization';
  static const String bearer = 'Bearer';
}
