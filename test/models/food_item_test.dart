import 'package:flutter_test/flutter_test.dart';
import 'package:food_loss_app/models/food_item.dart';

void main() {
  group('FoodItem Tests', () {
    test('FoodItemが正常に作成できること', () {
      final foodItem = FoodItem(
        id: 'test-id',
        name: 'テスト食材',
        expiryDate: DateTime.now().add(const Duration(days: 3)),
        registrationDate: DateTime.now(),
        quantity: 2,
        storageLocation: '冷蔵庫',
        category: '野菜',
      );

      expect(foodItem.id, 'test-id');
      expect(foodItem.name, 'テスト食材');
      expect(foodItem.quantity, 2);
      expect(foodItem.storageLocation, '冷蔵庫');
      expect(foodItem.category, '野菜');
    });

    test('賞味期限の状態が正しく判定されること', () {
      final now = DateTime.now();
      
      // 期限切れ
      final expiredItem = FoodItem(
        id: 'expired',
        name: '期限切れ食材',
        expiryDate: now.subtract(const Duration(days: 1)),
        registrationDate: now,
        quantity: 1,
        storageLocation: '冷蔵庫',
        category: '野菜',
      );
      expect(expiredItem.expiryStatus, ExpiryStatus.expired);
      expect(expiredItem.daysUntilExpiry, -1);

      // 期限当日
      final todayItem = FoodItem(
        id: 'today',
        name: '今日期限',
        expiryDate: now,
        registrationDate: now,
        quantity: 1,
        storageLocation: '冷蔵庫',
        category: '野菜',
      );
      expect(todayItem.expiryStatus, ExpiryStatus.urgent);
      expect(todayItem.daysUntilExpiry, 0);

      // 期限が近い（3日以内）
      final nearItem = FoodItem(
        id: 'near',
        name: '期限近い',
        expiryDate: now.add(const Duration(days: 2, hours: 23)),
        registrationDate: now,
        quantity: 1,
        storageLocation: '冷蔵庫',
        category: '野菜',
      );
      expect(nearItem.expiryStatus, ExpiryStatus.soon);
      expect(nearItem.daysUntilExpiry, 2);

      // 期限がまだ遠い
      final freshItem = FoodItem(
        id: 'fresh',
        name: '新鮮',
        expiryDate: now.add(const Duration(days: 10, hours: 1)),
        registrationDate: now,
        quantity: 1,
        storageLocation: '冷蔵庫',
        category: '野菜',
      );
      expect(freshItem.expiryStatus, ExpiryStatus.fresh);
      expect(freshItem.daysUntilExpiry, 10);
    });

    test('JSONへの変換と復元が正しく動作すること', () {
      final originalItem = FoodItem(
        id: 'test-id',
        name: 'テスト食材',
        expiryDate: DateTime(2024, 12, 31),
        registrationDate: DateTime(2024, 12, 25),
        quantity: 3,
        storageLocation: '冷蔵庫',
        category: '野菜',
        memo: 'テストメモ',
        price: 500,
        purchaseStore: 'テスト店',
        imagePath: 'https://example.com/image.jpg',
      );

      // JSONに変換
      final json = originalItem.toJson();
      
      expect(json['id'], 'test-id');
      expect(json['name'], 'テスト食材');
      expect(json['expiryDate'], '2024-12-31T00:00:00.000');
      expect(json['quantity'], 3);
      expect(json['storageLocation'], '冷蔵庫');
      expect(json['category'], '野菜');
      expect(json['memo'], 'テストメモ');
      expect(json['price'], 500);
      expect(json['purchaseStore'], 'テスト店');
      expect(json['imagePath'], 'https://example.com/image.jpg');

      // JSONから復元
      final restoredItem = FoodItem.fromJson(json);
      
      expect(restoredItem.id, originalItem.id);
      expect(restoredItem.name, originalItem.name);
      expect(restoredItem.expiryDate, originalItem.expiryDate);
      expect(restoredItem.quantity, originalItem.quantity);
      expect(restoredItem.storageLocation, originalItem.storageLocation);
      expect(restoredItem.category, originalItem.category);
      expect(restoredItem.memo, originalItem.memo);
      expect(restoredItem.price, originalItem.price);
      expect(restoredItem.purchaseStore, originalItem.purchaseStore);
      expect(restoredItem.imagePath, originalItem.imagePath);
    });

    test('コピーが正しく作成できること', () {
      final originalItem = FoodItem(
        id: 'test-id',
        name: 'テスト食材',
        expiryDate: DateTime.now(),
        registrationDate: DateTime.now(),
        quantity: 2,
        storageLocation: '冷蔵庫',
        category: '野菜',
      );

      final copiedItem = originalItem.copyWith(
        quantity: 5,
        memo: '変更されたメモ',
      );

      // 元の項目は変更されていないこと
      expect(originalItem.quantity, 2);
      expect(originalItem.memo, null);

      // コピーされた項目は変更されていること
      expect(copiedItem.id, originalItem.id);
      expect(copiedItem.name, originalItem.name);
      expect(copiedItem.quantity, 5);
      expect(copiedItem.memo, '変更されたメモ');
      expect(copiedItem.expiryDate, originalItem.expiryDate);
    });

    test('toStringが正しく動作すること', () {
      final foodItem = FoodItem(
        id: 'test-id',
        name: 'テスト食材',
        expiryDate: DateTime(2024, 12, 31),
        registrationDate: DateTime(2024, 12, 25),
        quantity: 2,
        storageLocation: '冷蔵庫',
        category: '野菜',
      );

      final stringRepresentation = foodItem.toString();
      
      // toStringが文字列を返すことを確認
      expect(stringRepresentation, isA<String>());
    });
  });
}
