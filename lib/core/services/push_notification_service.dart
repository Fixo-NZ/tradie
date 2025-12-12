import 'dart:convert';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import '../network/dio_client.dart';

class PushNotificationService {
  static final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  static final FlutterLocalNotificationsPlugin _localNotifications = FlutterLocalNotificationsPlugin();
  
  static String? _fcmToken;
  static Function(Map<String, dynamic>)? _onMessageReceived;

  /// Initialize push notifications
  static Future<void> initialize({
    Function(Map<String, dynamic>)? onMessageReceived,
  }) async {
    _onMessageReceived = onMessageReceived;
    
    try {
      // Request permission for notifications
      NotificationSettings settings = await _firebaseMessaging.requestPermission(
        alert: true,
        announcement: false,
        badge: true,
        carPlay: false,
        criticalAlert: false,
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

      // Get FCM token
      _fcmToken = await _firebaseMessaging.getToken();
      if (kDebugMode) {
        print('📱 FCM Token: $_fcmToken');
      }

      // Listen for token refresh
      _firebaseMessaging.onTokenRefresh.listen((token) {
        _fcmToken = token;
        if (kDebugMode) {
          print('🔄 FCM Token refreshed: $token');
        }
        // TODO: Send updated token to your backend
        _sendTokenToBackend(token);
      });

      // Handle foreground messages
      FirebaseMessaging.onMessage.listen(_handleForegroundMessage);

      // Handle background messages
      FirebaseMessaging.onBackgroundMessage(_handleBackgroundMessage);

      // Handle notification taps when app is terminated
      FirebaseMessaging.onMessageOpenedApp.listen(_handleNotificationTap);

      // Check if app was opened from a notification
      RemoteMessage? initialMessage = await _firebaseMessaging.getInitialMessage();
      if (initialMessage != null) {
        _handleNotificationTap(initialMessage);
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
          _onMessageReceived?.call(data);
        }
      },
    );
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

  /// Handle notification tap
  static void _handleNotificationTap(RemoteMessage message) {
    if (kDebugMode) {
      print('📱 Notification tapped: ${message.data}');
    }

    _onMessageReceived?.call(message.data);
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

  /// Get current FCM token
  static String? get fcmToken => _fcmToken;

  /// Clear all notifications
  static Future<void> clearAllNotifications() async {
    await _localNotifications.cancelAll();
  }

  /// Handle job reminder from Laravel sendJobReminderToTradie function
  /// Data structure: {'job_id': string, 'type': 'job_reminder', 'start_time': string}
  static void handleJobReminder(Map<String, dynamic> data) {
    if (kDebugMode) {
      print('🔔 Job reminder received from Laravel backend');
      print('📋 Job ID: ${data['job_id']}');
      print('⏰ Start Time: ${data['start_time']}');
      print('🔔 Type: ${data['type']}');
    }

    // Show immediate notification pop-up for job reminder
    _showJobReminderPopup(data);
  }

  /// Show job reminder notification pop-up (matches Laravel backend message)
  static Future<void> _showJobReminderPopup(Map<String, dynamic> data) async {
    final jobId = data['job_id'] ?? 'Unknown';
    final startTime = data['start_time'] ?? '';
    
    // Enhanced notification for job reminders (1 hour before start)
    const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      'job_reminders',
      'Job Reminders',
      channelDescription: 'Reminders for upcoming jobs (1 hour before start)',
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
      ledColor: Color.fromARGB(255, 255, 165, 0), // Orange color
      ledOnMs: 1000,
      ledOffMs: 500,
      // Make it persistent until user interacts
      ongoing: false,
      autoCancel: true,
    );

    const DarwinNotificationDetails iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
      interruptionLevel: InterruptionLevel.timeSensitive,
      categoryIdentifier: 'JOB_REMINDER',
    );

    const NotificationDetails platformDetails = NotificationDetails(
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
}

/// Background message handler (must be top-level function)
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  if (kDebugMode) {
    print('📱 Background message: ${message.notification?.title}');
  }
}