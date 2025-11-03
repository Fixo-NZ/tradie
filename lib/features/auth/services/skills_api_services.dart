import 'dart:convert';
import 'api_service.dart'; 


class SkillsApiService extends ApiService {

  
  Future<Map<String, dynamic>> updateSkillsAndService({
    required List<int> skills,                
    required int serviceRadius,              
    required Map<String, dynamic> serviceLocation,
  }) async {

    // Prepare the data that will be sent to the backend.
    final body = {
      "skills": skills,
      "service_radius": serviceRadius,
      "service_location": serviceLocation,
    };

    try {
      // Call the POST method from ApiService (base class)
      final response = await post('/profile-setup/skills', body);

      // Decode the backend response from JSON to a Dart Map
      final data = jsonDecode(response.body);

      // Return the formatted response
      return {
        'success': response.statusCode == 200 &&
            (data['success'] == true || data['success'] == 1), 
        'statusCode': response.statusCode, 
        'body': data,                      // Actual data from backend
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
