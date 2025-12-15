import 'dart:convert';

class NotificationModel {
  final String id;
  final String type;
  final bool isRead;
  final String title;
  final String message;
  final Map<String, dynamic> data;

  NotificationModel({
    required this.id,
    required this.type,
    required this.isRead,
    required this.title,
    required this.message,
    required this.data,
  });

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    Map<String, dynamic> dataMap = {};

    final rawData = json['data'];

    if (rawData != null) {
      if (rawData is String) {
        try {
          final decoded = jsonDecode(rawData);
          if (decoded is Map) {
            dataMap = Map<String, dynamic>.from(decoded);
          }
        } catch (e) {
          // If decoding fails, leave empty
          dataMap = {};
        }
      } else if (rawData is Map) {
        dataMap = Map<String, dynamic>.from(rawData);
      }
    }

    return NotificationModel(
      id: json['id'].toString(),
      type: json['type'] ?? '',
      isRead: json['read_at'] != null,
      title: dataMap['title']?.toString() ?? 'No title',
      message: dataMap['message']?.toString() ?? 'No message',
      data: dataMap,
    );
  }
}
