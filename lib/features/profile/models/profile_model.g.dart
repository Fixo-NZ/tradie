// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'profile_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ProfileModel _$ProfileModelFromJson(Map<String, dynamic> json) => ProfileModel(
  id: (json['id'] as num?)?.toInt(),
  firstName: json['first_name'] as String,
  middleName: json['middle_name'] as String?,
  lastName: json['last_name'] as String,
  email: json['email'] as String,
  phone: json['phone'] as String?,
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
  availabilityStatus: json['availability_status'] as String? ?? 'available',
  serviceRadius: (json['service_radius'] as num?)?.toInt() ?? 50,
);

Map<String, dynamic> _$ProfileModelToJson(ProfileModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'first_name': instance.firstName,
      'middle_name': instance.middleName,
      'last_name': instance.lastName,
      'email': instance.email,
      'phone': instance.phone,
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
