import 'package:json_annotation/json_annotation.dart';

part 'schedule_model.g.dart';

@JsonSerializable()
class ScheduleModel {
  final int id;
  final String title;
  final String description;
  @JsonKey(name: 'start_time')
  final String startTime;
  @JsonKey(name: 'end_time')
  final String endTime;
  final String color;
  final String status;
  @JsonKey(name: 'rescheduled_at')
  final String? rescheduledAt;

  ScheduleModel({
    required this.id,
    required this.title,
    required this.description,
    required this.startTime,
    required this.endTime,
    required this.color,
    required this.status,
    this.rescheduledAt
  });

  factory ScheduleModel.fromJson(Map<String, dynamic> json) =>
      _$ScheduleModelFromJson(json);

  Map<String, dynamic> toJson() => _$ScheduleModelToJson(this);

  DateTime get startDate => DateTime.parse(startTime);
  DateTime get endDate => DateTime.parse(endTime);
}
