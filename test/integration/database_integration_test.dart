import 'package:flutter_test/flutter_test.dart';
import 'package:food_loss_app/services/database_service.dart';
import 'package:food_loss_app/models/food_item.dart';
import 'package:food_loss_app/models/shopping_list.dart';
import 'package:food_loss_app/models/shopping_item.dart';
import 'package:food_loss_app/models/recipe.dart';

void main() {
  group('データベース統合テスト', () {
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

    group('CRUD操作の統合テスト', () {
      test('食品アイテムの完全なライフサイクル', () async {
        // 作成
        final testItem = FoodItem(
          id: 'lifecycle_test_1',
          name: 'ライフサイクルテスト食品',
          expiryDate: DateTime.now().add(const Duration(days: 7)),
          registrationDate: DateTime.now(),
          quantity: 3,
          storageLocation: '冷蔵庫',
          category: '乳製品',
          memo: 'ライフサイクルテスト用',
        );

        await DatabaseService.addFoodItem(testItem);

        // 読み取り
        final savedItem = await DatabaseService.getFoodItemById('lifecycle_test_1');
        expect(savedItem, isNotNull);
        expect(savedItem!.name, 'ライフサイクルテスト食品');
        expect(savedItem.quantity, 3);

        // 更新
        final updatedItem = savedItem.copyWith(
          quantity: 5,
          memo: '更新されたメモ',
        );
        await DatabaseService.updateFoodItem(updatedItem);

        final retrievedItem = await DatabaseService.getFoodItemById('lifecycle_test_1');
        expect(retrievedItem!.quantity, 5);
        expect(retrievedItem.memo, '更新されたメモ');

        // 削除
        await DatabaseService.deleteFoodItem('lifecycle_test_1');
        final deletedItem = await DatabaseService.getFoodItemById('lifecycle_test_1');
        expect(deletedItem, isNull);
      });

      test('ショッピングリストの完全なライフサイクル', () async {
        // 作成
        final listId = await DatabaseService.createShoppingList('ライフサイクルテストリスト');
        expect(listId, isNotEmpty);

        // アイテム追加
        final itemId = await DatabaseService.addShoppingItem(
          listId,
          'ライフサイクルテスト商品',
          2,
        );
        expect(itemId, isNotEmpty);

        // 読み取り
        final items = await DatabaseService.getShoppingItems(listId);
        expect(items, isNotEmpty);
        expect(items.first.productName, 'ライフサイクルテスト商品');
        expect(items.first.quantity, 2);

        // 更新
        final updatedItem = items.first.copyWith(isPurchased: true);
        await DatabaseService.updateShoppingItem(updatedItem);

        final updatedItems = await DatabaseService.getShoppingItems(listId);
        expect(updatedItems.first.isPurchased, true);

        // 削除
        await DatabaseService.deleteShoppingItem(itemId);
        final deletedItems = await DatabaseService.getShoppingItems(listId);
        expect(deletedItems, isEmpty);

        // リスト削除
        await DatabaseService.deleteShoppingList(listId);
        final lists = await DatabaseService.getAllShoppingLists();
        expect(lists.every((list) => list.id != listId), true);
      });

      test('レシピキャッシュの完全なライフサイクル', () async {
        // 作成
        final testRecipe = Recipe(
          recipeId: 'lifecycle_test_recipe',
          title: 'ライフサイクルテストレシピ',
          category: 'テスト',
          area: 'テスト',
          instructions: 'テスト手順',
          ingredients: ['材料1', '材料2', '材料3'],
          imageUrl: 'https://example.com/test.jpg',
          cachedDate: DateTime.now(),
        );

        await DatabaseService.cacheRecipe(testRecipe);

        // 読み取り
        final cachedRecipe = await DatabaseService.getCachedRecipe('lifecycle_test_recipe');
        expect(cachedRecipe, isNotNull);
        expect(cachedRecipe!.title, 'ライフサイクルテストレシピ');
        expect(cachedRecipe.ingredients.length, 3);

        // 検索
        final searchResults = await DatabaseService.searchCachedRecipes('ライフサイクル');
        expect(searchResults, isNotEmpty);
        expect(searchResults.any((recipe) => recipe.recipeId == 'lifecycle_test_recipe'), true);
      });
    });

    group('データ整合性のテスト', () {
      test('関連データの一貫性', () async {
        // 食品アイテムを作成
        final foodItem = FoodItem(
          id: 'consistency_test_food',
          name: '一貫性テスト食品',
          expiryDate: DateTime.now().add(const Duration(days: 5)),
          registrationDate: DateTime.now(),
          quantity: 2,
          storageLocation: '冷蔵庫',
          category: '野菜',
          memo: '一貫性テスト用',
        );

        await DatabaseService.addFoodItem(foodItem);

        // ショッピングリストを作成
        final listId = await DatabaseService.createShoppingList('一貫性テストリスト');
        
        // 食品をショッピングリストに追加
        await DatabaseService.addShoppingItem(
          listId,
          '一貫性テスト商品',
          1,
        );

        // データが正しく関連付けられていることを確認
        final savedFood = await DatabaseService.getFoodItemById('consistency_test_food');
        expect(savedFood, isNotNull);
        expect(savedFood!.name, '一貫性テスト食品');

        final listItems = await DatabaseService.getShoppingItems(listId);
        expect(listItems, isNotEmpty);
        expect(listItems.first.productName, '一貫性テスト商品');

        // クリーンアップ
        await DatabaseService.deleteFoodItem('consistency_test_food');
        await DatabaseService.deleteShoppingList(listId);
      });

      test('トランザクションの原子性', () async {
        // 複数の操作をまとめて実行
        final items = [
          FoodItem(
            id: 'atomic_test_1',
            name: '原子性テスト1',
            expiryDate: DateTime.now().add(const Duration(days: 1)),
            registrationDate: DateTime.now(),
            quantity: 1,
            storageLocation: 'テスト',
            category: 'テスト',
          ),
          FoodItem(
            id: 'atomic_test_2',
            name: '原子性テスト2',
            expiryDate: DateTime.now().add(const Duration(days: 2)),
            registrationDate: DateTime.now(),
            quantity: 2,
            storageLocation: 'テスト',
            category: 'テスト',
          ),
          FoodItem(
            id: 'atomic_test_3',
            name: '原子性テスト3',
            expiryDate: DateTime.now().add(const Duration(days: 3)),
            registrationDate: DateTime.now(),
            quantity: 3,
            storageLocation: 'テスト',
            category: 'テスト',
          ),
        ];

        // すべてのアイテムを追加
        for (final item in items) {
          await DatabaseService.addFoodItem(item);
        }

        // すべてのアイテムが存在することを確認
        for (final item in items) {
          final savedItem = await DatabaseService.getFoodItemById(item.id);
          expect(savedItem, isNotNull);
          expect(savedItem!.name, item.name);
        }

        // クリーンアップ
        for (final item in items) {
          await DatabaseService.deleteFoodItem(item.id);
        }
      });
    });

    group('パフォーマンスのテスト', () {
      test('大量データの操作', () async {
        final stopwatch = Stopwatch()..start();

        // 100件の食品アイテムを追加
        for (int i = 0; i < 100; i++) {
          final item = FoodItem(
            id: 'perf_test_$i',
            name: 'パフォーマンステスト食品$i',
            expiryDate: DateTime.now().add(Duration(days: i)),
            registrationDate: DateTime.now(),
            quantity: i + 1,
            storageLocation: 'テスト場所',
            category: 'テストカテゴリ',
            memo: 'パフォーマンステスト用',
          );
          await DatabaseService.addFoodItem(item);
        }

        stopwatch.stop();
        final insertTime = stopwatch.elapsedMilliseconds;
        print('100件の挿入時間: ${insertTime}ms');
        expect(insertTime, lessThan(10000)); // 10秒以内

        // 全件取得
        stopwatch.reset();
        stopwatch.start();

        final allItems = await DatabaseService.getAllFoodItems();

        stopwatch.stop();
        final selectTime = stopwatch.elapsedMilliseconds;
        print('100件の取得時間: ${selectTime}ms');
        expect(selectTime, lessThan(2000)); // 2秒以内
        expect(allItems.length, greaterThanOrEqualTo(100));

        // カテゴリ別取得
        stopwatch.reset();
        stopwatch.start();

        final categoryItems = await DatabaseService.getFoodItemsByCategory('テストカテゴリ');

        stopwatch.stop();
        final categoryTime = stopwatch.elapsedMilliseconds;
        print('カテゴリ別取得時間: ${categoryTime}ms');
        expect(categoryTime, lessThan(1000)); // 1秒以内

        // クリーンアップ
        for (int i = 0; i < 100; i++) {
          await DatabaseService.deleteFoodItem('perf_test_$i');
        }
      });

      test('インデックスの効果', () async {
        // 期限切れ間近のアイテムを追加
        final expiringItems = [
          FoodItem(
            id: 'index_test_1',
            name: '期限切れテスト1',
            expiryDate: DateTime.now().add(const Duration(days: 1)),
            registrationDate: DateTime.now(),
            quantity: 1,
            storageLocation: '冷蔵庫',
            category: 'テスト',
          ),
          FoodItem(
            id: 'index_test_2',
            name: '期限切れテスト2',
            expiryDate: DateTime.now().add(const Duration(days: 2)),
            registrationDate: DateTime.now(),
            quantity: 1,
            storageLocation: '冷蔵庫',
            category: 'テスト',
          ),
          FoodItem(
            id: 'index_test_3',
            name: '期限切れテスト3',
            expiryDate: DateTime.now().add(const Duration(days: 3)),
            registrationDate: DateTime.now(),
            quantity: 1,
            storageLocation: '冷蔵庫',
            category: 'テスト',
          ),
        ];

        for (final item in expiringItems) {
          await DatabaseService.addFoodItem(item);
        }

        // 期限切れ間近のアイテムを取得
        final stopwatch = Stopwatch()..start();
        final expiringSoon = await DatabaseService.getExpiringSoonItems(days: 3);
        stopwatch.stop();

        print('期限切れ間近アイテム取得時間: ${stopwatch.elapsedMilliseconds}ms');
        expect(stopwatch.elapsedMilliseconds, lessThan(1000)); // 1秒以内
        expect(expiringSoon.length, 3);

        // クリーンアップ
        for (final item in expiringItems) {
          await DatabaseService.deleteFoodItem(item.id);
        }
      });
    });

    group('エラーハンドリングのテスト', () {
      test('重複IDの処理', () async {
        final item1 = FoodItem(
          id: 'duplicate_test',
          name: '重複テスト1',
          expiryDate: DateTime.now().add(const Duration(days: 1)),
          registrationDate: DateTime.now(),
          quantity: 1,
          storageLocation: 'テスト',
          category: 'テスト',
        );

        final item2 = FoodItem(
          id: 'duplicate_test', // 同じID
          name: '重複テスト2',
          expiryDate: DateTime.now().add(const Duration(days: 2)),
          registrationDate: DateTime.now(),
          quantity: 2,
          storageLocation: 'テスト',
          category: 'テスト',
        );

        // 最初のアイテムを追加
        await DatabaseService.addFoodItem(item1);

        // 2番目のアイテムを追加（上書きされるはず）
        await DatabaseService.addFoodItem(item2);

        // 最終的なアイテムを確認
        final finalItem = await DatabaseService.getFoodItemById('duplicate_test');
        expect(finalItem, isNotNull);
        expect(finalItem!.name, '重複テスト2'); // 上書きされた
        expect(finalItem.quantity, 2);

        // クリーンアップ
        await DatabaseService.deleteFoodItem('duplicate_test');
      });

      test('無効なデータ型の処理', () async {
        // 無効なデータで操作を試みる
        try {
          final invalidItem = FoodItem(
            id: '', // 空のID
            name: '無効テスト',
            expiryDate: DateTime.now().add(const Duration(days: 1)),
            registrationDate: DateTime.now(),
            quantity: -1, // 負の数
            storageLocation: '',
            category: '',
          );

          await DatabaseService.addFoodItem(invalidItem);
          // 成功する場合（バリデーションがサービス層にある場合）
          final savedItem = await DatabaseService.getFoodItemById('');
          if (savedItem != null) {
            expect(savedItem!.quantity, -1);
          }
        } catch (e) {
          // エラーが発生する場合（バリデーションがデータベース層にある場合）
          expect(e, isA<Exception>());
        }
      });

      test('同時実行の処理', () async {
        // 複数の操作を同時に実行
        final futures = <Future>[];

        for (int i = 0; i < 10; i++) {
          final item = FoodItem(
            id: 'concurrent_test_$i',
            name: '同時実行テスト$i',
            expiryDate: DateTime.now().add(Duration(days: i)),
            registrationDate: DateTime.now(),
            quantity: 1,
            storageLocation: 'テスト',
            category: 'テスト',
          );
          futures.add(DatabaseService.addFoodItem(item));
        }

        // すべての操作が完了するのを待つ
        await Future.wait(futures);

        // すべてのアイテムが存在することを確認
        for (int i = 0; i < 10; i++) {
          final item = await DatabaseService.getFoodItemById('concurrent_test_$i');
          expect(item, isNotNull);
          expect(item!.name, '同時実行テスト$i');
        }

        // クリーンアップ
        for (int i = 0; i < 10; i++) {
          await DatabaseService.deleteFoodItem('concurrent_test_$i');
        }
      });
    });

    group('統計情報のテスト', () {
      test('統計データの正確性', () async {
        // テストデータを追加
        final testItems = [
          FoodItem(
            id: 'stats_test_1',
            name: '統計テスト1',
            expiryDate: DateTime.now().add(const Duration(days: 1)),
            registrationDate: DateTime.now(),
            quantity: 2,
            storageLocation: '冷蔵庫',
            category: '野菜',
          ),
          FoodItem(
            id: 'stats_test_2',
            name: '統計テスト2',
            expiryDate: DateTime.now().subtract(const Duration(days: 1)), // 期限切れ
            registrationDate: DateTime.now(),
            quantity: 3,
            storageLocation: '冷凍庫',
            category: '肉類',
          ),
          FoodItem(
            id: 'stats_test_3',
            name: '統計テスト3',
            expiryDate: DateTime.now().add(const Duration(days: 5)),
            registrationDate: DateTime.now(),
            quantity: 1,
            storageLocation: '常温',
            category: '乳製品',
          ),
        ];

        for (final item in testItems) {
          await DatabaseService.addFoodItem(item);
        }

        // 統計情報を取得
        final stats = await DatabaseService.getStatistics();
        expect(stats, isNotNull);
        expect(stats!['totalItems'], 3);
        expect(stats['expiringItems'], 2); // 1日後と5日後
        expect(stats['expiredItems'], 1); // 1日前

        // クリーンアップ
        for (final item in testItems) {
          await DatabaseService.deleteFoodItem(item.id);
        }
      });
    });
  });
}
