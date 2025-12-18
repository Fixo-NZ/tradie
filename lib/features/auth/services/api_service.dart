import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

class ApiService {
  // Base URL for all API requests
<<<<<<< Updated upstream
  //static const String baseUrl = "http://192.168.4.111:8000/api/tradie";
  //  static const String baseUrl = "http://10.0.2.2:8000/api/tradie";   //For testing - Kath
  static const String baseUrl = "http://192.168.100.53:8000/api/tradie"; //For testing - erika
  // static const String baseUrl = "http://192.168.5.7:8000/api/tradie"; //For testing - erika school

  // static const String token =
      //  "11|imr6an8C0medfaHg7KYrnRjI5Y3nIBCydSu0E8QAc00bde93"; //For testing - Kath 
=======
  //static const String baseUrl = "http://192.168.4.111:8000/api";
  //  static const String baseUrl = "http://10.0.2.2:8000/api";   //For testing - Kath
  static const String baseUrl = "http://192.168.100.53:8000/api"; //For testing - erika
  // static const String baseUrl = "http://192.168.5.7:8000/api"; //For testing - erika school

  // static const String token =
  //      "11|imr6an8C0medfaHg7KYrnRjI5Y3nIBCydSu0E8QAc00bde93"; //For testing - Kath 
>>>>>>> Stashed changes

  // Temporary token for testing (normally stored securely)
  static const String token =
     "6|45dKRUfQ1OLscEVH4Th3bZiW2m3l0YPN3qTh0aiZ59e3c337"; //For testing - erika

  // Generic GET
  Future<Map<String, dynamic>> get(String endpoint) async {
    final uri = Uri.parse('$baseUrl$endpoint');
    final headers = _headers();
    _logOutgoingRequest('GET', uri, headers);

    final response = await http.get(
      uri,
      headers: headers,
    );

    _logResponse(response);
    return jsonDecode(response.body);
  }

  // Generic POST (for JSON body)
  Future<http.Response> post(String endpoint, Map<String, dynamic> body) async {
    final uri = Uri.parse('$baseUrl$endpoint');
    final headers = _headers();
    _logOutgoingRequest('POST', uri, headers, body: body);

    final response = await http.post(
      uri,
      headers: headers,
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

    // Log outgoing multipart request with masked token
    _logOutgoingRequest('MULTIPART POST', uri, request.headers);

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

  // Mask token for logs (show first 6 chars only)
  String _maskToken(String? t) {
    if (t == null || t.isEmpty) return '';
    if (t.length <= 6) return '***';
    return '${t.substring(0, 6)}...';
  }

  void _logOutgoingRequest(String method, Uri uri, Map<String, String>? headers, {Object? body}) {
    try {
      final h = Map<String, String>.from(headers ?? {});
      if (h.containsKey('Authorization')) {
        final v = h['Authorization']!;
        // Keep the 'Bearer ' prefix if present
        if (v.toLowerCase().startsWith('bearer ')) {
          final tokenPart = v.substring(7);
          h['Authorization'] = 'Bearer ${_maskToken(tokenPart)}';
        } else {
          h['Authorization'] = _maskToken(v);
        }
      }

      print('--- Outgoing API Request ---');
      print('Method: $method');
      print('URL: $uri');
      print('Headers: $h');
      if (body != null) print('Body: $body');
      print('----------------------------');
    } catch (_) {}
  }

  // Log API responses for debugging
  void _logResponse(http.Response response) {
    print("[${response.statusCode}] ${response.request?.url}");
    print("Response body: ${response.body}");
  }
}
