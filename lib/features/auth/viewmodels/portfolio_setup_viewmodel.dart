import 'package:flutter_riverpod/flutter_riverpod.dart';

class PortfolioSetupViewModel extends StateNotifier<List<String>> {
  PortfolioSetupViewModel() : super([]);

  void addImage(String imagePath) {
    state = [...state, imagePath];
  }

  void removeImage(int index) {
    if (index >= 0 && index < state.length) {
      final updatedList = [...state]..removeAt(index);
      state = updatedList;
    }
  }
}