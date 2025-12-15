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

  Future<void> loadNotifications() async {
    state = const AsyncValue.loading();
    try {
      final notifications = await _repository.fetchNotifications();
      print('DEBUG: Loaded notifications count: ${notifications.length}');
      state = AsyncValue.data(notifications);
    } catch (e, st) {
      print('DEBUG: Error loading notifications: $e');

      state = AsyncValue.error(e, st);
    }
  }

  Future<void> markAsRead(String id) async {
    try {
      await _repository.markAsRead(id);
      state.whenData((list) {
        final updated = list.map((n) {
          if (n.id == id) {
            return NotificationModel(
              id: n.id,
              type: n.type,
              isRead: true,
              title: n.title, // keep existing title
              message: n.message, // keep existing message
              data: n.data,
            );
          }
          return n;
        }).toList();
        state = AsyncValue.data(updated);
      });
    } catch (e) {
      // optional: log error
    }
  }
}
