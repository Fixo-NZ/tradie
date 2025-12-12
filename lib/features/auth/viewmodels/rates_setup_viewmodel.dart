// Rates viewmodel removed — stub kept to preserve API shape if accidentally imported.
import 'package:flutter_riverpod/flutter_riverpod.dart';
<<<<<<< HEAD
import '../services/rates_api_service.dart';

class RatesSetupViewModel extends StateNotifier<RatesSetupState> {
  RatesSetupViewModel() : super(const RatesSetupState());

  void updateChargeMode(int mode) {
    state = state.copyWith(chargeMode: mode);
  }

  void updateHourlyRate(String rate) {
    state = state.copyWith(hourlyRate: rate);
  }

  void updateMinimumHoursString(String time) {
    state = state.copyWith(minimumHoursString: time);
  }

  void updateDescription(String value) {
    state = state.copyWith(description: value);
  }

  void updateAfterHoursFee(String value) {
    state = state.copyWith(afterHoursFee: value);
  }

  void updateCallOutFee(String value) {
    state = state.copyWith(callOutFee: value);
  }

  void toggleAfterHours(bool? value) {
    state = state.copyWith(afterHours: value ?? false);
  }

  void toggleCallOut(bool? value) {
    state = state.copyWith(callOut: value ?? false);
  }

  // Convert "HH:MM" string to integer hours for backend
  int? get minimumHoursInt {
    if (state.minimumHoursString.isEmpty) return null;
    final parts = state.minimumHoursString.split(':');
    final hours = int.tryParse(parts[0]) ?? 0;
    final minutes = int.tryParse(parts[1]) ?? 0;
    return hours + (minutes >= 30 ? 1 : 0); // round up if minutes >= 30
  }

  // Save rates to backend (null-safe & optional fields)
  Future<bool> saveRates() async {
    try {
      final api = RatesApiService();
      final success = await api.saveRates(
        chargeMode: state.chargeMode,
        hourlyRate: state.hourlyRate.isEmpty ? null : state.hourlyRate,
        minimumHours: state.minimumHoursString.isEmpty
            ? null
            : minimumHoursInt,
        afterHours: state.afterHours,
        callOut: state.callOut,
        description: state.description.isEmpty ? null : state.description,
      );
      return success;
    } catch (e) {
      print('Failed to save rates: $e');
      return false;
    }
  }
}
=======
>>>>>>> f92fede8de9f93b9d130c4d8ccb47e1a2de544fd

class RatesSetupState {
  const RatesSetupState();
}

@deprecated
class RatesSetupViewModel extends StateNotifier<RatesSetupState> {
  RatesSetupViewModel() : super(const RatesSetupState()) {
    throw UnimplementedError(
        'RatesSetupViewModel removed — rates feature deprecated in this branch.');
  }
}
