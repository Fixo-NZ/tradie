import 'package:json_annotation/json_annotation.dart';

part 'profile_model.g.dart';

@JsonSerializable(createToJson: true, createFactory: false)
class ProfileModel {
  final int? id;
  final String? firstName;
  final String? middleName;
  final String? lastName;
  final String? email;
  final String? phone;
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

  const ProfileModel({
    this.id,
    this.firstName,
    this.middleName,
    this.lastName,
    this.email,
    this.phone,
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

  /// ✅ SAFE FACTORY
  factory ProfileModel.fromJson(Map<String, dynamic> json) {
    double? _toDouble(dynamic v) {
      if (v == null) return null;
      if (v is num) return v.toDouble();
      if (v is String) return double.tryParse(v);
      return null;
    }

    int? _toInt(dynamic v) {
      if (v == null) return null;
      if (v is num) return v.toInt();
      if (v is String) return int.tryParse(v);
      return null;
    }

    return ProfileModel(
      id: _toInt(json['id']),
      firstName: json['first_name'] as String?,
      middleName: json['middle_name'] as String?,
      lastName: json['last_name'] as String?,
      email: json['email'] as String?,
      phone: json['phone'] as String?,
      bio: json['bio'] as String?,
      address: json['address'] as String?,
      city: json['city'] as String?,
      region: json['region'] as String?,
      postalCode: json['postal_code'] as String?,
      latitude: _toDouble(json['latitude']),
      longitude: _toDouble(json['longitude']),
      businessName: json['business_name'] as String?,
      licenseNumber: json['license_number'] as String?,
      insuranceDetails: json['insurance_details'] as String?,
      yearsExperience: _toInt(json['years_experience']),
      hourlyRate: _toDouble(json['hourly_rate']),
      availabilityStatus: json['availability_status'] as String?,
      serviceRadius: _toInt(json['service_radius']),
    );
  }

  Map<String, dynamic> toJson() => _$ProfileModelToJson(this);
}
