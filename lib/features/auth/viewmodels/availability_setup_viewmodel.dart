import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/availability_api_service.dart';

class AvailabilitySetupState {
  final bool isLoading;
  final String? errorMessage;
  final List<String> days;
  final String? fromTime;
  final String? toTime;
  final bool emergencyAvailability;
  final bool success;

  const AvailabilitySetupState({
    this.isLoading = false,
    this.errorMessage,
    this.days = const [],
    this.fromTime,
    this.toTime,
    this.emergencyAvailability = false,
    this.success = false,
  });

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

final availabilitySetupViewModelProvider =
    StateNotifierProvider<AvailabilitySetupViewModel, AvailabilitySetupState>(
  (ref) => AvailabilitySetupViewModel(),
);

class AvailabilitySetupViewModel extends StateNotifier<AvailabilitySetupState> {
  AvailabilitySetupViewModel() : super(const AvailabilitySetupState());

  final _api = AvailabilityApiService();

  void toggleDay(String day) {
    final updated = List<String>.from(state.days);
    if (updated.contains(day)) {
      updated.remove(day);
    } else {
      updated.add(day);
    }
    state = state.copyWith(days: updated);
  }

  void setFromTime(String time) => state = state.copyWith(fromTime: time);
  void setToTime(String time) => state = state.copyWith(toTime: time);
  void setEmergency(bool value) =>
      state = state.copyWith(emergencyAvailability: value);

/*************  ✨ Windsurf Command ⭐  *************/
  /// Save the current availability settings to the server.
  ///
  /// [selectedDays] are the days that are currently selected.
  /// [fromTime] is the time at which the availability starts.
  /// [toTime] is the time at which the availability ends.
  /// [emergencyAvailable] is whether emergency availability is enabled.
/*******  cfa5b43b-11e5-4a51-b354-c6c46bd6ce6b  *******/
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
