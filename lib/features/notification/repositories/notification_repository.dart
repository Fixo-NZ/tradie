import 'dart:convert';
import 'package:dio/dio.dart';
import '../../../core/network/dio_client.dart';
import '../../../core/constants/api_constants.dart';
import '../models/notification_model.dart';

class NotificationRepository {
  final Dio _dio;

  NotificationRepository({Dio? dio}) : _dio = dio ?? DioClient.instance.dio;

  // =====================
  // Fetch notifications
  // =====================
  Future<List<NotificationModel>> fetchNotifications() async {
    final res = await _dio.get(
      '${ApiConstants.baseUrl}${ApiConstants.notifications}',
    );

    print('DEBUG: /notifications response data: ${res.data}');

    if (res.data['data'] == null) {
      print('DEBUG: No "data" field in response!');
      return [];
    }

    final rawList = res.data['data'] as List;

    return rawList.map((n) {
      print('DEBUG: Raw notification: $n');

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

      final Map<String, dynamic> jsonData = {
        'id': n['id'],
        'type': n['type'],
        'read_at': n['read_at'],
        'data': decodedData,
      };

      print('DEBUG: Merged notification data: $jsonData');

      return NotificationModel.fromJson(jsonData);
    }).toList();
  }

  // =====================
  // Mark notification as read
  // =====================
  Future<void> markAsRead(String id) async {
    print('DEBUG: Marking notification $id as read');

    await _dio.post(
      '${ApiConstants.baseUrl}${ApiConstants.markNotificationRead(id)}',
    );
  }

  // =====================
  // Accept booking request
  // =====================
  Future<void> acceptBooking(int bookingId) async {
    print('DEBUG: Accepting booking $bookingId');
    final url =
        '${ApiConstants.baseUrl}${ApiConstants.acceptBooking(bookingId.toString())}';
    try {
      // backend controls canonical status; no body required
      await _dio.post(url);
    } on DioException catch (e) {
      final status = e.response?.statusCode;
      final data = e.response?.data;
      final msg = data is String
          ? data
          : (data?.toString() ?? e.message ?? 'unknown');
      if (status == 404) {
        throw Exception('HTTP_404: acceptBooking failed: $msg');
      }
      throw Exception('HTTP_${status ?? 'ERR'}: acceptBooking failed: $msg');
    }
  }

  // =====================
  // Decline booking request
  // =====================
  Future<void> declineBooking(int bookingId) async {
    print('DEBUG: Declining booking $bookingId');
    final url =
        '${ApiConstants.baseUrl}${ApiConstants.declineBooking(bookingId.toString())}';
    try {
      // backend controls canonical status; no body required
      await _dio.post(url);
    } on DioException catch (e) {
      final status = e.response?.statusCode;
      final data = e.response?.data;
      final msg = data is String
          ? data
          : (data?.toString() ?? e.message ?? 'unknown');
      if (status == 404) {
        throw Exception('HTTP_404: declineBooking failed: $msg');
      }
      throw Exception('HTTP_${status ?? 'ERR'}: declineBooking failed: $msg');
    }
  }
}
