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
  final String? token;

  const ResetPasswordState({
    this.isLoading = false,
    this.error,
    this.step = ResetPasswordStep.enterEmail,
    this.email = '',
    this.token,
  });

  ResetPasswordState copyWith({
    bool? isLoading,
    String? error,
    ResetPasswordStep? step,
    String? email,
    String? token,
  }) {
    return ResetPasswordState(
      isLoading: isLoading ?? this.isLoading,
      error: error,
      step: step ?? this.step,
      email: email ?? this.email,
      token: token ?? this.token,
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
      case Success(data: final token):
        state = state.copyWith(
          isLoading: false,
          step: ResetPasswordStep.enterNewPassword,
          token: token,
        );
      case Failure():
        state = state.copyWith(isLoading: false, error: result.message);
    }
  }

  Future<void> setNewPassword(
      String password, String passwordConfirmation) async {

    // Safety check for token
    if (state.token == null) {
      state = state.copyWith(error: "Session expired. Please verify OTP again.");
      return;
    }

    state = state.copyWith(isLoading: true, error: null);

    final result = await _authRepository.setNewPassword(
      token: state.token!,
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