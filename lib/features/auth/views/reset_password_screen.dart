import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../viewmodels/reset_password_viewmodel.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_dimensions.dart';
import '../../../core/theme/app_text_styles.dart';
import 'otp_screen.dart';
import 'new_password_screen.dart';

class ResetPasswordScreen extends ConsumerWidget {
  const ResetPasswordScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final resetState = ref.watch(resetPasswordViewModelProvider);
    final resetViewModel = ref.read(resetPasswordViewModelProvider.notifier);

    ref.listen<ResetPasswordState>(resetPasswordViewModelProvider,
            (previous, next) {
          if (next.step == ResetPasswordStep.success) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text("Password reset successfully!"),
                backgroundColor: AppColors.primary,
              ),
            );
            context.go('/login');
          }

          if (next.error != null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(next.error!),
                backgroundColor: AppColors.error,
              ),
            );
            resetViewModel.clearError();
          }
        });

    switch (resetState.step) {
      case ResetPasswordStep.enterEmail:
        return const _EnterEmailView();
      case ResetPasswordStep.enterOtp:
        return const OtpScreen();
      case ResetPasswordStep.enterNewPassword:
        return const NewPasswordScreen();
      case ResetPasswordStep.success:
        return const Scaffold(
          body: Center(child: CircularProgressIndicator()),
        );
    }
  }
}

class _EnterEmailView extends ConsumerStatefulWidget {
  const _EnterEmailView();

  @override
  ConsumerState<_EnterEmailView> createState() => __EnterEmailViewState();
}

class __EnterEmailViewState extends ConsumerState<_EnterEmailView> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  void _submit() {
    if (_formKey.currentState!.validate()) {
      final viewModel = ref.read(resetPasswordViewModelProvider.notifier);
      viewModel.requestOtp(_emailController.text.trim());
    }
  }

  String? _validateEmailOrPhone(String? value) {
    if (value == null || value.isEmpty) {
      return "Please enter your Email/Number";
    }
    final input = value.trim();
    final phoneRegex = RegExp(r'^\d{11}$');
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!phoneRegex.hasMatch(input) && !emailRegex.hasMatch(input)) {
      return "Enter a valid Email or 11-digit Phone Number";
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = ref
        .watch(resetPasswordViewModelProvider.select((s) => s.isLoading));

    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: AppColors.background,
      appBar: AppBar(backgroundColor: Colors.transparent, elevation: 0),
      body: Stack(
        children: [
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            height: MediaQuery.of(context).size.height * 0.33,
            child: Image.asset(
              "assets/background.png",
              fit: BoxFit.cover,
            ),
          ),
          Form(
            key: _formKey,
            child: Column(
              children: [
                Expanded(
                  flex: 1,
                  // --- FIX: Added SingleChildScrollView ---
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Adding padding in case it's at the very top
                        const SizedBox(height: 10),
                        Image.asset("assets/logo.png", height: 75),
                        const SizedBox(height: 20),
                        Text("FIXO", style: AppTextStyles.displaySmall),
                        const SizedBox(height: 5),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child: Text(
                            "Enter the Email/Number Registered to the Forgotten account",
                            textAlign: TextAlign.center,
                            style: AppTextStyles.bodyLarge
                                .copyWith(color: AppColors.onSurfaceVariant),
                          ),
                        ),
                        // Adding padding in case it's at the very bottom
                        const SizedBox(height: 10),
                      ],
                    ),
                  ),
                ),
                Expanded(
                  flex: 1,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: AppDimensions.paddingLarge),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        TextFormField(
                          controller: _emailController,
                          decoration: InputDecoration(
                            labelText: "Email/Number",
                            hintText: "example@email.com / 09123456789",
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          validator: _validateEmailOrPhone,
                        ),
                      ],
                    ),
                  ),
                ),
                Expanded(
                  flex: 1,
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: AppDimensions.paddingLarge),
                      child: SizedBox(
                        width: double.infinity,
                        height: AppDimensions.buttonHeight,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                          ),
                          onPressed: isLoading ? null : _submit,
                          child: isLoading
                              ? const CircularProgressIndicator(
                              color: Colors.white)
                              : const Text(
                            "Reset Password",
                            style: TextStyle(
                                fontSize: 16, color: Colors.white),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}