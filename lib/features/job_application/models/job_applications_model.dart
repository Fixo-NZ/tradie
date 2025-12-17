import 'package:json_annotation/json_annotation.dart';

part 'job_applications_model.g.dart';

// Simplified models that don't depend on homeowner package
@JsonSerializable()
class JobFeedItem {
  final int id;
  final String title;
  final String description;
  final String address;
  @JsonKey(name: 'job_type')
  final String jobType;
  @JsonKey(name: 'job_size')
  final String jobSize;
  @JsonKey(name: 'preferred_date')
  final String? preferredDate;
  final String status;
  @JsonKey(name: 'photo_urls')
  final List<String> photoUrls;
  final Map<String, dynamic>? category;
  final Map<String, dynamic>? homeowner;
  @JsonKey(name: 'created_at')
  final String createdAt;

  const JobFeedItem({
    required this.id,
    required this.title,
    required this.description,
    required this.address,
    required this.jobType,
    required this.jobSize,
    this.preferredDate,
    required this.status,
    required this.photoUrls,
    this.category,
    this.homeowner,
    required this.createdAt,
  });

  factory JobFeedItem.fromJson(Map<String, dynamic> json) =>
      _$JobFeedItemFromJson(json);
  Map<String, dynamic> toJson() => _$JobFeedItemToJson(this);

  String get homeownerName {
    if (homeowner != null && homeowner!['name'] != null) {
      return homeowner!['name'];
    }
    return 'Homeowner';
  }
}

@JsonSerializable()
class JobApplication {
  final int id;
  @JsonKey(name: 'job_offer_id')
  final int jobOfferId;
  final String? message;
  final String status;
  @JsonKey(name: 'applied_at')
  final String appliedAt;
  @JsonKey(name: 'accepted_at')
  final String? acceptedAt;
  @JsonKey(name: 'rejected_at')
  final String? rejectedAt;
  @JsonKey(name: 'completed_at')
  final String? completedAt;
  @JsonKey(name: 'job_offer')
  final Map<String, dynamic>? jobOffer;
  final Map<String, dynamic>? homeowner;

  const JobApplication({
    required this.id,
    required this.jobOfferId,
    this.message,
    required this.status,
    required this.appliedAt,
    this.acceptedAt,
    this.rejectedAt,
    this.completedAt,
    this.jobOffer,
    this.homeowner,
  });

  JobApplication copyWith({
    int? id,
    int? jobOfferId,
    String? message,
    String? status,
    String? appliedAt,
    String? acceptedAt,
    String? rejectedAt,
    String? completedAt,
    Map<String, dynamic>? jobOffer,
    Map<String, dynamic>? homeowner,
  }) {
    return JobApplication(
      id: id ?? this.id,
      jobOfferId: jobOfferId ?? this.jobOfferId,
      message: message ?? this.message,
      status: status ?? this.status,
      appliedAt: appliedAt ?? this.appliedAt,
      acceptedAt: acceptedAt ?? this.acceptedAt,
      rejectedAt: rejectedAt ?? this.rejectedAt,
      completedAt: completedAt ?? this.completedAt,
      jobOffer: jobOffer ?? this.jobOffer,
      homeowner: homeowner ?? this.homeowner,
    );
  }

  factory JobApplication.fromJson(Map<String, dynamic> json) =>
      _$JobApplicationFromJson(json);
  Map<String, dynamic> toJson() => _$JobApplicationToJson(this);

  bool get isPending => status == 'pending';
  bool get isAccepted => status == 'accepted';
  bool get isRejected => status == 'rejected';
  bool get isCompleted => status == 'completed';
}

@JsonSerializable()
class ApplyJobRequest {
  final String? message;

  const ApplyJobRequest({this.message});

  factory ApplyJobRequest.fromJson(Map<String, dynamic> json) =>
      _$ApplyJobRequestFromJson(json);
  Map<String, dynamic> toJson() => _$ApplyJobRequestToJson(this);
}

@JsonSerializable()
class JobApplicationResponse {
  final bool success;
  final String message;
  final dynamic data;

  const JobApplicationResponse({
    required this.success,
    required this.message,
    required this.data,
  });

  factory JobApplicationResponse.fromJson(Map<String, dynamic> json) =>
      _$JobApplicationResponseFromJson(json);
  Map<String, dynamic> toJson() => _$JobApplicationResponseToJson(this);
}
