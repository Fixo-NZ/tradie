// lib/viewmodels/profile_setup_viewmodel.dart
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/painting.dart';
import '../services/profile_api_service.dart';
import '../services/profile_service.dart'; // 👈 add this import at the top


class ProfileSetupState {
  final String firstName;
  final String lastName;
  final String email;
  final String phone;
  final String businessName;
  final String professionalBio;
  final File? pickedImage;
  final Uint8List? pickedImageBytes;
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
  this.pickedImageBytes,
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
  Uint8List? pickedImageBytes,
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
      pickedImageBytes: pickedImageBytes ?? this.pickedImageBytes,
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
  Future<void> setPickedImage(File file) async {
    // Read the file bytes to drive Image.memory rendering (avoids FileImage cache persistence)
    Uint8List? bytes;
    try {
      bytes = await file.readAsBytes();
    } catch (_) {
      bytes = null;
    }
    state = state.copyWith(pickedImage: file, pickedImageBytes: bytes);
  }

  /// Remove the picked image and evict it from the image cache so the
  /// UI doesn't keep showing a cached preview.
  Future<void> removeImage() async {
    final file = state.pickedImage;
    if (file != null) {
      try {
        // Evict the file-backed image from Flutter's image cache.
        await FileImage(file).evict();
        // As a stronger fallback clear the global in-memory image cache.
        try {
          PaintingBinding.instance.imageCache.clear();
        } catch (_) {}
      } catch (_) {
        // ignore cache-eviction errors
      }
    }
    state = state.copyWith(pickedImage: null, pickedImageBytes: null);
  }

  // ✅ Updated submit method
  // ✅ Fixed submit method
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

  // ✅ Send the picked image along with basic info
  final result = await _service.submitBasicInfo(
    firstName: state.firstName,
    lastName: state.lastName,
    email: state.email,
    phone: state.phone,
    businessName: state.businessName,
    professionalBio: state.professionalBio.isEmpty ? null : state.professionalBio,
    avatarImage: state.pickedImage, // 👈 this makes sure the image gets uploaded
  );

  state = state.copyWith(isLoading: false);

  final success = result['success'] == true;
  if (!success) {
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

Future<bool> uploadProfileImage(File image) async {
  try {
    state = state.copyWith(isLoading: true);

    // ✅ use ProfileService directly here, not _service
    final profileService = ProfileService();
    final response = await profileService.uploadAvatar(image);

    final success = response.statusCode == 200 || response.statusCode == 201;
    state = state.copyWith(isLoading: false);

    if (success) {
      print('✅ Image uploaded successfully!');
    } else {
      print('❌ Image upload failed: ${response.statusCode}');
    }

    return success;
  } catch (e) {
    print('Image upload failed: $e');
    state = state.copyWith(isLoading: false, errorMessage: e.toString());
    return false;
  }
}


}