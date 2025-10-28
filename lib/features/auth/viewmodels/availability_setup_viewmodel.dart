import 'package:flutter_riverpod/flutter_riverpod.dart';

class AvailabilitySetupState {
  final List<bool> days;
  final String fromTime;
  final String toTime;
  final bool emergencyAvailability;

  AvailabilitySetupState({
    this.days = const [true, true, true, true, true, false, false],
    this.fromTime = '08:00 AM',
    this.toTime = '05:00 PM',
    this.emergencyAvailability = false,
  });

  AvailabilitySetupState copyWith({
    List<bool>? days,
    String? fromTime,
    String? toTime,
    bool? emergencyAvailability,
  }) {
    return AvailabilitySetupState(
      days: days ?? this.days,
      fromTime: fromTime ?? this.fromTime,
      toTime: toTime ?? this.toTime,
      emergencyAvailability: emergencyAvailability ?? this.emergencyAvailability,
    );
  }
}

class AvailabilitySetupViewModel extends StateNotifier<AvailabilitySetupState> {
  AvailabilitySetupViewModel() : super(AvailabilitySetupState());

  void toggleDay(int index) {
    final updatedDays = List<bool>.from(state.days);
    updatedDays[index] = !updatedDays[index];
    state = state.copyWith(days: updatedDays);
  }

  void updateFromTime(String? time) {
    if (time != null) {
      state = state.copyWith(fromTime: time);
    }
  }

  void updateToTime(String? time) {
    if (time != null) {
      state = state.copyWith(toTime: time);
    }
  }

  void toggleEmergencyAvailability() {
    state = state.copyWith(emergencyAvailability: !state.emergencyAvailability);
  }
}

final availabilitySetupViewModelProvider = StateNotifierProvider<AvailabilitySetupViewModel, AvailabilitySetupState>((ref) {
  return AvailabilitySetupViewModel();
});