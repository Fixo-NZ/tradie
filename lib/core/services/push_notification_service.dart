import 'dart:convert';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import '../network/dio_client.dart';
import 'navigation_service.dart';

class PushNotificationService {
  static final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  static final FlutterLocalNotificationsPlugin _localNotifications = FlutterLocalNotificationsPlugin();
  
  static String? _fcmToken;
  static Function(Map<String, dynamic>)? _onMessageReceived;
  static final Set<String> _shownNotifications = {}; // Track shown notifications

  /// Initialize push notifications
  static Future<void> initialize({
    Function(Map<String, dynamic>)? onMessageReceived,
  }) async {
    _onMessageReceived = onMessageReceived;
    
    try {
      if (kDebugMode) {
        print('🚀 Initializing push notifications...');
      }
      
      // Enable auto-initialization to speed up FCM connection
      await _firebaseMessaging.setAutoInitEnabled(true);
      
      // Request permission for notifications with high priority
      NotificationSettings settings = await _firebaseMessaging.requestPermission(
        alert: true,
        announcement: false,
        badge: true,
        carPlay: false,
        criticalAlert: true, // Enable critical alerts for faster delivery
        provisional: false,
        sound: true,
      );

      if (settings.authorizationStatus == AuthorizationStatus.authorized) {
        if (kDebugMode) {
          print('✅ Push notification permission granted');
        }
      } else {
        if (kDebugMode) {
          print('❌ Push notification permission denied');
        }
        return;
      }

      // Initialize local notifications
      await _initializeLocalNotifications();

      // Get FCM token with retry mechanism
      _fcmToken = await _getFCMTokenWithRetry();
      if (kDebugMode) {
        print('📱 FCM Token: $_fcmToken');
      }

      // Warm up FCM connection by subscribing to a topic
      await _warmUpFCMConnection();

      // Listen for token refresh
      _firebaseMessaging.onTokenRefresh.listen((token) {
        _fcmToken = token;
        if (kDebugMode) {
          print('🔄 FCM Token refreshed: $token');
        }
        _sendTokenToBackend(token);
      });

      // Handle foreground messages
      FirebaseMessaging.onMessage.listen(_handleForegroundMessage);

      // Handle background messages
      FirebaseMessaging.onBackgroundMessage(_handleBackgroundMessage);

      // Handle notification taps when app is terminated
      FirebaseMessaging.onMessageOpenedApp.listen(_handleFCMNotificationTap);

      // Check if app was opened from a notification
      RemoteMessage? initialMessage = await _firebaseMessaging.getInitialMessage();
      if (initialMessage != null) {
        _handleFCMNotificationTap(initialMessage);
      }

      // Send token to backend
      if (_fcmToken != null) {
        await _sendTokenToBackend(_fcmToken!);
      }

    } catch (e) {
      if (kDebugMode) {
        print('❌ Failed to initialize push notifications: $e');
      }
    }
  }

  /// Initialize local notifications for foreground display
  static Future<void> _initializeLocalNotifications() async {
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const DarwinInitializationSettings initializationSettingsIOS =
        DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const InitializationSettings initializationSettings =
        InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsIOS,
    );

    await _localNotifications.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: (NotificationResponse response) {
        if (response.payload != null) {
          final data = jsonDecode(response.payload!);
          
          if (kDebugMode) {
            print('🔔 Notification tapped with payload: $data');
            print('🔔 Action ID: ${response.actionId}');
          }
          
          // Handle notification tap navigation
          _handleLocalNotificationTap(data, response.actionId);
          
          // Don't call _onMessageReceived for notification taps to prevent re-showing notifications
          // _onMessageReceived?.call(data); // Commented out to prevent notification loop
        }
      },
    );

    // Create high-priority notification channel for faster delivery
    await _createHighPriorityNotificationChannel();
  }

  /// Create high-priority notification channel for Android
  static Future<void> _createHighPriorityNotificationChannel() async {
    // High priority channel
    const AndroidNotificationChannel highPriorityChannel = AndroidNotificationChannel(
      'job_reminders_high_priority',
      'Job Reminders (High Priority)',
      description: 'High priority notifications for job reminders',
      importance: Importance.max,
      playSound: true,
      enableVibration: true,
      enableLights: true,
      ledColor: Color.fromARGB(255, 255, 165, 0),
      showBadge: true,
    );

    // Persistent channel for job reminders that don't auto-dismiss
    const AndroidNotificationChannel persistentChannel = AndroidNotificationChannel(
      'job_reminders_persistent',
      'Job Reminders (Persistent)',
      description: 'Persistent job reminder notifications that stay until dismissed',
      importance: Importance.max,
      playSound: true,
      enableVibration: true,
      enableLights: true,
      ledColor: Color.fromARGB(255, 255, 165, 0),
      showBadge: true,
    );

    final androidPlugin = _localNotifications
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();

    await androidPlugin?.createNotificationChannel(highPriorityChannel);
    await androidPlugin?.createNotificationChannel(persistentChannel);

    if (kDebugMode) {
      print('✅ High-priority and persistent notification channels created');
    }
  }

  /// Handle foreground messages
  static Future<void> _handleForegroundMessage(RemoteMessage message) async {
    if (kDebugMode) {
      print('📱 Foreground message received: ${message.notification?.title}');
      print('📱 Message data: ${message.data}');
    }

    // Check if this is a job reminder - if so, don't show generic notification
    final messageType = message.data['type'];
    if (messageType == 'job_reminder') {
      if (kDebugMode) {
        print('🔔 Job reminder detected - skipping generic notification');
      }
      // Only call the custom handler, don't show generic notification
      _onMessageReceived?.call(message.data);
      return;
    }

    // Show local notification when app is in foreground (for non-job-reminder messages)
    await _showLocalNotification(message);

    // Call custom handler
    _onMessageReceived?.call(message.data);
  }

  /// Handle background messages (must be top-level function)
  static Future<void> _handleBackgroundMessage(RemoteMessage message) async {
    if (kDebugMode) {
      print('📱 Background message received: ${message.notification?.title}');
    }
  }

  /// Handle notification tap from FCM
  static void _handleFCMNotificationTap(RemoteMessage message) {
    if (kDebugMode) {
      print('📱 FCM Notification tapped: ${message.data}');
    }

    // Handle navigation for FCM notifications
    NavigationService.handleNotificationTap(message.data);
    
    _onMessageReceived?.call(message.data);
  }

  /// Handle local notification tap
  static void _handleLocalNotificationTap(Map<String, dynamic> payload, String? actionId) {
    if (kDebugMode) {
      print('🔔 Local notification tapped');
      print('📋 Payload: $payload');
      print('🎯 Action ID: $actionId');
    }

    // Get notification ID for dismissal
    final jobId = payload['job_id'];
    final notificationId = int.tryParse(jobId?.toString() ?? '') ?? DateTime.now().millisecondsSinceEpoch;

    // Handle different action buttons
    switch (actionId) {
      case 'view_job':
        if (kDebugMode) {
          print('👁️ View Job action tapped');
        }
        NavigationService.handleNotificationTap(payload);
        break;
      case 'dismiss':
        if (kDebugMode) {
          print('❌ Dismiss action tapped - dismissing notification');
        }
        // Just dismiss, no navigation
        _dismissNotification(notificationId);
        break;
      default:
        // Default tap (not an action button)
        if (kDebugMode) {
          print('📱 Default notification tap - navigating and dismissing notification');
        }
        NavigationService.handleNotificationTap(payload);
        // Dismiss the notification after a short delay to ensure navigation completes
        Future.delayed(const Duration(milliseconds: 500), () {
          _dismissNotification(notificationId);
        });
        break;
    }
  }

  /// Show local notification
  static Future<void> _showLocalNotification(RemoteMessage message) async {
    const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      'job_reminders',
      'Job Reminders',
      channelDescription: 'Notifications for upcoming jobs and updates',
      importance: Importance.max,
      priority: Priority.max,
      showWhen: true,
      enableVibration: true,
      playSound: true,
      visibility: NotificationVisibility.public,
      // Enable heads-up notification (pop-up)
      fullScreenIntent: true,
      category: AndroidNotificationCategory.message,
    );

    const DarwinNotificationDetails iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
      interruptionLevel: InterruptionLevel.timeSensitive,
    );

    const NotificationDetails platformDetails = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _localNotifications.show(
      message.hashCode,
      message.notification?.title ?? 'New Notification',
      message.notification?.body ?? 'You have a new update',
      platformDetails,
      payload: jsonEncode(message.data),
    );
  }

  /// Send FCM token to backend
  static Future<void> _sendTokenToBackend(String token) async {
    try {
      if (kDebugMode) {
        print('📤 Sending FCM token to backend: $token');
        print('🔗 Using endpoint: /tradie/update-token');
      }
      
      // Use the correct endpoint that matches your Laravel routes
      final dioClient = DioClient.instance;
      await dioClient.dio.post('/schedules/tradie/update-token', data: {'fcm_token': token});
      
      if (kDebugMode) {
        print('✅ FCM token sent successfully to /tradie/update-token');
      }
      
    } catch (e) {
      if (kDebugMode) {
        print('❌ Failed to send FCM token to backend: $e');
        print('🔍 Make sure /tradie/update-token endpoint exists and accepts fcm_token');
      }
    }
  }

  /// Get FCM token with retry mechanism
  static Future<String?> _getFCMTokenWithRetry({int maxRetries = 3}) async {
    for (int i = 0; i < maxRetries; i++) {
      try {
        final token = await _firebaseMessaging.getToken();
        if (token != null) {
          if (kDebugMode) {
            print('✅ FCM Token obtained on attempt ${i + 1}');
          }
          return token;
        }
      } catch (e) {
        if (kDebugMode) {
          print('❌ FCM Token attempt ${i + 1} failed: $e');
        }
      }
      
      if (i < maxRetries - 1) {
        await Future.delayed(Duration(milliseconds: 500 * (i + 1)));
      }
    }
    
    if (kDebugMode) {
      print('❌ Failed to get FCM token after $maxRetries attempts');
    }
    return null;
  }

  /// Warm up FCM connection to reduce initial notification delay
  static Future<void> _warmUpFCMConnection() async {
    try {
      if (kDebugMode) {
        print('🔥 Warming up FCM connection...');
      }
      
      // Subscribe to a general topic to establish connection
      await _firebaseMessaging.subscribeToTopic('app_notifications');
      
      // Set foreground notification presentation options
      await _firebaseMessaging.setForegroundNotificationPresentationOptions(
        alert: true,
        badge: true,
        sound: true,
      );
      
      if (kDebugMode) {
        print('✅ FCM connection warmed up');
      }
    } catch (e) {
      if (kDebugMode) {
        print('⚠️ FCM warm-up failed: $e');
      }
    }
  }

  /// Get current FCM token
  static String? get fcmToken => _fcmToken;

  /// Clear all notifications
  static Future<void> clearAllNotifications() async {
    await _localNotifications.cancelAll();
  }

  /// Handle job reminder from Laravel sendJobReminderToTradie function
  /// Data structure: {'job_id': string, 'type': 'job_reminder', 'start_time': string}
  static void handleJobReminder(Map<String, dynamic> data) {
    final jobId = data['job_id']?.toString() ?? 'unknown';
    final startTime = data['start_time']?.toString() ?? '';
    
    // Create a unique key that includes start time to allow rescheduled notifications
    final startTimeHash = startTime.isNotEmpty ? startTime.hashCode.toString() : DateTime.now().millisecondsSinceEpoch.toString();
    final notificationKey = 'job_reminder_${jobId}_$startTimeHash';
    
    if (kDebugMode) {
      print('🔔 Job reminder received from Laravel backend');
      print('📋 Job ID: $jobId');
      print('⏰ Start Time: $startTime');
      print('🔔 Type: ${data['type']}');
      print('🔍 Notification key: $notificationKey');
    }

    // Check if we've already shown this exact notification (same job + same time)
    if (_shownNotifications.contains(notificationKey)) {
      if (kDebugMode) {
        print('⚠️ Notification already shown for job $jobId at time $startTime - skipping duplicate');
      }
      return;
    }

    // Clear any previous notifications for this job (different times)
    _clearPreviousJobNotifications(jobId);

    // Mark this notification as shown
    _shownNotifications.add(notificationKey);

    // Show persistent notification for job reminder
    _showPersistentJobReminderNotification(data);
  }

  /// Clear previous notifications for a job (when rescheduled)
  static void _clearPreviousJobNotifications(String jobId) {
    try {
      // Remove all notification keys for this job ID
      final keysToRemove = _shownNotifications.where((key) => key.startsWith('job_reminder_$jobId')).toList();
      
      for (final key in keysToRemove) {
        _shownNotifications.remove(key);
      }
      
      // Cancel the notification in the system
      final notificationId = int.tryParse(jobId) ?? DateTime.now().millisecondsSinceEpoch;
      _localNotifications.cancel(notificationId);
      
      if (kDebugMode && keysToRemove.isNotEmpty) {
        print('🧹 Cleared ${keysToRemove.length} previous notifications for job $jobId');
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error clearing previous notifications: $e');
      }
    }
  }

  /// Show persistent job reminder notification that stays until user dismisses
  static Future<void> _showPersistentJobReminderNotification(Map<String, dynamic> data) async {
    final jobId = data['job_id'] ?? 'Unknown';
    final startTime = data['start_time'] ?? '';
    
    if (kDebugMode) {
      print('🔔 Showing persistent job reminder notification for job: $jobId');
    }
    
    // Create a truly persistent notification for job reminders
    final AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      'job_reminders_persistent',
      'Job Reminders (Persistent)',
      channelDescription: 'Persistent job reminder notifications that stay until dismissed',
      importance: Importance.max,
      priority: Priority.max,
      showWhen: true,
      enableVibration: true,
      playSound: true,
      visibility: NotificationVisibility.public,
      // Force heads-up notification (pop-up)
      fullScreenIntent: true,
      category: AndroidNotificationCategory.alarm,
      // Custom styling for job reminders
      enableLights: true,
      ledColor: const Color.fromARGB(255, 255, 165, 0), // Orange color
      ledOnMs: 1000,
      ledOffMs: 500,
      // Make it truly persistent
      ongoing: false, // User can dismiss, but won't auto-dismiss
      autoCancel: false, // Don't dismiss when tapped
      // No timeout - stays until user dismisses
      when: DateTime.now().millisecondsSinceEpoch,
      onlyAlertOnce: false, // Allow repeated alerts
      // Add action buttons for better UX
      actions: [
        AndroidNotificationAction(
          'view_job',
          'View Job',
          showsUserInterface: true,
        ),
        AndroidNotificationAction(
          'dismiss',
          'Dismiss',
          showsUserInterface: false,
        ),
      ],
    );

    const DarwinNotificationDetails iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
      interruptionLevel: InterruptionLevel.critical, // Highest priority on iOS
      categoryIdentifier: 'JOB_REMINDER_PERSISTENT',
      threadIdentifier: 'job_reminders',
    );

    final NotificationDetails platformDetails = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _localNotifications.show(
      int.tryParse(jobId.toString()) ?? DateTime.now().millisecondsSinceEpoch,
      '⏰ Job Reminder - Action Required',
      'You have a job starting in 1 hour! Tap to view details.',
      platformDetails,
      payload: jsonEncode({
        ...data,
        'notification_type': 'job_reminder_persistent',
        'action': 'view_job_details',
      }),
    );

    if (kDebugMode) {
      print('✅ Persistent job reminder notification shown for job: $jobId');
      print('📌 Notification will stay until user dismisses it');
    }
  }

  /// Show job reminder notification pop-up (matches Laravel backend message)
  static Future<void> _showJobReminderPopup(Map<String, dynamic> data) async {
    final jobId = data['job_id'] ?? 'Unknown';
    final startTime = data['start_time'] ?? '';
    
    if (kDebugMode) {
      print('🔔 Showing job reminder notification for job: $jobId');
    }
    
    // Enhanced notification for job reminders using high-priority channel
    final AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      'job_reminders_high_priority', // Use the high-priority channel
      'Job Reminders (High Priority)',
      channelDescription: 'High priority reminders for upcoming jobs',
      importance: Importance.max,
      priority: Priority.max,
      showWhen: true,
      enableVibration: true,
      playSound: true,
      visibility: NotificationVisibility.public,
      // Force heads-up notification (pop-up)
      fullScreenIntent: true,
      category: AndroidNotificationCategory.alarm,
      // Custom styling for job reminders
      enableLights: true,
      ledColor: const Color.fromARGB(255, 255, 165, 0), // Orange color
      ledOnMs: 1000,
      ledOffMs: 500,
      // Make it persistent until user manually dismisses it
      ongoing: false, // Not an ongoing notification (user can dismiss)
      autoCancel: false, // Don't auto-dismiss when tapped
      // Remove timeout - let notification stay until user dismisses
      // timeoutAfter: removed to prevent auto-disappearing
      when: DateTime.now().millisecondsSinceEpoch, // Show current time
      // Make it sticky in notification bar
      onlyAlertOnce: false, // Allow repeated alerts if needed
    );

    const DarwinNotificationDetails iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
      interruptionLevel: InterruptionLevel.timeSensitive,
      categoryIdentifier: 'JOB_REMINDER',
      // Make iOS notification persistent
      threadIdentifier: 'job_reminders', // Group job reminders together
    );

    final NotificationDetails platformDetails = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _localNotifications.show(
      int.tryParse(jobId.toString()) ?? DateTime.now().millisecondsSinceEpoch,
      '⏰ Upcoming Job Reminder', // Matches Laravel title
      'You have a job scheduled in 1 hour! Tap to view details.', // Simplified body
      platformDetails,
      payload: jsonEncode({
        ...data,
        'notification_type': 'job_reminder',
        'action': 'view_job_details',
      }),
    );

    if (kDebugMode) {
      print('✅ Job reminder pop-up notification shown for job: $jobId');
      print('⏰ Job starts at: $startTime');
    }
  }

  /// Handle job status updates
  static void handleJobUpdate(Map<String, dynamic> data) {
    if (kDebugMode) {
      print('🔄 Job update received: $data');
    }

    // final jobId = data['job_id'];
    // final status = data['status'];
    
    // Update local data or refresh schedules
    // You can trigger a schedule refresh here
  }

  /// Dismiss a specific notification by ID
  static Future<void> _dismissNotification(int notificationId) async {
    try {
      await _localNotifications.cancel(notificationId);
      
      // Remove from shown notifications tracking
      final jobId = notificationId.toString();
      final notificationKey = 'job_reminder_$jobId';
      _shownNotifications.remove(notificationKey);
      
      if (kDebugMode) {
        print('✅ Notification $notificationId dismissed and removed from tracking');
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error dismissing notification $notificationId: $e');
      }
    }
  }
}

/// Background message handler (must be top-level function)
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  if (kDebugMode) {
    print('📱 Background message: ${message.notification?.title}');
  }
}