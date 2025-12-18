// lib/viewmodels/profile_setup_viewmodel.dart
// import '../services/profile_service.dart'; 
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/painting.dart';
import '../services/profile_api_service.dart';

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
  final Map<String, dynamic>? profile; 

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
    this.profile,
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
    Map<String, dynamic>? profile,
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
      profile: profile ?? this.profile,
    );
  }
}

final profileSetupViewModelProvider = StateNotifierProvider<ProfileSetupViewModel, ProfileSetupState>((ref) {
  final service = ProfileApiService();
  return ProfileSetupViewModel(service);
});

class ProfileSetupViewModel extends StateNotifier<ProfileSetupState> {
  final ProfileApiService _service;

  ProfileSetupViewModel(this._service) : super(ProfileSetupState());

  //Field update methods
  void updateFirstName(String v) => state = state.copyWith(firstName: v);
  void updateLastName(String v) => state = state.copyWith(lastName: v);
  void updateEmail(String v) => state = state.copyWith(email: v);
  void updatePhone(String v) => state = state.copyWith(phone: v);
  void updateBusinessName(String v) => state = state.copyWith(businessName: v);
  void updateProfessionalBio(String v) => state = state.copyWith(professionalBio: v);

  Future<void> setPickedImage(File file) async {
    Uint8List? bytes;
    try {
      bytes = await file.readAsBytes();
    } catch (_) {
      bytes = null;
    }
    state = state.copyWith(pickedImage: file, pickedImageBytes: bytes);
  }

  Future<void> removeImage() async {
    final file = state.pickedImage;
    if (file != null) {
      try {
        await FileImage(file).evict();
        try {
          PaintingBinding.instance.imageCache.clear();
        } catch (_) {}
      } catch (_) {}
    }
    state = state.copyWith(pickedImage: null, pickedImageBytes: null);
  }

  // Basic Info Submission
  Future<bool> submitBasicInfo() async {
    if (state.firstName.isEmpty ||
        state.lastName.isEmpty ||
        state.email.isEmpty ||
        state.phone.isEmpty ||
        state.businessName.isEmpty) {
      state =
          state.copyWith(errorMessage: 'Please fill in all required fields');
      return false;
    }

    state = state.copyWith(isLoading: true, errorMessage: null);

    final result = await _service.submitBasicInfo(
      firstName: state.firstName,
      lastName: state.lastName,
      email: state.email,
      phone: state.phone,
      businessName: state.businessName,
      professionalBio:
          state.professionalBio.isEmpty ? null : state.professionalBio,
      avatarImage: state.pickedImage, 
    );

    state = state.copyWith(isLoading: false);

    final success = result['success'] == true;
    if (!success) {
      final body = result['body'];
      String message = 'Failed to save profile. Try again.';
      try {
        // SPECIAL HANDLING FOR EMAIL VALIDATION ERROR
        if (body is Map &&
            body.containsKey('error') &&
            body['error'] is Map &&
            body['error']['details'] is Map &&
            body['error']['details']['email'] is List &&
            body['error']['details']['email'].isNotEmpty) {
          message = 'email is invalid';
        }

        // Fallback existing logic (unchanged)
        else if (body is Map && body.containsKey('message')) {
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
    } else {
      // Automatically upload avatar after saving basic info
      if (state.pickedImage != null) {
        print('Uploading avatar automatically after basic info save...');
        await uploadProfileImage(state.pickedImage!);
      }
    }
    return success;
  }

  Future<bool> uploadProfileImage(File image) async {
    try {
      state = state.copyWith(isLoading: true);
      print('📸 Starting avatar upload for file: ${image.path}');

      final response = await _service.uploadAvatar(image);
      final success = response.statusCode == 200 || response.statusCode == 201;

      state = state.copyWith(isLoading: false);

      if (success) {
        print('✅ Avatar uploaded successfully!');
        print('📸 Response: ${response.data}');

        // Fetch latest profile from backend
        final profileResponse = await _service.getProfile();
        if (profileResponse['success'] == true) {
          state = state.copyWith(profile: profileResponse['data']);
          print('✅ Profile updated after avatar upload.');
        } else {
          print('⚠️ Failed to fetch updated profile data.');
        }
      } else {
        print('❌ Avatar upload failed: ${response.statusCode}');
        print('❌ Response body: ${response.data}');
        state = state.copyWith(
          errorMessage: 'Image upload failed: ${response.statusCode}');
        }
      return success;
    } catch (e) {
      print('Image upload failed: $e');
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
      return false;
    }
  }
}
