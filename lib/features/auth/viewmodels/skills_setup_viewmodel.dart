import 'package:flutter_riverpod/flutter_riverpod.dart';

class SkillItem {
  final String title;
  final String description;
  final bool isSelected;

  SkillItem({
    required this.title,
    required this.description,
    this.isSelected = false,
  });

  SkillItem copyWith({bool? isSelected}) {
    return SkillItem(
      title: title,
      description: description,
      isSelected: isSelected ?? this.isSelected,
    );
  }
}

class SkillsSetupState {
  final List<SkillItem> skills;
  final double serviceRadius;

  SkillsSetupState({
    this.skills = const [],
    this.serviceRadius = 25.0,
  });

  SkillsSetupState copyWith({
    List<SkillItem>? skills,
    double? serviceRadius,
  }) {
    return SkillsSetupState(
      skills: skills ?? this.skills,
      serviceRadius: serviceRadius ?? this.serviceRadius,
    );
  }
}

class SkillsSetupViewModel extends StateNotifier<SkillsSetupState> {
  SkillsSetupViewModel()
      : super(SkillsSetupState(
          skills: [
            SkillItem(title: 'Painting', description: 'Interior & exterior painting...'),
            SkillItem(title: 'Electrical', description: 'Wiring, lighting installation...'),
            SkillItem(title: 'Carpentry', description: 'Custom furniture, cabinet...'),
            SkillItem(title: 'Pest Control', description: 'Termite treatment, rodent...'),
            SkillItem(title: 'Plumbing', description: 'Pipes, leaks, and repairs...'),
            SkillItem(title: 'Cleaning', description: 'Residential & office cleaning...'),
          ],
        ));

  void toggleSkillSelection(int index) {
    final updatedSkills = state.skills.map((skill) {
      if (state.skills.indexOf(skill) == index) {
        return skill.copyWith(isSelected: !skill.isSelected);
      }
      return skill;
    }).toList();

    state = state.copyWith(skills: updatedSkills);
  }

  void updateServiceRadius(double radius) {
    state = state.copyWith(serviceRadius: radius);
  }
}

final skillsSetupViewModelProvider = StateNotifierProvider<SkillsSetupViewModel, SkillsSetupState>((ref) {
  return SkillsSetupViewModel();
});