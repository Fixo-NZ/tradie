import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../viewmodels/register_viewmodel.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_dimensions.dart';
import '../../../core/theme/app_text_styles.dart';

final registerViewModelProvider = StateNotifierProvider<RegisterViewModel, RegisterState>(
  (ref) => RegisterViewModel(),
);

class RegisterScreen extends ConsumerWidget {
  const RegisterScreen({super.key});

  @override
<<<<<<< HEAD
  Widget build(BuildContext context, WidgetRef ref) {
    final registerState = ref.watch(registerViewModelProvider);
    final registerViewModel = ref.read(registerViewModelProvider.notifier);
=======
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _firstNameController = TextEditingController();
  final _middleNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  @override
  void dispose() {
    _firstNameController.dispose();
    _middleNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authViewModelProvider);
    final authViewModel = ref.read(authViewModelProvider.notifier);

    // Listen to auth state changes
    ref.listen<AuthState>(authViewModelProvider, (previous, next) {
      // --- FIX IS HERE ---
      // Changed from 'next.isAuthenticated' to checking the status enum
      if (next.status == AppStatus.authenticated) {
        context.go('/dashboard');
      }
      // --- END OF FIX ---

      if (next.error != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(next.error!),
            backgroundColor: AppColors.error,
          ),
        );
      }
    });
>>>>>>> origin/g8/mobile-login

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text('Register', style: AppTextStyles.appBarTitle),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/login'),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppDimensions.paddingLarge),
          child: Form(
            key: GlobalKey<FormState>(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Header
                const Icon(
                  Icons.person_add,
                  size: AppDimensions.iconXXLarge - 4,
                  color: AppColors.primary,
                ),
                const SizedBox(height: AppDimensions.spacing16),
                Text(
                  'Create Account',
                  style: AppTextStyles.headlineMedium.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: AppDimensions.spacing8),
                Text(
                  'Join our tradie community',
                  style: AppTextStyles.bodyLarge.copyWith(
                    color: AppColors.onSurfaceVariant,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: AppDimensions.spacing32),

                // Password
                TextFormField(
                  obscureText: registerState.obscurePassword,
                  decoration: InputDecoration(
                    labelText: 'Password *',
                    prefixIcon: const Icon(Icons.lock_outline),
                    suffixIcon: IconButton(
                      icon: Icon(
                        registerState.obscurePassword
                            ? Icons.visibility
                            : Icons.visibility_off,
                      ),
                      onPressed: registerViewModel.togglePasswordVisibility,
                    ),
                  ),
                ),

                // Confirm Password
                TextFormField(
                  obscureText: registerState.obscureConfirmPassword,
                  decoration: InputDecoration(
                    labelText: 'Confirm Password *',
                    prefixIcon: const Icon(Icons.lock_outline),
                    suffixIcon: IconButton(
                      icon: Icon(
                        registerState.obscureConfirmPassword
                            ? Icons.visibility
                            : Icons.visibility_off,
                      ),
                      onPressed: registerViewModel.toggleConfirmPasswordVisibility,
                    ),
<<<<<<< HEAD
                  ),
=======
                    errorText:
                    authState.fieldErrors?['password_confirmation']?.first,
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please confirm your password';
                    }
                    if (value != _passwordController.text) {
                      return 'Passwords do not match';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: AppDimensions.spacing32),

                // Register button
                SizedBox(
                  height: AppDimensions.buttonHeight,
                  child: ElevatedButton(
                    onPressed: authState.isLoading
                        ? null
                        : () async {
                      if (_formKey.currentState!.validate()) {
                        authViewModel.clearError();
                        await authViewModel.register(
                          firstName: _firstNameController.text.trim(),
                          middleName:
                          _middleNameController.text.trim().isEmpty
                              ? null
                              : _middleNameController.text.trim(),
                          lastName: _lastNameController.text.trim(),
                          email: _emailController.text.trim(),
                          password: _passwordController.text,
                          passwordConfirmation:
                          _confirmPasswordController.text,
                          phone: _phoneController.text.trim().isEmpty
                              ? null
                              : _phoneController.text.trim(),
                        );
                      }
                    },
                    child: authState.isLoading
                        ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          Colors.white,
                        ),
                      ),
                    )
                        : const Text('Register'),
                  ),
                ),
                const SizedBox(height: AppDimensions.spacing16),

                // Login link
                TextButton(
                  onPressed: () {
                    context.go('/login');
                  },
                  child: const Text('Already have an account? Login'),
>>>>>>> origin/g8/mobile-login
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}