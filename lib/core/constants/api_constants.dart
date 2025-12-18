class ApiConstants {
 
  // Base URLs
  // NOTE: Do not remove these URLs just in case we need to switch between local and public servers
  // Main API URL
<<<<<<< Updated upstream
  //static const String baseUrl = "http://192.168.4.111:8000/api/tradie"; 
  // static const String baseUrl = "http://10.0.2.2:8000/api/tradie";   //For testing - Kath
  static const String baseUrl = "http://192.168.100.53:8000/api/tradie"; //For testing - Erika
  // static const String baseUrl = "http://192.168.5.7:8000/api/tradie"; //For testing - Erika school
=======
  //static const String baseUrl = "http://192.168.4.111:8000/api"; 
  // static const String baseUrl = "http://10.0.2.2:8000/api";   //For testing - Kath
  static const String baseUrl = "http://192.168.100.53:8000/api"; //For testing - Erika
  // static const String baseUrl = "http://192.168.5.7:8000/api"; //For testing - Erika school
>>>>>>> Stashed changes
  // Public assets URL
  //static const String publicBaseUrl = "http://192.168.4.111:8000";   
  // static const String publicBaseUrl = "http://10.0.2.2:8000";   //For testing - Kath
  static const String publicBaseUrl = "http://192.168.100.53:8000"; //For testing - Erika
  // static const String publicBaseUrl = "http://192.168.5.7:8000"; //For testing - Erika school


  // Alternative URLs (for emulator or different networks)
  //static const String baseUrl = "http://10.0.2.2:8000/api/tradie";         // Android emulator
  //static const String baseUrl = 'http://192.168.100.250:8000/api/tradie';  // Local network option
  //static const String baseUrl = "http://192.168.100.53:8000/api/tradie";
  //static const String publicBaseUrl = "http://192.168.100.53:8000";
  //static const String publicBaseUrl = "http://192.168.4.111:8000";
  //static const String baseUrl = "http://10.0.2.2:8000/api/tradie";
  //static const String baseUrl = 'http://192.168.100.250:8000/api/tradie';

  // Auth Endpoints
  static const String loginEndpoint = '/login';
  static const String registerEndpoint = '/register';
  static const String logoutEndpoint = '/logout';
  static const String refreshTokenEndpoint = '/refresh';   // Refresh token API
  static const String uploadAvatarEndpoint = '/upload-avatar';

  // Profile Setup Endpoints
  static const String basicInfoEndpoint = '/profile-setup/basic-info';
  static const String skillsEndpoint = '/profile-setup/skills';
  static const String licenseUploadEndpoint = '/profile-setup/licenses';

  // Headers
  static const String contentType = 'application/json';
  static const String accept = 'application/json';
  static const String authorization = 'Authorization';
  static const String bearer = 'Bearer';
}


