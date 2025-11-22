// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'tradie_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

TradieModel _$TradieModelFromJson(Map<String, dynamic> json) => TradieModel(
  id: (json['id'] as num?)?.toInt(),
  firstName: json['first_name'] as String,
  lastName: json['last_name'] as String,
  middleName: json['middle_name'] as String?,
  email: json['email'] as String,
  phone: json['phone'] as String?,
  address: json['address'] as String?,
  city: json['city'] as String?,
  region: json['region'] as String?,
  postalCode: json['postal_code'] as String?,
  businessName: json['business_name'] as String?,
  licenseNumber: json['license_number'] as String?,
  yearsExperience: (json['years_experience'] as num?)?.toInt(),
  hourlyRate: _doubleFromString(json['hourly_rate']),
  availabilityStatus: json['availability_status'] as String?,
  serviceRadius: (json['service_radius'] as num?)?.toInt(),
  isVerified: json['is_verified'] as bool?,
  status: json['status'] as String?,
  userType: json['user_type'] as String?,
);

Map<String, dynamic> _$TradieModelToJson(TradieModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'first_name': instance.firstName,
      'last_name': instance.lastName,
      'middle_name': instance.middleName,
      'email': instance.email,
      'phone': instance.phone,
      'address': instance.address,
      'city': instance.city,
      'region': instance.region,
      'postal_code': instance.postalCode,
      'business_name': instance.businessName,
      'license_number': instance.licenseNumber,
      'years_experience': instance.yearsExperience,
      'hourly_rate': instance.hourlyRate,
      'availability_status': instance.availabilityStatus,
      'service_radius': instance.serviceRadius,
      'is_verified': instance.isVerified,
      'status': instance.status,
      'user_type': instance.userType,
    };
