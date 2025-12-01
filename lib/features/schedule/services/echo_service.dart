import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import '../../../core/config/echo_config.dart';

class LaravelEchoService {
  static WebSocket? _socket;
  static bool _connected = false;
  static final Set<String> _subscribedChannels = {};
  static void Function(Map<String, dynamic>)? _onEvent;
  static void Function(String)? _onConnectionStateChange;

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
      final wsUrl = '${EchoConfig.scheme == 'https' ? 'wss' : 'ws'}://${EchoConfig.host}:${EchoConfig.port}/app/${EchoConfig.appKey}';
      
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
      
      if (event != null && event.startsWith('schedule.')) {
        _handleScheduleEvent(event, message);
      } else if (event == 'pusher:connection_established') {
        if (kDebugMode) {
          print("🔄 Reverb Connection Established");
        }
      } else if (event == 'pusher:subscription_succeeded') {
        if (kDebugMode) {
          print("✅ Subscription Succeeded");
        }
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
        print("📡 Reverb Schedule Event: $eventName");
        print("Event data: $message");
      }

      final eventData = <String, dynamic>{
        'event': eventName,
        'data': message['data'] ?? {},
        'channel': message['channel'],
      };

      _onEvent?.call(eventData);
    } catch (e) {
      if (kDebugMode) {
        print("❌ Failed to handle schedule event: $e");
        print("Raw message: $message");
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