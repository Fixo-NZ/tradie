import 'package:dio/dio.dart';
import '../../../core/network/api_result.dart';
import '../../../core/network/dio_client.dart';

class NotificationRepository {
  final DioClient _dioClient = DioClient.instance;

  /// Send FCM token to backend
  Future<ApiResult<void>> sendFcmToken(String fcmToken) async {
    try {
      await _dioClient.dio.post(
        '/auth/fcm-token',
        data: {'fcm_token': fcmToken},
      );

      return const Success(null);
    } on DioException catch (e) {
      return Failure(message: 'Failed to send FCM token: ${e.message}');
    } catch (e) {
      return Failure(message: 'Unexpected error: $e');
    }
  }

  /// Update notification preferences
  Future<ApiResult<void>> updateNotificationPreferences({
    required bool jobReminders,
    required bool jobUpdates,
    required bool newJobOffers,
  }) async {
    try {
      await _dioClient.dio.post(
        '/notifications/preferences',
        data: {
          'job_reminders': jobReminders,
          'job_updates': jobUpdates,
          'new_job_offers': newJobOffers,
        },
      );

      return const Success(null);
    } on DioException catch (e) {
      return Failure(message: 'Failed to update preferences: ${e.message}');
    } catch (e) {
      return Failure(message: 'Unexpected error: $e');
    }
  }

  /// Get notification history
  Future<ApiResult<List<Map<String, dynamic>>>> getNotificationHistory() async {
    try {
      final response = await _dioClient.dio.get('/notifications/history');
      
      final notifications = (response.data['notifications'] as List)
          .cast<Map<String, dynamic>>();
      
      return Success(notifications);
    } on DioException catch (e) {
      return Failure(message: 'Failed to get notifications: ${e.message}');
    } catch (e) {
      return Failure(message: 'Unexpected error: $e');
    }
  }

  /// Mark notification as read
  Future<ApiResult<void>> markAsRead(int notificationId) async {
    try {
      await _dioClient.dio.post('/notifications/$notificationId/read');
      return const Success(null);
    } on DioException catch (e) {
      return Failure(message: 'Failed to mark as read: ${e.message}');
    } catch (e) {
      return Failure(message: 'Unexpected error: $e');
    }
  }
}