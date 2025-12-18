import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../viewmodels/auth_viewmodel.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_dimensions.dart';
import '../../../core/theme/app_text_styles.dart';

class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();

  // Controllers
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

  // --- Validators ---
  String? _validateRequired(String? value, String fieldName) {
    if (value == null || value.trim().isEmpty) {
      return 'Please enter your $fieldName';
    }
    return null;
  }

  String? _validateEmail(String? value) {
    if (value == null || value.isEmpty) return 'Please enter your email';
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(value)) return 'Please enter a valid email';
    return null;
  }

  String? _validatePhone(String? value) {
    if (value == null || value.isEmpty) return 'Please enter your phone number';
    final phoneRegex = RegExp(r'^\+?[0-9]{7,15}$');
    if (!phoneRegex.hasMatch(value)) return 'Please enter a valid phone number';
    return null;
  }

  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) return 'Please enter a password';
    if (value.length < 8) return 'Password must be at least 8 characters';
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authViewModelProvider);
    final authViewModel = ref.read(authViewModelProvider.notifier);

    // Listen for Registration Success
    ref.listen<AuthState>(authViewModelProvider, (previous, next) {
      if (next.isRegistered) {
        final emailForVerification =
            next.pendingEmail ?? _emailController.text.trim();

        // Acknowledge event to prevent double firing
        ref.read(authViewModelProvider.notifier).acknowledgeRegistrationHandled();

        // Navigate to verification
        context.go(
            '/email-verification?email=${Uri.encodeComponent(emailForVerification)}');
      }

      if (next.error != null && next.error!.isNotEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(next.error!),
            backgroundColor: AppColors.error,
          ),
        );
        authViewModel.clearError();
      }
    });

    return Scaffold(
      resizeToAvoidBottomInset: false, // Prevents background squishing
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          // --- Background Image (Bottom 33%) ---
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            height: MediaQuery.of(context).size.height * 0.33,
            child: Image.asset(
              "assets/background.png", // Consistent with LoginScreen
              fit: BoxFit.cover,
            ),
          ),

          // --- Main Content ---
          SafeArea(
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  // 1. TOP SECTION (Header)
                  Expanded(
                    flex: 0, // Keeps it compact
                    child: Padding(
                      padding: const EdgeInsets.only(top: 20, bottom: 10),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Image.asset("assets/logo.png", height: 60),
                          const SizedBox(height: 10),
                          Text(
                            "Create Account",
                            style: AppTextStyles.headlineMedium.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            "Join our community",
                            style: AppTextStyles.bodyLarge.copyWith(
                              color: AppColors.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // 2. MIDDLE SECTION (Scrollable Form)
                  Expanded(
                    flex: 3,
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppDimensions.paddingLarge,
                        vertical: 10,
                      ),
                      child: Column(
                        children: [
                          // First Name
                          TextFormField(
                            controller: _firstNameController,
                            decoration: InputDecoration(
                              labelText: 'First Name *',
                              prefixIcon: const Icon(Icons.person_outline),
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                              errorText: authState.fieldErrors?['first_name']?.first,
                            ),
                            validator: (v) => _validateRequired(v, 'First Name'),
                          ),
                          const SizedBox(height: AppDimensions.spacing16),

                          // Middle Name
                          TextFormField(
                            controller: _middleNameController,
                            decoration: InputDecoration(
                              labelText: 'Middle Name',
                              prefixIcon: const Icon(Icons.person_outline),
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                              errorText: authState.fieldErrors?['middle_name']?.first,
                            ),
                          ),
                          const SizedBox(height: AppDimensions.spacing16),

                          // Last Name
                          TextFormField(
                            controller: _lastNameController,
                            decoration: InputDecoration(
                              labelText: 'Last Name *',
                              prefixIcon: const Icon(Icons.person_outline),
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                              errorText: authState.fieldErrors?['last_name']?.first,
                            ),
                            validator: (v) => _validateRequired(v, 'Last Name'),
                          ),
                          const SizedBox(height: AppDimensions.spacing16),

                          // Email
                          TextFormField(
                            controller: _emailController,
                            keyboardType: TextInputType.emailAddress,
                            decoration: InputDecoration(
                              labelText: 'Email *',
                              prefixIcon: const Icon(Icons.email_outlined),
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                              errorText: authState.fieldErrors?['email']?.first,
                            ),
                            validator: _validateEmail,
                          ),
                          const SizedBox(height: AppDimensions.spacing16),

                          // Phone
                          TextFormField(
                            controller: _phoneController,
                            keyboardType: TextInputType.phone,
                            decoration: InputDecoration(
                              labelText: 'Phone *',
                              prefixIcon: const Icon(Icons.phone_outlined),
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                              errorText: authState.fieldErrors?['phone']?.first,
                            ),
                            validator: _validatePhone,
                          ),
                          const SizedBox(height: AppDimensions.spacing16),

                          // Password
                          TextFormField(
                            controller: _passwordController,
                            obscureText: _obscurePassword,
                            decoration: InputDecoration(
                              labelText: 'Password *',
                              prefixIcon: const Icon(Icons.lock_outline),
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                              suffixIcon: IconButton(
                                icon: Icon(_obscurePassword
                                    ? Icons.visibility
                                    : Icons.visibility_off),
                                onPressed: () => setState(
                                        () => _obscurePassword = !_obscurePassword),
                              ),
                              errorText: authState.fieldErrors?['password']?.first,
                            ),
                            validator: _validatePassword,
                          ),
                          const SizedBox(height: AppDimensions.spacing16),

                          // Confirm Password
                          TextFormField(
                            controller: _confirmPasswordController,
                            obscureText: _obscureConfirmPassword,
                            decoration: InputDecoration(
                              labelText: 'Confirm Password *',
                              prefixIcon: const Icon(Icons.lock_outline),
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                              suffixIcon: IconButton(
                                icon: Icon(_obscureConfirmPassword
                                    ? Icons.visibility
                                    : Icons.visibility_off),
                                onPressed: () => setState(() =>
                                _obscureConfirmPassword =
                                !_obscureConfirmPassword),
                              ),
                              errorText: authState.fieldErrors?['password_confirmation']
                                  ?.first,
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
                        ],
                      ),
                    ),
                  ),

                  // 3. BOTTOM SECTION (Actions)
                  Container(
                    padding: const EdgeInsets.all(AppDimensions.paddingLarge),
                    // Adding a slight background to make buttons pop over the image if they overlap
                    color: Colors.transparent,
                    child: Column(
                      children: [
                        SizedBox(
                          width: double.infinity,
                          height: AppDimensions.buttonHeight,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primary,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30),
                              ),
                            ),
                            onPressed: authState.isLoading
                                ? null
                                : () {
                              if (_formKey.currentState!.validate()) {
                                authViewModel.clearError();
                                authViewModel.register(
                                  firstName: _firstNameController.text.trim(),
                                  middleName: _middleNameController.text.trim().isEmpty
                                      ? null
                                      : _middleNameController.text.trim(),
                                  lastName: _lastNameController.text.trim(),
                                  email: _emailController.text.trim(),
                                  password: _passwordController.text,
                                  passwordConfirmation:
                                  _confirmPasswordController.text,
                                  phone: _phoneController.text.trim(),
                                );
                              }
                            },
                            child: authState.isLoading
                                ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor:
                                AlwaysStoppedAnimation<Color>(Colors.white),
                              ),
                            )
                                : const Text(
                              'Register',
                              style: TextStyle(fontSize: 16, color: Colors.white),
                            ),
                          ),
                        ),
                        const SizedBox(height: 10),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              "Already have an account? ",
                              style: TextStyle(color: AppColors.onSurfaceVariant),
                            ),
                            GestureDetector(
                              onTap: () => context.go('/login'),
                              child: Text(
                                "Login",
                                style: TextStyle(
                                  color: AppColors.black54,
                                  fontWeight: FontWeight.bold,
                                  decoration: TextDecoration.underline,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}