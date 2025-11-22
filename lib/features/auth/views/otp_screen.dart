import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../viewmodels/reset_password_viewmodel.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_dimensions.dart';
import '../../../core/theme/app_text_styles.dart';

class OtpScreen extends ConsumerStatefulWidget {
  const OtpScreen({super.key});

  @override
  ConsumerState<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends ConsumerState<OtpScreen> {
  final List<TextEditingController> _controllers =
  List.generate(6, (_) => TextEditingController());
  final List<FocusNode> _focusNodes = List.generate(6, (_) => FocusNode());
  bool _isButtonEnabled = false;

  @override
  void initState() {
    super.initState();
    for (var controller in _controllers) {
      controller.addListener(_updateButtonState);
    }
  }

  @override
  void dispose() {
    for (var controller in _controllers) {
      controller.removeListener(_updateButtonState);
      controller.dispose();
    }
    for (var node in _focusNodes) {
      node.dispose();
    }
    super.dispose();
  }

  void _updateButtonState() {
    final otp = _controllers.map((c) => c.text).join();
    setState(() {
      _isButtonEnabled = otp.length == 6;
    });
  }

  void _verifyOtp() {
    if (_isButtonEnabled) {
      final otp = _controllers.map((c) => c.text).join();
      ref.read(resetPasswordViewModelProvider.notifier).verifyOtp(otp);
    }
  }

  Widget _buildOtpBox(int index) {
    return SizedBox(
      width: 45,
      height: 45,
      child: TextField(
        controller: _controllers[index],
        focusNode: _focusNodes[index],
        keyboardType: TextInputType.number,
        textAlign: TextAlign.center,
        maxLength: 1,
        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 30),
        decoration: const InputDecoration(
          counterText: "",
          border: OutlineInputBorder(),
          contentPadding: EdgeInsets.only(bottom: 0),
        ),
        onChanged: (value) {
          if (value.isNotEmpty && index < 5) {
            _focusNodes[index + 1].requestFocus();
          } else if (value.isEmpty && index > 0) {
            _focusNodes[index - 1].requestFocus();
          }
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final vmState = ref.watch(resetPasswordViewModelProvider);
    final isLoading = vmState.isLoading;
    final email = vmState.email;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(backgroundColor: Colors.transparent, elevation: 0),
      body: Stack(
        children: [
          Align(
            alignment: Alignment.bottomCenter,
            child: SizedBox(
              height: MediaQuery.of(context).size.height * 0.33,
              width: double.infinity,
              child: Image.asset(
                "assets/background.png",
                fit: BoxFit.cover,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(
                horizontal: AppDimensions.paddingLarge),
            child: Column(
              children: [
                Expanded(
                  flex: 1,
                  // --- FIX: Added SingleChildScrollView ---
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const SizedBox(height: 10),
                        Text(
                          "Enter Verification Code",
                          style: AppTextStyles.displaySmall
                              .copyWith(fontSize: 28),
                        ),
                        const SizedBox(height: 5),
                        Text(
                          "A verification code has been sent to",
                          textAlign: TextAlign.center,
                          style: AppTextStyles.bodyLarge
                              .copyWith(color: AppColors.onSurfaceVariant),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          email,
                          style: AppTextStyles.titleMedium
                              .copyWith(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 10),
                      ],
                    ),
                  ),
                ),
                Expanded(
                  flex: 1,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: List.generate(6, (i) => _buildOtpBox(i)),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  flex: 1,
                  child: Center(
                    child: SizedBox(
                      width: double.infinity,
                      height: AppDimensions.buttonHeight,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _isButtonEnabled
                              ? AppColors.primary
                              : Colors.grey,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                        ),
                        onPressed: (isLoading || !_isButtonEnabled)
                            ? null
                            : _verifyOtp,
                        child: isLoading
                            ? const CircularProgressIndicator(
                            color: Colors.white)
                            : const Text(
                          "Verify",
                          style: TextStyle(
                              fontSize: 16, color: Colors.white),
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