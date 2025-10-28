import 'package:flutter_riverpod/flutter_riverpod.dart';

class DoneViewModel extends StateNotifier<DoneState> {
  DoneViewModel() : super(DoneState());

  void updateSelectedTab(int index) {
    state = state.copyWith(selectedTabIndex: index);
  }
}

class DoneState {
  final int selectedTabIndex;

  DoneState({this.selectedTabIndex = 0});

  DoneState copyWith({int? selectedTabIndex}) {
    return DoneState(
      selectedTabIndex: selectedTabIndex ?? this.selectedTabIndex,
    );
  }
}