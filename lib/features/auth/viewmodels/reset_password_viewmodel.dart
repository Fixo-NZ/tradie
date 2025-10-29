import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../repositories/auth_repository.dart';
import '../../../core/network/api_result.dart';
import 'auth_viewmodel.dart'; // <-- THIS IS THE FIX FOR ERROR 2

// 1. Define the states for the 3-step flow
enum ResetPasswordStep {
  enterEmail, // Step 1: Show ResetPasswordScreen
  enterOtp, // Step 2: Show OtpScreen
  enterNewPassword, // Step 3: Show NewPasswordScreen
  success, // Final state: Show success, then navigate
}

// 2. Define the State class
class ResetPasswordState {
  final bool isLoading;
  final String? error;
  final ResetPasswordStep step;
  final String email; // We need to remember the email

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
      error: error, // Allow setting error to null
      step: step ?? this.step,
      email: email ?? this.email,
    );
  }
}

// 3. Define the ViewModel
class ResetPasswordViewModel extends StateNotifier<ResetPasswordState> {
  final AuthRepository _authRepository;

  ResetPasswordViewModel(this._authRepository)
      : super(const ResetPasswordState());

  // Step 1: Request OTP
  Future<void> requestOtp(String email) async {
    state = state.copyWith(isLoading: true, error: null);

    // --- API CALL ---
    final result = await _authRepository.requestPasswordReset(email);

    switch (result) {
      case Success():
      // On success, save the email and move to the OTP step
        state = state.copyWith(
          isLoading: false,
          email: email,
          step: ResetPasswordStep.enterOtp,
        );
      case Failure():
        state = state.copyWith(isLoading: false, error: result.message);
    }
  }

  // Step 2: Verify OTP
  Future<void> verifyOtp(String otp) async {
    state = state.copyWith(isLoading: true, error: null);

    // --- API CALL ---
    // We use the email we saved in the state
    final result = await _authRepository.verifyPasswordResetOtp(
      state.email,
      otp,
    );

    switch (result) {
      case Success():
      // On success, move to the new password step
        state = state.copyWith(
          isLoading: false,
          step: ResetPasswordStep.enterNewPassword,
        );
      case Failure():
        state = state.copyWith(isLoading: false, error: result.message);
    }
  }

  // Step 3: Set New Password
  Future<void> setNewPassword(
      String password, String passwordConfirmation) async {
    state = state.copyWith(isLoading: true, error: null);

    // --- API CALL ---
    final result = await _authRepository.setNewPassword(
      email: state.email,
      password: password,
      passwordConfirmation: passwordConfirmation,
    );

    switch (result) {
      case Success():
      // On success, move to the final step
        state = state.copyWith(
          isLoading: false,
          step: ResetPasswordStep.success,
        );
      case Failure():
        state = state.copyWith(isLoading: false, error: result.message);
    }
  }

  // Helper to clear errors
  void clearError() {
    state = state.copyWith(error: null);
  }
}

// 4. Define the Riverpod Provider
final resetPasswordViewModelProvider =
StateNotifierProvider<ResetPasswordViewModel, ResetPasswordState>((ref) {
  // authRepositoryProvider is now correctly found
  final authRepository = ref.watch(authRepositoryProvider);
  return ResetPasswordViewModel(authRepository);
});