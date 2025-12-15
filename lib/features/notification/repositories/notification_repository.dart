import 'dart:convert';
import 'package:dio/dio.dart';
import '../../../core/network/dio_client.dart';
import '../../../core/constants/api_constants.dart';
import '../models/notification_model.dart';

class NotificationRepository {
  final Dio _dio;

  NotificationRepository({Dio? dio}) : _dio = dio ?? DioClient.instance.dio;

  Future<List<NotificationModel>> fetchNotifications() async {
    final res = await _dio.get(
      '${ApiConstants.baseUrl}${ApiConstants.notifications}',
    );

    // Debug: print full response
    print('DEBUG: /notifications response data: ${res.data}');

    if (res.data['data'] == null) {
      print('DEBUG: No "data" field in response!');
      return [];
    }

    final rawList = res.data['data'] as List;

    return rawList.map((n) {
      // Debug: print each notification raw
      print('DEBUG: Raw notification: $n');

      // Decode the `data` field which may be a Map, a JSON string, or null
      Map<String, dynamic> decodedData = {};
      final rawData = n['data'];

      if (rawData == null) {
        print('DEBUG: Data field is null');
      } else if (rawData is String) {
        try {
          final decoded = json.decode(rawData);
          if (decoded is Map) {
            decodedData = Map<String, dynamic>.from(decoded);
          }
        } catch (e) {
          print('DEBUG: Failed to decode notification data from string: $e');
        }
      } else if (rawData is Map) {
        decodedData = Map<String, dynamic>.from(rawData);
      } else {
        print('DEBUG: Data field is neither String nor Map: $rawData');
      }

      // Merge id, type, read_at with decodedData
      final Map<String, dynamic> jsonData = {
        'id': n['id'],
        'type': n['type'],
        'read_at': n['read_at'],
        'data': decodedData,
      };

      // Debug: print merged jsonData
      print('DEBUG: Merged notification data: $jsonData');

      return NotificationModel.fromJson(jsonData);
    }).toList();
  }

  Future<void> markAsRead(String id) async {
    print('DEBUG: Marking notification $id as read');
    await _dio.post(
      '${ApiConstants.baseUrl}${ApiConstants.markNotificationRead(id)}',
    );
  }
}
