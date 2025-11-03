import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/availability_api_service.dart';

class AvailabilitySetupState {
  final bool isLoading; // Indicates if data is being loaded
  final String? errorMessage; // Stores any error message
  final List<String> days; // List of selected available days
  final String? fromTime; // Start time of availability
  final String? toTime; // End time of availability
  final bool emergencyAvailability; // If emergency service is available
  final bool success; // Indicates if the save operation was successful

  const AvailabilitySetupState({
    this.isLoading = false,
    this.errorMessage,
    this.days = const [],
    this.fromTime,
    this.toTime,
    this.emergencyAvailability = false,
    this.success = false,
  });

  // Creates a copy of the current state with updated values
  AvailabilitySetupState copyWith({
    bool? isLoading,
    String? errorMessage,
    List<String>? days,
    String? fromTime,
    String? toTime,
    bool? emergencyAvailability,
    bool? success,
  }) {
    return AvailabilitySetupState(
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage ?? this.errorMessage,
      days: days ?? this.days,
      fromTime: fromTime ?? this.fromTime,
      toTime: toTime ?? this.toTime,
      emergencyAvailability:
          emergencyAvailability ?? this.emergencyAvailability,
      success: success ?? this.success,
    );
  }
}

// Provides access to the AvailabilitySetupViewModel for Riverpod state management
final availabilitySetupViewModelProvider =
    StateNotifierProvider<AvailabilitySetupViewModel, AvailabilitySetupState>(
  (ref) => AvailabilitySetupViewModel(),
);

// Handles the logic and state changes for Availability Setup
class AvailabilitySetupViewModel extends StateNotifier<AvailabilitySetupState> {
  AvailabilitySetupViewModel() : super(const AvailabilitySetupState());

  final _api = AvailabilityApiService();

  // Toggles (adds/removes) a selected day in the availability list
  void toggleDay(String day) {
    final updated = List<String>.from(state.days);
    if (updated.contains(day)) {
      updated.remove(day);
    } else {
      updated.add(day);
    }
    state = state.copyWith(days: updated);
  }

  // Sets the start time of availability
  void setFromTime(String time) => state = state.copyWith(fromTime: time);

  // Sets the end time of availability
  void setToTime(String time) => state = state.copyWith(toTime: time);

  // Enables or disables emergency availability
  void setEmergency(bool value) =>
      state = state.copyWith(emergencyAvailability: value);

  // Saves the selected availability settings to the backend API
  Future<bool> saveAvailability() async {
    final selectedDays = state.days;

    return await _api.updateAvailability(
      days: selectedDays,
      fromTime: state.fromTime,
      toTime: state.toTime,
      emergencyAvailable: state.emergencyAvailability,
    );
  }
}
