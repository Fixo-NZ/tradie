// lib/features/auth/models/auth_data_model.dart
import 'package:json_annotation/json_annotation.dart';
import '../../../core/models/tradie_model.dart';

part 'auth_data_model.g.dart';

@JsonSerializable()
class AuthDataModel {
  final TradieModel user;
  final String token;

  const AuthDataModel({required this.user, required this.token});

  factory AuthDataModel.fromJson(Map<String, dynamic> json) =>
      _$AuthDataModelFromJson(json);

  Map<String, dynamic> toJson() => _$AuthDataModelToJson(this);
}