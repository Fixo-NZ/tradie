// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'schedule_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ScheduleModel _$ScheduleModelFromJson(Map<String, dynamic> json) =>
    ScheduleModel(
      id: (json['id'] as num).toInt(),
      homeownerId: (json['homeowner_id'] as num).toInt(),
      title: json['title'] as String,
      description: json['description'] as String,
      jobTitle: json['job_title'] as String,
      duration: json['duration'] as String,
      date: json['date'] as String,
      startTime: json['start_time'] as String,
      endTime: json['end_time'] as String,
      color: json['color'] as String,
      status: json['status'] as String,
      rescheduledAt: json['rescheduled_at'] as String?,
      createdAt: json['created_at'] as String?,
      updatedAt: json['updated_at'] as String?,
      homeowner: Homeowner.fromJson(json['homeowner'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$ScheduleModelToJson(ScheduleModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'homeowner_id': instance.homeownerId,
      'title': instance.title,
      'description': instance.description,
      'job_title': instance.jobTitle,
      'duration': instance.duration,
      'date': instance.date,
      'start_time': instance.startTime,
      'end_time': instance.endTime,
      'color': instance.color,
      'status': instance.status,
      'rescheduled_at': instance.rescheduledAt,
      'created_at': instance.createdAt,
      'updated_at': instance.updatedAt,
      'homeowner': instance.homeowner.toJson(),
    };

Homeowner _$HomeownerFromJson(Map<String, dynamic> json) => Homeowner(
  id: (json['id'] as num).toInt(),
  firstName: json['first_name'] as String,
  lastName: json['last_name'] as String,
  middleName: json['middle_name'] as String,
  email: json['email'] as String,
  address: json['address'] as String,
  phone: json['phone'] as String,
);

Map<String, dynamic> _$HomeownerToJson(Homeowner instance) => <String, dynamic>{
  'id': instance.id,
  'first_name': instance.firstName,
  'last_name': instance.lastName,
  'middle_name': instance.middleName,
  'email': instance.email,
  'address': instance.address,
  'phone': instance.phone,
};
