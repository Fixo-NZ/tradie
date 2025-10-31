import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_dimensions.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/navigation_widgets.dart';
import 'availability_setup_screen.dart';
import '../viewmodels/skills_viewmodel.dart';
import '../services/skills_api_services.dart';

class SkillsSetupScreen extends ConsumerWidget {
  const SkillsSetupScreen({super.key});

  static const Color kCustomBlue = Color.fromRGBO(9, 12, 155, 1.0);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final viewModel = ref.read(skillsViewModelProvider.notifier);
    final state = ref.watch(skillsViewModelProvider);

    // Controllers for location fields
    final addressController = TextEditingController(text: "123 Test Street");
    final cityController = TextEditingController(text: "San Juan");
    final regionController = TextEditingController(text: "La Union");
    final postalCodeController = TextEditingController(text: "2514");

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
    final success = await viewModel.submitSkills(
      address: addressController.text,
      city: cityController.text,
      region: regionController.text,
      postalCode: postalCodeController.text,
    );

    if (success) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Skills & service area saved successfully!"),
            backgroundColor: Colors.green,
          ),
        );

        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const AvailabilitySetupScreen()),
        );
      }
    } else {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Failed to save skills & service area. Please try again."),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  },
),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(
            horizontal: AppDimensions.paddingLarge,
            vertical: AppDimensions.spacing8,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Progress bar
              LinearProgressIndicator(
                value: 2 / 6,
                minHeight: 4,
                color: kCustomBlue,
                backgroundColor: const Color(0xFFDDE9FF),
              ),
              const SizedBox(height: AppDimensions.spacing16),

              // Title
              Text(
                'Skills & Service Area',
                style: AppTextStyles.headlineSmall.copyWith(
                  color: kCustomBlue,
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: AppDimensions.spacing12),

              // Skill items horizontally scrollable
              SizedBox(
                height: 280,
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Wrap(
                    direction: Axis.vertical,
                    spacing: 12,
                    runSpacing: 12,
                    children: List.generate(state.skills.length, (index) {
                      final skill = state.skills[index];
                      return GestureDetector(
                        onTap: () => viewModel.toggleSkillSelection(index),
                        child: Container(
                          width: 160,
                          height: 130,
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: skill.isSelected
                                  ? kCustomBlue
                                  : AppColors.surfaceVariant,
                              width: skill.isSelected ? 2 : 1,
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Icon(
                                skill.icon,
                                size: 28,
                                color: skill.isSelected
                                    ? kCustomBlue
                                    : AppColors.onSurface,
                              ),
                              const SizedBox(height: 8),
                              Text(
                                skill.title,
                                style: AppTextStyles.titleMedium.copyWith(
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                skill.description,
                                style: AppTextStyles.bodySmall.copyWith(
                                  color: AppColors.onSurfaceVariant,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                      );
                    }),
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // Service Radius
              Text(
                'Service Radius (km)',
                style: AppTextStyles.bodyLarge.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                "Define where you're willing to provide your services",
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 8),
              SliderTheme(
                data: SliderTheme.of(context).copyWith(
                  activeTrackColor: kCustomBlue,
                  inactiveTrackColor: const Color(0xFFDDE9FF),
                  thumbColor: kCustomBlue,
                  trackHeight: 8,
                ),
                child: Slider(
                  value: state.serviceRadius,
                  min: 0,
                  max: 100,
                  onChanged: viewModel.updateServiceRadius,
                ),
              ),
              Align(
                alignment: Alignment.centerRight,
                child: Text(
                  '${state.serviceRadius.round()} km',
                  style: AppTextStyles.titleMedium.copyWith(
                    color: AppColors.onSurface,
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // Location Inputs
              Text(
                'Your Location',
                style: AppTextStyles.bodyLarge.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: addressController,
                decoration: InputDecoration(
                  labelText: 'Address',
                  prefixIcon: const Icon(Icons.location_on),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: cityController,
                decoration: InputDecoration(
                  labelText: 'City',
                  prefixIcon: const Icon(Icons.location_city),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: regionController,
                decoration: InputDecoration(
                  labelText: 'Region',
                  prefixIcon: const Icon(Icons.map),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: postalCodeController,
                decoration: InputDecoration(
                  labelText: 'Postal Code',
                  prefixIcon: const Icon(Icons.local_post_office),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Dummy Map
              Container(
                height: 200,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppColors.surfaceVariant),
                  color: AppColors.surface,
                ),
                clipBehavior: Clip.antiAlias,
                child: Image.asset(
                  'assets/images/map.png',
                  fit: BoxFit.cover,
                ),
              ),

              const SizedBox(height: 80),
            ],
          ),
        ),
      ),
    );
  }
}
