import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/network/api_result.dart';
import '../models/schedule_model.dart';
import '../repositories/schedule_repository.dart';

class ScheduleState {
  final bool isLoading;
  final List<ScheduleModel> schedules;
  final String? error;

  const ScheduleState({
    this.isLoading = false,
    this.schedules = const [],
    this.error,
  });

  ScheduleState copyWith({
    bool? isLoading,
    List<ScheduleModel>? schedules,
    String? error,
  }) {
    return ScheduleState(
      isLoading: isLoading ?? this.isLoading,
      schedules: schedules ?? this.schedules,
      error: error,
    );
  }
}

class ScheduleViewModel extends StateNotifier<ScheduleState> {
  final ScheduleRepository _repository;

  ScheduleViewModel(this._repository) : super(const ScheduleState()) {
    loadSchedules();
  }

  // Future<void> loadSchedules() async {
  //   state = state.copyWith(isLoading: true, error: null);

  //   final result = await _repository.getSchedules();
  //   switch (result) {
  //     case Success<List<ScheduleModel>>():
  //       state = state.copyWith(isLoading: false, schedules: result.data);
  //     case Failure<List<ScheduleModel>>():
  //       state = state.copyWith(isLoading: false, error: result.message);
  //   }
  // }

  Future<void> loadSchedules() async {
  debugPrint('🚀 loadSchedules() CALLED');
  state = state.copyWith(isLoading: true, error: null);

  final result = await _repository.getSchedules();
  debugPrint('📡 loadSchedules() result: $result');

  switch (result) {
    case Success<List<ScheduleModel>>():
      debugPrint('✅ Loaded ${result.data.length} schedules');
      state = state.copyWith(isLoading: false, schedules: result.data);
    case Failure<List<ScheduleModel>>():
      debugPrint('❌ Failed to load schedules: ${result.message}');
      state = state.copyWith(isLoading: false, error: result.message);
  }
}
}

final scheduleRepositoryProvider = Provider<ScheduleRepository>((ref) {
  return ScheduleRepository();
});

final scheduleViewModelProvider =
    StateNotifierProvider<ScheduleViewModel, ScheduleState>((ref) {
  final repository = ref.watch(scheduleRepositoryProvider);
  return ScheduleViewModel(repository);
});
