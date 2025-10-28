import 'package:flutter_riverpod/flutter_riverpod.dart';

class RatesSetupViewModel extends StateNotifier<RatesSetupState> {
  RatesSetupViewModel() : super(RatesSetupState());

  void updateChargeMode(int mode) {
    state = state.copyWith(chargeMode: mode);
  }

  void updateHourlyRate(String rate) {
    state = state.copyWith(hourlyRate: rate);
  }

  void updateMinimumHours(int hours) {
    state = state.copyWith(minimumHours: hours);
  }

  void toggleAfterHours(bool? value) {
    state = state.copyWith(afterHours: value ?? false);
  }

  void toggleCallOut(bool? value) {
    state = state.copyWith(callOut: value ?? false);
  }
}

class RatesSetupState {
  final int chargeMode;
  final String hourlyRate;
  final int minimumHours;
  final bool afterHours;
  final bool callOut;

  RatesSetupState({
    this.chargeMode = 0,
    this.hourlyRate = '',
    this.minimumHours = 1,
    this.afterHours = false,
    this.callOut = false,
  });

  RatesSetupState copyWith({
    int? chargeMode,
    String? hourlyRate,
    int? minimumHours,
    bool? afterHours,
    bool? callOut,
  }) {
    return RatesSetupState(
      chargeMode: chargeMode ?? this.chargeMode,
      hourlyRate: hourlyRate ?? this.hourlyRate,
      minimumHours: minimumHours ?? this.minimumHours,
      afterHours: afterHours ?? this.afterHours,
      callOut: callOut ?? this.callOut,
    );
  }
}