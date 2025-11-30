import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_dimensions.dart';
import '../../../core/theme/app_text_styles.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );

    _animation = CurvedAnimation(parent: _controller, curve: Curves.easeInOut);

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
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

          Center(
            child: ScaleTransition(
              scale: _animation,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Image.asset(
                    "assets/logo.png",
                    height: 75,
                  ),
                  const SizedBox(height: AppDimensions.spacing16),
                  Text(
                    'FIXO',
                    style: AppTextStyles.displaySmall.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppColors.onSecondary,
                    ),
                    textAlign: TextAlign.center,
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