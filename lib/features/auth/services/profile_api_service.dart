import 'dart:io';
import 'package:dio/dio.dart';
import 'package:http_parser/http_parser.dart';
import '../../../core/constants/api_constants.dart';
import 'api_service.dart';
import 'dart:convert';

class ProfileApiService extends ApiService {
  // Submit Basic Info (now supports avatar upload too)
  Future<Map<String, dynamic>> submitBasicInfo({
    required String firstName,
    required String lastName,
    required String email,
    required String phone,
    required String businessName,
    String? professionalBio,
    File? avatarImage, 
  }) async {
    try {
      final dio = Dio();
      final usedToken = ApiService.token;

      final formData = FormData.fromMap({
        "first_name": firstName,
        "last_name": lastName,
        "email": email,
        "phone": phone,
        "business_name": businessName,
        if (professionalBio != null && professionalBio.isNotEmpty)
          "professional_bio": professionalBio,
        if (avatarImage != null)
          "avatar": await MultipartFile.fromFile(
            avatarImage.path,
            filename: avatarImage.path.split(Platform.pathSeparator).last,
            contentType: MediaType.parse("image/jpeg"),
          ),
      });

      // Allow Dio to return non-2xx responses instead of throwing so we can
      // inspect server error bodies (useful for debugging 500s).
      final response = await dio.post(
        '${ApiService.baseUrl}/profile-setup/basic-info',
        data: formData,
        options: Options(
          headers: {
            'Authorization': 'Bearer $usedToken',
            'Accept': 'application/json',
          },
          contentType: 'multipart/form-data',
          validateStatus: (status) => true,
        ),
      );

      // Log server response for debugging (especially for 500 errors)
      try {
        print('Basic info response status: ${response.statusCode}');
        print('Basic info response body: ${response.data}');
      } catch (_) {}

      return {
        'success': response.statusCode == 200 &&
            (response.data is Map && (response.data['success'] == true || response.data['success'] == 1)),
        'statusCode': response.statusCode,
        'body': response.data,
      };
    } catch (e) {
      print("Error submitting basic info: $e");
      return {
        'success': false,
        'statusCode': 0,
        'body': {'message': e.toString()},
      };
    }
  }

  // Upload Avatar (uses correct Laravel route)
  Future<Response> uploadAvatar(File image, {String? token}) async {
    final dio = Dio();

    final filename = image.path.split(Platform.pathSeparator).last;
    final isJpg = filename.toLowerCase().endsWith('.jpg') ||
        filename.toLowerCase().endsWith('.jpeg');
    final isPng = filename.toLowerCase().endsWith('.png');
    final contentType =
        isPng ? 'image/png' : (isJpg ? 'image/jpeg' : 'image/jpeg');

    final formData = FormData.fromMap({
      'avatar': await MultipartFile.fromFile(
        image.path,
        filename: filename,
        contentType: MediaType.parse(contentType),
      ),
    });

    final usedToken =
        (token != null && token.isNotEmpty) ? token : ApiService.token;

    final options = Options(
      headers: {
        if (usedToken.isNotEmpty) 'Authorization': 'Bearer $usedToken',
        'Accept': 'application/json',
      },
      contentType: 'multipart/form-data',
    );

    // Backend defines upload-avatar at the top-level tradie prefix (not under profile-setup)
    final url = '${ApiService.baseUrl}${ApiConstants.uploadAvatarEndpoint}';
    print('Uploading avatar to URL: $url');

    final response = await dio.post(url, data: formData, options: options);
    print("Upload response: ${response.data}");
    return response;
  }

  // Get Profile Info (fetch latest user profile after upload)
  Future<Map<String, dynamic>> getProfile({String? token}) async {
    try {
      final dio = Dio();
      final usedToken =
          (token != null && token.isNotEmpty) ? token : ApiService.token;

      final options = Options(
        headers: {
          if (usedToken.isNotEmpty) 'Authorization': 'Bearer $usedToken',
          'Accept': 'application/json',
        },
      );

      // Adjust this URL if your Laravel route is different
      final url = '${ApiService.baseUrl}/profile-setup/get-profile';
      print('Fetching profile from URL: $url');

      final response = await dio.get(url, options: options);

      if (response.statusCode == 200) {
        print('Profile fetched: ${response.data}');
        return {
          'success': true,
          'data': response.data,
        };
      } else {
        print('Failed to fetch profile: ${response.statusCode}');
        return {
          'success': false,
          'data': null,
        };
      }
    } catch (e) {
      print('Error fetching profile: $e');
      return {
        'success': false,
        'data': null,
      };
    }
  }
}
