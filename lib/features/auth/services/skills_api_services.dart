import 'dart:convert';
import 'api_service.dart';

class SkillsApiService extends ApiService {

  Future<Map<String, dynamic>> updateSkillsAndService({
    required List<int> skills,
    required int serviceRadius,
    required Map<String, dynamic> serviceLocation,
  }) async {

    // 🔐 Ensure skills are integers (backend safety)
    final sanitizedSkills = skills.map((e) => e is int ? e : int.parse(e.toString())).toList();

    // 🗺️ Ensure location contains correct lat/lng for OSM
    final sanitizedLocation = {
      "address": serviceLocation["address"],
      "city": serviceLocation["city"],
      "region": serviceLocation["region"],
      "postal_code": serviceLocation["postal_code"],
      "latitude": serviceLocation["latitude"] ?? 0.0,
      "longitude": serviceLocation["longitude"] ?? 0.0,
    };

    // 📦 FINAL REQUEST PAYLOAD
    final body = {
      "skills": sanitizedSkills,
      "service_radius": serviceRadius,
      "service_location": sanitizedLocation,
    };

    try {
      // 🌐 Send POST request to backend
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
