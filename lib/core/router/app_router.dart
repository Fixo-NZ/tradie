import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../features/auth_otp/views/login_screen.dart';
import '../../features/auth_otp/views/register_screen.dart';
import '../../features/auth_otp/views/dashboard_screen.dart';
import '../../features/auth_otp/views/otp_screen.dart';
import '../../features/auth_otp/views/reset_password_screen.dart';
import '../../features/auth_otp/viewmodels/auth_viewmodel.dart';
import '../../features/profile/views/profile_screen.dart';

final routerProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authViewModelProvider);

  return GoRouter(
    initialLocation: '/login',
    redirect: (context, state) {
      final isAuthenticated = authState.isAuthenticated;
      final isLoggingIn = state.matchedLocation == '/login';
      final isRegistering = state.matchedLocation == '/register';
      final isOtp = state.matchedLocation == '/otp';
      final isResetPassword = state.matchedLocation == '/reset-password';

      // If not authenticated and not on login/register/otp/reset-password page, redirect to login
      if (!isAuthenticated && !isLoggingIn && !isRegistering && !isOtp && !isResetPassword) {
        return '/login';
      }

      // If authenticated and on login/register/otp/reset-password page, redirect to dashboard
      if (isAuthenticated && (isLoggingIn || isRegistering || isOtp || isResetPassword)) {
        return '/dashboard';
      }

      return null;
    },
    routes: [
      GoRoute(path: '/login', builder: (context, state) => const LoginScreen()),
      GoRoute(
        path: '/register',
        builder: (context, state) {
          final phoneNumber = state.extra as String?;
          return RegisterScreen(phoneNumber: phoneNumber);
        },
      ),
      GoRoute(
        path: '/otp',
        builder: (context, state) {
          final phoneNumber = state.extra as String? ?? '';
          return OtpScreen(phoneNumber: phoneNumber);
        },
      ),
      GoRoute(
        path: '/reset-password',
        builder: (context, state) => const ResetPasswordScreen(),
      ),
      GoRoute(
        path: '/dashboard',
        builder: (context, state) => const DashboardScreen(),
      ),
      GoRoute(
        path: '/profile',
        builder: (context, state) => const ProfileScreen(),
      ),
    ],
  );
});
