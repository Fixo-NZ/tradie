// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'edit_profile.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

EditProfile _$EditProfileFromJson(Map<String, dynamic> json) => EditProfile(
  firstName: json['firstName'] as String?,
  middleName: json['middleName'] as String?,
  lastName: json['lastName'] as String?,
  phone: json['phone'] as String?,
  avatar: json['avatar'] as String?,
  bio: json['bio'] as String?,
  address: json['address'] as String?,
  city: json['city'] as String?,
  region: json['region'] as String?,
  postalCode: json['postalCode'] as String?,
  latitude: (json['latitude'] as num?)?.toDouble(),
  longitude: (json['longitude'] as num?)?.toDouble(),
  businessName: json['businessName'] as String?,
  licenseNumber: json['licenseNumber'] as String?,
  insuranceDetails: json['insuranceDetails'] as String?,
  yearsExperience: (json['yearsExperience'] as num?)?.toInt(),
  hourlyRate: (json['hourlyRate'] as num?)?.toDouble(),
  availabilityStatus: json['availabilityStatus'] as String?,
  serviceRadius: (json['serviceRadius'] as num?)?.toInt(),
);

Map<String, dynamic> _$EditProfileToJson(EditProfile instance) =>
    <String, dynamic>{
      'firstName': instance.firstName,
      'middleName': instance.middleName,
      'lastName': instance.lastName,
      'phone': instance.phone,
      'avatar': instance.avatar,
      'bio': instance.bio,
      'address': instance.address,
      'city': instance.city,
      'region': instance.region,
      'postalCode': instance.postalCode,
      'latitude': instance.latitude,
      'longitude': instance.longitude,
      'businessName': instance.businessName,
      'licenseNumber': instance.licenseNumber,
      'insuranceDetails': instance.insuranceDetails,
      'yearsExperience': instance.yearsExperience,
      'hourlyRate': instance.hourlyRate,
      'availabilityStatus': instance.availabilityStatus,
      'serviceRadius': instance.serviceRadius,
    };
