import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class ConfirmationScreen extends StatelessWidget {
  final int bookingId;
  final String action; // 'accepted' or 'declined'

  const ConfirmationScreen({
    super.key,
    required this.bookingId,
    required this.action,
  });

  @override
  Widget build(BuildContext context) {
    final title = action == 'accepted'
        ? 'Booking Accepted'
        : 'Booking Declined';
    final icon = action == 'accepted'
        ? Icons.check_circle_outline
        : Icons.cancel_outlined;
    final color = action == 'accepted' ? Colors.green : Colors.red;

    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 72, color: color),
              const SizedBox(height: 16),
              Text(
                title,
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Booking #$bookingId has been $action.',
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () => context.go('/dashboard'),
                child: const Text('Go to Dashboard'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
