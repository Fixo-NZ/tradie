import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class SkillItem {
  final int id; // ✅ Add ID field
  final String title;
  final String description;
  final IconData icon;
  final bool isSelected;

  SkillItem({
    required this.id, // ✅ Required now
    required this.title,
    required this.description,
    required this.icon,
    this.isSelected = false,
  });

  SkillItem copyWith({bool? isSelected}) {
    return SkillItem(
      id: id, // ✅ Preserve the ID
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

  SkillsState({
    required this.skills,
    required this.serviceRadius,
  });

  SkillsState copyWith({
    List<SkillItem>? skills,
    double? serviceRadius,
  }) {
    return SkillsState(
      skills: skills ?? this.skills,
      serviceRadius: serviceRadius ?? this.serviceRadius,
    );
  }
}

class SkillsViewModel extends StateNotifier<SkillsState> {
  SkillsViewModel()
      : super(
          SkillsState(
            skills: [
              SkillItem(
                id: 1,
                title: 'Painting',
                description: 'Interior & exterior painting...',
                icon: Icons.format_paint,
              ),
              SkillItem(
                id: 2,
                title: 'Electrical',
                description: 'Wiring, lighting installation...',
                icon: Icons.flash_on,
              ),
              SkillItem(
                id: 3,
                title: 'Carpentry',
                description: 'Custom furniture, cabinet...',
                icon: Icons.construction,
              ),
              SkillItem(
                id: 4,
                title: 'Pest Control',
                description: 'Termite treatment, rodent...',
                icon: Icons.bug_report,
              ),
              SkillItem(
                id: 5,
                title: 'Plumbing',
                description: 'Pipe repairs, leak fixes...',
                icon: Icons.plumbing,
              ),
              SkillItem(
                id: 6,
                title: 'Cleaning',
                description: 'House and office cleaning...',
                icon: Icons.cleaning_services,
              ),
              SkillItem(
                id: 7,
                title: 'Masonry',
                description: 'Tile setting, bricklaying...',
                icon: Icons.architecture,
              ),
              SkillItem(
                id: 8,
                title: 'Landscaping',
                description: 'Garden and outdoor design...',
                icon: Icons.park,
              ),
              SkillItem(
                id: 9,
                title: 'Repair',
                description: 'Fixing appliances & more...',
                icon: Icons.build,
              ),
              SkillItem(
                id: 10,
                title: 'Aircon Service',
                description: 'Installation & maintenance...',
                icon: Icons.ac_unit,
              ),
              SkillItem(
                id: 11,
                title: 'Locksmith',
                description: 'Door and lock repair...',
                icon: Icons.vpn_key,
              ),
            ],
            serviceRadius: 25.0,
          ),
        );

  void toggleSkillSelection(int index) {
    final updatedSkills = state.skills.asMap().entries.map((entry) {
      int i = entry.key;
      SkillItem skill = entry.value;
      if (i == index) {
        return skill.copyWith(isSelected: !skill.isSelected);
      }
      return skill;
    }).toList();

    state = state.copyWith(skills: updatedSkills);
  }

/*************  ✨ Windsurf Command ⭐  *************/
/*******  ef9a0178-6605-44e1-8725-866ef6aa8a72  *******/
  void updateServiceRadius(double radius) {
    state = state.copyWith(serviceRadius: radius);
  }
}

final skillsViewModelProvider =
    StateNotifierProvider<SkillsViewModel, SkillsState>((ref) {
  return SkillsViewModel();
});
