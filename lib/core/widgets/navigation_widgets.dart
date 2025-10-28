import 'package:flutter/material.dart';
import '../../core/theme/app_dimensions.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';

/// A reusable back button used in AppBar.leading across screens.
class AppBackButton extends StatelessWidget {
  final Color? color;
  const AppBackButton({super.key, this.color});

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: Icon(Icons.arrow_back, color: color ?? Colors.black),
      onPressed: () => Navigator.of(context).maybePop(),
    );
  }
}

/// A consistent Continue button placed on the bottom-right using
/// FloatingActionButton.extended. Use this instead of duplicating
/// Continue button code in each screen.
class ContinueFloatingButton extends StatelessWidget {
  final VoidCallback onPressed;
  final String label;
  final Color backgroundColor;
  final Color foregroundColor;
  // Provide uniform defaults so the button looks consistent across screens.
  final double width;
  final double height;

  const ContinueFloatingButton({
    super.key,
    required this.onPressed,
    this.label = 'Continue',
    this.backgroundColor = AppColors.tradieBlue,
    this.foregroundColor = Colors.white,
    this.width = 130.0,
    this.height = 48.0,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppDimensions.spacing12, right: AppDimensions.paddingLarge),
  child: SizedBox(
  width: width,
  height: height,
        child: FloatingActionButton.extended(
          onPressed: onPressed,
          backgroundColor: backgroundColor,
          foregroundColor: foregroundColor,
          shape: const StadiumBorder(),
          label: Text(label, style: AppTextStyles.buttonLarge.copyWith(color: foregroundColor)),
        ),
      ),
    );
  }
}
