import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:latlong2/latlong.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_dimensions.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/navigation_widgets.dart';
import '../../../core/widgets/osm_location_map.dart';
import '../../../core/services/geocoding_service.dart';
import 'availability_setup_screen.dart';
import '../viewmodels/skills_viewmodel.dart';


class SkillsSetupScreen extends ConsumerStatefulWidget {
  const SkillsSetupScreen({super.key});

  @override
  ConsumerState<SkillsSetupScreen> createState() => _SkillsSetupScreenState();
}

class _SkillsSetupScreenState extends ConsumerState<SkillsSetupScreen> {
  static const Color kCustomBlue = Color.fromRGBO(9, 12, 155, 1.0);
  
  // Controllers for location fields (default to Auckland, NZ)
  late final TextEditingController addressController;
  late final TextEditingController cityController;
  late final TextEditingController regionController;
  late final TextEditingController postalCodeController;
  
  // Current map position
  LatLng? currentMapPosition;
  
  @override
  void initState() {
    super.initState();
    addressController = TextEditingController(text: "1 Queen Street");
    cityController = TextEditingController(text: "Auckland");
    regionController = TextEditingController(text: "Auckland");
    postalCodeController = TextEditingController(text: "1010");
  }
  
  @override
  void dispose() {
    addressController.dispose();
    cityController.dispose();
    regionController.dispose();
    postalCodeController.dispose();
    super.dispose();
  }

  // Function to geocode address and update map
  Future<void> geocodeAndUpdateMap() async {
    final fullAddress = '${addressController.text}, ${cityController.text}, ${regionController.text}, ${postalCodeController.text}';
    
    if (fullAddress.trim().replaceAll(',', '').trim().isEmpty) return;
    
    final result = await GeocodingService.geocodeAddress(fullAddress);
    if (result != null) {
      setState(() {
        currentMapPosition = LatLng(result['latitude'], result['longitude']);
      });
    }
  }

  // Function to reverse geocode map position and update address fields
  Future<void> reverseGeocodeAndUpdateFields(double latitude, double longitude) async {
    final result = await GeocodingService.reverseGeocode(latitude, longitude);
    if (result != null) {
      setState(() {
        addressController.text = result['address'] ?? '';
        cityController.text = result['city'] ?? '';
        regionController.text = result['region'] ?? '';
        postalCodeController.text = result['postal_code'] ?? '';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
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
      floatingActionButton: ContinueFloatingButton(
  onPressed: () async {
    // Update the address in viewmodel state first
    viewModel.updateAddress(
      address: addressController.text,
      city: cityController.text,
      region: regionController.text,
      postalCode: postalCodeController.text,
    );

    final success = await viewModel.submitSkills();

    if (success) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              "Skills & service area saved successfully!",
              style: TextStyle(color: Colors.black87),
            ),
            backgroundColor: Color(0xFFEEEEEE),
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
                onChanged: (value) => geocodeAndUpdateMap(),
                decoration: InputDecoration(
                  labelText: 'Address',
                  labelStyle: AppTextStyles.bodyLarge.copyWith(
                    color: AppColors.onSurface,
                    fontSize: 16,
                  ),
                  prefixIcon: Icon(Icons.location_on, color: AppColors.onSurfaceVariant),
                  filled: true,
                  fillColor: Colors.white,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(color: Color(0xFFDDDDDD)),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(color: Color(0xFFDDDDDD)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(color: kCustomBlue),
                  ),
                ),
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.onSurface,
                ),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: cityController,
                onChanged: (value) => geocodeAndUpdateMap(),
                decoration: InputDecoration(
                  labelText: 'City',
                  labelStyle: AppTextStyles.bodyLarge.copyWith(
                    color: AppColors.onSurface,
                    fontSize: 16,
                  ),
                  prefixIcon: Icon(Icons.location_city, color: AppColors.onSurfaceVariant),
                  filled: true,
                  fillColor: Colors.white,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(color: Color(0xFFDDDDDD)),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(color: Color(0xFFDDDDDD)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(color: kCustomBlue),
                  ),
                ),
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.onSurface,
                ),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: regionController,
                onChanged: (value) => geocodeAndUpdateMap(),
                decoration: InputDecoration(
                  labelText: 'Region',
                  labelStyle: AppTextStyles.bodyLarge.copyWith(
                    color: AppColors.onSurface,
                    fontSize: 16,
                  ),
                  prefixIcon: Icon(Icons.map, color: AppColors.onSurfaceVariant),
                  filled: true,
                  fillColor: Colors.white,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(color: Color(0xFFDDDDDD)),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(color: Color(0xFFDDDDDD)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(color: kCustomBlue),
                  ),
                ),
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.onSurface,
                ),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: postalCodeController,
                onChanged: (value) => geocodeAndUpdateMap(),
                decoration: InputDecoration(
                  labelText: 'Postal Code',
                  labelStyle: AppTextStyles.bodyLarge.copyWith(
                    color: AppColors.onSurface,
                    fontSize: 16,
                  ),
                  prefixIcon: Icon(Icons.local_post_office, color: AppColors.onSurfaceVariant),
                  filled: true,
                  fillColor: Colors.white,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(color: Color(0xFFDDDDDD)),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(color: Color(0xFFDDDDDD)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(color: kCustomBlue),
                  ),
                ),
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.onSurface,
                ),
              ),

              const SizedBox(height: 16),

              // Interactive OSM Map — tap to set your service location
              SizedBox(
                child: OSMLocationMap(
                  initialPosition: currentMapPosition,
                  onLocationChanged: reverseGeocodeAndUpdateFields,
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
