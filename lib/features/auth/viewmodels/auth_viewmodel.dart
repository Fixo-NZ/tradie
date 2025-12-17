import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/models/tradie_model.dart';
import '../models/auth_models.dart';
import '../repositories/auth_repository.dart';
import '../../../core/network/api_result.dart';

// --- 1. DEFINE THE APP STATUS ---
enum AppStatus {
  initializing,
  unauthenticated,
  authenticated,
}

// --- 2. UPDATE AuthState ---
class AuthState {
  final AppStatus status;
  final bool isLoading;
  final TradieModel? user;
  final String? error;
  final Map<String, List<String>>? fieldErrors;

  // --- ADDED FIELDS FOR REGISTRATION & RESET ---
  final bool isRegistered;
  final String? pendingEmail;
  final bool isPasswordResetRequested;

  const AuthState({
    this.status = AppStatus.initializing,
    this.isLoading = false,
    this.user,
    this.error,
    this.fieldErrors,
    // Initialize new fields
    this.isRegistered = false,
    this.pendingEmail,
    this.isPasswordResetRequested = false,
  });

  AuthState copyWith({
    AppStatus? status,
    bool? isLoading,
    TradieModel? user,
    String? error,
    Map<String, List<String>>? fieldErrors,
    // Add new fields to copyWith
    bool? isRegistered,
    String? pendingEmail,
    bool? isPasswordResetRequested,
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
    );
  }
}

// --- 3. UPDATE AuthViewModel ---
class AuthViewModel extends StateNotifier<AuthState> {
  final AuthRepository _authRepository;

  AuthViewModel(this._authRepository) : super(const AuthState()) {
    _checkAuthStatus();
  }

  // --- INITIAL CHECK ---
  Future<void> _checkAuthStatus() async {
    final results = await Future.wait([
      _authRepository.isLoggedIn(),
      Future.delayed(const Duration(seconds: 2)),
    ]);

    final isLoggedIn = results[0] as bool;

    if (isLoggedIn) {
      state = state.copyWith(status: AppStatus.authenticated);
    } else {
      state = state.copyWith(status: AppStatus.unauthenticated);
    }
  }

  // --- LOGIN ---
  Future<bool> login(String email, String password) async {
    state = state.copyWith(isLoading: true, error: null, fieldErrors: null);
    final request = LoginRequest(email: email, password: password);
    final result = await _authRepository.login(request);

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

  // --- REGISTER ---
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
      // We set isRegistered to true so the UI can navigate to Email Verification.
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

  // --- REGISTRATION HELPER (Fixes error in register_screen.dart) ---
  void acknowledgeRegistrationHandled() {
    state = state.copyWith(isRegistered: false);
  }

  // --- PASSWORD RESET ---
  Future<bool> requestPasswordReset(String email) async {
    state = state.copyWith(isLoading: true, error: null, fieldErrors: null);
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

  // --- VERIFY OTP (Updated to use correct Repository name) ---
  Future<bool> verifyOtp({required String email, required String otp}) async {
    state = state.copyWith(isLoading: true, error: null);
    // Updated call to verifyPasswordResetOtp
    final result = await _authRepository.verifyPasswordResetOtp(email, otp);

    switch (result) {
      case Success():
        state = state.copyWith(isLoading: false);
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

  // --- RESET PASSWORD (Updated to use correct Repository name) ---
  Future<bool> resetPassword({
    required String email,
    required String newPassword,
    required String confirmNewPassword,
  }) async {
    state = state.copyWith(isLoading: true, error: null);
    // Updated call to setNewPassword
    final result = await _authRepository.setNewPassword(
      email: email,
      newPassword: newPassword,
      confirmNewPassword: confirmNewPassword,
    );

    switch (result) {
      case Success():
        state = state.copyWith(isLoading: false);
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

  // --- LOGOUT ---
  Future<void> logout() async {
    state = state.copyWith(isLoading: true);
    await _authRepository.logout();
    state = const AuthState(status: AppStatus.unauthenticated);
  }

  void clearError() {
    state = state.copyWith(error: null, fieldErrors: null);
  }
}

// Providers
final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepository();
});

final authViewModelProvider = StateNotifierProvider<AuthViewModel, AuthState>((ref) {
  final authRepository = ref.watch(authRepositoryProvider);
  return AuthViewModel(authRepository);
});