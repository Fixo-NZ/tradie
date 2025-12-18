class ApiConstants {
 
  // Base URLs
  // NOTE: Do not remove these URLs just in case we need to switch between local and public servers
  // Main API URL
  //static const String baseUrl = "http://192.168.4.111:8000/api"; 
  static const String baseUrl = "http://10.0.2.2:8000/api";   //For testing - Kath
  //static const String baseUrl = "http://192.168.100.53:8000/api"; //For testing - Erika
  // static const String baseUrl = "http://192.168.5.7:8000/api"; //For testing - Erika school
  // Public assets URL
  //static const String publicBaseUrl = "http://192.168.4.111:8000";   
  static const String publicBaseUrl = "http://10.0.2.2:8000";   //For testing - Kath
  //static const String publicBaseUrl = "http://192.168.100.53:8000"; //For testing - Erika
  // static const String publicBaseUrl = "http://192.168.5.7:8000"; //For testing - Erika school


  // Alternative URLs (for emulator or different networks)
  //static const String baseUrl = "http://10.0.2.2:8000/api";         // Android emulator
  //static const String baseUrl = 'http://192.168.100.250:8000/api';  // Local network option
  //static const String baseUrl = "http://192.168.100.53:8000/api";
  //static const String publicBaseUrl = "http://192.168.100.53:8000";
  //static const String publicBaseUrl = "http://192.168.4.111:8000";
  //static const String baseUrl = "http://10.0.2.2:8000/api";
  //static const String baseUrl = 'http://192.168.100.250:8000/api';

  // Auth Endpoints
  static const String refreshTokenEndpoint = '/refresh';
  static const String loginEndpoint = '/tradie/login';
  static const String registerEndpoint = '/tradie/register';
  static const String logoutEndpoint = '/tradie/logout';
  static const String meEndpoint = '/tradie/me';

  // Password Reset
  static const String requestPasswordResetEndpoint = '/tradie/reset-password-request';
  static const String requestOtpEndpoint = '/tradie/request-otp';
  static const String verifyPasswordResetOtpEndpoint = '/tradie/verify-otp';
  static const String setNewPasswordEndpoint = '/tradie/reset-password';

  // Email Verification
  static const String resendEmailVerificationEndpoint = '/tradie/auth/resend-email-verification';

  // Profile Setup Endpoints - All under /tradie/profile-setup/
  static const String uploadAvatarEndpoint = '/tradie/profile-setup/avatar';
  static const String basicInfoEndpoint = '/tradie/profile-setup/basic-info';
  static const String skillsEndpoint = '/tradie/profile-setup/skills';
  static const String availabilityEndpoint = '/tradie/profile-setup/availability';
  static const String portfolioEndpoint = '/tradie/profile-setup/portfolio';
  static const String completeSetupEndpoint = '/tradie/profile-setup/complete';
  static const String getProfileEndpoint = '/tradie/profile-setup/get-profile';
  static const String getSkillsEndpoint = '/tradie/profile-setup/get-skills';
  static const String licenseUploadEndpoint = '/tradie/profile-setup/licenses';

  // Headers
  static const String contentType = 'application/json';
  static const String accept = 'application/json';
  static const String authorization = 'Authorization';
  static const String bearer = 'Bearer';
}
