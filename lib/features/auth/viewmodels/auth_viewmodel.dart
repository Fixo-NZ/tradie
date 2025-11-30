import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/models/tradie_model.dart';
import '../models/auth_models.dart';
import '../repositories/auth_repository.dart';
import '../../../core/network/api_result.dart';

// --- 1. DEFINE THE APP STATUS ---
enum AppStatus {
  initializing, // App is starting, checking for a token
  unauthenticated, // User is logged out
  authenticated, // User is logged in
}

// --- 2. UPDATE AuthState ---
class AuthState {
  final AppStatus status; // Use the enum instead of bool
  final bool isLoading; // This is for the login button spinner
  final TradieModel? user;
  final String? error;
  final Map<String, List<String>>? fieldErrors;

  const AuthState({
    this.status = AppStatus.initializing, // Start as initializing
    this.isLoading = false,
    this.user,
    this.error,
    this.fieldErrors,
  });

  // Remove `isAuthenticated` from copyWith
  AuthState copyWith({
    AppStatus? status,
    bool? isLoading,
    TradieModel? user,
    String? error,
    Map<String, List<String>>? fieldErrors,
  }) {
    return AuthState(
      status: status ?? this.status,
      isLoading: isLoading ?? this.isLoading,
      user: user ?? this.user,
      error: error,
      fieldErrors: fieldErrors,
    );
  }
}

// --- 3. UPDATE AuthViewModel ---
class AuthViewModel extends StateNotifier<AuthState> {
  final AuthRepository _authRepository;

  AuthViewModel(this._authRepository) : super(const AuthState()) {
    _checkAuthStatus(); // This will run on app start
  }

  // --- THIS IS THE FIX ---
  // We force this to take at least 2 seconds so the animation can play.
  Future<void> _checkAuthStatus() async {
    // Run both the check AND the timer at the same time
    final results = await Future.wait([
      _authRepository.isLoggedIn(),            // Task 1: Check token (Fast)
      Future.delayed(const Duration(seconds: 2)), // Task 2: Wait 2 secs (Slow)
    ]);

    // results[0] holds the boolean from _authRepository.isLoggedIn()
    final isLoggedIn = results[0] as bool;

    if (isLoggedIn) {
      state = state.copyWith(status: AppStatus.authenticated);
    } else {
      state = state.copyWith(status: AppStatus.unauthenticated);
    }
  }
  // --- END OF FIX ---

  Future<bool> login(String email, String password) async {
    state = state.copyWith(isLoading: true, error: null, fieldErrors: null);
    final request = LoginRequest(email: email, password: password);
    final result = await _authRepository.login(request);

    switch (result) {
      case Success<AuthResponse>():
        state = state.copyWith(
          isLoading: false,
          status: AppStatus.authenticated, // SET STATUS
          user: result.data.user,
        );
        return true;
      case Failure<AuthResponse>():
        state = state.copyWith(
          isLoading: false,
          error: result.message,
          fieldErrors: result.errors,
          // Status remains unauthenticated
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
          status: AppStatus.authenticated, // SET STATUS
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

  Future<void> logout() async {
    state = state.copyWith(isLoading: true);
    await _authRepository.logout();
    // Reset the state to a fresh, unauthenticated state
    state = const AuthState(status: AppStatus.unauthenticated);
  }

  void clearError() {
    state = state.copyWith(error: null, fieldErrors: null);
  }
}

// Providers (no change here)
final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepository();
});

final authViewModelProvider = StateNotifierProvider<AuthViewModel, AuthState>((
    ref,
    ) {
  final authRepository = ref.watch(authRepositoryProvider);
  return AuthViewModel(authRepository);
});