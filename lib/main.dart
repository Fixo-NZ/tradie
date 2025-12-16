import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';
import 'core/services/push_notification_service.dart';
import 'core/services/navigation_service.dart';

// Background message handler (must be top-level)
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  print("\n🔔 BACKGROUND MESSAGE RECEIVED:");
  print("Title: ${message.notification?.title}");
  print("Body: ${message.notification?.body}");
  print("Data: ${message.data}");
  print("="*50 + "\n");
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Firebase
  try {
    await Firebase.initializeApp();
    print("✅ Firebase initialized successfully");
    
    // Set background message handler
    FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);
    
    // Initialize Push Notification Service (handles foreground notifications)
    await PushNotificationService.initialize(
      onMessageReceived: (data) {
        print("📱 Notification data received: $data");
        
        // Handle job reminder notifications from Laravel backend
        final notificationType = data['type'] ?? data['notification_type'];
        
        print("🔍 NOTIFICATION DEBUG:");
        print("📋 Type: $notificationType");
        print("📋 Full data: $data");
        
        if (notificationType == 'job_reminder') {
          print("✅ Job reminder detected - processing...");
          // This handles notifications from your Laravel sendJobReminderToTradie function
          PushNotificationService.handleJobReminder(data);
        } else {
          print("⚠️ Unknown notification type: $notificationType");
        }
      },
    );
    
    // Get FCM Token and display it clearly
    await _getFCMToken();
    
  } catch (e) {
    print("❌ Firebase initialization failed: $e");
  }
  
  runApp(const ProviderScope(child: TradieApp()));
}

Future<void> _getFCMToken() async {
  try {
    // Request permission
    NotificationSettings settings = await FirebaseMessaging.instance.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      String? token = await FirebaseMessaging.instance.getToken();
      
      if (token != null) {
        print("\n" + "="*80);
        print("🔥 FCM TOKEN FOR TESTING:");
        print("="*80);
        print(token);
        print("="*80);
        print("📋 Copy this token and paste it in your Laravel test page!");
        print("🔗 Token length: ${token.length} characters");
        print("="*80 + "\n");
        
        // Set up message handlers
        _setupMessageHandlers();
      } else {
        print("❌ FCM Token is null");
      }
    } else {
      print("❌ Notification permission denied");
    }
  } catch (e) {
    print("❌ Error getting FCM token: $e");
  }
}

void _setupMessageHandlers() {
  // Handle foreground messages
  FirebaseMessaging.onMessage.listen((RemoteMessage message) {
    print("\n🔔 FOREGROUND MESSAGE RECEIVED:");
    print("Title: ${message.notification?.title}");
    print("Body: ${message.notification?.body}");
    print("Data: ${message.data}");
    print("="*50 + "\n");
  });

  // Handle background messages when app is opened
  FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
    print("\n🔔 MESSAGE OPENED APP:");
    print("Title: ${message.notification?.title}");
    print("Body: ${message.notification?.body}");
    print("Data: ${message.data}");
    print("="*50 + "\n");
  });

  // Check if app was opened from a terminated state
  FirebaseMessaging.instance.getInitialMessage().then((RemoteMessage? message) {
    if (message != null) {
      print("\n🔔 APP OPENED FROM TERMINATED STATE:");
      print("Title: ${message.notification?.title}");
      print("Body: ${message.notification?.body}");
      print("Data: ${message.data}");
      print("="*50 + "\n");
    }
  });
  
  print("✅ FCM message handlers set up successfully");
}

class TradieApp extends ConsumerWidget {
  const TradieApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);

    // Initialize navigation service with router
    NavigationService.initialize(router);

    return MaterialApp.router(
      title: 'Tradie',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system,
      routerConfig: router,
      // Add navigator key for global navigation
      // navigatorKey: NavigationService.navigatorKey, // Not needed with GoRouter
    );
  }
}
