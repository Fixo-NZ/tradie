// lib/services/profile_api_service.dart
import 'dart:io';
import 'package:http/http.dart' as http;

class ProfileApiService {
  static const String baseUrl = "http://192.168.4.175:8000/api/tradie";
  static const String token = "5|XMGbQkyg7DtrB35QWxe6r9UrJXV197ZTR64CJGjH91266e95";

  Future<bool> submitBasicInfo({
    required String firstName,
    required String lastName,
    required String email,
    required String phone,
    required String businessName,
    String? professionalBio,
    File? avatarImage,
  }) async {
    final uri = Uri.parse("$baseUrl/profile-setup/basic-info");
    final request = http.MultipartRequest("POST", uri);

    request.headers["Authorization"] = "Bearer $token";
    request.headers["Accept"] = "application/json";

    request.fields["first_name"] = firstName;
    request.fields["last_name"] = lastName;
    request.fields["email"] = email;
    request.fields["phone"] = phone;
    request.fields["business_name"] = businessName;
    if (professionalBio != null && professionalBio.isNotEmpty) {
      request.fields["professional_bio"] = professionalBio;
    }

    if (avatarImage != null) {
      request.files.add(await http.MultipartFile.fromPath('avatar', avatarImage.path));
    }

    try {
      final response = await request.send();
      final responseBody = await response.stream.bytesToString();
      print("🔹 Laravel response: $responseBody");

      if (response.statusCode == 200) {
        print("✅ Profile setup success");
        return true;
      } else {
        print("❌ Failed: ${response.statusCode}");
        return false;
      }
    } catch (e) {
      print("⚠️ Error submitting basic info: $e");
      return false;
    }
  }
}
