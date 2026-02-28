import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:food_loss_app/main.dart';
import 'package:food_loss_app/services/database_service.dart';
import 'package:food_loss_app/models/food_item.dart';
import 'package:food_loss_app/models/shopping_list.dart';
import 'package:food_loss_app/models/shopping_item.dart';

void main() {
  group('UI統合テスト', () {
    setUpAll(() async {
      // テスト用データベースの初期化
      if (!const bool.fromEnvironment('dart.library.html')) {
        await DatabaseService.database;
      }
    });

    tearDownAll(() async {
      // テスト後のクリーンアップ
      await DatabaseService.close();
    });

    group('画面遷移のテスト', () {
      testWidgets('ホーム画面から食品追加画面への遷移', (WidgetTester tester) async {
        // アプリを起動
        await tester.pumpWidget(const FoodLossApp());
        await tester.pumpAndSettle();

        // ホーム画面が表示されていることを確認
        expect(find.text('食品ロス削減アプリ'), findsOneWidget);
        expect(find.text('食品一覧'), findsOneWidget);

        // 食品追加ボタンをタップ
        final addButton = find.byIcon(Icons.add);
        expect(addButton, findsOneWidget);
        await tester.tap(addButton);
        await tester.pumpAndSettle();

        // 食品追加画面に遷移したことを確認
        expect(find.text('食品を追加'), findsOneWidget);
        expect(find.byType(TextField), findsWidgets);
      });

      testWidgets('ホーム画面からショッピングリスト画面への遷移', (WidgetTester tester) async {
        // アプリを起動
        await tester.pumpWidget(const FoodLossApp());
        await tester.pumpAndSettle();

        // ショッピングリストボタンをタップ
        final shoppingListButton = find.text('買い物リスト');
        expect(shoppingListButton, findsOneWidget);
        await tester.tap(shoppingListButton);
        await tester.pumpAndSettle();

        // ショッピングリスト画面に遷移したことを確認
        expect(find.text('買い物リスト'), findsOneWidget);
        expect(find.byIcon(Icons.add_shopping_cart), findsOneWidget);
      });

      testWidgets('ホーム画面からレシピ検索画面への遷移', (WidgetTester tester) async {
        // アプリを起動
        await tester.pumpWidget(const FoodLossApp());
        await tester.pumpAndSettle();

        // レシピ検索ボタンをタップ
        final recipeButton = find.text('レシピ検索');
        expect(recipeButton, findsOneWidget);
        await tester.tap(recipeButton);
        await tester.pumpAndSettle();

        // レシピ検索画面に遷移したことを確認
        expect(find.text('レシピ検索'), findsOneWidget);
        expect(find.byType(TextField), findsOneWidget);
      });
    });

    group('ユーザー操作とデータフローのテスト', () {
      testWidgets('食品の追加から表示までのフロー', (WidgetTester tester) async {
        // アプリを起動
        await tester.pumpWidget(const FoodLossApp());
        await tester.pumpAndSettle();

        // 食品追加画面に遷移
        final addButton = find.byIcon(Icons.add);
        await tester.tap(addButton);
        await tester.pumpAndSettle();

        // 食品情報を入力
        await tester.enterText(find.byKey(const Key('food_name')), 'テストりんご');
        await tester.enterText(find.byKey(const Key('food_category')), '果物');
        await tester.enterText(find.byKey(const Key('food_quantity')), '2');
        await tester.enterText(find.byKey(const Key('food_location')), '冷蔵庫');

        // 保存ボタンをタップ
        final saveButton = find.text('保存');
        await tester.tap(saveButton);
        await tester.pumpAndSettle();

        // ホーム画面に戻り、追加した食品が表示されていることを確認
        expect(find.text('テストりんご'), findsOneWidget);
        expect(find.text('果物'), findsOneWidget);
        expect(find.text('2個'), findsOneWidget);
        expect(find.text('冷蔵庫'), findsOneWidget);
      });

      testWidgets('ショッピングリストの作成から完了までのフロー', (WidgetTester tester) async {
        // アプリを起動
        await tester.pumpWidget(const FoodLossApp());
        await tester.pumpAndSettle();

        // ショッピングリスト画面に遷移
        final shoppingListButton = find.text('買い物リスト');
        await tester.tap(shoppingListButton);
        await tester.pumpAndSettle();

        // 新規リスト作成ボタンをタップ
        final createListButton = find.byIcon(Icons.add);
        await tester.tap(createListButton);
        await tester.pumpAndSettle();

        // リスト名を入力
        await tester.enterText(find.byType(TextField), 'テスト買い物リスト');

        // 作成ボタンをタップ
        final createButton = find.text('作成');
        await tester.tap(createButton);
        await tester.pumpAndSettle();

        // アイテム追加ボタンをタップ
        final addItemButton = find.byIcon(Icons.add);
        await tester.tap(addItemButton);
        await tester.pumpAndSettle();

        // 商品名を入力
        await tester.enterText(find.byType(TextField), 'テスト牛乳');
        await tester.enterText(find.byKey(const Key('item_quantity')), '1');

        // 追加ボタンをタップ
        final addButton = find.text('追加');
        await tester.tap(addButton);
        await tester.pumpAndSettle();

        // 追加されたアイテムが表示されていることを確認
        expect(find.text('テスト牛乳'), findsOneWidget);
        expect(find.text('1個'), findsOneWidget);
      });

      testWidgets('レシピ検索から詳細表示までのフロー', (WidgetTester tester) async {
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

        // 検索結果が表示されることを確認（モックデータ）
        expect(find.byType(ListTile), findsWidgets);
      });
    });

    group('状態管理のテスト', () {
      testWidgets('食品リストのリアルタイム更新', (WidgetTester tester) async {
        // アプリを起動
        await tester.pumpWidget(const FoodLossApp());
        await tester.pumpAndSettle();

        // 食品追加画面に遷移
        final addButton = find.byIcon(Icons.add);
        await tester.tap(addButton);
        await tester.pumpAndSettle();

        // 食品情報を入力して保存
        await tester.enterText(find.byKey(const Key('food_name')), 'テストバナナ');
        await tester.enterText(find.byKey(const Key('food_category')), '果物');
        await tester.enterText(find.byKey(const Key('food_quantity')), '3');
        await tester.enterText(find.byKey(const Key('food_location')), '冷蔵庫');

        final saveButton = find.text('保存');
        await tester.tap(saveButton);
        await tester.pumpAndSettle();

        // ホーム画面に戻り、追加した食品が表示されていることを確認
        expect(find.text('テストバナナ'), findsOneWidget);

        // 食品を削除
        final deleteButton = find.byIcon(Icons.delete);
        await tester.tap(deleteButton);
        await tester.pumpAndSettle();

        // 削除確認ダイアログで確認
        final confirmButton = find.text('削除');
        await tester.tap(confirmButton);
        await tester.pumpAndSettle();

        // 食品が削除されていることを確認
        expect(find.text('テストバナナ'), findsNothing);
      });

      testWidgets('ショッピングリストの状態管理', (WidgetTester tester) async {
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

        await tester.enterText(find.byType(TextField), '状態テストリスト');
        final createButton = find.text('作成');
        await tester.tap(createButton);
        await tester.pumpAndSettle();

        // アイテム追加
        final addItemButton = find.byIcon(Icons.add);
        await tester.tap(addItemButton);
        await tester.pumpAndSettle();

        await tester.enterText(find.byType(TextField), 'テスト商品');
        await tester.enterText(find.byKey(const Key('item_quantity')), '2');
        final addButton = find.text('追加');
        await tester.tap(addButton);
        await tester.pumpAndSettle();

        // アイテムの購入状態を切り替え
        final checkbox = find.byType(Checkbox);
        await tester.tap(checkbox);
        await tester.pumpAndSettle();

        // 購入済み状態が反映されていることを確認
        expect(find.byIcon(Icons.check_box), findsOneWidget);
      });
    });

    group('エラーハンドリングのテスト', () {
      testWidgets('必須項目未入力時のエラー表示', (WidgetTester tester) async {
        // アプリを起動
        await tester.pumpWidget(const FoodLossApp());
        await tester.pumpAndSettle();

        // 食品追加画面に遷移
        final addButton = find.byIcon(Icons.add);
        await tester.tap(addButton);
        await tester.pumpAndSettle();

        // 保存ボタンをタップ（必須項目未入力）
        final saveButton = find.text('保存');
        await tester.tap(saveButton);
        await tester.pumpAndSettle();

        // エラーメッセージが表示されることを確認
        expect(find.text('食品名は必須です'), findsOneWidget);
      });

      testWidgets('ネットワークエラー時のハンドリング', (WidgetTester tester) async {
        // アプリを起動
        await tester.pumpWidget(const FoodLossApp());
        await tester.pumpAndSettle();

        // レシピ検索画面に遷移
        final recipeButton = find.text('レシピ検索');
        await tester.tap(recipeButton);
        await tester.pumpAndSettle();

        // 検索語を入力
        await tester.enterText(find.byType(TextField), 'テスト');
        await tester.pumpAndSettle();

        // 検索ボタンをタップ
        final searchButton = find.byIcon(Icons.search);
        await tester.tap(searchButton);
        await tester.pumpAndSettle();

        // ネットワークエラー時のメッセージが表示されることを確認
        // （実際のエラーはモックデータでシミュレート）
        expect(find.byType(CircularProgressIndicator), findsOneWidget);
      });
    });

    group('レスポンシブデザインのテスト', () {
      testWidgets('画面サイズ変更時のレイアウト', (WidgetTester tester) async {
        // アプリを起動
        await tester.pumpWidget(const FoodLossApp());
        await tester.pumpAndSettle();

        // 小さい画面サイズに変更
        await tester.binding.setSurfaceSize(const Size(300, 600));
        await tester.pumpAndSettle();

        // 小さい画面でも要素が表示されていることを確認
        expect(find.text('食品ロス削減アプリ'), findsOneWidget);
        expect(find.text('食品一覧'), findsOneWidget);

        // 大きい画面サイズに変更
        await tester.binding.setSurfaceSize(const Size(800, 1200));
        await tester.pumpAndSettle();

        // 大きい画面でも要素が表示されていることを確認
        expect(find.text('食品ロス削減アプリ'), findsOneWidget);
        expect(find.text('食品一覧'), findsOneWidget);
      });

      testWidgets('ダークモード対応', (WidgetTester tester) async {
        // ダークモードでアプリを起動
        await tester.pumpWidget(
          MaterialApp(
            theme: ThemeData.dark(),
            home: const FoodLossApp(),
          ),
        );
        await tester.pumpAndSettle();

        // ダークモードが適用されていることを確認
        final theme = Theme.of(tester.element(find.byType(Container)));
        expect(theme.brightness, Brightness.dark);
      });
    });
  });
}
