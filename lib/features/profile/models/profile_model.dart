import 'package:json_annotation/json_annotation.dart';

part 'profile_model.g.dart';

@JsonSerializable()
class ProfileModel {
  final int? id;
  @JsonKey(name: 'first_name') final String firstName;
  @JsonKey(name: 'middle_name') final String? middleName;
  @JsonKey(name: 'last_name') final String lastName;
  final String email;
  final String? phone;
  final String? bio;
  final String? address;
  final String? city;
  final String? region;
  @JsonKey(name: 'postal_code') final String? postalCode;
  final double? latitude;
  final double? longitude;
  @JsonKey(name: 'business_name') final String? businessName;
  @JsonKey(name: 'license_number') final String? licenseNumber;
  @JsonKey(name: 'insurance_details') final String? insuranceDetails;
  @JsonKey(name: 'years_experience') final int? yearsExperience;
  @JsonKey(name: 'hourly_rate') final double? hourlyRate;
  @JsonKey(name: 'availability_status') final String availabilityStatus;
  @JsonKey(name: 'service_radius') final int serviceRadius;

  const ProfileModel({
    this.id,
    required this.firstName,
    this.middleName,
    required this.lastName,
    required this.email,
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
    this.availabilityStatus = 'available',
    this.serviceRadius = 50,
  });

  factory ProfileModel.fromJson(Map<String, dynamic> json) =>
      _$ProfileModelFromJson(json);

  Map<String, dynamic> toJson() => _$ProfileModelToJson(this);
}
