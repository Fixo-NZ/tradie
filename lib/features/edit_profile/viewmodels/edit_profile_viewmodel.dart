import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tradie/core/network/dio_client.dart';
import '../../../core/models/tradie_model.dart';
import '../models/edit_profile.dart';
import '../repositories/edit_profile_repository.dart';

final editProfileViewModelProvider =
    StateNotifierProvider<EditProfileViewModel, AsyncValue<TradieModel>>((ref) {
      final repo = ref.read(editProfileRepositoryProvider);
      return EditProfileViewModel(repo);
    });

final editProfileRepositoryProvider = Provider<EditProfileRepository>((ref) {
  // Ensure you provide a configured Dio instance in core/network
  final dio = ref.read(dioProvider);
  return EditProfileRepository(dio);
});

class EditProfileViewModel extends StateNotifier<AsyncValue<TradieModel>> {
  EditProfileViewModel(this._repository) : super(const AsyncValue.loading()) {
    loadProfile();
  }

  final EditProfileRepository _repository;

  Future<void> loadProfile() async {
    state = const AsyncValue.loading();
    try {
      final profile = await _repository.getProfile();
      state = AsyncValue.data(profile);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> updateProfile(EditProfile request) async {
    state = const AsyncValue.loading();
    try {
      final updated = await _repository.updateProfile(request);
      state = AsyncValue.data(updated);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }
}
