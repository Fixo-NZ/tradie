import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

class ApiService {
<<<<<<< HEAD
  // Base URL for all API requests
  //static const String baseUrl = "http://192.168.4.111:8000/api/tradie";
  static const String baseUrl = "http://10.0.2.2:8000/api/tradie";   //For testing - Kath
=======
  static const String baseUrl = "http://192.168.100.53:8000/api/tradie";
>>>>>>> f92fede8de9f93b9d130c4d8ccb47e1a2de544fd

  static const String token =
      "21|PCy519KIhPLm4BGBpZHLjtebcR4cKPZcCIJOWxN28564712c"; //For testing - Kath 

  // Temporary token for testing (normally stored securely)
  //static const String token =
  //    "20|ANvW0nyB5qXnngNF01fVwBwIdEb6oFw1MbLtYtULa00a62cc";

  // Generic GET
  Future<Map<String, dynamic>> get(String endpoint) async {
    final uri = Uri.parse('$baseUrl$endpoint');
    
    final response = await http.get(
      uri,
      headers: _headers(),
    );

    _logResponse(response);
    return jsonDecode(response.body);
  }

  // Generic POST (for JSON body)
  Future<http.Response> post(String endpoint, Map<String, dynamic> body) async {
    final uri = Uri.parse('$baseUrl$endpoint');

    final response = await http.post(
      uri,
      headers: _headers(),
      body: jsonEncode(body),
    );

    _logResponse(response);
    return response;
  }

  // Generic Multipart POST (for uploading images/files)
  Future<Map<String, dynamic>> multipartPost({
    required String endpoint,
    required Map<String, String> fields,
    File? file,
    String? fileFieldName,
  }) async {
    final uri = Uri.parse('$baseUrl$endpoint');
    final request = http.MultipartRequest('POST', uri);

    request.headers.addAll({
      'Authorization': 'Bearer $token',
      'Accept': 'application/json',
    });

    request.fields.addAll(fields);

    if (file != null && fileFieldName != null) {
      request.files.add(await http.MultipartFile.fromPath(
        fileFieldName,
        file.path,
      ));
    }

    final streamedResponse = await request.send();
    final responseBody = await streamedResponse.stream.bytesToString();

    print("Laravel Response: $responseBody");

    return {
      'statusCode': streamedResponse.statusCode,
      'body': responseBody,
    };
  }

  // Common headers
  Map<String, String> _headers() => {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      };

  // Log API responses for debugging
  void _logResponse(http.Response response) {
    print("[${response.statusCode}] ${response.request?.url}");
    print("Response body: ${response.body}");
  }
}
