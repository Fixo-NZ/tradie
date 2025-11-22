import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../repositories/auth_repository.dart';
import '../../../core/network/api_result.dart';
import 'auth_viewmodel.dart';

enum ResetPasswordStep {
  enterEmail,
  enterOtp,
  enterNewPassword,
  success,
}

class ResetPasswordState {
  final bool isLoading;
  final String? error;
  final ResetPasswordStep step;
  final String email;

  const ResetPasswordState({
    this.isLoading = false,
    this.error,
    this.step = ResetPasswordStep.enterEmail,
    this.email = '',
  });

  ResetPasswordState copyWith({
    bool? isLoading,
    String? error,
    ResetPasswordStep? step,
    String? email,
  }) {
    return ResetPasswordState(
      isLoading: isLoading ?? this.isLoading,
      error: error,
      step: step ?? this.step,
      email: email ?? this.email,
    );
  }
}

class ResetPasswordViewModel extends StateNotifier<ResetPasswordState> {
  final AuthRepository _authRepository;

  ResetPasswordViewModel(this._authRepository)
      : super(const ResetPasswordState());

  Future<void> requestOtp(String email) async {
    state = state.copyWith(isLoading: true, error: null);

    final result = await _authRepository.requestPasswordReset(email);

    switch (result) {
      case Success():
        state = state.copyWith(
          isLoading: false,
          email: email,
          step: ResetPasswordStep.enterOtp,
        );
      case Failure():
        state = state.copyWith(isLoading: false, error: result.message);
    }
  }

  Future<void> verifyOtp(String otp) async {
    state = state.copyWith(isLoading: true, error: null);

    final result = await _authRepository.verifyPasswordResetOtp(
      state.email,
      otp,
    );

    switch (result) {
      case Success():
        state = state.copyWith(
          isLoading: false,
          step: ResetPasswordStep.enterNewPassword,
        );
      case Failure():
        state = state.copyWith(isLoading: false, error: result.message);
    }
  }

  Future<void> setNewPassword(
      String password, String passwordConfirmation) async {
    state = state.copyWith(isLoading: true, error: null);

    final result = await _authRepository.setNewPassword(
      email: state.email,
      password: password,
      passwordConfirmation: passwordConfirmation,
    );

    switch (result) {
      case Success():
        state = state.copyWith(
          isLoading: false,
          step: ResetPasswordStep.success,
        );
      case Failure():
        state = state.copyWith(isLoading: false, error: result.message);
    }
  }

  void clearError() {
    state = state.copyWith(error: null);
  }
}

final resetPasswordViewModelProvider =
StateNotifierProvider<ResetPasswordViewModel, ResetPasswordState>((ref) {
  final authRepository = ref.watch(authRepositoryProvider);
  return ResetPasswordViewModel(authRepository);
});