class ApiConstants {
 
  // Base URLs
  // NOTE: Do not remove these URLs just in case we need to switch between local and public servers
  // Main API URL
  //static const String baseUrl = "http://192.168.4.111:8000/api/tradie"; 
  static const String baseUrl = "http://10.0.2.2:8000/api/tradie";   //For testing - Kath
  // Public assets URL
  //static const String publicBaseUrl = "http://192.168.4.111:8000";   
  static const String publicBaseUrl = "http://10.0.2.2:8000";   //For testing - Kath


  // Alternative URLs (for emulator or different networks)
  //static const String baseUrl = "http://10.0.2.2:8000/api/tradie";         // Android emulator
  //static const String baseUrl = 'http://192.168.100.250:8000/api/tradie';  // Local network option

  // Auth Endpoints
  static const String loginEndpoint = '/login';
  static const String registerEndpoint = '/register';
  static const String logoutEndpoint = '/logout';
  static const String refreshTokenEndpoint = '/refresh';   // Refresh token API
  static const String uploadAvatarEndpoint = '/upload-avatar';

  // Profile Setup Endpoints
  static const String basicInfoEndpoint = '/profile-setup/basic-info';
  static const String skillsEndpoint = '/profile-setup/skills';

  // Headers
  static const String contentType = 'application/json';
  static const String accept = 'application/json';
  static const String authorization = 'Authorization';
  static const String bearer = 'Bearer';
}


