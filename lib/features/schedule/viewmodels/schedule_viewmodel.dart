import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tradie/features/schedule/models/schedule_model.dart';
import 'package:tradie/features/schedule/repositories/schedule_repository.dart';
import '../../../core/network/api_result.dart';
import '../services/websocket_service.dart';

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
    _initWebSocket();
  }

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

  Future<void> cancelEvent(int id) async {
    state = state.copyWith(isLoading: true);

    final result = await _repository.cancelSchedule(id);

    switch (result) {
      case Success<ScheduleModel>():
        final updatedList = state.schedules
            .where((event) => event.id != id)
            .toList();
        state = state.copyWith(isLoading: false, schedules: updatedList);
      case Failure<ScheduleModel>():
        state = state.copyWith(isLoading: false, error: result.message);
    }
  }

  Future<void> rescheduleEvent({
    required int id,
    required DateTime date,
    required DateTime startTime,
    required DateTime endTime,
  }) async {
    state = state.copyWith(isLoading: true);

    final result = await _repository.rescheduleEvent(
      id: id,
      date: date,
      startTime: startTime,
      endTime: endTime,
    );

    switch (result) {
      case Success<ScheduleModel>():
        final updatedList = state.schedules
            .map((event) => event.id == id ? result.data : event)
            .toList();
        state = state.copyWith(isLoading: false, schedules: updatedList);
      case Failure<ScheduleModel>():
        state = state.copyWith(isLoading: false, error: result.message);
    }
  }

  /// Initialize Pusher for real-time updates
  void _initWebSocket() {
    WebSocketService.init(
      url:
          'ws://127.0.0.1:8080/app/schedules', // Update with your Laravel WebSocket URL
      onMessage: (jsonData) {
        if (jsonData['schedule'] != null) {
          final updatedSchedule = ScheduleModel.fromJson(jsonData['schedule']);

          final updatedList = state.schedules.map((schedule) {
            return schedule.id == updatedSchedule.id
                ? updatedSchedule
                : schedule;
          }).toList();

          if (!updatedList.any((s) => s.id == updatedSchedule.id)) {
            updatedList.add(updatedSchedule);
          }

          state = state.copyWith(schedules: updatedList);
        }
      },
    );
  }

  /// Dispose Pusher when not needed
  @override
  void dispose() {
    WebSocketService.disconnect();
    super.dispose();
  }
}

/// Providers
final scheduleRepositoryProvider = Provider<ScheduleRepository>((ref) {
  return ScheduleRepository();
});

final scheduleViewModelProvider =
    StateNotifierProvider<ScheduleViewModel, ScheduleState>((ref) {
      final repository = ref.watch(scheduleRepositoryProvider);
      return ScheduleViewModel(repository);
    });
