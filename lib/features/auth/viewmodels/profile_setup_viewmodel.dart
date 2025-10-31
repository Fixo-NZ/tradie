// lib/viewmodels/profile_setup_viewmodel.dart
import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/profile_api_service.dart';

class ProfileSetupState {
  final String firstName;
  final String lastName;
  final String email;
  final String phone;
  final String businessName;
  final String professionalBio;
  final File? pickedImage;
  final bool isLoading;
  final String? errorMessage;

  ProfileSetupState({
    this.firstName = '',
    this.lastName = '',
    this.email = '',
    this.phone = '',
    this.businessName = '',
    this.professionalBio = '',
    this.pickedImage,
    this.isLoading = false,
    this.errorMessage,
  });

  ProfileSetupState copyWith({
    String? firstName,
    String? lastName,
    String? email,
    String? phone,
    String? businessName,
    String? professionalBio,
    File? pickedImage,
    bool? isLoading,
    String? errorMessage,
  }) {
    return ProfileSetupState(
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      businessName: businessName ?? this.businessName,
      professionalBio: professionalBio ?? this.professionalBio,
      pickedImage: pickedImage ?? this.pickedImage,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
    );
  }
}

final profileSetupViewModelProvider =
    StateNotifierProvider<ProfileSetupViewModel, ProfileSetupState>((ref) {
  final service = ProfileApiService();
  return ProfileSetupViewModel(service);
});

class ProfileSetupViewModel extends StateNotifier<ProfileSetupState> {
  final ProfileApiService _service;

  ProfileSetupViewModel(this._service) : super(ProfileSetupState());

  // Update field methods
  void updateFirstName(String v) => state = state.copyWith(firstName: v);
  void updateLastName(String v) => state = state.copyWith(lastName: v);
  void updateEmail(String v) => state = state.copyWith(email: v);
  void updatePhone(String v) => state = state.copyWith(phone: v);
  void updateBusinessName(String v) => state = state.copyWith(businessName: v);
  void updateProfessionalBio(String v) => state = state.copyWith(professionalBio: v);
  void setPickedImage(File file) => state = state.copyWith(pickedImage: file);
  void removeImage() => state = state.copyWith(pickedImage: null);

  // ✅ Updated submit method
  Future<bool> submitBasicInfo() async {
    if (state.firstName.isEmpty ||
        state.lastName.isEmpty ||
        state.email.isEmpty ||
        state.phone.isEmpty ||
        state.businessName.isEmpty) {
      state = state.copyWith(errorMessage: 'Please fill in all required fields');
      return false;
    }

    state = state.copyWith(isLoading: true, errorMessage: null);

    final result = await _service.submitBasicInfo(
      firstName: state.firstName,
      lastName: state.lastName,
      email: state.email,
      phone: state.phone,
      businessName: state.businessName,
      professionalBio: state.professionalBio.isEmpty ? null : state.professionalBio,
      avatarImage: state.pickedImage, // ✅ include image
    );

    state = state.copyWith(isLoading: false);

    final success = result['success'] == true;
    if (!success) {
      // try to extract a helpful message from server response
      final body = result['body'];
      String message = 'Failed to save profile. Try again.';
      try {
        if (body is Map && body.containsKey('message')) {
          message = body['message'].toString();
        } else if (body is Map && body.containsKey('error')) {
          message = body['error'].toString();
        } else if (body is Map && body.containsKey('errors')) {
          final errors = body['errors'];
          if (errors is Map && errors.isNotEmpty) {
            final firstKey = errors.keys.first;
            final firstVal = errors[firstKey];
            if (firstVal is List && firstVal.isNotEmpty) {
              message = firstVal.first.toString();
            }
          }
        }
      } catch (_) {}

      state = state.copyWith(errorMessage: message);
    }

    return success;
  }
}
