import 'package:json_annotation/json_annotation.dart';

part 'schedule_model.g.dart';

@JsonSerializable(explicitToJson: true)
class ScheduleResponse {
  final List<ScheduleModel> schedules;

  ScheduleResponse({
    required this.schedules,
  });

  factory ScheduleResponse.fromJson(Map<String, dynamic> json) =>
      _$ScheduleResponseFromJson(json);

  Map<String, dynamic> toJson() => _$ScheduleResponseToJson(this);
}

@JsonSerializable(explicitToJson: true)
class ScheduleModel {
  final int id;
  @JsonKey(name: 'homeowner_id')
  final int homeownerId;
  @JsonKey(name: 'service_category_id')
  final int serviceCategoryId;
  @JsonKey(name: 'tradie_id')
  final int tradieId;
  @JsonKey(name: 'job_type')
  final String jobType;
  @JsonKey(name: 'preferred_date')
  final String? preferredDate;
  final String? frequency;
  @JsonKey(name: 'start_date')
  final String? startDate;
  @JsonKey(name: 'end_date')
  final String? endDate;
  final String title;
  @JsonKey(name: 'job_size')
  final String jobSize;
  final String description;
  final String address;
  final double latitude;
  final double longitude;
  final String status;
  @JsonKey(name: 'created_at')
  final String? createdAt;
  @JsonKey(name: 'updated_at')
  final String? updatedAt;
  @JsonKey(name: 'start_time')
  final String startTime;
  @JsonKey(name: 'end_time')
  final String endTime;
  @JsonKey(name: 'rescheduled_at')
  final String? rescheduledAt;
  @JsonKey(name: 'photo_urls')
  final List<String>? photoUrls;
  final Homeowner homeowner;
  final Category category;
  final List<Photo>? photos;

  ScheduleModel({
    required this.id,
    required this.homeownerId,
    required this.serviceCategoryId,
    required this.tradieId,
    required this.jobType,
    this.preferredDate,
    this.frequency,
    this.startDate,
    this.endDate,
    required this.title,
    required this.jobSize,
    required this.description,
    required this.address,
    required this.latitude,
    required this.longitude,
    required this.status,
    this.createdAt,
    this.updatedAt,
    required this.startTime,
    required this.endTime,
    this.rescheduledAt,
    this.photoUrls,
    required this.homeowner,
    required this.category,
    this.photos,
  });

  factory ScheduleModel.fromJson(Map<String, dynamic> json) =>
      _$ScheduleModelFromJson(json);

  Map<String, dynamic> toJson() => _$ScheduleModelToJson(this);

  DateTime get startDateTime => DateTime.parse(startTime);
  DateTime get endDateTime => DateTime.parse(endTime);
  DateTime? get preferredDateTime => preferredDate != null ? DateTime.parse(preferredDate!) : null;
  DateTime? get startDateOnly => startDate != null ? DateTime.parse(startDate!) : null;
  DateTime? get endDateOnly => endDate != null ? DateTime.parse(endDate!) : null;
}

@JsonSerializable()
class Homeowner {
  final int id;
  @JsonKey(name: 'first_name')
  final String firstName;
  @JsonKey(name: 'last_name')
  final String lastName;
  @JsonKey(name: 'middle_name')
  final String? middleName;
  final String email;
  final String address;
  final String phone;

  Homeowner({
    required this.id,
    required this.firstName,
    required this.lastName,
    this.middleName,
    required this.email,
    required this.address,
    required this.phone,
  });

  factory Homeowner.fromJson(Map<String, dynamic> json) =>
      _$HomeownerFromJson(json);

  Map<String, dynamic> toJson() => _$HomeownerToJson(this);

  String get fullName {
    final middle = middleName != null ? ' $middleName ' : ' ';
    return '$firstName$middle$lastName';
  }
}

@JsonSerializable()
class Category {
  final int id;
  final String name;
  final String description;
  final String icon;
  final String status;

  Category({
    required this.id,
    required this.name,
    required this.description,
    required this.icon,
    required this.status,
  });

  factory Category.fromJson(Map<String, dynamic> json) =>
      _$CategoryFromJson(json);

  Map<String, dynamic> toJson() => _$CategoryToJson(this);
}

@JsonSerializable()
class Photo {
  final int id;
  @JsonKey(name: 'job_offer_id')
  final int jobOfferId;
  @JsonKey(name: 'file_path')
  final String filePath;
  @JsonKey(name: 'original_name')
  final String originalName;
  @JsonKey(name: 'file_size')
  final int fileSize;
  @JsonKey(name: 'created_at')
  final String? createdAt;
  @JsonKey(name: 'updated_at')
  final String? updatedAt;
  final String url;

  Photo({
    required this.id,
    required this.jobOfferId,
    required this.filePath,
    required this.originalName,
    required this.fileSize,
    this.createdAt,
    this.updatedAt,
    required this.url,
  });

  factory Photo.fromJson(Map<String, dynamic> json) =>
      _$PhotoFromJson(json);

  Map<String, dynamic> toJson() => _$PhotoToJson(this);
}
