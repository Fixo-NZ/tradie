import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/notification_model.dart';
import '../repositories/notification_repository.dart';

final notificationRepositoryProvider = Provider<NotificationRepository>((ref) {
  return NotificationRepository();
});

final notificationViewModelProvider =
    StateNotifierProvider<
      NotificationViewModel,
      AsyncValue<List<NotificationModel>>
    >((ref) {
      final repo = ref.read(notificationRepositoryProvider);
      return NotificationViewModel(repo);
    });

class NotificationViewModel
    extends StateNotifier<AsyncValue<List<NotificationModel>>> {
  final NotificationRepository _repository;

  NotificationViewModel(this._repository) : super(const AsyncValue.loading()) {
    loadNotifications();
  }

  // =====================
  // Load notifications
  // =====================
  Future<void> loadNotifications() async {
    try {
      state = const AsyncValue.loading();
      final notifications = await _repository.fetchNotifications();
      print('DEBUG: Loaded notifications count: ${notifications.length}');
      state = AsyncValue.data(notifications);
    } catch (e, st) {
      print('DEBUG: Error loading notifications: $e');
      state = AsyncValue.error(e, st);
    }
  }

  // =====================
  // Mark notification as read
  // =====================
  Future<void> markAsRead(String notificationId) async {
    try {
      await _repository.markAsRead(notificationId);

      state.whenData((list) {
        state = AsyncValue.data(
          list.map((n) {
            if (n.id == notificationId) {
              return NotificationModel(
                id: n.id,
                type: n.type,
                isRead: true,
                title: n.title,
                message: n.message,
                data: n.data,
              );
            }
            return n;
          }).toList(),
        );
      });
    } catch (e) {
      print('DEBUG: Failed to mark notification as read: $e');
    }
  }

  // =====================
  // Accept booking (from notification)
  // =====================
  Future<void> acceptBooking(NotificationModel notification) async {
    try {
      final rawBookingId = notification.data['booking_id'];

      if (rawBookingId == null) {
        throw Exception('booking_id missing in notification data');
      }

      final bookingId = rawBookingId is int
          ? rawBookingId
          : int.tryParse(rawBookingId.toString());

      if (bookingId == null) {
        throw Exception('booking_id is not a valid integer: $rawBookingId');
      }

      await _repository.acceptBooking(bookingId);
      await markAsRead(notification.id);

      // Refresh list from backend
      await loadNotifications();
    } catch (e) {
      print('DEBUG: Failed to accept job: $e');
      rethrow;
    }
  }

  // =====================
  // Decline booking (from notification)
  // =====================
  Future<void> declineBooking(NotificationModel notification) async {
    try {
      final rawBookingId = notification.data['booking_id'];

      if (rawBookingId == null) {
        throw Exception('booking_id missing in notification data');
      }

      final bookingId = rawBookingId is int
          ? rawBookingId
          : int.tryParse(rawBookingId.toString());

      if (bookingId == null) {
        throw Exception('booking_id is not a valid integer: $rawBookingId');
      }

      await _repository.declineBooking(bookingId);
      await markAsRead(notification.id);

      // Refresh list from backend
      await loadNotifications();
    } catch (e) {
      print('DEBUG: Failed to decline job: $e');
      rethrow;
    }
  }
}
