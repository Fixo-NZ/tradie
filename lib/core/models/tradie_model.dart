// lib/core/models/tradie_model.dart
import 'package:json_annotation/json_annotation.dart';

part 'tradie_model.g.dart';

@JsonSerializable()
class TradieModel {
  final int? id;
  @JsonKey(name: 'first_name')
  final String firstName;
  @JsonKey(name: 'last_name')
  final String lastName;
  @JsonKey(name: 'middle_name')
  final String? middleName;
  final String email;
  final String? phone;
  final String? address;
  final String? city;
  final String? region;
  @JsonKey(name: 'postal_code')
  final String? postalCode;
  @JsonKey(name: 'business_name')
  final String? businessName;
  @JsonKey(name: 'license_number')
  final String? licenseNumber;
  @JsonKey(name: 'years_experience')
  final int? yearsExperience;
  @JsonKey(name: 'hourly_rate')
  final double? hourlyRate;
  @JsonKey(name: 'availability_status')
  final String? availabilityStatus;
  @JsonKey(name: 'service_radius')
  final int? serviceRadius;
  @JsonKey(name: 'is_verified')
  final bool? isVerified;
  final String? status;
  @JsonKey(name: 'user_type')
  final String? userType;

  const TradieModel({
    this.id,
    required this.firstName,
    required this.lastName,
    this.middleName,
    required this.email,
    this.phone,
    this.address,
    this.city,
    this.region,
    this.postalCode,
    this.businessName,
    this.licenseNumber,
    this.yearsExperience,
    this.hourlyRate,
    this.availabilityStatus,
    this.serviceRadius,
    this.isVerified,
    this.status,
    this.userType,
  });

  factory TradieModel.fromJson(Map<String, dynamic> json) =>
      _$TradieModelFromJson(json);

  Map<String, dynamic> toJson() => _$TradieModelToJson(this);

  String get fullName => '$firstName ${middleName ?? ''} $lastName'.trim();
}