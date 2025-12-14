import 'package:dio/dio.dart';
import '../../../core/models/tradie_model.dart';
import '../models/edit_profile.dart';

class EditProfileRepository {
  final Dio _dio;

  // ✅ ADD THIS CONSTRUCTOR
  EditProfileRepository(this._dio);

  Future<TradieModel> updateProfile(EditProfile request) async {
    final data = <String, dynamic>{};

    if (request.firstName != null) data['first_name'] = request.firstName;
    if (request.middleName != null) data['middle_name'] = request.middleName;
    if (request.lastName != null) data['last_name'] = request.lastName;
    if (request.phone != null) data['phone'] = request.phone;
    if (request.bio != null) data['bio'] = request.bio;
    if (request.address != null) data['address'] = request.address;
    if (request.city != null) data['city'] = request.city;
    if (request.region != null) data['region'] = request.region;
    if (request.postalCode != null) data['postal_code'] = request.postalCode;
    if (request.latitude != null) data['latitude'] = request.latitude;
    if (request.longitude != null) data['longitude'] = request.longitude;
    if (request.businessName != null) data['business_name'] = request.businessName;
    if (request.licenseNumber != null) data['license_number'] = request.licenseNumber;
    if (request.insuranceDetails != null) {
      data['insurance_details'] = request.insuranceDetails;
    }
    if (request.yearsExperience != null) {
      data['years_experience'] = request.yearsExperience;
    }
    if (request.hourlyRate != null) data['hourly_rate'] = request.hourlyRate;
    if (request.availabilityStatus != null) {
      data['availability_status'] = request.availabilityStatus;
    }
    if (request.serviceRadius != null) {
      data['service_radius'] = request.serviceRadius;
    }

    final response = await _dio.put('/tradie/profile', data: data);

    final responseData = response.data;
    return TradieModel.fromJson(
      responseData['data'] ?? responseData,
    );
  }

  Future<TradieModel> getProfile() async {
    final response = await _dio.get('/tradie/me');

    final responseData = response.data;
    final data = responseData['data'];
    return TradieModel.fromJson(data['user'] ?? data);
  }
}
