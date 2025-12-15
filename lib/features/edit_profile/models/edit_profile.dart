import 'package:json_annotation/json_annotation.dart';

part 'edit_profile.g.dart';

@JsonSerializable(fieldRename: FieldRename.snake)
class EditProfile {
  final String? firstName;
  final String? middleName;
  final String? lastName;
  final String? phone;
  final String? avatar;
  final String? bio;
  final String? address;
  final String? city;
  final String? region;
  final String? postalCode;
  final double? latitude;
  final double? longitude;
  final String? businessName;
  final String? licenseNumber;
  final String? insuranceDetails;
  final int? yearsExperience;
  final double? hourlyRate;
  final String? availabilityStatus;
  final int? serviceRadius;

  const EditProfile({
    this.firstName,
    this.middleName,
    this.lastName,
    this.phone,
    this.avatar,
    this.bio,
    this.address,
    this.city,
    this.region,
    this.postalCode,
    this.latitude,
    this.longitude,
    this.businessName,
    this.licenseNumber,
    this.insuranceDetails,
    this.yearsExperience,
    this.hourlyRate,
    this.availabilityStatus,
    this.serviceRadius,
  });

  /// ----------------------
  /// SAFE JSON PARSING
  /// ----------------------
  factory EditProfile.fromJson(Map<String, dynamic> json) {
    int? parseInt(dynamic value) {
      if (value == null) return null;
      if (value is int) return value;
      if (value is String && value.isNotEmpty) return int.tryParse(value);
      return null;
    }

    double? parseDouble(dynamic value) {
      if (value == null) return null;
      if (value is double) return value;
      if (value is int) return value.toDouble();
      if (value is String && value.isNotEmpty) return double.tryParse(value);
      return null;
    }

    String? parseString(dynamic value) {
      if (value == null) return null;
      if (value is String && value.isNotEmpty) return value;
      return value?.toString();
    }

    return EditProfile(
      firstName: parseString(json['first_name']),
      middleName: parseString(json['middle_name']),
      lastName: parseString(json['last_name']),
      phone: parseString(json['phone']),
      avatar: parseString(json['avatar']),
      bio: parseString(json['bio']),
      address: parseString(json['address']),
      city: parseString(json['city']),
      region: parseString(json['region']),
      postalCode: parseString(json['postal_code']),
      latitude: parseDouble(json['latitude']),
      longitude: parseDouble(json['longitude']),
      businessName: parseString(json['business_name']),
      licenseNumber: parseString(json['license_number']),
      insuranceDetails: parseString(json['insurance_details']),
      yearsExperience: parseInt(json['years_experience']),
      hourlyRate: parseDouble(json['hourly_rate']),
      availabilityStatus: parseString(json['availability_status']),
      serviceRadius: parseInt(json['service_radius']),
    );
  }

  /// ----------------------
  /// TO JSON
  /// ----------------------
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};

    void add(String key, dynamic value) {
      if (value != null) data[key] = value;
    }

    add('first_name', firstName);
    add('middle_name', middleName);
    add('last_name', lastName);
    add('phone', phone);
    add('avatar', avatar);
    add('bio', bio);
    add('address', address);
    add('city', city);
    add('region', region);
    add('postal_code', postalCode);
    add('latitude', latitude);
    add('longitude', longitude);
    add('business_name', businessName);
    add('license_number', licenseNumber);
    add('insurance_details', insuranceDetails);
    add('years_experience', yearsExperience);
    add('hourly_rate', hourlyRate);
    add('availability_status', availabilityStatus);
    add('service_radius', serviceRadius);

    return data;
  }
}
