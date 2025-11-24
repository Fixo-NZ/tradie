import 'dart:convert';
import 'package:pusher_channels_flutter/pusher_channels_flutter.dart';

class PusherService {
  static final PusherChannelsFlutter _pusher = PusherChannelsFlutter.getInstance();
  static bool _connected = false;

  /// Initialize and connect to Pusher
  static Future<void> init({
    required String apiKey,
    required String channel,
    String cluster = 'mt1',
    required void Function(Map<String, dynamic>) onEvent,
  }) async {
    if (_connected) return;

    await _pusher.init(
      apiKey: apiKey,
      cluster: cluster,
      onEvent: (event) {
        try {
          final jsonData = jsonDecode(event.data);
          onEvent(jsonData);
        } catch (e) {
          print("Failed to decode Pusher event: $e");
        }
      },
      onError: (message, code, exception) {
        print("Pusher error: $message");
      },
    );

    await _pusher.subscribe(channelName: channel);
    await _pusher.connect();
    _connected = true;
  }

  /// Disconnect Pusher
  static void disconnect({required String channel}) {
    if (_connected) {
      _pusher.unsubscribe(channelName: channel);
      _pusher.disconnect();
      _connected = false;
    }
  }
}
