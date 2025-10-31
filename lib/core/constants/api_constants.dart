// lib/constants/api_constants.dart
class ApiConstants {
  // ✅ Use your local IP for emulator/device testing
  // static const String baseUrl = "http://192.168.100.53:8000/api/tradie";
  static const String baseUrl = "http://10.0.2.2:8000/api/tradie";
  //static const String baseUrl = 'http://127.0.0.1:8000/api';

  // Auth Endpoints
  static const String loginEndpoint = '/login';
  static const String registerEndpoint = '/register';
  static const String logoutEndpoint = '/logout';
  static const String refreshTokenEndpoint = '/refresh';

  // Profile Setup
  static const String basicInfoEndpoint = '/profile-setup/basic-info';
  static const String skillsEndpoint = '/profile-setup/skills';

  // endpoint expects a leading slash and will be appended to baseUrl
  static const String uploadAvatarEndpoint = '/tradie/upload-avatar';

  // Headers
  static const String contentType = 'application/json';
  static const String accept = 'application/json';
  static const String authorization = 'Authorization';
  static const String bearer = 'Bearer';
}



 // // ✅ Correct base URL (make sure this matches your local IP)
  // static const String baseUrl = "http://192.168.4.175:8000/api";

  // // ✅ Hardcoded token (replace with your working one)
  // static const String token = "5|XMGbQkyg7DtrB35QWxe6r9UrJXV197ZTR64CJGjH91266e95";
