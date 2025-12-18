// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:tradie/main.dart';

void main() {
  testWidgets('App starts with login screen', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const ProviderScope(child: TradieApp()));

    // Wait for the app to settle
    await tester.pumpAndSettle();

    // Verify that we're on the login screen
    // We updated these lines to match your new UI
    expect(find.text('FIXO'), findsOneWidget);
    expect(find.text('Enter your credentials to get started.'), findsOneWidget);

    // This one finds the "Login" button, which exists in both designs
    expect(find.text('Login'), findsOneWidget);
  });
}