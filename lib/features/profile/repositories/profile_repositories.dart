import 'package:dio/dio.dart';
import '../../../core/network/dio_client.dart';
import '../models/profile_model.dart';

class ProfileRepository {
  final Dio _dio = DioClient.instance.dio;

  Future<ProfileModel> fetchProfile() async {
    final res = await _dio.get('/tradie/me');
    
    // Laravel returns { success: true, data: { user: {...} } }
    final responseData = res.data;
    if (responseData is Map<String, dynamic> && responseData['data'] != null) {
      final data = responseData['data'] as Map<String, dynamic>;
      if (data['user'] != null && data['user'] is Map<String, dynamic>) {
        return ProfileModel.fromJson(data['user'] as Map<String, dynamic>);
      }
      return ProfileModel.fromJson(data);
    }
    return ProfileModel.fromJson(responseData as Map<String, dynamic>);
  }

  Future<ProfileModel> updateProfile(Map<String, dynamic> data) async {
    // Ensure keys are in snake_case as Laravel expects
    final requestData = <String, dynamic>{};
    data.forEach((key, value) {
      // Convert camelCase to snake_case if needed
      final snakeKey = key.replaceAllMapped(
        RegExp(r'([A-Z])'),
        (match) => '_${match.group(1)!.toLowerCase()}',
      );
      requestData[snakeKey] = value;
    });
    
    final res = await _dio.put('/tradie/profile', data: requestData);
    
    // Laravel returns { success: true, message: "...", data: {...} }
    final responseData = res.data;
    if (responseData is Map<String, dynamic> && responseData['data'] != null) {
      return ProfileModel.fromJson(responseData['data'] as Map<String, dynamic>);
    }
    return ProfileModel.fromJson(responseData as Map<String, dynamic>);
  }
}
