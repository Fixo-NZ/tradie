// lib/features/auth/models/auth_models.dart
import 'package:json_annotation/json_annotation.dart';
import '../../../core/models/tradie_model.dart';
import 'auth_data_model.dart'; // <-- Import the new file

part 'auth_models.g.dart';

@JsonSerializable()
class LoginRequest {
  final String email;
  final String password;

  const LoginRequest({required this.email, required this.password});

  factory LoginRequest.fromJson(Map<String, dynamic> json) =>
      _$LoginRequestFromJson(json);

  Map<String, dynamic> toJson() => _$LoginRequestToJson(this);
}

@JsonSerializable()
class RegisterRequest {
  @JsonKey(name: 'first_name')
  final String firstName;
  @JsonKey(name: 'last_name')
  final String lastName;

  @JsonKey(name: 'middle_name', toJson: _middleNameToJson)
  final String? middleName;

  final String email;
  final String password;
  @JsonKey(name: 'password_confirmation')
  final String passwordConfirmation;
  final String? phone;

  const RegisterRequest({
    required this.firstName,
    required this.lastName,
    this.middleName,
    required this.email,
    required this.password,
    required this.passwordConfirmation,
    this.phone,
  });

  factory RegisterRequest.fromJson(Map<String, dynamic> json) =>
      _$RegisterRequestFromJson(json);

  Map<String, dynamic> toJson() => _$RegisterRequestToJson(this);
}

@JsonSerializable()
class AuthResponse {
  final bool success;
  final AuthDataModel data;

  const AuthResponse({
    required this.success,
    required this.data,
  });

  // Helper getters so we don't have to change any other files
  String get accessToken => data.token;
  TradieModel get user => data.user;

  factory AuthResponse.fromJson(Map<String, dynamic> json) =>
      _$AuthResponseFromJson(json);

  Map<String, dynamic> toJson() => _$AuthResponseToJson(this);
}

@JsonSerializable()
class ErrorPayload {
  final String? code;
  final String? message;

  const ErrorPayload({this.code, this.message});

  factory ErrorPayload.fromJson(Map<String, dynamic> json) =>
      _$ErrorPayloadFromJson(json);

  Map<String, dynamic> toJson() => _$ErrorPayloadToJson(this);
}

@JsonSerializable()
class ApiError {
  final bool? success;
  final ErrorPayload? error;
  final Map<String, List<String>>? errors;

  const ApiError({this.success, this.error, this.errors});

  factory ApiError.fromJson(Map<String, dynamic> json) =>
      _$ApiErrorFromJson(json);

  Map<String, dynamic> toJson() => _$ApiErrorToJson(this);
}

String _middleNameToJson(String? middleName) => middleName ?? "";