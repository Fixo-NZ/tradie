import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

class TestFCMWidget extends StatefulWidget {
  const TestFCMWidget({super.key});

  @override
  State<TestFCMWidget> createState() => _TestFCMWidgetState();
}

class _TestFCMWidgetState extends State<TestFCMWidget> {
  String? fcmToken;
  bool isLoading = true;
  String? error;

  @override
  void initState() {
    super.initState();
    _getFCMToken();
  }

  Future<void> _getFCMToken() async {
    try {
      setState(() {
        isLoading = true;
        error = null;
      });

      // Request permission first
      NotificationSettings settings = await FirebaseMessaging.instance.requestPermission(
        alert: true,
        badge: true,
        sound: true,
      );

      if (settings.authorizationStatus == AuthorizationStatus.authorized) {
        // Get the token
        String? token = await FirebaseMessaging.instance.getToken();
        
        setState(() {
          fcmToken = token;
          isLoading = false;
        });

        print("🔥 FCM Token: $token");
        
        // Listen for token refresh
        FirebaseMessaging.instance.onTokenRefresh.listen((newToken) {
          print("🔄 FCM Token Refreshed: $newToken");
          setState(() {
            fcmToken = newToken;
          });
        });
        
      } else {
        setState(() {
          error = "Notification permission denied";
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        error = "Error getting FCM token: $e";
        isLoading = false;
      });
      print("❌ Error: $e");
    }
  }

  void _copyToken() {
    if (fcmToken != null) {
      Clipboard.setData(ClipboardData(text: fcmToken!));
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('FCM Token copied to clipboard!')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('FCM Token Test'),
        backgroundColor: Colors.blue,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '🔥 Firebase Cloud Messaging Token',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            
            if (isLoading)
              const Center(
                child: Column(
                  children: [
                    CircularProgressIndicator(),
                    SizedBox(height: 10),
                    Text('Getting FCM Token...'),
                  ],
                ),
              )
            else if (error != null)
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.red.shade100,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('❌ Error:', style: TextStyle(fontWeight: FontWeight.bold)),
                    Text(error!),
                    const SizedBox(height: 10),
                    ElevatedButton(
                      onPressed: _getFCMToken,
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              )
            else if (fcmToken != null)
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.green.shade100,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('✅ FCM Token:', style: TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    SelectableText(
                      fcmToken!,
                      style: const TextStyle(fontSize: 12, fontFamily: 'monospace'),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        ElevatedButton.icon(
                          onPressed: _copyToken,
                          icon: const Icon(Icons.copy),
                          label: const Text('Copy Token'),
                        ),
                        const SizedBox(width: 10),
                        ElevatedButton.icon(
                          onPressed: _getFCMToken,
                          icon: const Icon(Icons.refresh),
                          label: const Text('Refresh'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            
            const SizedBox(height: 30),
            const Text(
              '📋 How to Test:',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            const Text('1. Copy the FCM token above'),
            const Text('2. Go to Firebase Console → Messaging'),
            const Text('3. Click "Send your first message"'),
            const Text('4. Click "Send test message"'),
            const Text('5. Paste your FCM token'),
            const Text('6. Click "Test" to send notification'),
            
            const SizedBox(height: 20),
            const Text(
              '🔧 Token Info:',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            if (fcmToken != null) ...[
              Text('Length: ${fcmToken!.length} characters'),
              Text('Starts with: ${fcmToken!.substring(0, 20)}...'),
            ],
          ],
        ),
      ),
    );
  }
}