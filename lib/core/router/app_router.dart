import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../features/auth/views/login_screen.dart';
import '../../features/auth/views/register_screen.dart';
import '../../features/auth/views/dashboard_screen.dart';
import '../../features/auth/views/reset_password_screen.dart';
import '../../features/auth/viewmodels/auth_viewmodel.dart';
import '../../features/auth/views/splash_screen.dart';

final routerProvider = Provider<GoRouter>((ref) {
  // --- 1. Watch the ViewModel and get the new status ---
  final authState = ref.watch(authViewModelProvider);
  final appStatus = authState.status;

  return GoRouter(
    initialLocation: '/', // Start at splash screen

    // --- 2. This is the new, more powerful redirect logic ---
    redirect: (context, state) {
      final location = state.matchedLocation;

      // If the app is still initializing, stay on the splash screen
      if (appStatus == AppStatus.initializing) {
        // Stay on splash, or go to splash if we are anywhere else
        return (location == '/') ? null : '/';
      }

      // If the user is unauthenticated
      if (appStatus == AppStatus.unauthenticated) {
        // If they are on the login, register, or reset password page, let them be
        if (location == '/login' ||
            location == '/register' ||
            location == '/reset-password') {
          return null;
        }
        // If they are anywhere else, redirect to login
        return '/login';
      }

      // If the user is authenticated
      if (appStatus == AppStatus.authenticated) {
        // If they are on the splash or login/register pages, send to dashboard
        if (location == '/' || location == '/login' || location == '/register') {
          return '/dashboard';
        }
      }

      // No other rule matched, so stay where you are
      return null;
    },
    // --- End of new redirect logic ---

    routes: [
      GoRoute(
        path: '/',
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/register',
        builder: (context, state) => const RegisterScreen(),
      ),
      GoRoute(
        path: '/dashboard',
        builder: (context, state) => const DashboardScreen(),
      ),
      GoRoute(
        path: '/reset-password',
        builder: (context, state) => const ResetPasswordScreen(),
      ),
    ],
  );
});