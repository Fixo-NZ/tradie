import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/network/dio_client.dart';
import '../models/edit_profile.dart';
import '../repositories/edit_profile_repository.dart';

/// Repository provider
final editProfileRepositoryProvider =
Provider<EditProfileRepository>((ref) {
  final dio = ref.read(dioProvider); // your Dio provider
  return EditProfileRepository(dio);
});

/// ViewModel provider
final editProfileViewModelProvider =
StateNotifierProvider<EditProfileViewModel, AsyncValue<EditProfile>>((ref) {
  final repo = ref.read(editProfileRepositoryProvider);
  return EditProfileViewModel(repo);
});

/// ----------------------
/// EditProfile ViewModel
/// ----------------------
class EditProfileViewModel extends StateNotifier<AsyncValue<EditProfile>> {
  EditProfileViewModel(this._repository) : super(const AsyncValue.loading()) {
    // Automatically load profile on initialization
    loadProfile();
  }

  final EditProfileRepository _repository;

  /// Load profile (GET)
  Future<void> loadProfile() async {
    // Keep old value while loading if you want
    final previous = state.valueOrNull;
    state = AsyncValue.loading();

    try {
      final profile = await _repository.getProfile();
      state = AsyncValue.data(profile);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  /// Update profile (PUT/PATCH)
  Future<void> updateProfile(EditProfile request) async {
    final previous = state.valueOrNull;
    state = AsyncValue.loading();

    try {
      final updated = await _repository.updateProfile(request);
      state = AsyncValue.data(updated);
    } catch (e, st) {
      state = AsyncValue.error(e, st); // previous not allowed in AsyncValue.error
    }
  }
}
