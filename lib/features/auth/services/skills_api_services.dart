import 'dart:convert';
import 'api_service.dart'; // ✅ already contains baseUrl and token logic

class SkillsApiService extends ApiService {
  Future<Map<String, dynamic>> updateSkillsAndService({
    required List<int> skills,
    required int serviceRadius,
    required Map<String, dynamic> serviceLocation,
  }) async {
    final body = {
      "skills": skills,
      "service_radius": serviceRadius,
      "service_location": serviceLocation,
    };

    try {
      final response = await post('/profile-setup/skills', body);
      final data = jsonDecode(response.body);

      return {
        'success': response.statusCode == 200 &&
            (data['success'] == true || data['success'] == 1),
        'statusCode': response.statusCode,
        'body': data,
      };
    } catch (e) {
      print("⚠️ Error updating skills and service: $e");
      return {
        'success': false,
        'statusCode': 0,
        'body': {'message': e.toString()},
      };
    }
  }
}
