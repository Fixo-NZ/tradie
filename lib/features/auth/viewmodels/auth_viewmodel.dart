import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/models/tradie_model.dart';
import '../models/auth_models.dart';
import '../repositories/auth_repository.dart';
import '../../../core/network/api_result.dart';

enum AppStatus { initializing, unauthenticated, authenticated }

class AuthState {
  final AppStatus status;
  final bool isLoading;
  final TradieModel? user;
  final String? error;
  final Map<String, List<String>>? fieldErrors;
  final bool isRegistered;
  final String? pendingEmail;
  final bool isPasswordResetRequested;
  final String? token; // Added token to store OTP result

  const AuthState({
    this.status = AppStatus.initializing,
    this.isLoading = false,
    this.user,
    this.error,
    this.fieldErrors,
    this.isRegistered = false,
    this.pendingEmail,
    this.isPasswordResetRequested = false,
    this.token,
  });

  AuthState copyWith({
    AppStatus? status,
    bool? isLoading,
    TradieModel? user,
    String? error,
    Map<String, List<String>>? fieldErrors,
    bool? isRegistered,
    String? pendingEmail,
    bool? isPasswordResetRequested,
    String? token,
  }) {
    return AuthState(
      status: status ?? this.status,
      isLoading: isLoading ?? this.isLoading,
      user: user ?? this.user,
      error: error,
      fieldErrors: fieldErrors,
      isRegistered: isRegistered ?? this.isRegistered,
      pendingEmail: pendingEmail ?? this.pendingEmail,
      isPasswordResetRequested: isPasswordResetRequested ?? this.isPasswordResetRequested,
      token: token ?? this.token,
    );
  }
}

class AuthViewModel extends StateNotifier<AuthState> {
  final AuthRepository _authRepository;

  AuthViewModel(this._authRepository) : super(const AuthState()) {
    _checkAuthStatus();
  }

  // FIXED: Avoids List<Future> type error
  Future<void> _checkAuthStatus() async {
    // Start the delay
    final delayFuture = Future.delayed(const Duration(seconds: 2));
    // Start the check
    final loginCheckFuture = _authRepository.isLoggedIn();

    // Wait for both
    await delayFuture;
    final isLoggedIn = await loginCheckFuture;

    if (isLoggedIn) {
      state = state.copyWith(status: AppStatus.authenticated);
    } else {
      state = state.copyWith(status: AppStatus.unauthenticated);
    }
  }

  Future<bool> login(String email, String password) async {
    state = state.copyWith(isLoading: true, error: null, fieldErrors: null);
    final result = await _authRepository.login(LoginRequest(email: email, password: password));

    switch (result) {
      case Success<AuthResponse>():
        state = state.copyWith(
          isLoading: false,
          status: AppStatus.authenticated,
          user: result.data.user,
        );
        return true;
      case Failure<AuthResponse>():
        state = state.copyWith(
          isLoading: false,
          error: result.message,
          fieldErrors: result.errors,
        );
        return false;
    }
  }

  Future<bool> register({
    required String firstName,
    required String lastName,
    String? middleName,
    required String email,
    required String password,
    required String passwordConfirmation,
    String? phone,
  }) async {
    state = state.copyWith(isLoading: true, error: null, fieldErrors: null);
    final request = RegisterRequest(
      firstName: firstName,
      lastName: lastName,
      middleName: middleName,
      email: email,
      password: password,
      passwordConfirmation: passwordConfirmation,
      phone: phone,
    );
    final result = await _authRepository.register(request);

    switch (result) {
      case Success<AuthResponse>():
        state = state.copyWith(
          isLoading: false,
          isRegistered: true,
          pendingEmail: email,
        );
        return true;
      case Failure<AuthResponse>():
        state = state.copyWith(
          isLoading: false,
          error: result.message,
          fieldErrors: result.errors,
        );
        return false;
    }
  }

  void acknowledgeRegistrationHandled() {
    state = state.copyWith(isRegistered: false);
  }

  // --- PASSWORD RESET ---

  Future<bool> requestPasswordReset(String email) async {
    state = state.copyWith(isLoading: true, error: null);
    final result = await _authRepository.requestPasswordReset(email);

    switch (result) {
      case Success():
        state = state.copyWith(
          isLoading: false,
          isPasswordResetRequested: true,
          pendingEmail: email,
        );
        return true;
      case Failure():
        state = state.copyWith(
          isLoading: false,
          error: result.message,
          fieldErrors: result.errors,
        );
        return false;
    }
  }

  void acknowledgePasswordResetRequestHandled() {
    state = state.copyWith(isPasswordResetRequested: false);
  }

  Future<bool> verifyOtp({required String email, required String otp}) async {
    state = state.copyWith(isLoading: true, error: null);
    final result = await _authRepository.verifyPasswordResetOtp(email, otp);

    switch (result) {
      case Success(data: final token):
        state = state.copyWith(isLoading: false, token: token);
        return true;
      case Failure():
        state = state.copyWith(isLoading: false, error: result.message, fieldErrors: result.errors);
        return false;
    }
  }

  Future<bool> resetPassword({
    required String email,
    required String newPassword,
    required String confirmNewPassword,
  }) async {
    if (state.token == null) {
      state = state.copyWith(error: "Session expired.");
      return false;
    }

    state = state.copyWith(isLoading: true, error: null);
    final result = await _authRepository.resetPassword(
      token: state.token!,
      email: email,
      newPassword: newPassword,
      confirmNewPassword: confirmNewPassword,
    );

    switch (result) {
      case Success():
        state = state.copyWith(isLoading: false);
        return true;
      case Failure():
        state = state.copyWith(isLoading: false, error: result.message, fieldErrors: result.errors);
        return false;
    }
  }

  Future<void> logout() async {
    state = state.copyWith(isLoading: true);
    await _authRepository.logout();
    state = const AuthState(status: AppStatus.unauthenticated);
  }

  void clearError() {
    state = state.copyWith(error: null, fieldErrors: null);
  }
}

final authRepositoryProvider = Provider<AuthRepository>((ref) => AuthRepository());
final authViewModelProvider = StateNotifierProvider<AuthViewModel, AuthState>((ref) {
  final repo = ref.watch(authRepositoryProvider);
  return AuthViewModel(repo);
});