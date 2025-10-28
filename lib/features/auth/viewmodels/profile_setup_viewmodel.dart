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

    final success = await _service.submitBasicInfo(
      firstName: state.firstName,
      lastName: state.lastName,
      email: state.email,
      phone: state.phone,
      businessName: state.businessName,
      professionalBio: state.professionalBio,
      avatarImage: state.pickedImage, // ✅ include image
    );

    state = state.copyWith(isLoading: false);

    if (!success) {
      state = state.copyWith(errorMessage: 'Failed to save profile. Try again.');
    }

    return success;
  }
}
