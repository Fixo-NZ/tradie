import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/profile_model.dart';
import '../repositories/profile_repositories.dart';

class ProfileState {
  final bool isLoading;
  final ProfileModel? profile;
  final String? errorMessage;

  const ProfileState({this.isLoading = false, this.profile, this.errorMessage});

  ProfileState copyWith({
    bool? isLoading,
    ProfileModel? profile,
    String? errorMessage,
  }) {
    return ProfileState(
      isLoading: isLoading ?? this.isLoading,
      profile: profile ?? this.profile,
      errorMessage: errorMessage,
    );
  }
}

class ProfileViewModel extends StateNotifier<ProfileState> {
  final ProfileRepository _repo;

  ProfileViewModel(this._repo) : super(const ProfileState());

  /// Loads the profile from the backend and returns it (or null on error).
  Future<ProfileModel?> loadProfile() async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      final profile = await _repo.fetchProfile();
      state = state.copyWith(
        isLoading: false,
        profile: profile,
        errorMessage: null,
      );
      return profile;
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
      return null;
    }
  }

  /// Update profile with a map of fields. Returns true on success.
  Future<bool> updateProfile(Map<String, dynamic> data) async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      final updated = await _repo.updateProfile(data);
      state = state.copyWith(
        isLoading: false,
        profile: updated,
        errorMessage: null,
      );
      return true;
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
      return false;
    }
  }
}

/// Providers
final profileRepositoryProvider = Provider<ProfileRepository>((ref) {
  return ProfileRepository();
});

final profileViewModelProvider =
    StateNotifierProvider<ProfileViewModel, ProfileState>((ref) {
      final repo = ref.watch(profileRepositoryProvider);
      return ProfileViewModel(repo);
    });
