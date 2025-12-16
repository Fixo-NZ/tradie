class TradieModel {
  final int? id;
  final String? firstName;
  final String? lastName;
  final String? middleName;
  final String email;
  final String? phone;
  final String? address;
  final String? city;
  final String? region;
  final String? postalCode;
  final String? businessName;
  final String? licenseNumber;
  final int? yearsExperience;
  final double? hourlyRate;
  final String? availabilityStatus;
  final int? serviceRadius;
  final bool? isVerified;
  final String? status;
  final String? userType;

  const TradieModel({
    this.id,
    this.firstName,
    this.lastName,
    this.middleName,
    required this.email,
    this.phone,
    this.address,
    this.city,
    this.region,
    this.postalCode,
    this.businessName,
    this.licenseNumber,
    this.yearsExperience,
    this.hourlyRate,
    this.availabilityStatus,
    this.serviceRadius,
    this.isVerified,
    this.status,
    this.userType,
  });

  factory TradieModel.fromJson(Map<String, dynamic> json) {
    return TradieModel(
      id: json['id'] as int?,
      // We use 'as String?' to safely handle if the server returns null
      firstName: json['first_name'] as String?,
      lastName: json['last_name'] as String?,
      middleName: json['middle_name'] as String?,
      email: json['email'] ?? '',
      phone: json['phone'] as String?,
      address: json['address'] as String?,
      city: json['city'] as String?,
      region: json['region'] as String?,
      postalCode: json['postal_code'] as String?,
      businessName: json['business_name'] as String?,
      licenseNumber: json['license_number'] as String?,

      // Safely parse integers (handles string "5" or int 5)
      yearsExperience: json['years_experience'] is String
          ? int.tryParse(json['years_experience'])
          : json['years_experience'] as int?,

      // Safely parse doubles (handles "100.50", 100, or 100.50)
      hourlyRate: _parseDouble(json['hourly_rate']),

      availabilityStatus: json['availability_status'] as String?,

      serviceRadius: json['service_radius'] is String
          ? int.tryParse(json['service_radius'])
          : json['service_radius'] as int?,

      // Handle boolean (sometimes APIs return 1/0 for bools)
      isVerified: json['is_verified'] == 1 || json['is_verified'] == true,

      status: json['status'] as String?,
      userType: json['user_type'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'first_name': firstName,
      'last_name': lastName,
      'middle_name': middleName,
      'email': email,
      'phone': phone,
      'address': address,
      'city': city,
      'region': region,
      'postal_code': postalCode,
      'business_name': businessName,
      'license_number': licenseNumber,
      'years_experience': yearsExperience,
      'hourly_rate': hourlyRate,
      'availability_status': availabilityStatus,
      'service_radius': serviceRadius,
      'is_verified': isVerified,
      'status': status,
      'user_type': userType,
    };
  }

  String get fullName => '${firstName ?? ''} ${middleName ?? ''} ${lastName ?? ''}'.trim();

  // Helper function to safely parse doubles from Strings or Numbers
  static double? _parseDouble(dynamic value) {
    if (value == null) return null;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value);
    return null;
  }
}