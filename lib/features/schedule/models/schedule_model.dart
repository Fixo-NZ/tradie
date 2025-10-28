import 'package:json_annotation/json_annotation.dart';

part 'schedule_model.g.dart';

@JsonSerializable(explicitToJson: true)
class ScheduleModel {
  final int id;
  @JsonKey(name: 'homeowner_id')
  final int homeownerId;
  final String title;
  final String description;
  @JsonKey(name: 'job_title')
  final String jobTitle;
  final String duration;
  final String date;
  @JsonKey(name: 'start_time')
  final String startTime;
  @JsonKey(name: 'end_time')
  final String endTime;
  final String color;
  final String status;
  @JsonKey(name: 'rescheduled_at')
  final String? rescheduledAt;
  @JsonKey(name: 'created_at')
  final String? createdAt;
  @JsonKey(name: 'updated_at')
  final String? updatedAt;
  final Homeowner homeowner;

  ScheduleModel({
    required this.id,
    required this.homeownerId,
    required this.title,
    required this.description,
    required this.jobTitle,
    required this.duration,
    required this.date,
    required this.startTime,
    required this.endTime,
    required this.color,
    required this.status,
    this.rescheduledAt,
    this.createdAt,
    this.updatedAt,
    required this.homeowner,
  });

  factory ScheduleModel.fromJson(Map<String, dynamic> json) =>
      _$ScheduleModelFromJson(json);

  Map<String, dynamic> toJson() => _$ScheduleModelToJson(this);

  DateTime get startDate => DateTime.parse(startTime);
  DateTime get endDate => DateTime.parse(endTime);
}

@JsonSerializable()
class Homeowner {
  final int id;
  @JsonKey(name: 'first_name')
  final String firstName;
  @JsonKey(name: 'last_name')
  final String lastName;
  @JsonKey(name: 'middle_name')
  final String middleName;
  final String email;
  final String address;
  final String phone;

  Homeowner({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.middleName,
    required this.email,
    required this.address,
    required this.phone,
  });

  factory Homeowner.fromJson(Map<String, dynamic> json) =>
      _$HomeownerFromJson(json);

  Map<String, dynamic> toJson() => _$HomeownerToJson(this);
}
