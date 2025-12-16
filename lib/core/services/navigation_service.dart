import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter/foundation.dart';

/// Service to handle navigation from notifications and other global contexts
class NavigationService {
  static final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
  static GoRouter? _router;

  /// Initialize the navigation service with the router
  static void initialize(GoRouter router) {
    _router = router;
    if (kDebugMode) {
      print('✅ Navigation service initialized');
    }
  }

  /// Get the current context
  static BuildContext? get currentContext => navigatorKey.currentContext;

  /// Navigate to job details screen
  static Future<void> navigateToJobDetails(String jobId) async {
    try {
      if (kDebugMode) {
        print('🧭 Navigating to job details for job ID: $jobId');
      }

      if (_router == null) {
        if (kDebugMode) {
          print('❌ Router not initialized');
        }
        return;
      }

      // Parse job ID to int
      final eventId = int.tryParse(jobId);
      if (eventId == null) {
        if (kDebugMode) {
          print('❌ Invalid job ID: $jobId');
        }
        return;
      }

      // Navigate to job details with the event ID
      _router!.push('/job-details', extra: eventId);
      
      if (kDebugMode) {
        print('✅ Navigation to job details initiated');
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Navigation error: $e');
      }
    }
  }

  /// Navigate to schedule screen
  static Future<void> navigateToSchedule() async {
    try {
      if (kDebugMode) {
        print('🧭 Navigating to schedule screen');
      }

      if (_router == null) {
        if (kDebugMode) {
          print('❌ Router not initialized');
        }
        return;
      }

      _router!.push('/schedule');
      
      if (kDebugMode) {
        print('✅ Navigation to schedule initiated');
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Navigation error: $e');
      }
    }
  }

  /// Navigate to dashboard
  static Future<void> navigateToDashboard() async {
    try {
      if (kDebugMode) {
        print('🧭 Navigating to dashboard');
      }

      if (_router == null) {
        if (kDebugMode) {
          print('❌ Router not initialized');
        }
        return;
      }

      _router!.go('/dashboard');
      
      if (kDebugMode) {
        print('✅ Navigation to dashboard initiated');
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Navigation error: $e');
      }
    }
  }

  /// Handle notification tap with payload
  static Future<void> handleNotificationTap(Map<String, dynamic> payload) async {
    try {
      if (kDebugMode) {
        print('🔔 Handling notification tap with payload: $payload');
      }

      final notificationType = payload['notification_type'] ?? payload['type'];
      final action = payload['action'];
      final jobId = payload['job_id'];

      switch (notificationType) {
        case 'job_reminder':
        case 'job_reminder_persistent':
          if (action == 'view_job_details' && jobId != null) {
            await navigateToJobDetails(jobId.toString());
          } else {
            // Default to schedule screen if no specific job ID
            await navigateToSchedule();
          }
          break;
        
        case 'job_update':
        case 'schedule_update':
          if (jobId != null) {
            await navigateToJobDetails(jobId.toString());
          } else {
            await navigateToSchedule();
          }
          break;
        
        default:
          // Default navigation to dashboard
          await navigateToDashboard();
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error handling notification tap: $e');
      }
      // Fallback to dashboard
      await navigateToDashboard();
    }
  }

  /// Check if navigation is available
  static bool get isAvailable => _router != null && currentContext != null;
}