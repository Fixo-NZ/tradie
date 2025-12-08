import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/services/push_notification_service.dart';
import '../../schedule/viewmodels/schedule_viewmodel.dart';

class NotificationHandler {
  static WidgetRef? _ref;

  /// Initialize notification handling
  static void initialize(WidgetRef ref) {
    _ref = ref;
    
    // Initialize push notifications with custom handler
    PushNotificationService.initialize(
      onMessageReceived: _handleNotificationReceived,
    );
  }

  /// Handle received notifications
  static void _handleNotificationReceived(Map<String, dynamic> data) {
    if (kDebugMode) {
      print('🔔 Notification received: $data');
    }

    final type = data['type'] as String?;
    
    switch (type) {
      case 'job_reminder':
        _handleJobReminder(data);
        break;
      case 'job_update':
        _handleJobUpdate(data);
        break;
      case 'job_cancelled':
        _handleJobCancelled(data);
        break;
      case 'job_rescheduled':
        _handleJobRescheduled(data);
        break;
      case 'new_job_offer':
        _handleNewJobOffer(data);
        break;
      default:
        if (kDebugMode) {
          print('🤷 Unknown notification type: $type');
        }
    }
  }

  /// Handle job reminder notifications
  static void _handleJobReminder(Map<String, dynamic> data) {
    if (kDebugMode) {
      print('⏰ Job reminder: ${data['job_id']}');
    }

    PushNotificationService.handleJobReminder(data);
    
    // Optionally refresh schedules to ensure latest data
    _refreshSchedules();
  }

  /// Handle job update notifications
  static void _handleJobUpdate(Map<String, dynamic> data) {
    if (kDebugMode) {
      print('🔄 Job update: ${data['job_id']} - ${data['status']}');
    }

    PushNotificationService.handleJobUpdate(data);
    
    // Refresh schedules to show updated status
    _refreshSchedules();
  }

  /// Handle job cancellation notifications
  static void _handleJobCancelled(Map<String, dynamic> data) {
    if (kDebugMode) {
      print('❌ Job cancelled: ${data['job_id']}');
    }

    // Refresh schedules to remove cancelled job
    _refreshSchedules();
  }

  /// Handle job rescheduled notifications
  static void _handleJobRescheduled(Map<String, dynamic> data) {
    if (kDebugMode) {
      print('📅 Job rescheduled: ${data['job_id']}');
    }

    // Refresh schedules to show new times
    _refreshSchedules();
  }

  /// Handle new job offer notifications
  static void _handleNewJobOffer(Map<String, dynamic> data) {
    if (kDebugMode) {
      print('🆕 New job offer: ${data['job_id']}');
    }

    // Refresh schedules to show new job
    _refreshSchedules();
  }

  /// Refresh schedules when notifications are received
  static void _refreshSchedules() {
    if (_ref != null) {
      try {
        final scheduleNotifier = _ref!.read(scheduleViewModelProvider.notifier);
        scheduleNotifier.loadSchedules();
        
        if (kDebugMode) {
          print('🔄 Schedules refreshed due to notification');
        }
      } catch (e) {
        if (kDebugMode) {
          print('❌ Failed to refresh schedules: $e');
        }
      }
    }
  }

  /// Show custom notification dialog (optional)
  static void showCustomNotificationDialog({
    required String title,
    required String message,
    String? actionText,
    VoidCallback? onAction,
  }) {
    // You can implement custom notification UI here
    // For example, show a dialog or snackbar
    if (kDebugMode) {
      print('📱 Custom notification: $title - $message');
    }
  }
}