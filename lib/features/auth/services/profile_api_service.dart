import 'dart:io';
import 'api_service.dart';
import 'dart:convert';

class ProfileApiService extends ApiService {
  Future<Map<String, dynamic>> submitBasicInfo({
    required String firstName,
    required String lastName,
    required String email,
    required String phone,
    required String businessName,
    String? professionalBio,
    File? avatarImage,
  }) async {
    final fields = {
      "first_name": firstName,
      "last_name": lastName,
      "email": email,
      "phone": phone,
      "business_name": businessName,
      if (professionalBio != null && professionalBio.isNotEmpty)
        "professional_bio": professionalBio,
    };

    try {
      final result = await multipartPost(
        endpoint: '/profile-setup/basic-info',
        fields: fields,
        file: avatarImage, // You can leave this null for now
        fileFieldName: 'avatar',
      );

      final statusCode = result['statusCode'];
      final body = jsonDecode(result['body']);

      return {
        'success': statusCode == 200 && (body['success'] == true || body['success'] == 1),
        'statusCode': statusCode,
        'body': body,
      };
    } catch (e) {
      print("⚠️ Error submitting basic info: $e");
      return {
        'success': false,
        'statusCode': 0,
        'body': {'message': e.toString()}
      };
    }
  }
}