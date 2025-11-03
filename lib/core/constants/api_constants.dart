class ApiConstants {
 
   static const String baseUrl = "http://192.168.100.53:8000/api/tradie";
  //static const String baseUrl = "http://10.0.2.2:8000/api/tradie";
  //static const String baseUrl = 'http://127.0.0.1:8000/api';

  // Auth Endpoints
  static const String loginEndpoint = '/login';
  static const String registerEndpoint = '/register';
  static const String logoutEndpoint = '/logout';
  static const String refreshTokenEndpoint = '/refresh';

  static const String basicInfoEndpoint = '/profile-setup/basic-info';
  static const String skillsEndpoint = '/profile-setup/skills';

  static const String uploadAvatarEndpoint = '/tradie/upload-avatar';

  // Headers
  static const String contentType = 'application/json';
  static const String accept = 'application/json';
  static const String authorization = 'Authorization';
  static const String bearer = 'Bearer';
}


