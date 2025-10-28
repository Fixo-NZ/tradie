import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_dimensions.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/navigation_widgets.dart';
import 'calendar_screen.dart';
import 'portfolio_setup_screen.dart';
import '../viewmodels/availability_setup_viewmodel.dart';

class AvailabilitySetupScreen extends ConsumerWidget {
  const AvailabilitySetupScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final viewModel = ref.read(availabilitySetupViewModelProvider.notifier);
    final state = ref.watch(availabilitySetupViewModelProvider);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: const AppBackButton(),
        title: Text(
          'Create Profile',
          style: AppTextStyles.appBarTitle.copyWith(color: Colors.black),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      floatingActionButton: ContinueFloatingButton(
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => const PortfolioSetupScreen()),
          );
        },
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppDimensions.paddingLarge,
            vertical: AppDimensions.spacing8,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              LinearProgressIndicator(
                value: 3 / 6,
                minHeight: 4,
                color: const Color.fromRGBO(9, 12, 155, 1.0),
                backgroundColor: const Color(0xFFDDE9FF)
              ),
              const SizedBox(height: AppDimensions.spacing16),
              Text(
                'Your Availability',
                style: AppTextStyles.headlineSmall.copyWith(
                  color: const Color.fromRGBO(9, 12, 155, 1.0),
                  fontSize: 18,
                ),
              ),
              const SizedBox(height: AppDimensions.spacing12),
              Text(
                'Set your working hours and manage your calendar',
                style: AppTextStyles.bodyLarge,
              ),
              const SizedBox(height: AppDimensions.spacing8),
              // day chips (custom so no check icon is shown)
              // one-line, scrollable row of day boxes
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: List.generate(7, (index) {
                    final labels = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
                    final selected = state.days[index];
                    return Padding(
                      padding: const EdgeInsets.only(right: 6.0),
                      child: GestureDetector(
                        onTap: () => viewModel.toggleDay(index),
                        child: Container(
                          width: 49.5,
                          height: 35,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: selected ? const Color.fromRGBO(9, 12, 155, 1.0) : Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: selected ? const Color.fromRGBO(9, 12, 155, 1.0) : AppColors.surfaceVariant,
                            ),
                          ),
                          child: Text(
                            labels[index],
                            style: selected
                                ? AppTextStyles.bodyLarge.copyWith(color: Colors.white)
                                : AppTextStyles.bodyLarge.copyWith(color: Colors.black87),
                          ),
                        ),
                      ),
                    );
                  }),
                ),
              ),
              const SizedBox(height: AppDimensions.spacing16),
              Text('Working Hours', style: AppTextStyles.bodyLarge),
              const SizedBox(height: AppDimensions.spacing8),
              // Dropdowns for From / To
              Row(
                children: [
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      value: state.fromTime,
                      items: ['08:00 AM', '09:00 AM', '10:00 AM'].map((time) {
                        return DropdownMenuItem(
                          value: time,
                          child: Text(time),
                        );
                      }).toList(),
                      onChanged: viewModel.updateFromTime,
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: Colors.white,
                        contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text('To'),
                  const SizedBox(width: 12),
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      value: state.toTime,
                      items: ['05:00 PM', '06:00 PM', '07:00 PM'].map((time) {
                        return DropdownMenuItem(
                          value: time,
                          child: Text(time),
                        );
                      }).toList(),
                      onChanged: viewModel.updateToTime,
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: Colors.white,
                        contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppDimensions.spacing16),
              // Emergency availability card with checkbox (per mock)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppColors.surfaceVariant),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Checkbox(
                      value: state.emergencyAvailability,
                      activeColor: const Color.fromRGBO(9, 12, 155, 1.0),
                      checkColor: Colors.white,
                      onChanged: (_) => viewModel.toggleEmergencyAvailability(),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Emergency Availability', style: AppTextStyles.titleMedium),
                          const SizedBox(height: 6),
                          Text(
                            'Customers can contact you for urgent jobs outside your regular working hours',
                            style: AppTextStyles.bodySmall.copyWith(color: AppColors.onSurfaceVariant),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppDimensions.spacing20),
              Text('Availability Calendar', style: AppTextStyles.bodyLarge),
              const SizedBox(height: AppDimensions.spacing12),
              Center(
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const CalendarScreen()),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color.fromRGBO(9, 12, 155, 1.0),
                    foregroundColor: Colors.white,
                    shape: const StadiumBorder(),
                  ),
                  child: const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    child: Text('Calendar', style: TextStyle(fontWeight: FontWeight.w600)),
                  ),
                ),
              ),
              const SizedBox(height: AppDimensions.spacing20),
            ],
          ),
        ),
      ),
    );
  }
}
