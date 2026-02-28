import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:food_loss_app/main.dart';

void main() {
  testWidgets('App smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const FoodLossApp(notificationService: null));

    // Verify that our app starts with the home screen
    expect(find.text('食品ロス削減アプリ'), findsWidgets);
  });
}
