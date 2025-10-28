// lib/services/api_service.dart
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

class ApiService {
  // ✅ Correct base URL (make sure this matches your local IP)
  static const String baseUrl = "http://192.168.4.175:8000/api/tradie";

  // ✅ Hardcoded token (replace with your working one)
  static const String token = "5|XMGbQkyg7DtrB35QWxe6r9UrJXV197ZTR64CJGjH91266e95";

  /// Upload basic profile information
  Future<bool> uploadBasicInfo({
    required String firstName,
    required String lastName,
    required String email,
    required String phoneNumber,
    required String businessName,
    String? bio,
    File? avatarImage,
  }) async {
    final uri = Uri.parse("$baseUrl/profile-setup/basic-info"); // ✅ Matches backend route
    final request = http.MultipartRequest("POST", uri);

    // ✅ Headers
    request.headers["Authorization"] = "Bearer $token";
    request.headers["Accept"] = "application/json";

    // ✅ Fields
    request.fields["first_name"] = firstName;
    request.fields["last_name"] = lastName;
    request.fields["email"] = email;
    request.fields["phone"] = phoneNumber;
    request.fields["business_name"] = businessName;
    if (bio != null) request.fields["professional_bio"] = bio;

    // ✅ Optional image
    if (avatarImage != null) {
      request.files.add(await http.MultipartFile.fromPath(
        'avatar',
        avatarImage.path,
      ));
    }

    final response = await request.send();
    final responseBody = await response.stream.bytesToString();
    print("Response: $responseBody");

    if (response.statusCode == 200) {
      print("✅ Profile info uploaded successfully!");
      return true;
    } else {
      print("❌ Failed to upload basic info. Status: ${response.statusCode}");
      return false;
    }
  }
}
