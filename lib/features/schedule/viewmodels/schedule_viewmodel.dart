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
    required DateTime startTime,
    required DateTime endTime,
  }) async {
    state = state.copyWith(isLoading: true, error: null);

    if (kDebugMode) {
      print('🔄 Rescheduling event $id');
      print('📅 Start: ${startTime.toIso8601String()}');
      print('📅 End: ${endTime.toIso8601String()}');
    }

    final result = await _repository.rescheduleEvent(
      id: id,
      startTime: startTime,
      endTime: endTime,
    );

    switch (result) {
      case Success<ScheduleModel>():
        final updatedList = state.schedules
            .map((event) => event.id == id ? result.data : event)
            .toList();
        state = state.copyWith(isLoading: false, schedules: updatedList);
        
        if (kDebugMode) {
          print('✅ Schedule rescheduled successfully: ${result.data.id}');
          print('📅 New start: ${result.data.startDateTime}');
          print('📅 New end: ${result.data.endDateTime}');
        }
        
      case Failure<ScheduleModel>():
        state = state.copyWith(isLoading: false, error: result.message);
        
        if (kDebugMode) {
          print('❌ Failed to reschedule: ${result.message}');
        }
    }
  }

  void _initRealtime() {
    // Initialize with the correct channel for job offers
    LaravelEchoService.init(
      channel: "schedule-updates", // Match your backend channel name
      onEvent: (jsonData) {
        final eventName = jsonData['event'];
        debugPrint('📡 Received real-time event: $eventName');
        debugPrint('📡 Full event data: $jsonData');

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
          case 'schedule.displayed':
            _handleScheduleDisplayed(jsonData);
            break;
          case 'schedule.cancelled':
            _handleScheduleCancelled(jsonData);
            break;
          // Job offer events
          case 'job.created':
          case 'job.offer.created':
          case 'JobOfferCreated':
            _handleJobOfferCreated(jsonData);
            break;
          case 'job.updated':
          case 'job.offer.updated':
          case 'JobOfferUpdated':
            _handleJobOfferUpdated(jsonData);
            break;
          default:
            debugPrint('🤷 Unknown event type: $eventName');
            debugPrint('📡 Full event data: $jsonData');
            // Try to handle it as a generic job event
            _handleGenericJobEvent(jsonData);
        }
      },
      onConnectionStateChange: (connectionState) {
        debugPrint('🔄 Laravel Echo connection state: $connectionState');
        // Connection status updated - no additional subscriptions needed
        // since we already subscribe to the correct channel: "schedule-updates"
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
    if (kDebugMode) {
      print('🔄 SCHEDULE UPDATED EVENT RECEIVED!');
      print('📡 Refreshing schedules from API...');
    }
    
    // Simple solution: Just refresh the schedules from the API
    // This avoids JSON parsing issues and ensures data consistency
    loadSchedules();
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

  void _handleScheduleDisplayed(Map<String, dynamic> jsonData) {
    if (kDebugMode) {
      print('🎯 SCHEDULE DISPLAYED EVENT RECEIVED!');
      print('📡 Refreshing schedules from API...');
    }
    
    // Simple solution: Just refresh the schedules from the API
    // This avoids JSON parsing issues and ensures data consistency
    loadSchedules();
  }

  void _handleScheduleCancelled(Map<String, dynamic> jsonData) {
    if (kDebugMode) {
      print('🚫 SCHEDULE CANCELLED EVENT RECEIVED!');
      print('📡 Event data: $jsonData');
    }
    
    try {
      // Extract schedule data from the event
      final eventData = jsonData['data'] ?? jsonData;
      final scheduleData = eventData['schedule'];
      
      if (kDebugMode) {
        print('📋 Schedule data type: ${scheduleData.runtimeType}');
        print('📋 Schedule data: $scheduleData');
      }
      
      if (scheduleData != null && scheduleData is Map<String, dynamic> && scheduleData['id'] != null) {
        // Safely extract the ID
        dynamic rawId = scheduleData['id'];
        int cancelledId;
        
        if (rawId is int) {
          cancelledId = rawId;
        } else if (rawId is String) {
          cancelledId = int.parse(rawId);
        } else {
          throw Exception('Invalid ID type: ${rawId.runtimeType}');
        }
        
        // Remove the cancelled schedule from the list
        final updatedList = state.schedules.where((event) => event.id != cancelledId).toList();
        state = state.copyWith(schedules: updatedList);
        
        if (kDebugMode) {
          print('✅ Schedule cancelled and removed from list: $cancelledId');
          print('📊 Remaining schedules: ${updatedList.length}');
        }
      } else {
        // Fallback: refresh schedules from API
        if (kDebugMode) {
          print('⚠️ Could not extract schedule ID or invalid data structure');
          print('📋 Schedule data is null: ${scheduleData == null}');
          print('📋 Schedule data is Map: ${scheduleData is Map<String, dynamic>}');
          print('📋 Has ID: ${scheduleData != null ? scheduleData['id'] != null : false}');
          print('📡 Refreshing from API instead');
        }
        loadSchedules();
      }
    } catch (e, stackTrace) {
      if (kDebugMode) {
        print('❌ Error handling schedule cancelled: $e');
        print('📚 Stack trace: $stackTrace');
        print('📡 Falling back to API refresh');
      }
      // Fallback: refresh schedules from API
      loadSchedules();
    }
  }

  void _handleJobOfferCreated(Map<String, dynamic> jsonData) {
    try {
      // Job offers might be converted to schedules
      final jobData = jsonData['data'] ?? jsonData;
      
      // If the job offer contains schedule information, add it
      if (jobData['schedule'] != null) {
        final newSchedule = ScheduleModel.fromJson(jobData['schedule']);
        final updatedList = [...state.schedules, newSchedule];
        state = state.copyWith(schedules: updatedList);
      } else {
        // Refresh schedules to get the latest data
        loadSchedules();
      }
    } catch (e) {
      // Fallback: refresh schedules
      loadSchedules();
    }
  }

  void _handleJobOfferUpdated(Map<String, dynamic> jsonData) {
    // For now, just refresh the schedules when job offers are updated
    loadSchedules();
  }

  void _handleGenericJobEvent(Map<String, dynamic> jsonData) {
    // If it contains schedule data, try to handle it
    final eventData = jsonData['data'] ?? jsonData;
    if (eventData['schedules'] != null) {
      _handleScheduleDisplayed(jsonData);
    } else if (eventData['schedule'] != null) {
      _handleScheduleUpdated(jsonData);
    }
  }



  @override
  void dispose() {
    LaravelEchoService.disconnect(channel: "schedule-updates");
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
