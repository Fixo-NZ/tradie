import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/skills_api_services.dart';

class SkillItem {
  final int id;
  final String title;
  final String description;
  final IconData icon;
  final bool isSelected;

  SkillItem({
    required this.id,
    required this.title,
    required this.description,
    required this.icon,
    this.isSelected = false,
  });

  SkillItem copyWith({bool? isSelected}) {
    return SkillItem(
      id: id,
      title: title,
      description: description,
      icon: icon,
      isSelected: isSelected ?? this.isSelected,
    );
  }
}

class SkillsState {
  final List<SkillItem> skills;
  final double serviceRadius;
  final bool isLoading;
  final String? errorMessage;

  // ⭐ NEW: store map coordinates
  final double latitude;
  final double longitude;

  SkillsState({
    required this.skills,
    required this.serviceRadius,
    this.isLoading = false,
    this.errorMessage,
    this.latitude = 0.0,
    this.longitude = 0.0,
  });

  SkillsState copyWith({
    List<SkillItem>? skills,
    double? serviceRadius,
    bool? isLoading,
    String? errorMessage,
    double? latitude,
    double? longitude,
  }) {
    return SkillsState(
      skills: skills ?? this.skills,
      serviceRadius: serviceRadius ?? this.serviceRadius,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
    );
  }
}

class SkillsViewModel extends StateNotifier<SkillsState> {
  final _api = SkillsApiService();

  SkillsViewModel()
      : super(
          SkillsState(
            skills: [
              SkillItem(id: 1, title: 'Painting', description: 'Interior & exterior painting...', icon: Icons.format_paint),
              SkillItem(id: 2, title: 'Electrical', description: 'Wiring, lighting installation...', icon: Icons.flash_on),
              SkillItem(id: 3, title: 'Carpentry', description: 'Custom furniture, cabinet...', icon: Icons.construction),
              SkillItem(id: 4, title: 'Pest Control', description: 'Termite treatment, rodent...', icon: Icons.bug_report),
              SkillItem(id: 5, title: 'Plumbing', description: 'Pipe repairs, leak fixes...', icon: Icons.plumbing),
              SkillItem(id: 6, title: 'Cleaning', description: 'House and office cleaning...', icon: Icons.cleaning_services),
              SkillItem(id: 7, title: 'Masonry', description: 'Tile setting, bricklaying...', icon: Icons.architecture),
              SkillItem(id: 8, title: 'Landscaping', description: 'Garden and outdoor design...', icon: Icons.park),
              SkillItem(id: 9, title: 'Repair', description: 'Fixing appliances & more...', icon: Icons.build),
              SkillItem(id: 10, title: 'Aircon Service', description: 'Installation & maintenance...', icon: Icons.ac_unit),
              SkillItem(id: 11, title: 'Locksmith', description: 'Door and lock repair...', icon: Icons.vpn_key),
            ],
            serviceRadius: 25.0,
          ),
        );

  // -------------------------------------------------------------
  // SELECT SKILLS
  // -------------------------------------------------------------
  void toggleSkillSelection(int index) {
    final updatedSkills = state.skills
        .asMap()
        .entries
        .map((entry) => entry.key == index
            ? entry.value.copyWith(isSelected: !entry.value.isSelected)
            : entry.value)
        .toList();

    state = state.copyWith(skills: updatedSkills);
  }

  // -------------------------------------------------------------
  // UPDATE SERVICE RADIUS
  // -------------------------------------------------------------
  void updateServiceRadius(double radius) {
    state = state.copyWith(serviceRadius: radius);
  }

  // -------------------------------------------------------------
  // ⭐ NEW: UPDATE MAP PIN LOCATION
  // -------------------------------------------------------------
  void updateSelectedLocation(double latitude, double longitude) {
    state = state.copyWith(
      latitude: latitude,
      longitude: longitude,
    );

    print("📍 Updated location: $latitude, $longitude");
  }

  // -------------------------------------------------------------
  // SUBMIT DATA TO API
  // -------------------------------------------------------------
  Future<bool> submitSkills({
    required String address,
    required String city,
    required String region,
    required String postalCode,
  }) async {
    state = state.copyWith(isLoading: true, errorMessage: null);

    final selectedSkillIds =
        state.skills.where((s) => s.isSelected).map((s) => s.id).toList();

    print("🟢 Selected skills (before API): $selectedSkillIds");

    final serviceLocation = {
      "address": address,
      "city": city,
      "region": region,
      "postal_code": postalCode,

      // ⭐ Use REAL map coordinates chosen by the user
      "latitude": state.latitude,
      "longitude": state.longitude,
    };

    final result = await _api.updateSkillsAndService(
      skills: selectedSkillIds,
      serviceRadius: state.serviceRadius.toInt(),
      serviceLocation: serviceLocation,
    );

    final success = result['success'] == true;
    state = state.copyWith(isLoading: false);

    return success;
  }
}

final skillsViewModelProvider =
    StateNotifierProvider<SkillsViewModel, SkillsState>((ref) {
  return SkillsViewModel();
});
