// Rates viewmodel removed — stub kept to preserve API shape if accidentally imported.
import 'package:flutter_riverpod/flutter_riverpod.dart';

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
