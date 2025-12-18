import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

// --- Auth Views ---
import '../../features/auth/views/login_screen.dart';
import '../../features/auth/views/register_screen.dart';
import '../../features/auth/views/reset_password_screen.dart';
import '../../features/auth/views/splash_screen.dart';
import '../../features/auth/viewmodels/auth_viewmodel.dart';

// --- Dashboard Views ---
// FIX: We changed the import from 'auth/views' to 'dashboard/views'
import '../../features/auth/views/dashboard_screen.dart';

final routerProvider = Provider<GoRouter>((ref) {
  // --- 1. Watch the ViewModel and get the new status ---
  final authState = ref.watch(authViewModelProvider);
  final appStatus = authState.status;

  return GoRouter(
    initialLocation: '/', // Start at splash screen

    // --- 2. Redirect Logic ---
    redirect: (context, state) {
      final location = state.matchedLocation;

      // If the app is still initializing, stay on the splash screen
      if (appStatus == AppStatus.initializing) {
        return (location == '/') ? null : '/';
      }

      // If the user is unauthenticated
      if (appStatus == AppStatus.unauthenticated) {
        // Allow access to login, register, and reset password
        if (location == '/login' ||
            location == '/register' ||
            location == '/reset-password') {
          return null;
        }
        // Redirect everything else to login
        return '/login';
      }

      // If the user is authenticated
      if (appStatus == AppStatus.authenticated) {
        // Redirect splash/login/register to dashboard
        if (location == '/' || location == '/login' || location == '/register') {
          return '/dashboard';
        }
      }

      // No other rule matched, stay where you are
      return null;
    },

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