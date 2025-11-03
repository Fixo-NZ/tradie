import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  final String baseUrl = 'http://localhost:8000'; // adjust as needed
  
  Future<Map<String, dynamic>> get(String endpoint) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl$endpoint'),
        headers: await _getHeaders(),
      );
      
      return json.decode(response.body);
    } catch (e) {
      return {
        'success': false,
        'error': {
          'message': e.toString()
        }
      };
    }
  }

  Future<Map<String, String>> _getHeaders() async {
    // Add your auth token logic here
    return {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      // 'Authorization': 'Bearer ${await _getToken()}'
    };
  }
}