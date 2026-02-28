import 'package:flutter_test/flutter_test.dart';
import 'package:food_loss_app/models/food_item.dart';

void main() {
  group('FoodItem 単体テスト', () {
    late FoodItem testFoodItem;

    setUp(() {
      testFoodItem = FoodItem(
        id: 'test_food_1',
        name: 'テストトマト',
        expiryDate: DateTime.now().add(const Duration(days: 4)), // 4日後に変更
        quantity: 2,
        storageLocation: '冷蔵庫',
        category: '野菜',
        memo: 'テスト用トマト',
        price: 150.0,
        purchaseStore: 'テストスーパー',
        registrationDate: DateTime.now().subtract(const Duration(days: 2)),
        isConsumed: false,
      );
    });

    test('FoodItemの基本プロパティが正しく設定される', () {
      expect(testFoodItem.id, 'test_food_1');
      expect(testFoodItem.name, 'テストトマト');
      expect(testFoodItem.quantity, 2);
      expect(testFoodItem.storageLocation, '冷蔵庫');
      expect(testFoodItem.category, '野菜');
      expect(testFoodItem.isConsumed, false);
    });

    test('期限切れチェックが正しく機能する', () {
      // 期限切れの食材
      final expiredFood = FoodItem(
        id: 'expired_food',
        name: '期限切れ食材',
        expiryDate: DateTime.now().subtract(const Duration(days: 1)),
        quantity: 1,
        storageLocation: '冷蔵庫',
        category: '野菜',
        registrationDate: DateTime.now(),
        isConsumed: false,
      );

      // 期限切れチェック
      expect(expiredFood.isExpired(), true);
      expect(testFoodItem.isExpired(), false);
    });

    test('copyWithメソッドが正しく機能する', () {
      final copiedItem = testFoodItem.copyWith(
        quantity: 5,
        memo: '更新されたメモ',
      );

      expect(copiedItem.id, testFoodItem.id);
      expect(copiedItem.name, testFoodItem.name);
      expect(copiedItem.quantity, 5);
      expect(copiedItem.memo, '更新されたメモ');
    });

    test('toJsonメソッドが正しく機能する', () {
      final json = testFoodItem.toJson();
      
      expect(json['id'], 'test_food_1');
      expect(json['name'], 'テストトマト');
      expect(json['quantity'], 2);
      expect(json['storageLocation'], '冷蔵庫');
      expect(json['category'], '野菜');
      expect(json['isConsumed'], 0);
    });

    test('fromJsonメソッドが正しく機能する', () {
      final json = {
        'id': 'json_test_food',
        'name': 'JSONテスト食材',
        'expiryDate': DateTime.now().add(const Duration(days: 3)).toIso8601String(),
        'registrationDate': DateTime.now().toIso8601String(),
        'quantity': 3,
        'storageLocation': '常温',
        'category': '果物',
        'memo': 'JSONテストメモ',
        'price': 250.0,
        'purchaseStore': 'JSONテストストア',
        'consumptionDate': DateTime.now().toIso8601String(),
        'isConsumed': 1,
      };

      final foodItem = FoodItem.fromJson(json);
      
      expect(foodItem.id, 'json_test_food');
      expect(foodItem.name, 'JSONテスト食材');
      expect(foodItem.quantity, 3);
      expect(foodItem.storageLocation, '常温');
      expect(foodItem.category, '果物');
      expect(foodItem.isConsumed, true);
    });

    test('残り日数計算が正しく機能する', () {
      final futureFood = FoodItem(
        id: 'future_food',
        name: '未来の食材',
        expiryDate: DateTime.now().add(const Duration(days: 7)),
        quantity: 1,
        storageLocation: '冷蔵庫',
        category: '野菜',
        registrationDate: DateTime.now(),
        isConsumed: false,
      );

      expect(futureFood.daysUntilExpiry, greaterThan(6)); // 6日より大きい値
    });

    test('価格が正しく設定される', () {
      expect(testFoodItem.price, 150.0);
      expect(testFoodItem.price, isA<double>());
    });

    test('購入店が正しく設定される', () {
      expect(testFoodItem.purchaseStore, 'テストスーパー');
      expect(testFoodItem.purchaseStore, isA<String>());
    });

    test('日付関連のプロパティが正しく設定される', () {
      expect(testFoodItem.expiryDate, isA<DateTime>());
      expect(testFoodItem.registrationDate, isA<DateTime>());
      expect(testFoodItem.consumptionDate, isNull); // 未消費なのでnull
    });

    test('toStringメソッドが正しく機能する', () {
      final result = testFoodItem.toString();
      expect(result, contains('テストトマト'));
      expect(result, contains('test_food_1'));
      expect(result, contains('2'));
    });

    test('等価性比較が正しく機能する', () {
      final sameItem = FoodItem(
        id: testFoodItem.id,
        name: testFoodItem.name,
        expiryDate: testFoodItem.expiryDate,
        quantity: testFoodItem.quantity,
        storageLocation: testFoodItem.storageLocation,
        category: testFoodItem.category,
        registrationDate: testFoodItem.registrationDate,
        isConsumed: testFoodItem.isConsumed,
      );

      expect(testFoodItem == sameItem, true);
      
      final differentItem = testFoodItem.copyWith(quantity: 10);
      expect(testFoodItem == differentItem, false);
    });

    test('hashCodeが正しく機能する', () {
      final sameItem = FoodItem(
        id: testFoodItem.id,
        name: testFoodItem.name,
        expiryDate: testFoodItem.expiryDate,
        quantity: testFoodItem.quantity,
        storageLocation: testFoodItem.storageLocation,
        category: testFoodItem.category,
        registrationDate: testFoodItem.registrationDate,
        isConsumed: testFoodItem.isConsumed,
      );

      expect(testFoodItem.hashCode, sameItem.hashCode);
    });
  });

  group('FoodItem 境界値テスト', () {
    test('空の名前でFoodItemを作成できる', () {
      final foodItem = FoodItem(
        id: 'test_empty_name',
        name: '',
        expiryDate: DateTime.now().add(const Duration(days: 1)),
        quantity: 1,
        storageLocation: '冷蔵庫',
        category: 'その他',
        registrationDate: DateTime.now(),
        isConsumed: false,
      );

      expect(foodItem.name, '');
    });

    test('数量が0のFoodItemを作成できる', () {
      final foodItem = FoodItem(
        id: 'test_zero_quantity',
        name: '数量ゼロ食材',
        expiryDate: DateTime.now().add(const Duration(days: 1)),
        quantity: 0,
        storageLocation: '冷蔵庫',
        category: 'その他',
        registrationDate: DateTime.now(),
        isConsumed: false,
      );

      expect(foodItem.quantity, 0);
    });

    test('nullのメモでFoodItemを作成できる', () {
      final foodItem = FoodItem(
        id: 'test_null_memo',
        name: 'nullメモ食材',
        expiryDate: DateTime.now().add(const Duration(days: 1)),
        quantity: 1,
        storageLocation: '冷蔵庫',
        category: 'その他',
        registrationDate: DateTime.now(),
        isConsumed: false,
      );

      expect(foodItem.memo, isNull);
    });

    test('nullの価格でFoodItemを作成できる', () {
      final foodItem = FoodItem(
        id: 'test_null_price',
        name: 'null価格食材',
        expiryDate: DateTime.now().add(const Duration(days: 1)),
        quantity: 1,
        storageLocation: '冷蔵庫',
        category: 'その他',
        registrationDate: DateTime.now(),
        isConsumed: false,
      );

      expect(foodItem.price, isNull);
    });
  });
}
