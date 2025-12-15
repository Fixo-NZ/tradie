// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'edit_profile.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

EditProfile _$EditProfileFromJson(Map<String, dynamic> json) => EditProfile(
  firstName: json['first_name'] as String?,
  middleName: json['middle_name'] as String?,
  lastName: json['last_name'] as String?,
  phone: json['phone'] as String?,
  avatar: json['avatar'] as String?,
  bio: json['bio'] as String?,
  address: json['address'] as String?,
  city: json['city'] as String?,
  region: json['region'] as String?,
  postalCode: json['postal_code'] as String?,
  latitude: (json['latitude'] as num?)?.toDouble(),
  longitude: (json['longitude'] as num?)?.toDouble(),
  businessName: json['business_name'] as String?,
  licenseNumber: json['license_number'] as String?,
  insuranceDetails: json['insurance_details'] as String?,
  yearsExperience: (json['years_experience'] as num?)?.toInt(),
  hourlyRate: (json['hourly_rate'] as num?)?.toDouble(),
  availabilityStatus: json['availability_status'] as String?,
  serviceRadius: (json['service_radius'] as num?)?.toInt(),
);

Map<String, dynamic> _$EditProfileToJson(EditProfile instance) =>
    <String, dynamic>{
      'first_name': instance.firstName,
      'middle_name': instance.middleName,
      'last_name': instance.lastName,
      'phone': instance.phone,
      'avatar': instance.avatar,
      'bio': instance.bio,
      'address': instance.address,
      'city': instance.city,
      'region': instance.region,
      'postal_code': instance.postalCode,
      'latitude': instance.latitude,
      'longitude': instance.longitude,
      'business_name': instance.businessName,
      'license_number': instance.licenseNumber,
      'insurance_details': instance.insuranceDetails,
      'years_experience': instance.yearsExperience,
      'hourly_rate': instance.hourlyRate,
      'availability_status': instance.availabilityStatus,
      'service_radius': instance.serviceRadius,
    };
