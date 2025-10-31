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

  Future<void> _selectTime(
    BuildContext context,
    WidgetRef ref, {
    required bool isStart,
  }) async {
    final viewModel = ref.read(availabilitySetupViewModelProvider.notifier);
    final initialTime = TimeOfDay.now();

    final pickedTime = await showTimePicker(
      context: context,
      initialTime: initialTime,
      builder: (BuildContext context, Widget? child) {
        return Theme(
          data: Theme.of(context).copyWith(
            dialogTheme: const DialogThemeData(
              backgroundColor: Colors.white, // ✅ fixed type
            ),
            colorScheme: const ColorScheme.light(
              primary: Color.fromRGBO(9, 12, 155, 1.0),
              onSurface: Colors.black,
            ),
          ),
          child: child!,
        );
      },
    );

    // ✅ guard BuildContext after async
    if (!context.mounted) return;

    if (pickedTime != null) {
      final formattedTime = pickedTime.format(context);
      if (isStart) {
        viewModel.setFromTime(formattedTime);
      } else {
        viewModel.setToTime(formattedTime);
      }
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final viewModel = ref.read(availabilitySetupViewModelProvider.notifier);
    final state = ref.watch(availabilitySetupViewModelProvider);

    final labels = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

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
        onPressed: () async {
          final success = await viewModel.saveAvailability();

          if (!context.mounted) return;

          if (success) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text("Availability saved successfully!")),
            );
            if (context.mounted) {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const PortfolioSetupScreen()),
              );
            }
          } else {
            if (context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("Failed to save availability.")),
              );
            }
          }
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
                backgroundColor: const Color(0xFFDDE9FF),
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

              // Days of the week
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: List.generate(7, (index) {
                    final day = labels[index];
                    final selected = state.days.contains(day);

                    return Padding(
                      padding: const EdgeInsets.only(right: 6.0),
                      child: GestureDetector(
                        onTap: () => viewModel.toggleDay(day),
                        child: Container(
                          width: 49.5,
                          height: 35,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: selected
                                ? const Color.fromRGBO(9, 12, 155, 1.0)
                                : Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: selected
                                  ? const Color.fromRGBO(9, 12, 155, 1.0)
                                  : AppColors.surfaceVariant,
                            ),
                          ),
                          child: Text(
                            labels[index],
                            style: selected
                                ? AppTextStyles.bodyLarge
                                    .copyWith(color: Colors.white)
                                : AppTextStyles.bodyLarge
                                    .copyWith(color: Colors.black87),
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

              // From / To
              Row(
                children: [
                  Expanded(
                    child: InkWell(
                      onTap: () => _selectTime(context, ref, isStart: true),
                      child: InputDecorator(
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: Colors.white,
                          contentPadding: const EdgeInsets.symmetric(
                            vertical: 12,
                            horizontal: 12,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: Text(
                          (state.fromTime ?? '').isEmpty
                              ? 'Start Time'
                              : state.fromTime!,
                          style: const TextStyle(color: Colors.black87),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Text('To'),
                  const SizedBox(width: 12),
                  Expanded(
                    child: InkWell(
                      onTap: () => _selectTime(context, ref, isStart: false),
                      child: InputDecorator(
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: Colors.white,
                          contentPadding: const EdgeInsets.symmetric(
                            vertical: 12,
                            horizontal: 12,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: Text(
                          (state.toTime ?? '').isEmpty
                              ? 'End Time'
                              : state.toTime!,
                          style: const TextStyle(color: Colors.black87),
                        ),
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: AppDimensions.spacing16),

              // Emergency Availability
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
                      onChanged: (value) =>
                          viewModel.setEmergency(value ?? false),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Emergency Availability',
                              style: AppTextStyles.titleMedium),
                          const SizedBox(height: 6),
                          Text(
                            'Customers can contact you for urgent jobs outside your regular working hours',
                            style: AppTextStyles.bodySmall
                                .copyWith(color: AppColors.onSurfaceVariant),
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
                    child: Text('Calendar',
                        style: TextStyle(fontWeight: FontWeight.w600)),
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
