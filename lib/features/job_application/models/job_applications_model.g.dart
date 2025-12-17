// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'job_applications_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

JobFeedItem _$JobFeedItemFromJson(Map<String, dynamic> json) => JobFeedItem(
  id: (json['id'] as num).toInt(),
  title: json['title'] as String,
  description: json['description'] as String,
  address: json['address'] as String,
  jobType: json['job_type'] as String,
  jobSize: json['job_size'] as String,
  preferredDate: json['preferred_date'] as String?,
  status: json['status'] as String,
  photoUrls: (json['photo_urls'] as List<dynamic>)
      .map((e) => e as String)
      .toList(),
  category: json['category'] as Map<String, dynamic>?,
  homeowner: json['homeowner'] as Map<String, dynamic>?,
  createdAt: json['created_at'] as String,
);

Map<String, dynamic> _$JobFeedItemToJson(JobFeedItem instance) =>
    <String, dynamic>{
      'id': instance.id,
      'title': instance.title,
      'description': instance.description,
      'address': instance.address,
      'job_type': instance.jobType,
      'job_size': instance.jobSize,
      'preferred_date': instance.preferredDate,
      'status': instance.status,
      'photo_urls': instance.photoUrls,
      'category': instance.category,
      'homeowner': instance.homeowner,
      'created_at': instance.createdAt,
    };

JobApplication _$JobApplicationFromJson(Map<String, dynamic> json) =>
    JobApplication(
      id: (json['id'] as num).toInt(),
      jobOfferId: (json['job_offer_id'] as num).toInt(),
      message: json['message'] as String?,
      status: json['status'] as String,
      appliedAt: json['applied_at'] as String,
      acceptedAt: json['accepted_at'] as String?,
      rejectedAt: json['rejected_at'] as String?,
      completedAt: json['completed_at'] as String?,
      jobOffer: json['job_offer'] as Map<String, dynamic>?,
      homeowner: json['homeowner'] as Map<String, dynamic>?,
    );

Map<String, dynamic> _$JobApplicationToJson(JobApplication instance) =>
    <String, dynamic>{
      'id': instance.id,
      'job_offer_id': instance.jobOfferId,
      'message': instance.message,
      'status': instance.status,
      'applied_at': instance.appliedAt,
      'accepted_at': instance.acceptedAt,
      'rejected_at': instance.rejectedAt,
      'completed_at': instance.completedAt,
      'job_offer': instance.jobOffer,
      'homeowner': instance.homeowner,
    };

ApplyJobRequest _$ApplyJobRequestFromJson(Map<String, dynamic> json) =>
    ApplyJobRequest(message: json['message'] as String?);

Map<String, dynamic> _$ApplyJobRequestToJson(ApplyJobRequest instance) =>
    <String, dynamic>{'message': instance.message};

JobApplicationResponse _$JobApplicationResponseFromJson(
  Map<String, dynamic> json,
) => JobApplicationResponse(
  success: json['success'] as bool,
  message: json['message'] as String,
  data: json['data'],
);

Map<String, dynamic> _$JobApplicationResponseToJson(
  JobApplicationResponse instance,
) => <String, dynamic>{
  'success': instance.success,
  'message': instance.message,
  'data': instance.data,
};
