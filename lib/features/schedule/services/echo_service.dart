import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';

// Updated Laravel Echo Service for Reverb - Replace your existing service with this
class LaravelEchoService {
  static WebSocket? _socket;
  static bool _connected = false;
  static final Set<String> _subscribedChannels = {};
  static void Function(Map<String, dynamic>)? _onEvent;
  static void Function(String)? _onConnectionStateChange;

  // Reverb configuration - update these values to match your setup
  static const String _scheme = 'ws'; // Use 'wss' for HTTPS
  static const String _host = '10.0.2.2'; // Android emulator's localhost
  static const int _port = 8080;
  static const String _appKey = 'wjnobqtydgun94yxiqhq'; // Your REVERB_APP_KEY
  
  // Add debugging flag
  // static const bool _enableVerboseLogging = false;

  /// Initialize and connect to Laravel Reverb
  static Future<void> init({
    required String channel,
    required void Function(Map<String, dynamic>) onEvent,
    void Function(String)? onConnectionStateChange,
  }) async {
    if (_connected && _socket != null) {
      // If already connected, just subscribe to the new channel
      _subscribeToChannel(channel);
      return;
    }

    _onEvent = onEvent;
    _onConnectionStateChange = onConnectionStateChange;

    try {
      // Build WebSocket URL for Reverb
      final wsUrl = '$_scheme://$_host:$_port/app/$_appKey';
      
      if (kDebugMode) {
        print("🔄 Connecting to Reverb: $wsUrl");
      }

      // Connect to Reverb WebSocket
      _socket = await WebSocket.connect(wsUrl);
      
      // Set up connection handlers
      _socket!.listen(
        (data) {
          _handleMessage(data);
        },
        onError: (error) {
          if (kDebugMode) {
            print("❌ WebSocket Error: $error");
          }
          _connected = false;
          _onConnectionStateChange?.call('DISCONNECTED');
        },
        onDone: () {
          if (kDebugMode) {
            print("🔌 WebSocket Disconnected");
          }
          _connected = false;
          _onConnectionStateChange?.call('DISCONNECTED');
        },
      );

      _connected = true;
      _onConnectionStateChange?.call('CONNECTED');
      
      if (kDebugMode) {
        print("🚀 Laravel Reverb Service initialized");
      }

      // Subscribe to the initial channel
      _subscribeToChannel(channel);

    } catch (e) {
      if (kDebugMode) {
        print("❌ Failed to initialize Laravel Reverb: $e");
      }
      rethrow;
    }
  }

  /// Subscribe to a specific channel
  static void _subscribeToChannel(String channelName) {
    if (_socket == null || _subscribedChannels.contains(channelName)) return;

    try {
      // Send subscription message to Reverb
      _sendMessage({
        'event': 'pusher:subscribe',
        'data': {
          'channel': channelName,
        },
      });

      _subscribedChannels.add(channelName);
      
      if (kDebugMode) {
        print("✅ Successfully subscribed to Reverb channel: $channelName");
      }

    } catch (e) {
      if (kDebugMode) {
        print("❌ Failed to subscribe to channel $channelName: $e");
      }
    }
  }

  /// Subscribe to an additional channel (public method)
  static void subscribeToAdditionalChannel(String channelName) {
    _subscribeToChannel(channelName);
  }

  /// Send message to WebSocket
  static void _sendMessage(Map<String, dynamic> message) {
    if (_socket != null) {
      _socket!.add(jsonEncode(message));
    }
  }

  /// Handle incoming WebSocket messages
  static void _handleMessage(dynamic data) {
    try {
      final Map<String, dynamic> message = jsonDecode(data);
      
      if (kDebugMode) {
        print("📡 Reverb Message: $message");
      }

      // Handle different message types
      final event = message['event'] as String?;
      
      if (event == 'pusher:connection_established') {
        if (kDebugMode) {
          print("🔄 Reverb Connection Established");
        }
      } else if (event == 'pusher:subscription_succeeded' || event == 'pusher_internal:subscription_succeeded') {
        if (kDebugMode) {
          print("✅ Subscription Succeeded for channel: ${message['channel']}");
        }
      } else if (event == 'pusher:ping') {
        // Respond to ping with pong
        if (kDebugMode) {
          print("🏓 Received ping, sending pong");
        }
        _sendMessage({'event': 'pusher:pong', 'data': {}});
      } else if (event == 'pusher:error') {
        if (kDebugMode) {
          print("❌ Pusher Error: ${message['data']}");
        }
      }
      
      if (event != null && (event.startsWith('schedule.') || event == 'schedule.displayed' || event.contains('job') || event.contains('Job'))) {
        if (kDebugMode) {
          print("🎯 SCHEDULE EVENT DETECTED: $event");
        }
        _handleScheduleEvent(event, message);
      }
    } catch (e) {
      if (kDebugMode) {
        print("❌ Failed to handle message: $e");
        print("Raw message: $data");
      }
    }
  }

  /// Handle schedule events from Reverb
  static void _handleScheduleEvent(String eventName, Map<String, dynamic> message) {
    try {
      if (kDebugMode) {
        print("🎯 HANDLING SCHEDULE EVENT: $eventName");
        print("📡 Full message: $message");
      }
      
      final eventData = <String, dynamic>{
        'event': eventName,
        'data': message['data'] ?? {},
        'channel': message['channel'],
      };

      _onEvent?.call(eventData);
      
      if (kDebugMode) {
        print("✅ Event passed to handler");
      }
    } catch (e) {
      if (kDebugMode) {
        print("❌ Error handling schedule event: $e");
      }
    }
  }

  /// Unsubscribe from a specific channel
  static void unsubscribeFromChannel(String channelName) {
    if (_socket == null || !_subscribedChannels.contains(channelName)) return;

    try {
      // Send unsubscribe message
      _sendMessage({
        'event': 'pusher:unsubscribe',
        'data': {
          'channel': channelName,
        },
      });
      
      _subscribedChannels.remove(channelName);
      
      if (kDebugMode) {
        print("📤 Unsubscribed from Reverb channel: $channelName");
      }
    } catch (e) {
      if (kDebugMode) {
        print("❌ Error unsubscribing from channel $channelName: $e");
      }
    }
  }

  /// Disconnect from all channels and Reverb
  static void disconnect({String? channel}) {
    if (_socket == null) return;

    try {
      if (channel != null) {
        unsubscribeFromChannel(channel);
      } else {
        // Disconnect from all channels
        for (final channelName in _subscribedChannels.toList()) {
          unsubscribeFromChannel(channelName);
        }
        _subscribedChannels.clear();
        
        _socket!.close();
        _socket = null;
        _connected = false;
        
        if (kDebugMode) {
          print("🔌 Reverb Service disconnected");
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print("❌ Error during Reverb disconnect: $e");
      }
    }
  }

  /// Send a client event to a channel
  static void whisper(String channelName, String event, Map<String, dynamic> data) {
    if (_socket == null || !_subscribedChannels.contains(channelName)) return;

    try {
      _sendMessage({
        'event': 'client-$event',
        'channel': channelName,
        'data': data,
      });
      
      if (kDebugMode) {
        print("📤 Whispered event '$event' to channel '$channelName'");
      }
    } catch (e) {
      if (kDebugMode) {
        print("❌ Error whispering to channel $channelName: $e");
      }
    }
  }

  /// Get connection status
  static bool get isConnected => _connected && _socket != null;
  
  /// Get subscribed channels
  static Set<String> get subscribedChannels => Set.from(_subscribedChannels);
}