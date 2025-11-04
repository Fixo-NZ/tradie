class ApiConstants {
 
  // static const String baseUrl = "http://192.168.100.53:8000/api/tradie";
  // static const String baseUrl = "http://10.0.2.2:8000/api/tradie";
  static const String baseUrl = 'http://192.168.100.250:8000/api/tradie';

  // Auth Endpoints
  static const String loginEndpoint = '/login';
  static const String registerEndpoint = '/register';
  static const String logoutEndpoint = '/logout';
  static const String refreshTokenEndpoint = '/refresh';
  static const String uploadAvatarEndpoint = '/upload-avatar';

  static const String basicInfoEndpoint = '/profile-setup/basic-info';
  static const String skillsEndpoint = '/profile-setup/skills';

  // Headers
  static const String contentType = 'application/json';
  static const String accept = 'application/json';
  static const String authorization = 'Authorization';
  static const String bearer = 'Bearer';
}


