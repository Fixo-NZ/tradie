import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/theme/app_dimensions.dart';
import '../../../core/widgets/navigation_widgets.dart'; // Corrected import path

class ConfirmationScreen extends StatelessWidget {
  const ConfirmationScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          // Wavy background image
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Image.asset(
              'assets/images/wave.png', // Ensure this file exists
              fit: BoxFit.cover,
            ),
          ),

          // Foreground content
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppDimensions.paddingLarge),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Title
                  Text(
                    'Your profile is all set!',
                    style: AppTextStyles.headlineMedium.copyWith(
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                      fontSize: 28, // Increased font size
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: AppDimensions.spacing24),

                  // Popper image
                  Image.asset(
                    'assets/images/Confirm.png', // Ensure this file exists
                    width: 200,
                    height: 200,
                  ),
                  const SizedBox(height: AppDimensions.spacing24),

                  // Subtitle
                  Text(
                    'Your profile is complete—now you can connect with clients on Fixo.',
                    style: AppTextStyles.bodyLarge.copyWith(
                      color: AppColors.onSurfaceVariant,
                      fontSize: 16,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: AppDimensions.spacing32),
                ],
              ),
            ),
          ),
        ],
      ),

      // Updated the Continue button to use the ContinueFloatingButton widget
      floatingActionButton: ContinueFloatingButton(
        onPressed: () {
          Navigator.of(context).popUntil((route) => route.isFirst);
        },
        backgroundColor: AppColors.tradieBlue,
      ),
    );
  }
}
