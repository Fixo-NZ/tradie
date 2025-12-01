import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tradie/features/schedule/models/schedule_model.dart';
import 'package:tradie/features/schedule/repositories/schedule_repository.dart';
import 'package:tradie/features/schedule/services/echo_service.dart';
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
    if (kDebugMode) {
      print('🔴 CANCEL RESPONSE: $result');
    }

    // If the call didn’t throw, remove locally
    final updatedList = state.schedules.where((event) => event.id != id).toList();
    state = state.copyWith(isLoading: false, schedules: updatedList);

    if (kDebugMode) {
      print('🟢 FINAL state.schedules: ${state.schedules.map((e) => e.id).toList()}');
    }
  } catch (e) {
    if (kDebugMode) {
      print('❌ DELETE FAILED: $e');
    }
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
    LaravelEchoService.init(
      channel: "schedules",
      onEvent: (jsonData) {
        final eventName = jsonData['event'];
        debugPrint('📡 Received real-time event: $eventName');

        switch (eventName) {
          case 'schedule.created':
            _handleScheduleCreated(jsonData);
            break;
          case 'schedule.updated':
            _handleScheduleUpdated(jsonData);
            break;
          case 'schedule.deleted':
            _handleScheduleDeleted(jsonData);
            break;
          case 'schedule.rescheduled':
            _handleScheduleRescheduled(jsonData);
            break;
          default:
            debugPrint('🤷 Unknown event type: $eventName');
        }
      },
      onConnectionStateChange: (connectionState) {
        debugPrint('🔄 Laravel Echo connection state: $connectionState');
        // You could update UI to show connection status
      },
    );
  }

  void _handleScheduleCreated(Map<String, dynamic> jsonData) {
    if (jsonData['schedule'] != null) {
      try {
        final newSchedule = ScheduleModel.fromJson(jsonData['schedule']);
        final updatedList = [...state.schedules, newSchedule];
        state = state.copyWith(schedules: updatedList);
        debugPrint('✅ Schedule created: ${newSchedule.id}');
      } catch (e) {
        debugPrint('❌ Error handling schedule created: $e');
      }
    }
  }

  void _handleScheduleUpdated(Map<String, dynamic> jsonData) {
    if (jsonData['schedule'] != null) {
      try {
        final updatedSchedule = ScheduleModel.fromJson(jsonData['schedule']);
        final updatedList = state.schedules.map((event) {
          return event.id == updatedSchedule.id ? updatedSchedule : event;
        }).toList();

        // Add if not exists (in case we missed the created event)
        if (!updatedList.any((s) => s.id == updatedSchedule.id)) {
          updatedList.add(updatedSchedule);
        }

        state = state.copyWith(schedules: updatedList);
        debugPrint('✅ Schedule updated: ${updatedSchedule.id}');
      } catch (e) {
        debugPrint('❌ Error handling schedule updated: $e');
      }
    }
  }

  void _handleScheduleDeleted(Map<String, dynamic> jsonData) {
    final scheduleId = jsonData['scheduleId'] ?? jsonData['id'];
    if (scheduleId != null) {
      try {
        final idToRemove = scheduleId is int ? scheduleId : int.parse(scheduleId.toString());
        final updatedList = state.schedules.where((event) => event.id != idToRemove).toList();
        state = state.copyWith(schedules: updatedList);
        debugPrint('✅ Schedule deleted: $idToRemove');
      } catch (e) {
        debugPrint('❌ Error handling schedule deleted: $e');
      }
    }
  }

  void _handleScheduleRescheduled(Map<String, dynamic> jsonData) {
    // Handle rescheduled events (same as updated for now)
    _handleScheduleUpdated(jsonData);
  }



  @override
  void dispose() {
    LaravelEchoService.disconnect(channel: "schedules");
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
