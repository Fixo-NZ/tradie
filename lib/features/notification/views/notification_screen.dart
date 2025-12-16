import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../viewmodels/notification_viewmodel.dart';
import 'package:go_router/go_router.dart';
import 'confirmation_screen.dart';

class NotificationScreen extends ConsumerStatefulWidget {
  const NotificationScreen({super.key});

  @override
  ConsumerState<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends ConsumerState<NotificationScreen> {
  final Map<int, String> _loadingBookingAction =
      {}; // bookingId -> 'accept'|'decline'

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(notificationViewModelProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/dashboard'),
        ),
      ),
      body: state.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (notifications) {
          if (notifications.isEmpty) {
            return const Center(child: Text('No notifications yet.'));
          }

          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: notifications.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final n = notifications[index];

              final bool isJobBooked =
                  n.data['type'] == 'job_booked' &&
                  n.data['booking_id'] != null;

              final rawBookingId = isJobBooked ? n.data['booking_id'] : null;
              // booking status provided by backend (e.g., 'pending','confirmed','canceled')
              final bookingStatus = n.data['status']?.toString();
              final int? bookingId = rawBookingId is int
                  ? rawBookingId
                  : (rawBookingId != null
                        ? int.tryParse(rawBookingId.toString())
                        : null);

              final isAcceptLoading =
                  bookingId != null &&
                  _loadingBookingAction[bookingId] == 'accept';
              final isDeclineLoading =
                  bookingId != null &&
                  _loadingBookingAction[bookingId] == 'decline';
              final isAnyLoading =
                  bookingId != null &&
                  _loadingBookingAction.containsKey(bookingId);

              return Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: n.isRead ? Colors.white : Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Title
                    Text(
                      n.title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),

                    // Message
                    Text(n.message, style: const TextStyle(fontSize: 14)),

                    // Accept / Decline buttons
                    // Only show actions if booking is pending (or status not provided by server)
                    if (isJobBooked &&
                        !n.isRead &&
                        bookingId != null &&
                        (bookingStatus == null ||
                            bookingStatus == 'pending')) ...[
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: ElevatedButton(
                              onPressed: (bookingId == null || isAnyLoading)
                                  ? null
                                  : () async {
                                      setState(() {
                                        if (bookingId != null)
                                          _loadingBookingAction[bookingId] =
                                              'accept';
                                      });

                                      try {
                                        await ref
                                            .read(
                                              notificationViewModelProvider
                                                  .notifier,
                                            )
                                            .acceptBooking(n);

                                        Navigator.of(context).push(
                                          MaterialPageRoute(
                                            builder: (_) => ConfirmationScreen(
                                              bookingId: bookingId,
                                              action: 'accepted',
                                            ),
                                          ),
                                        );
                                      } catch (e) {
                                        final msg = e.toString();

                                        // Treat 404 as "already handled / not found"
                                        if (msg.contains('HTTP_404') ||
                                            msg.contains('No query results') ||
                                            msg.contains('404')) {
                                          showDialog<void>(
                                            context: context,
                                            builder: (ctx) => AlertDialog(
                                              title: const Text('Notice'),
                                              content: const Text(
                                                'Booking not found or already handled. Refreshing notifications.',
                                              ),
                                              actions: [
                                                TextButton(
                                                  onPressed: () {
                                                    Navigator.of(ctx).pop();
                                                    // refresh notifications
                                                    ref
                                                        .read(
                                                          notificationViewModelProvider
                                                              .notifier,
                                                        )
                                                        .loadNotifications();
                                                  },
                                                  child: const Text('OK'),
                                                ),
                                              ],
                                            ),
                                          );
                                        } else {
                                          showDialog<void>(
                                            context: context,
                                            builder: (ctx) => AlertDialog(
                                              title: const Text('Error'),
                                              content: Text(
                                                'Failed to accept booking: $msg',
                                              ),
                                              actions: [
                                                TextButton(
                                                  onPressed: () =>
                                                      Navigator.of(ctx).pop(),
                                                  child: const Text('OK'),
                                                ),
                                              ],
                                            ),
                                          );
                                        }
                                      } finally {
                                        setState(() {
                                          if (bookingId != null)
                                            _loadingBookingAction.remove(
                                              bookingId,
                                            );
                                        });
                                      }
                                    },
                              child: isAcceptLoading
                                  ? const SizedBox(
                                      height: 16,
                                      width: 16,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        color: Colors.white,
                                      ),
                                    )
                                  : const Text('Accept'),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: OutlinedButton(
                              onPressed: (bookingId == null || isAnyLoading)
                                  ? null
                                  : () async {
                                      setState(() {
                                        if (bookingId != null)
                                          _loadingBookingAction[bookingId] =
                                              'decline';
                                      });

                                      try {
                                        await ref
                                            .read(
                                              notificationViewModelProvider
                                                  .notifier,
                                            )
                                            .declineBooking(n);

                                        Navigator.of(context).push(
                                          MaterialPageRoute(
                                            builder: (_) => ConfirmationScreen(
                                              bookingId: bookingId,
                                              action: 'declined',
                                            ),
                                          ),
                                        );
                                      } catch (e) {
                                        final msg = e.toString();

                                        if (msg.contains('HTTP_404') ||
                                            msg.contains('No query results') ||
                                            msg.contains('404')) {
                                          showDialog<void>(
                                            context: context,
                                            builder: (ctx) => AlertDialog(
                                              title: const Text('Notice'),
                                              content: const Text(
                                                'Booking not found or already handled. Refreshing notifications.',
                                              ),
                                              actions: [
                                                TextButton(
                                                  onPressed: () {
                                                    Navigator.of(ctx).pop();
                                                    ref
                                                        .read(
                                                          notificationViewModelProvider
                                                              .notifier,
                                                        )
                                                        .loadNotifications();
                                                  },
                                                  child: const Text('OK'),
                                                ),
                                              ],
                                            ),
                                          );
                                        } else {
                                          showDialog<void>(
                                            context: context,
                                            builder: (ctx) => AlertDialog(
                                              title: const Text('Error'),
                                              content: Text(
                                                'Failed to decline booking: $msg',
                                              ),
                                              actions: [
                                                TextButton(
                                                  onPressed: () =>
                                                      Navigator.of(ctx).pop(),
                                                  child: const Text('OK'),
                                                ),
                                              ],
                                            ),
                                          );
                                        }
                                      } finally {
                                        setState(() {
                                          if (bookingId != null)
                                            _loadingBookingAction.remove(
                                              bookingId,
                                            );
                                        });
                                      }
                                    },
                              child: isDeclineLoading
                                  ? const SizedBox(
                                      height: 16,
                                      width: 16,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                      ),
                                    )
                                  : const Text('Decline'),
                            ),
                          ),
                        ],
                      ),
                    ],

                    // Unread indicator
                    if (!n.isRead)
                      const Align(
                        alignment: Alignment.centerRight,
                        child: Padding(
                          padding: EdgeInsets.only(top: 8),
                          child: Icon(
                            Icons.circle,
                            size: 10,
                            color: Colors.blue,
                          ),
                        ),
                      ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}
