import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:food_loss_app/models/food_item.dart';
import 'package:food_loss_app/widgets/food_item_card_animated.dart';

void main() {
  group('FoodItemCardAnimated Tests', () {
    testWidgets('FoodItemCardAnimatedが基本的な情報を表示すること', (WidgetTester tester) async {
      final foodItem = FoodItem(
        id: 'test-id',
        name: 'テスト食材',
        expiryDate: DateTime.now().add(const Duration(days: 3)),
        registrationDate: DateTime.now(),
        quantity: 2,
        storageLocation: '冷蔵庫',
        category: '野菜',
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: FoodItemCardAnimated(
              foodItem: foodItem,
              onTap: () {},
              onEdit: () {},
              onDelete: () {},
              onConsume: () {},
            ),
          ),
        ),
      );

      // アニメーションが完了するまで待機
      await tester.pumpAndSettle();

      // 食材名が表示されていること
      expect(find.text('テスト食材'), findsOneWidget);
      
      // 数量が表示されていること
      expect(find.text('数量: 2'), findsOneWidget);
      
      // 保管場所が表示されていること
      expect(find.text('冷蔵庫'), findsOneWidget);
    });

    testWidgets('期限切れの食材が正しく表示されること', (WidgetTester tester) async {
      final expiredItem = FoodItem(
        id: 'expired-id',
        name: '期限切れ食材',
        expiryDate: DateTime.now().subtract(const Duration(days: 1)),
        registrationDate: DateTime.now(),
        quantity: 1,
        storageLocation: '冷蔵庫',
        category: '野菜',
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: FoodItemCardAnimated(
              foodItem: expiredItem,
              onTap: () {},
              onEdit: () {},
              onDelete: () {},
              onConsume: () {},
            ),
          ),
        ),
      );

      // アニメーションが完了するまで待機
      await tester.pumpAndSettle();

      // 期限切れの表示があること
      expect(find.text('期限切れ'), findsOneWidget);
    });

    testWidgets('期限が近い食材が正しく表示されること', (WidgetTester tester) async {
      final nearItem = FoodItem(
        id: 'near-id',
        name: '期限近い食材',
        expiryDate: DateTime.now().add(const Duration(days: 2, hours: 23)),
        registrationDate: DateTime.now(),
        quantity: 1,
        storageLocation: '冷蔵庫',
        category: '野菜',
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: FoodItemCardAnimated(
              foodItem: nearItem,
              onTap: () {},
              onEdit: () {},
              onDelete: () {},
              onConsume: () {},
            ),
          ),
        ),
      );

      // アニメーションが完了するまで待機
      await tester.pumpAndSettle();

      // 期限が近い表示があること
      expect(find.text('あと2日'), findsOneWidget);
    });

    testWidgets('タップイベントが正しく動作すること', (WidgetTester tester) async {
      bool onTapCalled = false;

      final foodItem = FoodItem(
        id: 'test-id',
        name: 'テスト食材',
        expiryDate: DateTime.now().add(const Duration(days: 3)),
        registrationDate: DateTime.now(),
        quantity: 2,
        storageLocation: '冷蔵庫',
        category: '野菜',
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: FoodItemCardAnimated(
              foodItem: foodItem,
              onTap: () => onTapCalled = true,
              onEdit: () {},
              onDelete: () {},
              onConsume: () {},
            ),
          ),
        ),
      );

      // アニメーションが完了するまで待機
      await tester.pumpAndSettle();

      // カード全体をタップ
      await tester.tap(find.byType(FoodItemCardAnimated));
      await tester.pump();

      expect(onTapCalled, true);
    });

    testWidgets('画像がある場合に正しく表示されること', (WidgetTester tester) async {
      final foodItem = FoodItem(
        id: 'test-id',
        name: '画像付き食材',
        expiryDate: DateTime.now().add(const Duration(days: 3)),
        registrationDate: DateTime.now(),
        quantity: 1,
        storageLocation: '冷蔵庫',
        category: '野菜',
        imagePath: 'https://example.com/image.jpg',
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: FoodItemCardAnimated(
              foodItem: foodItem,
              onTap: () {},
              onEdit: () {},
              onDelete: () {},
              onConsume: () {},
            ),
          ),
        ),
      );

      // アニメーションが完了するまで待機
      await tester.pumpAndSettle();

      // 画像が表示されていること
      expect(find.byType(Image), findsOneWidget);
    });

    testWidgets('アニメーションが正常に動作すること', (WidgetTester tester) async {
      final foodItem = FoodItem(
        id: 'test-id',
        name: 'テスト食材',
        expiryDate: DateTime.now().add(const Duration(days: 3)),
        registrationDate: DateTime.now(),
        quantity: 2,
        storageLocation: '冷蔵庫',
        category: '野菜',
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: FoodItemCardAnimated(
              foodItem: foodItem,
              onTap: () {},
              onEdit: () {},
              onDelete: () {},
              onConsume: () {},
            ),
          ),
        ),
      );

      // 初期状態ではアニメーションが開始されている
      await tester.pump();
      
      // アニメーションが完了するまで待機
      await tester.pumpAndSettle();

      // 食材名が表示されていることを確認
      expect(find.text('テスト食材'), findsOneWidget);
    });
  });
}
