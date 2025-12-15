import 'package:dio/dio.dart';
import '../../../core/models/tradie_model.dart';
import '../models/edit_profile.dart';

class EditProfileRepository {
  final Dio _dio;

  EditProfileRepository(this._dio);

  /// ----------------------
  /// GET PROFILE
  /// ----------------------
  Future<EditProfile> getProfile() async {
    final response = await _dio.get('/tradie/me');
    final responseData = response.data;

    // Safely extract user data
    final userData = responseData['data']?['user'] ?? responseData['data'] ?? responseData;

    return EditProfile.fromJson(userData);
  }

  /// ----------------------
  /// UPDATE PROFILE
  /// ----------------------
  Future<EditProfile> updateProfile(EditProfile request) async {
    final data = <String, dynamic>{};

    // Add only non-null fields
    void addIfNotNull(String key, dynamic value) {
      if (value != null) data[key] = value;
    }

    addIfNotNull('first_name', request.firstName);
    addIfNotNull('middle_name', request.middleName);
    addIfNotNull('last_name', request.lastName);
    addIfNotNull('phone', request.phone);
    addIfNotNull('avatar', request.avatar);
    addIfNotNull('bio', request.bio);
    addIfNotNull('address', request.address);
    addIfNotNull('city', request.city);
    addIfNotNull('region', request.region);
    addIfNotNull('postal_code', request.postalCode);
    addIfNotNull('latitude', request.latitude);
    addIfNotNull('longitude', request.longitude);
    addIfNotNull('business_name', request.businessName);
    addIfNotNull('license_number', request.licenseNumber);
    addIfNotNull('insurance_details', request.insuranceDetails);
    addIfNotNull('years_experience', request.yearsExperience);
    addIfNotNull('hourly_rate', request.hourlyRate);
    addIfNotNull('availability_status', request.availabilityStatus);
    addIfNotNull('service_radius', request.serviceRadius);

    final response = await _dio.put('/tradie/profile', data: data);
    final responseData = response.data;

    // UPDATE RESPONSE: data contains the profile directly
    final userData = responseData['data'] ?? responseData;

    return EditProfile.fromJson(userData);
  }
}
