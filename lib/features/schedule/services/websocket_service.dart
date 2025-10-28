import 'dart:convert';
import 'package:web_socket_channel/web_socket_channel.dart';

class WebSocketService {
  static WebSocketChannel? _channel;

  /// Connect to WebSocket server
  static void init({
    required String url,
    required void Function(Map<String, dynamic>) onMessage,
  }) {
    _channel = WebSocketChannel.connect(Uri.parse(url));

    _channel!.stream.listen(
      (data) {
        try {
          final jsonData = jsonDecode(data) as Map<String, dynamic>;
          onMessage(jsonData);
        } catch (e) {
          print('Failed to decode websocket message: $e');
        }
      },
      onError: (error) {
        print('WebSocket error: $error');
      },
      onDone: () {
        print('WebSocket connection closed.');
      },
    );
  }

  /// Send a message to server
  static void send(Map<String, dynamic> data) {
    _channel?.sink.add(jsonEncode(data));
  }

  /// Disconnect
  static void disconnect() {
    _channel?.sink.close();
    _channel = null;
  }
}
