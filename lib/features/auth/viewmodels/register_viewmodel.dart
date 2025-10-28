import 'package:flutter_riverpod/flutter_riverpod.dart';

class RegisterState {
  final bool obscurePassword;
  final bool obscureConfirmPassword;
  final bool isLoading;

  const RegisterState({
    this.obscurePassword = true,
    this.obscureConfirmPassword = true,
    this.isLoading = false,
  });

  RegisterState copyWith({
    bool? obscurePassword,
    bool? obscureConfirmPassword,
    bool? isLoading,
  }) {
    return RegisterState(
      obscurePassword: obscurePassword ?? this.obscurePassword,
      obscureConfirmPassword: obscureConfirmPassword ?? this.obscureConfirmPassword,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

class RegisterViewModel extends StateNotifier<RegisterState> {
  RegisterViewModel() : super(const RegisterState());

  void togglePasswordVisibility() {
    state = state.copyWith(obscurePassword: !state.obscurePassword);
  }

  void toggleConfirmPasswordVisibility() {
    state = state.copyWith(obscureConfirmPassword: !state.obscureConfirmPassword);
  }

  void setLoading(bool isLoading) {
    state = state.copyWith(isLoading: isLoading);
  }
}