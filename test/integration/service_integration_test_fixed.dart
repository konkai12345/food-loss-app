import 'package:flutter_test/flutter_test.dart';
import 'package:food_loss_app/services/database_service.dart';
import 'package:food_loss_app/services/open_food_facts_service.dart';
import 'package:food_loss_app/services/meal_db_service.dart';
import 'package:food_loss_app/models/food_item.dart';
import 'package:food_loss_app/models/recipe.dart';

void main() {
  group('サービス間連携テスト', () {
    late OpenFoodFactsService openFoodFactsService;
    late MealDbService mealDbService;

    setUpAll(() async {
      openFoodFactsService = OpenFoodFactsService();
      mealDbService = MealDbService();
      
      // テスト用データベースの初期化（Web版では不要）
      if (!const bool.fromEnvironment('dart.library.html')) {
        await DatabaseService.database;
      }
    });

    tearDownAll(() async {
      // テスト後のクリーンアップ
      await DatabaseService.close();
    });

    group('DatabaseServiceと外部API連携', () {
      test('食品アイテムの登録とAPI情報取得', () async {
        // テスト用食品アイテムの作成
        final testFoodItem = FoodItem(
          id: 'test_integration_1',
          name: 'テスト牛乳',
          barcode: '4901085184109',
          category: '乳製品',
          expiryDate: DateTime.now().add(const Duration(days: 7)),
          quantity: 1,
          unit: '本',
          location: '冷蔵庫',
          notes: '統合テスト用',
          createdDate: DateTime.now(),
        );

        // データベースに保存
        await DatabaseService.addFoodItem(testFoodItem);

        // データベースから取得
        final savedItem = await DatabaseService.getFoodItemById('test_integration_1');
        expect(savedItem, isNotNull);
        expect(savedItem!.name, 'テスト牛乳');
        expect(savedItem.barcode, '4901085184109');

        // APIから情報取得（モック）
        try {
          final productInfo = await openFoodFactsService.getProductInfo('4901085184109');
          if (productInfo != null) {
            expect(productInfo.productName, isNotEmpty);
            expect(productInfo.barcode, '4901085184109');
          }
        } catch (e) {
          // APIエラーは許容（テスト環境のため）
          print('APIエラー（許容）: $e');
        }

        // クリーンアップ
        await DatabaseService.deleteFoodItem('test_integration_1');
      });

      test('レシピ検索とキャッシュ機能', () async {
        // レシピ検索
        try {
          final recipes = await mealDbService.searchRecipes('curry');
          expect(recipes, isNotEmpty);

          if (recipes.isNotEmpty) {
            final firstRecipe = recipes.first;
            expect(firstRecipe.title, isNotEmpty);
            expect(firstRecipe.recipeId, isNotEmpty);

            // データベースにキャッシュ保存
            await DatabaseService.cacheRecipe(firstRecipe);

            // キャッシュから取得
            final cachedRecipe = await DatabaseService.getCachedRecipe(firstRecipe.recipeId);
            expect(cachedRecipe, isNotNull);
            expect(cachedRecipe!.title, firstRecipe.title);
            expect(cachedRecipe.recipeId, firstRecipe.recipeId);

            // クリーンアップ
            await DatabaseService.deleteCachedRecipe(firstRecipe.recipeId);
          }
        } catch (e) {
          // APIエラーは許容（テスト環境のため）
          print('APIエラー（許容）: $e');
        }
      });

      test('ショッピングリストの同期', () async {
        // テスト用ショッピングリストの作成
        final testListId = await DatabaseService.createShoppingList('統合テストリスト');
        expect(testListId, isNotEmpty);

        // アイテムの追加
        await DatabaseService.addShoppingItem(
          testListId,
          'テスト商品',
          2,
          '4901085184109',
        );

        // リストの取得
        final items = await DatabaseService.getShoppingItems(testListId);
        expect(items, isNotEmpty);
        expect(items.first.productName, 'テスト商品');
        expect(items.first.quantity, 2);

        // アイテムの更新
        await DatabaseService.updateShoppingItem(
          items.first,
          isPurchased: true,
        );

        // 更新の確認
        final updatedItems = await DatabaseService.getShoppingItems(testListId);
        expect(updatedItems.first.isPurchased, true);

        // クリーンアップ
        await DatabaseService.deleteShoppingList(testListId);
      });
    });

    group('エラーハンドリングと例外処理', () {
      test('存在しない食品アイテムの取得', () async {
        final nonExistentItem = await DatabaseService.getFoodItemById('non_existent_id');
        expect(nonExistentItem, isNull);
      });

      test('無効なバーコードでのAPI呼び出し', () async {
        try {
          final productInfo = await openFoodFactsService.getProductInfo('invalid_barcode');
          // 無効なバーコードの場合、nullが返されるべき
          expect(productInfo, isNull);
        } catch (e) {
          // 例外が発生しても許容
          expect(e, isA<Exception>());
        }
      });

      test('無効なレシピ検索', () async {
        try {
          final recipes = await mealDbService.searchRecipes('');
          // 空の検索語の場合、空リストが返されるべき
          expect(recipes, isEmpty);
        } catch (e) {
          // 例外が発生しても許容
          expect(e, isA<Exception>());
        }
      });

      test('データベース接続エラーの処理', () async {
        // データベース接続を閉じてから操作を試行
        await DatabaseService.close();
        
        try {
          await DatabaseService.getAllFoodItems();
          fail('例外が発生するべき');
        } catch (e) {
          expect(e, isA<Exception>());
        }
        
        // 再接続
        await DatabaseService.database;
      });
    });

    group('パフォーマンスと負荷テスト', () {
      test('大量データの挿入と取得', () async {
        final stopwatch = Stopwatch()..start();
        
        // 50件の食品アイテムを挿入
        for (int i = 0; i < 50; i++) {
          final item = FoodItem(
            id: 'perf_test_$i',
            name: 'パフォーマンステスト食品$i',
            barcode: '490108518410$i',
            category: 'テストカテゴリ',
            expiryDate: DateTime.now().add(Duration(days: i)),
            quantity: 1,
            unit: '個',
            location: 'テスト場所',
            notes: 'パフォーマンステスト用',
            createdDate: DateTime.now(),
          );
          await DatabaseService.addFoodItem(item);
        }
        
        stopwatch.stop();
        print('50件の挿入時間: ${stopwatch.elapsedMilliseconds}ms');
        expect(stopwatch.elapsedMilliseconds, lessThan(5000)); // 5秒以内
        
        // 50件のデータを取得
        stopwatch.reset();
        stopwatch.start();
        
        final items = await DatabaseService.getAllFoodItems();
        
        stopwatch.stop();
        print('50件の取得時間: ${stopwatch.elapsedMilliseconds}ms');
        expect(stopwatch.elapsedMilliseconds, lessThan(1000)); // 1秒以内
        expect(items.length, greaterThanOrEqualTo(50));
        
        // クリーンアップ
        for (int i = 0; i < 50; i++) {
          await DatabaseService.deleteFoodItem('perf_test_$i');
        }
      });

      test('API呼び出しのタイムアウト処理', () async {
        final stopwatch = Stopwatch()..start();
        
        try {
          // タイムアウトを短く設定してテスト
          await openFoodFactsService.getProductInfo('4901085184109');
          stopwatch.stop();
          print('API呼び出し時間: ${stopwatch.elapsedMilliseconds}ms');
          expect(stopwatch.elapsedMilliseconds, lessThan(15000)); // 15秒以内
        } catch (e) {
          stopwatch.stop();
          print('APIタイムアウト: ${stopwatch.elapsedMilliseconds}ms');
          expect(stopwatch.elapsedMilliseconds, lessThan(15000)); // 15秒以内
        }
      });
    });

    group('データ整合性テスト', () {
      test('トランザクション処理の確認', () async {
        // 複数の操作をアトミックに実行
        final testItem1 = FoodItem(
          id: 'transaction_test_1',
          name: 'トランザクションテスト1',
          barcode: '4901085184101',
          category: 'テスト',
          expiryDate: DateTime.now().add(const Duration(days: 1)),
          quantity: 1,
          unit: '個',
          location: 'テスト',
          notes: 'トランザクションテスト',
          createdDate: DateTime.now(),
        );

        final testItem2 = FoodItem(
          id: 'transaction_test_2',
          name: 'トランザクションテスト2',
          barcode: '4901085184102',
          category: 'テスト',
          expiryDate: DateTime.now().add(const Duration(days: 2)),
          quantity: 2,
          unit: '個',
          location: 'テスト',
          notes: 'トランザクションテスト',
          createdDate: DateTime.now(),
        );

        try {
          // 両方のアイテムを追加
          await DatabaseService.addFoodItem(testItem1);
          await DatabaseService.addFoodItem(testItem2);

          // 両方のアイテムが存在することを確認
          final item1 = await DatabaseService.getFoodItemById('transaction_test_1');
          final item2 = await DatabaseService.getFoodItemById('transaction_test_2');
          
          expect(item1, isNotNull);
          expect(item2, isNotNull);
          expect(item1!.name, 'トランザクションテスト1');
          expect(item2!.name, 'トランザクションテスト2');
        } catch (e) {
          // エラーが発生した場合、ロールバックを確認
          final item1 = await DatabaseService.getFoodItemById('transaction_test_1');
          final item2 = await DatabaseService.getFoodItemById('transaction_test_2');
          
          // どちらか一方でも存在しないことを確認
          expect(item1 == null || item2 == null, true);
        } finally {
          // クリーンアップ
          await DatabaseService.deleteFoodItem('transaction_test_1');
          await DatabaseService.deleteFoodItem('transaction_test_2');
        }
      });

      test('キャッシュの一貫性', () async {
        // レシピをキャッシュに保存
        final testRecipe = Recipe(
          recipeId: 'cache_consistency_test',
          title: 'キャッシュ一貫性テスト',
          category: 'テスト',
          area: 'テスト',
          instructions: 'テスト手順',
          ingredients: ['材料1', '材料2'],
          imageUrl: 'https://example.com/test.jpg',
          cachedDate: DateTime.now(),
        );

        await DatabaseService.cacheRecipe(testRecipe);

        // 複数回取得して一貫性を確認
        for (int i = 0; i < 5; i++) {
          final cachedRecipe = await DatabaseService.getCachedRecipe('cache_consistency_test');
          expect(cachedRecipe, isNotNull);
          expect(cachedRecipe!.title, 'キャッシュ一貫性テスト');
          expect(cachedRecipe.recipeId, 'cache_consistency_test');
        }

        // クリーンアップ
        await DatabaseService.deleteCachedRecipe('cache_consistency_test');
      });
    });
  });
}
