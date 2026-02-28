import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:food_loss_app/main.dart';
import 'package:food_loss_app/services/database_service.dart';
import 'package:food_loss_app/models/food_item.dart';
import 'package:food_loss_app/models/shopping_list.dart';
import 'package:food_loss_app/models/shopping_item.dart';

void main() {
  group('エンドツーエンドテスト', () {
    setUpAll(() async {
      // テスト用データベースの初期化
      if (!const bool.fromEnvironment('dart.library.html')) {
        try {
          await DatabaseService.database;
        } catch (e) {
          print('データベース初期化エラー（テスト環境のため許容）: $e');
        }
      }
    });

    tearDownAll(() async {
      // テスト後のクリーンアップ
      try {
        await DatabaseService.close();
      } catch (e) {
        print('データベースクローズエラー（テスト環境のため許容）: $e');
      }
    });

    group('ユーザーストーリーの完遂', () {
      testWidgets('新規ユーザーの初回利用フロー', (WidgetTester tester) async {
        // アプリを起動
        await tester.pumpWidget(const FoodLossApp());
        await tester.pumpAndSettle();

        // 初回起動画面が表示されることを確認
        expect(find.text('食品ロス削減アプリ'), findsOneWidget);
        expect(find.text('食品一覧'), findsOneWidget);
        expect(find.text('買い物リスト'), findsOneWidget);
        expect(find.text('レシピ検索'), findsOneWidget);

        // 食品追加機能をテスト
        final addFoodButton = find.byIcon(Icons.add);
        await tester.tap(addFoodButton);
        await tester.pumpAndSettle();

        // 食品情報を入力
        await tester.enterText(find.byKey(const Key('food_name')), 'テスト牛乳');
        await tester.enterText(find.byKey(const Key('food_category')), '乳製品');
        await tester.enterText(find.byKey(const Key('food_quantity')), '2');
        await tester.enterText(find.byKey(const Key('food_location')), '冷蔵庫');

        // 保存ボタンをタップ
        final saveButton = find.text('保存');
        await tester.tap(saveButton);
        await tester.pumpAndSettle();

        // ホーム画面に戻り、追加した食品が表示されていることを確認
        expect(find.text('テスト牛乳'), findsOneWidget);
        expect(find.text('乳製品'), findsOneWidget);
        expect(find.text('2個'), findsOneWidget);
        expect(find.text('冷蔵庫'), findsOneWidget);

        // ショッピングリスト機能をテスト
        final shoppingListButton = find.text('買い物リスト');
        await tester.tap(shoppingListButton);
        await tester.pumpAndSettle();

        // 新規リスト作成
        final createListButton = find.byIcon(Icons.add);
        await tester.tap(createListButton);
        await tester.pumpAndSettle();

        await tester.enterText(find.byType(TextField), '初回利用テストリスト');
        final createButton = find.text('作成');
        await tester.tap(createButton);
        await tester.pumpAndSettle();

        // リストが作成されたことを確認
        expect(find.text('初回利用テストリスト'), findsOneWidget);
      });

      testWidgets('食品の追加から消費までのライフサイクル', (WidgetTester tester) async {
        // アプリを起動
        await tester.pumpWidget(const FoodLossApp());
        await tester.pumpAndSettle();

        // 食品を追加
        final addFoodButton = find.byIcon(Icons.add);
        await tester.tap(addFoodButton);
        await tester.pumpAndSettle();

        await tester.enterText(find.byKey(const Key('food_name')), '消費テスト野菜');
        await tester.enterText(find.byKey(const Key('food_category')), '野菜');
        await tester.enterText(find.byKey(const Key('food_quantity')), '1');
        await tester.enterText(find.byKey(const Key('food_location')), '冷蔵庫');

        final saveButton = find.text('保存');
        await tester.tap(saveButton);
        await tester.pumpAndSettle();

        // 追加された食品を確認
        expect(find.text('消費テスト野菜'), findsOneWidget);

        // 食品を消費済みにする
        final consumeButton = find.byIcon(Icons.check);
        await tester.tap(consumeButton);
        await tester.pumpAndSettle();

        // 消費確認ダイアログで確認
        final confirmButton = find.text('消費');
        await tester.tap(confirmButton);
        await tester.pumpAndSettle();

        // 消費済み状態が反映されていることを確認
        expect(find.byIcon(Icons.check_circle), findsOneWidget);
      });

      testWidgets('ショッピングリストの作成から完了まで', (WidgetTester tester) async {
        // アプリを起動
        await tester.pumpWidget(const FoodLossApp());
        await tester.pumpAndSettle();

        // ショッピングリスト画面に遷移
        final shoppingListButton = find.text('買い物リスト');
        await tester.tap(shoppingListButton);
        await tester.pumpAndSettle();

        // 新規リスト作成
        final createListButton = find.byIcon(Icons.add);
        await tester.tap(createListButton);
        await tester.pumpAndSettle();

        await tester.enterText(find.byType(TextField), '完了テストリスト');
        final createButton = find.text('作成');
        await tester.tap(createButton);
        await tester.pumpAndSettle();

        // 複数アイテムを追加
        for (int i = 1; i <= 3; i++) {
          final addItemButton = find.byIcon(Icons.add);
          await tester.tap(addItemButton);
          await tester.pumpAndSettle();

          await tester.enterText(find.byType(TextField), 'テスト商品$i');
          await tester.enterText(find.byKey(const Key('item_quantity')), '$i');
          
          final addButton = find.text('追加');
          await tester.tap(addButton);
          await tester.pumpAndSettle();
        }

        // すべてのアイテムが追加されたことを確認
        expect(find.text('テスト商品1'), findsOneWidget);
        expect(find.text('テスト商品2'), findsOneWidget);
        expect(find.text('テスト商品3'), findsOneWidget);

        // アイテムを購入済みにする
        final checkboxes = find.byType(Checkbox);
        expect(checkboxes, findsNWidgets(3));

        // 最初のアイテムを購入済みに
        await tester.tap(checkboxes.first);
        await tester.pumpAndSettle();

        // 購入済み状態が反映されていることを確認
        expect(find.byIcon(Icons.check_box), findsOneWidget);
      });

      testWidgets('レシピ検索から材料追加まで', (WidgetTester tester) async {
        // アプリを起動
        await tester.pumpWidget(const FoodLossApp());
        await tester.pumpAndSettle();

        // レシピ検索画面に遷移
        final recipeButton = find.text('レシピ検索');
        await tester.tap(recipeButton);
        await tester.pumpAndSettle();

        // 検索語を入力
        await tester.enterText(find.byType(TextField), 'カレー');
        await tester.pumpAndSettle();

        // 検索ボタンをタップ
        final searchButton = find.byIcon(Icons.search);
        await tester.tap(searchButton);
        await tester.pumpAndSettle();

        // 検索結果が表示されることを確認
        expect(find.byType(ListTile), findsWidgets);

        // 最初のレシピをタップ
        final firstRecipe = find.byType(ListTile).first;
        await tester.tap(firstRecipe);
        await tester.pumpAndSettle();

        // レシピ詳細画面に遷移したことを確認
        expect(find.text('材料'), findsOneWidget);
        expect(find.text('作り方'), findsOneWidget);

        // 材料をショッピングリストに追加
        final addToShoppingListButton = find.text('買い物リストに追加');
        if (addToShoppingListButton.evaluate().isNotEmpty) {
          await tester.tap(addToShoppingListButton);
          await tester.pumpAndSettle();

          // 追加確認メッセージが表示されることを確認
          expect(find.text('材料を買い物リストに追加しました'), findsOneWidget);
        }
      });
    });

    group('複数画面をまたぐ操作', () {
      testWidgets('ホーム→食品追加→ショッピングリスト→ホーム', (WidgetTester tester) async {
        // アプリを起動
        await tester.pumpWidget(const FoodLossApp());
        await tester.pumpAndSettle();

        // ホーム→食品追加
        final addFoodButton = find.byIcon(Icons.add);
        await tester.tap(addFoodButton);
        await tester.pumpAndSettle();

        await tester.enterText(find.byKey(const Key('food_name')), '画面遷移テスト食品');
        await tester.enterText(find.byKey(const Key('food_category')), 'テスト');
        await tester.enterText(find.byKey(const Key('food_quantity')), '1');
        await tester.enterText(find.byKey(const Key('food_location')), 'テスト');

        final saveButton = find.text('保存');
        await tester.tap(saveButton);
        await tester.pumpAndSettle();

        // 食品追加→ショッピングリスト
        final shoppingListButton = find.text('買い物リスト');
        await tester.tap(shoppingListButton);
        await tester.pumpAndSettle();

        // ショッピングリスト→ホーム
        final homeButton = find.byIcon(Icons.home);
        await tester.tap(homeButton);
        await tester.pumpAndSettle();

        // ホーム画面に戻り、追加した食品が表示されていることを確認
        expect(find.text('画面遷移テスト食品'), findsOneWidget);
        expect(find.text('食品一覧'), findsOneWidget);
      });

      testWidgets('レシピ検索→詳細→材料追加→ホーム', (WidgetTester tester) async {
        // アプリを起動
        await tester.pumpWidget(const FoodLossApp());
        await tester.pumpAndSettle();

        // レシピ検索画面に遷移
        final recipeButton = find.text('レシピ検索');
        await tester.tap(recipeButton);
        await tester.pumpAndSettle();

        // 検索実行
        await tester.enterText(find.byType(TextField), 'テストレシピ');
        await tester.pumpAndSettle();

        final searchButton = find.byIcon(Icons.search);
        await tester.tap(searchButton);
        await tester.pumpAndSettle();

        // レシピ詳細に遷移
        if (find.byType(ListTile).evaluate().isNotEmpty) {
          final firstRecipe = find.byType(ListTile).first;
          await tester.tap(firstRecipe);
          await tester.pumpAndSettle();

          // 材料を追加
          final addToShoppingListButton = find.text('買い物リストに追加');
          if (addToShoppingListButton.evaluate().isNotEmpty) {
            await tester.tap(addToShoppingListButton);
            await tester.pumpAndSettle();

            // ホーム画面に戻る
            final homeButton = find.byIcon(Icons.home);
            await tester.tap(homeButton);
            await tester.pumpAndSettle();

            // ホーム画面が表示されていることを確認
            expect(find.text('食品一覧'), findsOneWidget);
          }
        }
      });
    });

    group('データの永続化', () {
      testWidgets('アプリ再起動時のデータ保持', (WidgetTester tester) async {
        // アプリを起動してデータを追加
        await tester.pumpWidget(const FoodLossApp());
        await tester.pumpAndSettle();

        final addFoodButton = find.byIcon(Icons.add);
        await tester.tap(addFoodButton);
        await tester.pumpAndSettle();

        await tester.enterText(find.byKey(const Key('food_name')), '永続化テスト食品');
        await tester.enterText(find.byKey(const Key('food_category')), 'テスト');
        await tester.enterText(find.byKey(const Key('food_quantity')), '1');
        await tester.enterText(find.byKey(const Key('food_location')), 'テスト');

        final saveButton = find.text('保存');
        await tester.tap(saveButton);
        await tester.pumpAndSettle();

        // アプリを再起動（シミュレート）
        await tester.pumpWidget(const FoodLossApp());
        await tester.pumpAndSettle();

        // データが保持されていることを確認
        expect(find.text('永続化テスト食品'), findsOneWidget);
      });

      testWidgets('ショッピングリストの状態保持', (WidgetTester tester) async {
        // アプリを起動
        await tester.pumpWidget(const FoodLossApp());
        await tester.pumpAndSettle();

        // ショッピングリスト画面に遷移
        final shoppingListButton = find.text('買い物リスト');
        await tester.tap(shoppingListButton);
        await tester.pumpAndSettle();

        // 新規リスト作成
        final createListButton = find.byIcon(Icons.add);
        await tester.tap(createListButton);
        await tester.pumpAndSettle();

        await tester.enterText(find.byType(TextField), '状態保持テストリスト');
        final createButton = find.text('作成');
        await tester.tap(createButton);
        await tester.pumpAndSettle();

        // アイテムを追加
        final addItemButton = find.byIcon(Icons.add);
        await tester.tap(addItemButton);
        await tester.pumpAndSettle();

        await tester.enterText(find.byType(TextField), '状態保持テスト商品');
        await tester.enterText(find.byKey(const Key('item_quantity')), '2');
        final addButton = find.text('追加');
        await tester.tap(addButton);
        await tester.pumpAndSettle();

        // アイテムを購入済みに
        final checkbox = find.byType(Checkbox);
        await tester.tap(checkbox);
        await tester.pumpAndSettle();

        // 画面を再描画（状態更新）
        await tester.pumpWidget(const FoodLossApp());
        await tester.pumpAndSettle();

        // 状態が保持されていることを確認
        expect(find.text('状態保持テストリスト'), findsOneWidget);
        expect(find.text('状態保持テスト商品'), findsOneWidget);
        expect(find.byIcon(Icons.check_box), findsOneWidget);
      });
    });

    group('エラーハンドリング', () {
      testWidgets('ネットワークエラー時のユーザー体験', (WidgetTester tester) async {
        // アプリを起動
        await tester.pumpWidget(const FoodLossApp());
        await tester.pumpAndSettle();

        // レシピ検索画面に遷移
        final recipeButton = find.text('レシピ検索');
        await tester.tap(recipeButton);
        await tester.pumpAndSettle();

        // 検索を実行（ネットワークエラーをシミュレート）
        await tester.enterText(find.byType(TextField), 'ネットワークエラーテスト');
        await tester.pumpAndSettle();

        final searchButton = find.byIcon(Icons.search);
        await tester.tap(searchButton);
        await tester.pumpAndSettle();

        // ローディングインジケーターが表示されることを確認
        expect(find.byType(CircularProgressIndicator), findsOneWidget);

        // エラーメッセージが表示されるまで待機
        await tester.pump(const Duration(seconds: 3));

        // エラーハンドリングが適切に行われていることを確認
        // （実際のエラーはAPI層で処理される）
        expect(find.byType(SnackBar), findsWidgets);
      });

      testWidgets('データベースエラー時のリカバリー', (WidgetTester tester) async {
        // アプリを起動
        await tester.pumpWidget(const FoodLossApp());
        await tester.pumpAndSettle();

        // 食品追加を試行
        final addFoodButton = find.byIcon(Icons.add);
        await tester.tap(addFoodButton);
        await tester.pumpAndSettle();

        // 無効なデータを入力
        await tester.enterText(find.byKey(const Key('food_name')), '');
        await tester.enterText(find.byKey(const Key('food_category')), '');
        await tester.enterText(find.byKey(const Key('food_quantity')), '');
        await tester.enterText(find.byKey(const Key('food_location')), '');

        // 保存ボタンをタップ
        final saveButton = find.text('保存');
        await tester.tap(saveButton);
        await tester.pumpAndSettle();

        // バリデーションエラーが表示されることを確認
        expect(find.text('食品名は必須です'), findsOneWidget);
        expect(find.text('カテゴリは必須です'), findsOneWidget);
        expect(find.text('数量は必須です'), findsOneWidget);
        expect(find.text('保管場所は必須です'), findsOneWidget);
      });
    });

    group('パフォーマンスのテスト', () {
      testWidgets('大量データ時の応答性', (WidgetTester tester) async {
        // アプリを起動
        await tester.pumpWidget(const FoodLossApp());
        await tester.pumpAndSettle();

        // 複数の食品を追加
        final stopwatch = Stopwatch()..start();
        
        for (int i = 0; i < 10; i++) {
          final addFoodButton = find.byIcon(Icons.add);
          await tester.tap(addFoodButton);
          await tester.pumpAndSettle();

          await tester.enterText(find.byKey(const Key('food_name')), 'パフォーマンステスト$i');
          await tester.enterText(find.byKey(const Key('food_category')), 'テスト');
          await tester.enterText(find.byKey(const Key('food_quantity')), '1');
          await tester.enterText(find.byKey(const Key('food_location')), 'テスト');

          final saveButton = find.text('保存');
          await tester.tap(saveButton);
          await tester.pumpAndSettle();
        }

        stopwatch.stop();
        print('10件の食品追加時間: ${stopwatch.elapsedMilliseconds}ms');
        expect(stopwatch.elapsedMilliseconds, lessThan(30000)); // 30秒以内

        // すべての食品が表示されていることを確認
        for (int i = 0; i < 10; i++) {
          expect(find.text('パフォーマンステスト$i'), findsOneWidget);
        }
      });

      testWidgets('画面遷移の応答性', (WidgetTester tester) async {
        // アプリを起動
        await tester.pumpWidget(const FoodLossApp());
        await tester.pumpAndSettle();

        final stopwatch = Stopwatch()..start();

        // 複数の画面遷移を実行
        final screens = [
          find.text('買い物リスト'),
          find.text('レシピ検索'),
          find.byIcon(Icons.home),
        ];

        for (final screen in screens) {
          if (screen.evaluate().isNotEmpty) {
            await tester.tap(screen);
            await tester.pumpAndSettle();
          }
        }

        stopwatch.stop();
        print('画面遷移時間: ${stopwatch.elapsedMilliseconds}ms');
        expect(stopwatch.elapsedMilliseconds, lessThan(5000)); // 5秒以内
      });
    });
  });
}
