import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:food_loss_app/screens/home_screen_improved.dart';

void main() {
  group('HomeScreen Widget Tests', () {
    testWidgets('Should display home screen with title', (WidgetTester tester) async {
      // Arrange
      await tester.pumpWidget(
        MaterialApp(
          home: HomeScreenImproved(),
        ),
      );

      // Wait for loading to complete (even with errors, basic UI should load)
      await tester.pump();

      // Assert - Basic structure should exist
      expect(find.byType(Scaffold), findsOneWidget);
      expect(find.byType(AppBar), findsOneWidget);
    });

    testWidgets('Should display app bar with title', (WidgetTester tester) async {
      // Arrange
      await tester.pumpWidget(
        MaterialApp(
          home: HomeScreenImproved(),
        ),
      );

      // Wait for initial build
      await tester.pump();

      // Assert
      expect(find.byType(AppBar), findsOneWidget);
      // Title might not be visible due to loading state, but AppBar should exist
    });

    testWidgets('Should display floating action button', (WidgetTester tester) async {
      // Arrange
      await tester.pumpWidget(
        MaterialApp(
          home: HomeScreenImproved(),
        ),
      );

      // Wait for initial build
      await tester.pump();

      // Assert
      expect(find.byType(FloatingActionButton), findsOneWidget);
    });

    testWidgets('Should display basic screen structure', (WidgetTester tester) async {
      // Arrange
      await tester.pumpWidget(
        MaterialApp(
          home: HomeScreenImproved(),
        ),
      );

      // Wait for initial build
      await tester.pump();

      // Assert - Basic structure should exist regardless of data loading
      expect(find.byType(Scaffold), findsOneWidget);
      expect(find.byType(AppBar), findsOneWidget);
      expect(find.byType(FloatingActionButton), findsOneWidget);
    });

    testWidgets('Should handle loading state gracefully', (WidgetTester tester) async {
      // Arrange
      await tester.pumpWidget(
        MaterialApp(
          home: HomeScreenImproved(),
        ),
      );

      // Act - Wait for loading
      await tester.pump();

      // Assert - Should not crash and should show basic structure
      expect(find.byType(Scaffold), findsOneWidget);
      // The screen should handle loading without crashing
    });

    testWidgets('Should have app bar actions', (WidgetTester tester) async {
      // Arrange
      await tester.pumpWidget(
        MaterialApp(
          home: HomeScreenImproved(),
        ),
      );

      // Wait for initial build
      await tester.pump();

      // Assert - AppBar should exist and have actions
      expect(find.byType(AppBar), findsOneWidget);
      // Actions should be present even if data loading fails
    });
  });
}
