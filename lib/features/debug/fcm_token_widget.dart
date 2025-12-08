import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

class FCMTokenWidget extends StatefulWidget {
  const FCMTokenWidget({super.key});

  @override
  State<FCMTokenWidget> createState() => _FCMTokenWidgetState();
}

class _FCMTokenWidgetState extends State<FCMTokenWidget> {
  String? fcmToken;
  bool isLoading = true;
  String? error;

  @override
  void initState() {
    super.initState();
    _initializeFirebaseAndGetToken();
  }

  Future<void> _initializeFirebaseAndGetToken() async {
    try {
      setState(() {
        isLoading = true;
        error = null;
      });

      // Firebase is already initialized in main.dart
      // Just request permission and get token
      NotificationSettings settings = await FirebaseMessaging.instance.requestPermission(
        alert: true,
        badge: true,
        sound: true,
      );

      if (settings.authorizationStatus == AuthorizationStatus.authorized) {
        // Get FCM token
        String? token = await FirebaseMessaging.instance.getToken();
        
        setState(() {
          fcmToken = token;
          isLoading = false;
        });

        print("🔥 FCM Token: $token");
        
      } else {
        setState(() {
          error = "Notification permission denied";
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        error = "Error: $e";
        isLoading = false;
      });
      print("❌ Firebase Error: $e");
    }
  }

  void _copyToken() {
    if (fcmToken != null) {
      Clipboard.setData(ClipboardData(text: fcmToken!));
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('FCM Token copied to clipboard!'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.blue.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              const Icon(Icons.notifications, color: Colors.blue),
              const SizedBox(width: 8),
              const Text(
                'FCM Token for Testing',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          
          if (isLoading)
            const Row(
              children: [
                SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
                SizedBox(width: 8),
                Text('Getting FCM Token...'),
              ],
            )
          else if (error != null)
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('❌ $error', style: const TextStyle(color: Colors.red)),
                const SizedBox(height: 8),
                ElevatedButton(
                  onPressed: _initializeFirebaseAndGetToken,
                  child: const Text('Retry'),
                ),
              ],
            )
          else if (fcmToken != null)
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('✅ Token Ready:', style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: SelectableText(
                    fcmToken!,
                    style: const TextStyle(fontSize: 12, fontFamily: 'monospace'),
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    ElevatedButton.icon(
                      onPressed: _copyToken,
                      icon: const Icon(Icons.copy, size: 16),
                      label: const Text('Copy Token'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text('Length: ${fcmToken!.length}', 
                         style: const TextStyle(fontSize: 12, color: Colors.grey)),
                  ],
                ),
              ],
            ),
          
          const SizedBox(height: 12),
          const Text(
            '💡 Copy this token and paste it in your Laravel test page',
            style: TextStyle(fontSize: 12, color: Colors.grey),
          ),
        ],
      ),
    );
  }
}