import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ablemate/main.dart'; // ✅ Fix: import your app entry point

void main() {
  testWidgets('App launches and shows Get Started screen', (WidgetTester tester) async {
    // Build app
    await tester.pumpWidget(const AbleMateApp());

    // Expect text from Get Started screen
    expect(find.text("Get Started"), findsOneWidget);
    expect(find.text("AbleMate"), findsOneWidget);
  });
}
