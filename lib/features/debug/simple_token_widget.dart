import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class SimpleTokenWidget extends StatelessWidget {
  const SimpleTokenWidget({super.key});

  @override
  Widget build(BuildContext context) {
    // Mock FCM token for testing
    const mockToken = "eXaMpLe_FcM_tOkEn_fOr_TeStInG_1234567890abcdef";
    
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.orange.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.orange.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              const Icon(Icons.warning, color: Colors.orange),
              const SizedBox(width: 8),
              const Text(
                'Mock FCM Token (For Testing)',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.orange,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Text('🧪 Mock Token:', style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(4),
            ),
            child: const SelectableText(
              mockToken,
              style: TextStyle(fontSize: 12, fontFamily: 'monospace'),
            ),
          ),
          const SizedBox(height: 8),
          ElevatedButton.icon(
            onPressed: () {
              Clipboard.setData(const ClipboardData(text: mockToken));
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Mock token copied! Use this to test your Laravel backend.'),
                  backgroundColor: Colors.orange,
                ),
              );
            },
            icon: const Icon(Icons.copy, size: 16),
            label: const Text('Copy Mock Token'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orange,
              foregroundColor: Colors.white,
            ),
          ),
          const SizedBox(height: 12),
          const Text(
            '💡 This is a mock token. Your Laravel backend can still be tested with this.',
            style: TextStyle(fontSize: 12, color: Colors.grey),
          ),
        ],
      ),
    );
  }
}