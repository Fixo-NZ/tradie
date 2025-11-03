import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/theme/app_dimensions.dart';
import '../../../core/widgets/navigation_widgets.dart'; 

class ConfirmationScreen extends StatelessWidget {
  const ConfirmationScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,

      // The Stack allows us to place widgets on top of each other
      body: Stack(
        children: [
          //  Background image placed at the bottom
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Image.asset(
              'assets/images/wave.png', // Background wave image
              fit: BoxFit.cover, // Covers the screen width
            ),
          ),

          //  Main content displayed above the background
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppDimensions.paddingLarge),
              child: Column(
                mainAxisAlignment: MainAxisAlignment
                    .center, 
                crossAxisAlignment: CrossAxisAlignment
                    .center, 
                children: [

                  Text(
                    'Your profile is all set!',
                    style: AppTextStyles.headlineMedium.copyWith(
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                      fontSize: 28, // Larger title for emphasis
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: AppDimensions.spacing24),

                  // 🎉 Confirmation Image (like a checkmark or confetti)
                  Image.asset(
                    'assets/images/Confirm.png', // ✅ Ensure this file is available in your assets folder
                    width: 200,
                    height: 200,
                  ),
                  const SizedBox(height: AppDimensions.spacing24),

                  // 📝 Subtitle text to give more context
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

      //  Floating Continue button at the bottom right
      floatingActionButton: ContinueFloatingButton(
        onPressed: () {
        
          Navigator.of(context).popUntil((route) => route.isFirst);
        },
        backgroundColor: AppColors.tradieBlue,
      ),
    );
  }
}
