class ApiConstants {
  static const String baseUrl = 'http://10.0.2.2:8000/api';
  static const String loginEndpoint = '/tradie/login';
  static const String registerEndpoint = '/tradie/register';
  static const String logoutEndpoint = '/tradie/logout';
  static const String refreshTokenEndpoint = '/tradie/refresh';


  // Tradie Job Application Endpoints
  static const String availableJobsEndpoint = '/tradie/jobs/available';
  static const String myApplicationsEndpoint = '/tradie/jobs/my-applications';
  static const String applyJobEndpoint = '/tradie/jobs'; // Will append /{id}/apply
  static const String completeJobEndpoint = '/tradie/jobs'; // Will append /{id}/complete

  // Headers
  static const String contentType = 'application/json';
  static const String accept = 'application/json';
  static const String authorization = 'Authorization';
  static const String bearer = 'Bearer';



}
