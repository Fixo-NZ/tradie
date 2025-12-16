import 'package:flutter_test/flutter_test.dart';
import 'package:tradie/features/notification/models/notification_model.dart';
import 'package:tradie/features/notification/repositories/notification_repository.dart';
import 'package:tradie/features/notification/viewmodels/notification_viewmodel.dart';

class FakeNotificationRepository extends NotificationRepository {
  final List<int> accepted = [];
  final List<int> declined = [];
  final List<String> markedRead = [];
  int fetchCalls = 0;
  final List<NotificationModel> _notifications;

  FakeNotificationRepository(this._notifications) : super(dio: null as dynamic);

  @override
  Future<List<NotificationModel>> fetchNotifications() async {
    fetchCalls++;
    return List<NotificationModel>.from(_notifications);
  }

  @override
  Future<void> markAsRead(String id) async {
    markedRead.add(id);
    return;
  }

  @override
  Future<void> acceptBooking(int bookingId) async {
    accepted.add(bookingId);
    return;
  }

  @override
  Future<void> declineBooking(int bookingId) async {
    declined.add(bookingId);
    return;
  }
}

NotificationModel buildNotification({
  required String id,
  required dynamic bookingId,
}) {
  return NotificationModel(
    id: id,
    type: 'JobBookedNotification',
    isRead: false,
    title: 'Title',
    message: 'Message',
    data: {'booking_id': bookingId},
  );
}

void main() {
  group('NotificationViewModel accept/decline', () {
    test(
      'acceptBooking with int booking_id calls repository with int',
      () async {
        final notif = buildNotification(id: 'n1', bookingId: 17);
        final repo = FakeNotificationRepository([notif]);

        final vm = NotificationViewModel(repo);

        // wait for initial load
        await Future.delayed(Duration(milliseconds: 50));

        await vm.acceptBooking(notif);

        expect(repo.accepted, [17]);
        expect(repo.markedRead, contains('n1'));
        expect(repo.fetchCalls, greaterThanOrEqualTo(1));
      },
    );

    test(
      'acceptBooking with String booking_id parses and calls repository',
      () async {
        final notif = buildNotification(id: 'n2', bookingId: '42');
        final repo = FakeNotificationRepository([notif]);

        final vm = NotificationViewModel(repo);
        await Future.delayed(Duration(milliseconds: 50));

        await vm.acceptBooking(notif);

        expect(repo.accepted, [42]);
        expect(repo.markedRead, contains('n2'));
      },
    );

    test(
      'declineBooking with int booking_id calls repository with int',
      () async {
        final notif = buildNotification(id: 'n3', bookingId: 7);
        final repo = FakeNotificationRepository([notif]);

        final vm = NotificationViewModel(repo);
        await Future.delayed(Duration(milliseconds: 50));

        await vm.declineBooking(notif);

        expect(repo.declined, [7]);
        expect(repo.markedRead, contains('n3'));
      },
    );

    test(
      'declineBooking with String booking_id parses and calls repository',
      () async {
        final notif = buildNotification(id: 'n4', bookingId: '99');
        final repo = FakeNotificationRepository([notif]);

        final vm = NotificationViewModel(repo);
        await Future.delayed(Duration(milliseconds: 50));

        await vm.declineBooking(notif);

        expect(repo.declined, [99]);
        expect(repo.markedRead, contains('n4'));
      },
    );
  });
}
