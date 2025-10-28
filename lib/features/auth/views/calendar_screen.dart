import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_dimensions.dart';
import '../../../core/theme/app_text_styles.dart';

class CalendarScreen extends StatelessWidget {
  const CalendarScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Availability Calendar'),
      ),
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: AppDimensions.spacing16),
            Text(
              'Mark specific dates when you’re available.',
              style: AppTextStyles.bodyLarge.copyWith(color: AppColors.onSurfaceVariant),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppDimensions.spacing16),
            Expanded(
              child: Center(
                child: Text(
                  'Calendar UI goes here.',
                  style: AppTextStyles.bodyLarge,
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                // Logic for creating calendar
              },
              child: const Text('Create Calendar'),
            ),
          ],
        ),
      ),
    );
  }
}