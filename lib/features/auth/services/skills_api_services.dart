import 'dart:convert';
import 'package:http/http.dart' as http;

class SkillsApiService {
  static const String baseUrl = "http://192.168.4.175:8000/api/tradie";
  static const String token = "5|XMGbQkyg7DtrB35QWxe6r9UrJXV197ZTR64CJGjH91266e95";

  Future<bool> updateSkillsAndService({
    required List<int> skillIds,
    required int serviceRadius,
    required Map<String, dynamic> serviceLocation,
  }) async {
    final url = Uri.parse("$baseUrl/profile-setup/skills");
    final headers = {
      'Accept': 'application/json',
      'Authorization': 'Bearer $token',
      'Content-Type': 'application/json',
    };

    final body = jsonEncode({
      "skills": skillIds,
      "service_radius": serviceRadius,
      "service_location": serviceLocation,
    });

    try {
      final response = await http.post(url, headers: headers, body: body);
      print("🔹 Response Code: ${response.statusCode}");
      print("🔹 Response Body: ${response.body}");

      if (response.statusCode == 200) {
        return true;
      } else {
        return false;
      }
    } catch (e) {
      print("⚠️ Error updating skills and service area: $e");
      return false;
    }
  }
}
