import 'package:dio/dio.dart';
import '../../../core/models/tradie_model.dart';
import '../models/edit_profile.dart';

class EditProfileRepository {
  final Dio _dio;
  EditProfileRepository(this._dio);

  Future<TradieModel> updateProfile(EditProfile request) async {
    final response = await _dio.put('/tradie/profile', data: request.toJson());
    return TradieModel.fromJson(response.data['data']);
  }

  Future<TradieModel> getProfile() async {
    final response = await _dio.get('/tradie/profile');
    return TradieModel.fromJson(response.data['data']);
  }
}
