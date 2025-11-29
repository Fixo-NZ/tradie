import 'package:json_annotation/json_annotation.dart';

part 'edit_profile.g.dart';

@JsonSerializable()
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

  factory EditProfile.fromJson(Map<String, dynamic> json) =>
      _$EditProfileFromJson(json);

  Map<String, dynamic> toJson() => _$EditProfileToJson(this);
}
