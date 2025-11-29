import 'package:dio/dio.dart';
import '../../../core/network/dio_client.dart';
import '../models/profile_model.dart';

class ProfileRepository {
  final Dio _dio = DioClient.instance.dio;

  Future<ProfileModel> fetchProfile() async {
    final res = await _dio.get('/tradie/me');
    // backend returns either data or data['data'] depending on impl — prefer data['data']
    final payload = res.data is Map && res.data['data'] != null ? res.data['data'] : res.data;
    return ProfileModel.fromJson(payload as Map<String, dynamic>);
  }

  Future<ProfileModel> updateProfile(Map<String, dynamic> data) async {
    final res = await _dio.put('/tradie/profile', data: data);
    final payload = res.data is Map && res.data['data'] != null ? res.data['data'] : res.data;
    return ProfileModel.fromJson(payload as Map<String, dynamic>);
  }
}
