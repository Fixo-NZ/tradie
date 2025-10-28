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

      // ✅ Updated Continue Button
      floatingActionButton: ContinueFloatingButton(
        onPressed: () async {
          final viewModelState = ref.read(skillsViewModelProvider);

          // 🧰 Collect selected skills (for now, using index+1 as fake ID)
          final selectedSkills = viewModelState.skills
              .asMap()
              .entries
              .where((e) => e.value.isSelected)
              .map((e) => e.key + 1)
              .toList();

          final serviceRadius = viewModelState.serviceRadius.round();

          // 🗺️ Temporary location data (replace later with real map data)
          final serviceLocation = {
            "address": "123 Test Street",
            "city": "Wellington",
            "region": "Wellington",
            "postal_code": "6011",
            "latitude": -41.2865,
            "longitude": 174.7762
          };

          // ✅ Call the API
          final api = SkillsApiService();
          final success = await api.updateSkillsAndService(
            skillIds: selectedSkills,
            serviceRadius: serviceRadius,
            serviceLocation: serviceLocation,
          );

          if (success) {
            print("✅ Skills & service area saved!");
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text("Saved successfully!")),
            );

            Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const AvailabilitySetupScreen()),
            );
          } else {
            print("❌ Failed to save skills & service area");
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text("Failed to save. Try again.")),
            );
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
              // 🔵 Progress bar
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

              // 🧰 Skill items in two rows, horizontally scrollable
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

              // 📍 Service Radius section
              Text(
                'Service Radius(km)',
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

              // Slider
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

              // 📍 Location
              Text(
                'Your Location',
                style: AppTextStyles.bodyLarge.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              TextFormField(
                decoration: InputDecoration(
                  hintText: 'Search Location...',
                  prefixIcon: const Icon(Icons.search),
                  filled: true,
                  fillColor: Colors.white,
                  contentPadding: const EdgeInsets.symmetric(vertical: 10),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(color: AppColors.surfaceVariant),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // 🗺️ Map
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