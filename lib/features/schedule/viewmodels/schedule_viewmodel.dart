import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tradie/features/schedule/models/schedule_model.dart';
import 'package:tradie/features/schedule/repositories/schedule_repository.dart';
import 'package:tradie/features/schedule/services/pusher_service.dart';
import '../../../core/network/api_result.dart';

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
    _initRealtime();
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

// Future<void> cancelEvent(int id) async {
//   state = state.copyWith(isLoading: true);

//   final result = await _repository.cancelSchedule(id);
//   switch (result) {
//     case Success<ScheduleModel>():
//       final updatedList = state.schedules.where((event) => event.id != id).toList();
//       state = state.copyWith(isLoading: false, schedules: updatedList);
//       break;

//     case Failure<ScheduleModel>():
//       state = state.copyWith(isLoading: false, error: result.message);
//       break;
//   }
// }
//   print("🟢 FINAL state.schedules: ${state.schedules.map((e) => e.id).toList()}");
// }

Future<void> cancelEvent(int id) async {
  state = state.copyWith(isLoading: true);

  try {
    final result = await _repository.cancelSchedule(id);

    // DEBUG: log the result
    print('🔴 CANCEL RESPONSE: $result');

    // If the call didn’t throw, remove locally
    final updatedList = state.schedules.where((event) => event.id != id).toList();
    state = state.copyWith(isLoading: false, schedules: updatedList);

    print('🟢 FINAL state.schedules: ${state.schedules.map((e) => e.id).toList()}');
  } catch (e) {
    print('❌ DELETE FAILED: $e');
    state = state.copyWith(isLoading: false, error: e.toString());
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

  void _initRealtime() {
  PusherService.init(
    apiKey: "o3kuufyyhwwte7mwu5fo",
    channel: "schedules",
    onEvent: (jsonData) {
      final eventName = jsonData['event'];

      if (eventName == 'schedule.updated' && jsonData['schedule'] != null) {
        // Update or add the schedule
        final updatedSchedule = ScheduleModel.fromJson(jsonData['schedule']);

        final updatedList = state.schedules.map((event) {
          return event.id == updatedSchedule.id ? updatedSchedule : event;
        }).toList();

        if (!updatedList.any((s) => s.id == updatedSchedule.id)) {
          updatedList.add(updatedSchedule);
        }

        state = state.copyWith(schedules: updatedList);
      }

      if (eventName == 'schedule.deleted' && jsonData['scheduleId'] != null) {
        // Remove the schedule
        final idToRemove = jsonData['scheduleId'] as int;
        final updatedList =
            state.schedules.where((event) => event.id != idToRemove).toList();

        state = state.copyWith(schedules: updatedList);
      }
    },
  );
}



  @override
  void dispose() {
    PusherService.disconnect(channel: "schedules");
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
