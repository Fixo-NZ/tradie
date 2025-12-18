import 'package:tradie/features/auth/services/api_service.dart';
import '../../../core/constants/api_constants.dart';

class DoneApiService {
  final ApiService _apiService = ApiService();

  // Fetch profile data (handles nested Laravel response)
  Future<Map<String, dynamic>> fetchProfile() async {
    try {
      // Backend route: /api/tradie/profile-setup/get-profile
      final response = await _apiService.get(ApiConstants.getProfileEndpoint);

      if (response['success'] == true && response['data'] != null) {
        // Laravel sometimes returns { "success": true, "data": { "data": {...}} }
        final data = response['data'] is Map && response['data'].containsKey('data')
            ? response['data']['data']
            : response['data'];

        return Map<String, dynamic>.from(data);
      } else {
        throw Exception(response['error']?['message'] ?? 'Invalid profile data');
      }
    } catch (e) {
      print("Error fetching profile: $e");
      rethrow;
    }
  }

  // Fetch skills data
  Future<List<dynamic>> fetchSkills() async {
    try {
      // Backend route: /api/tradie/profile-setup/get-skills
      final response = await _apiService.get(ApiConstants.getSkillsEndpoint);

      if (response['success'] == true &&
          response['data'] != null &&
          response['data']['skills'] != null) {
        return List<dynamic>.from(response['data']['skills']);
      } else {
        return [];
      }
    } catch (e) {
      print("Error fetching skills: $e");
      rethrow;
    }
  }
}
